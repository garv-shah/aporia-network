import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
Widget actionCard(
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
      child: SizedBox(
        height: 151,
        width: 151,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.deepPurpleAccent.shade400, size: 100),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(text),
            )
          ],
        )),
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
            Text(title, style: Theme.of(context).textTheme.headline4),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: OutlinedButton(
                  onPressed: () {
                    debugPrint('Received click');
                  },
                  style: OutlinedButton.styleFrom(
                      primary: Colors.deepPurpleAccent,
                      side: const BorderSide(color: Colors.deepPurpleAccent),
                      minimumSize: const Size(double.infinity, 40),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      )),
                  child: const Text(
                    'View Posts',
                    style: TextStyle(color: Colors.deepPurpleAccent),
                  )),
            )
          ],
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
          child: const Icon(Icons.logout)
      ),

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
                Padding(
                  padding: EdgeInsets.fromLTRB(38.0, 16.0, 38.0, 16.0),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
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
                              padding: const EdgeInsets.fromLTRB(
                                  12.0, 6.0, 12.0, 6.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Garv",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Level',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1),
                                      Text(
                                        '3',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6?.copyWith(color: Colors.deepPurpleAccent),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Experience',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1),
                                      Text(
                                        '2418/4000',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6?.copyWith(color: Colors.deepPurpleAccent),
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
                                            Color.fromARGB(255, 220, 220, 220),
                                        progressBarColor:
                                            Colors.deepPurpleAccent)),
                                innerWidget: (double percentage) {
                                  return const Center(
                                      child: CircleAvatar(
                                    backgroundImage: AssetImage(
                                      "assets/profile.gif",
                                    ),
                                    radius: 48.5,
                                  ));
                                },
                                min: 0,
                                max: 4000,
                                initialValue: 2418,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                /// horizontal carousel for actions
                SizedBox(
                  height: 175,
                  child: Center(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: [
                        actionCard(
                            icon: Icons.people,
                            text: "Leaderboards",
                            position: PositionPadding.start),
                        actionCard(
                            icon: Icons.admin_panel_settings,
                            text: "Admin View"),
                        actionCard(icon: Icons.create, text: "Create Post"),
                        actionCard(
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
