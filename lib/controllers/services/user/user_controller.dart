import 'package:efficacy_admin/models/user/user_model.dart';
import 'package:efficacy_admin/utils/database/constants.dart';
import 'package:efficacy_admin/utils/database/database.dart';
import 'package:efficacy_admin/utils/encrypter.dart';
import 'package:efficacy_admin/utils/local_database/constants.dart';
import 'package:efficacy_admin/utils/local_database/local_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UserController {
  static const String _collectionName = "users";
  static UserModel? currentUser;
  const UserController._();

  static Future<void> _save() async {
    if (currentUser == null) {
      LocalDatabase.delete(LocalCollections.user, LocalDocuments.currentUser);
    } else {
      await LocalDatabase.set(
        LocalCollections.user,
        LocalDocuments.currentUser,
        currentUser!.toJson(),
      );
    }
  }

  static UserModel _removePassword(UserModel user) {
    return user.copyWith(password: "");
  }

  /// Crates a user
  ///  * If user exists throws exception
  ///  * Hashes the password
  ///  * If user doesn't exist creates it
  ///
  /// Stores the value in local database
  /// Stores the value in currentUser field
  static Future<void> create(UserModel user) async {
    DbCollection collection = Database.instance.collection(_collectionName);

    if (await get(user.email) != null) {
      throw Exception("User exists with the provided email. Please Log in");
    } else {
      user = user.copyWith(
        password: Encryptor.encrypt(
          user.password,
          dotenv.env[EnvValues.ENCRYPTER_SALT.name]!,
        ),
      );
      Map<String, dynamic> res = await collection.insert(user.toJson());
      user = _removePassword(user);
      currentUser = user;
      await _save();
    }
  }

  /// Logs in the user
  ///  * If user exists throws exception
  ///  * If password doesn't match throws exception
  ///
  /// Stores the value in local database
  /// Stores the value in currentUser field
  static Future<void> login(String email, String password) async {
    UserModel? user = await get(email, keepPassword: true);
    if (user == null) {
      throw Exception("User exists with the provided email. Please Log in");
    } else {
      if (!Encryptor.isValid(user.password, password)) {
        throw Exception("Invalid password");
      }
      user = _removePassword(user);
      currentUser = user;
      await _save();
    }
  }

  /// Log in without internet i.e. from local database
  ///   * If returns null means the user data was not stored
  ///   * Returns the UserModel if exists
  ///   * Stores the user data in currentUser
  static Future<UserModel?> loginSilently() async {
    dynamic userData = await LocalDatabase.get(
        LocalCollections.user, LocalDocuments.currentUser);
    if (userData == null) {
      return null;
    }
    return currentUser = UserModel.fromJson(userData);
  }

  /// Fetches a  user from the provided email
  ///   * if keepPassword is true, the hashed password is kept (recommended not to keep)
  ///   * if keepPassword is false, the hashed password is replaced with ""
  static Future<UserModel?> get(String email,
      {bool keepPassword = false}) async {
    DbCollection collection = Database.instance.collection(_collectionName);
    SelectorBuilder selectorBuilder = SelectorBuilder();
    selectorBuilder.eq(UserFields.email.name, email);
    Map<String, dynamic>? res = await collection.findOne(selectorBuilder);

    if (res != null) {
      UserModel user = UserModel.fromJson(res);
      if (!keepPassword) {
        user = _removePassword(user);
      }
      return user;
    } else {
      return null;
    }
  }

  /// Updates the user data if exists in the database
  /// and stores it in the local database
  static Future<void> update(UserModel user) async {
    DbCollection collection = Database.instance.collection(_collectionName);

    if (await get(user.email) == null) {
      throw Exception("Couldn't find user");
    } else {
      SelectorBuilder selectorBuilder = SelectorBuilder();
      selectorBuilder.eq(UserFields.email.name, user.email);
      Map<String, dynamic> res = await collection.update(
        selectorBuilder,
        user.toJson(),
      );
      currentUser = user;
      await _save();
    }
  }

  /// Deletes the user if exists from both local database and server
  static Future<void> delete(String email) async {
    DbCollection collection = Database.instance.collection(_collectionName);

    if (await get(email) == null) {
      throw Exception("Couldn't find user");
    } else {
      SelectorBuilder selectorBuilder = SelectorBuilder();
      selectorBuilder.eq(UserFields.email.name, email);
      WriteResult res = await collection.deleteOne(selectorBuilder);

      currentUser = null;
      await _save();
    }
  }
}
