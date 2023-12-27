import 'package:efficacy_admin/config/config.dart';
import 'package:efficacy_admin/pages/club/club_page.dart';
import 'package:efficacy_admin/widgets/custom_app_bar/custom_app_bar.dart';
import 'package:efficacy_admin/widgets/custom_drawer/custom_drawer.dart';
import 'package:flutter/material.dart';

import 'widgets/clubs/clubs_stream.dart';
import 'widgets/invitations/invitations_stream.dart';

class OrganizationsPage extends StatefulWidget {
  const OrganizationsPage({super.key});
  static const String routeName = "/OrganizationsPage";

  @override
  State<OrganizationsPage> createState() => _OrganizationsPageState();
}

class _OrganizationsPageState extends State<OrganizationsPage> {
  ClubsStreamState clubsStreamState = ClubsStreamState();
  InvitationsStreamState invitationsStreamState = InvitationsStreamState();
  Future<void> _refresh() async{
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      clubsStreamState.refreshClubs();
      invitationsStreamState.refreshInvites();
    });
  }
  @override
  Widget build(BuildContext context) {
    //screen height and width
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    //size constants
    double pad = width * 0.05;
    double gap = height * 0.02;

    return Scaffold(
      appBar: const CustomAppBar(title: "Organizations"),
      endDrawer: const CustomDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ClubPage(
                createMode: true, // Example parameter value
                club: null,
              ),
            ),
          ).then((value) => setState(() {}));
        },
        heroTag: "Create club",
        tooltip: "Create a new club",
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Invitations",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: dark)),
                  const Divider(),
                  InvitationsStream(
                      maxHeight: height / 3,
                      onCompleteAction: () => setState(() {})),
                  const Divider(color: dark),
                  const Text(
                    "Clubs",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: dark),
                  ),
                  const Divider(),
                  const ClubsStream(),
                ].separate(gap),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
