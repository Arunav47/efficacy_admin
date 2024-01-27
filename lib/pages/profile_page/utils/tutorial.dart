import 'package:efficacy_admin/widgets/coach_mark_desc/coach_mark_desc.dart';
import 'package:flutter/cupertino.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

void showProfilePageTutorial(
  BuildContext context,
  GlobalKey editProfileKey,
  GlobalKey delProfileKey,
  ScrollController scrollController,
) {
  List<TargetFocus> targets =
      getTargets(editProfileKey, delProfileKey, scrollController);
  TutorialCoachMark(
    hideSkip: true,
    useSafeArea: true,
    targets: targets, // List<TargetFocus>
  ).show(context: context);
}

List<TargetFocus> getTargets(
  GlobalKey editProfileKey,
  GlobalKey delProfileKey,
  ScrollController scrollController,
) {
  return [
    TargetFocus(
      identify: "Edit Profile",
      keyTarget: editProfileKey,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return CoachmarkDesc(
              heading: "Edit Profile",
              text: "Click here to edit your profile details.",
              onNext: () async {
                RenderBox renderBox = delProfileKey.currentContext!
                    .findRenderObject() as RenderBox;
                Offset position = renderBox.localToGlobal(Offset.zero);
                scrollController.animateTo(
                  position.dy,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutExpo,
                );
                controller.next();
              },
              onSkip: () {
                controller.skip();
              },
            );
          },
        )
      ],
    ),
    TargetFocus(
      identify: "Delete Profile",
      keyTarget: delProfileKey,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder: (context, controller) {
            return CoachmarkDesc(
              heading: "Delete Profile",
              text: "Click here to delete your profile.",
              onNext: () {
                controller.next();
              },
              onSkip: () {
                controller.skip();
              },
            );
          },
        )
      ],
    ),
  ];
}
