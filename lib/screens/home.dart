import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
            Icon(icon, color: Colors.deepPurple.shade400, size: 100),
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
                      side: BorderSide(color: Colors.deepPurple.shade500),
                      minimumSize: const Size(double.infinity, 40),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      )),
                  child: Text(
                    'View Posts',
                    style: TextStyle(color: Colors.deepPurple.shade500),
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
                const Padding(
                  padding: EdgeInsets.fromLTRB(38.0, 16.0, 38.0, 16.0),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: SizedBox(
                      height: 175,
                      child: Center(child: Text('User Info Display')),
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
