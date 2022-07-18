import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:maths_club/screens/section.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../utils/components.dart';

/**
 * The following section includes functions for the home page.
 */

/// An enum for the horizontal carousel that returns padding based on position.
enum PositionPadding {
  start(EdgeInsets.fromLTRB(38.0, 8.0, 8.0, 8.0)),
  middle(EdgeInsets.all(8.0)),
  end(EdgeInsets.fromLTRB(8.00, 8.0, 38.0, 8.0));

  const PositionPadding(this.padding);
  final EdgeInsetsGeometry padding;
}

/// Creates cards within horizontal carousel that complete an action.
Widget actionCard(BuildContext context,
    {PositionPadding position = PositionPadding.middle,
    required IconData icon,
    required String text}) {
  return Padding(
    padding: position.padding,
    child: Card(
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        splashColor: Theme.of(context).colorScheme.primary.withAlpha(40),
        highlightColor: Theme.of(context).colorScheme.primary.withAlpha(20),
        onTap: () {
          debugPrint('Received click');
        },
        child: SizedBox(
          height: 151,
          width: 151,
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: Theme.of(context).colorScheme.primary, size: 100),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(text),
              )
            ],
          )),
        ),
      ),
    ),
  );
}

/// Creates section based cards that lead to quizzes/posts.
Widget sectionCard(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(38.0, 16.0, 38.0, 16.0),
    child: Card(
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: SizedBox(
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    ?.copyWith(color: Theme.of(context).primaryColorLight)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SectionPage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                      primary: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                      minimumSize: const Size(double.infinity, 40),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      )),
                  child: Text(
                    'View Posts',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  )),
            )
          ],
        ),
      ),
    ),
  );
}

/// Creates card with a summary of a user's information.
Widget userInfo(BuildContext context,
    {required String username,
    required String level,
    required double experience,
    ImageProvider<Object>? profilePicture}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(38.0, 16.0, 38.0, 16.0),
    child: Card(
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: SizedBox(
        height: 175,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 6.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(username,
                        style: Theme.of(context).textTheme.headline4?.copyWith(
                            color: Theme.of(context).primaryColorLight)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Level',
                            style: Theme.of(context).textTheme.subtitle1),
                        Text(
                          level,
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Experience',
                            style: Theme.of(context).textTheme.subtitle1),
                        Text(
                          "${experience.toInt()}/4000",
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SleekCircularSlider(
                  appearance: CircularSliderAppearance(
                      angleRange: 360.0,
                      startAngle: 0.0,
                      customWidths: CustomSliderWidths(
                          trackWidth: 15,
                          progressBarWidth: 15,
                          handlerSize: 0,
                          shadowWidth: 16),
                      customColors: CustomSliderColors(
                          trackColor:
                              Theme.of(context).primaryColorLight.withAlpha(25),
                          progressBarColors: [
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(context).colorScheme.primary
                          ])),
                  innerWidget: (double percentage) {
                    return Center(
                        child: (profilePicture == null)
                            ? const UserAvatar()
                            : CircleAvatar(
                                backgroundImage: profilePicture,
                                radius: 48.5,
                              ));
                  },
                  min: 0,
                  max: 4000,
                  initialValue: experience,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/**
 * The following section includes the actual home page.
 */

/// This is the main home page leading to other pages.
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Floating Action Button to Logout
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
          },
          child: const Icon(Icons.logout)),

      /// main body
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          /// top header, with maths club branding
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: header("Maths Club", context),
          ),

          /// bottom scrollable section
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                /// user info display
                userInfo(context,
                    username: "Garv",
                    level: "3",
                    experience: 2418,
                    profilePicture: const AssetImage(
                      "assets/profile.gif",
                    )),

                /// horizontal carousel for actions
                SizedBox(
                  height: 175,
                  child: Center(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: [
                        actionCard(context,
                            icon: Icons.people,
                            text: "Leaderboards",
                            position: PositionPadding.start),
                        actionCard(context,
                            icon: Icons.admin_panel_settings,
                            text: "Admin View"),
                        actionCard(context,
                            icon: Icons.create, text: "Create Post"),
                        actionCard(context,
                            icon: Icons.settings,
                            text: "Settings",
                            position: PositionPadding.end),
                      ],
                    ),
                  ),
                ),

                /// cards leading to individual sections
                sectionCard(context, "Junior"),
                sectionCard(context, "Senior"),
              ],
            ),
          )
        ],
      ),
    );
  }
}
