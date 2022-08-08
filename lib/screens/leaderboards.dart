import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:maths_club/screens/home_page.dart';

import '../utils/components.dart';

/**
 * The following section includes functions for the leaderboards page.
 */

/// A leaderboard position entry.
Widget user(BuildContext context,
    {required String username,
    required int position,
    required Widget profilePicture,
    required int experience,
    required bool infinity,
    required bool removeBackground}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
    child: Card(
      // If the background is to be removed, have transparent background and 0
      // elevation.
      color: removeBackground ? Colors.transparent : null,
      elevation: removeBackground ? 0 : 3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: SizedBox(
        height: 60,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // profile picture and name
            SizedBox(
              width: MediaQuery.of(context).size.width - 95,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                    child: profilePicture,
                  ),
                  Text("$username:",
                      style: Theme.of(context).textTheme.headline6),
                  const SizedBox(width: 10),
                  Flexible(
                    // If user has infinite experience somehow, render that
                    child: Text(infinity ? "Infinity" : experience.toString(),
                        style: Theme.of(context).textTheme.headline6?.copyWith(
                            color: Theme.of(context).colorScheme.primary),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        maxLines: 1),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: Text(position.toString()),
            )
          ],
        ),
      ),
    ),
  );
}

/**
 * The following section includes the actual leaderboards page.
 */

/// This is the leaderboards page for rankings based on experience.
class Leaderboards extends StatefulWidget {
  const Leaderboards({Key? key}) : super(key: key);

  @override
  State<Leaderboards> createState() => _LeaderboardsState();
}

class _LeaderboardsState extends State<Leaderboards> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          // Gets the quizPoints collection ordered by the amount of experience
          // each user has.
          stream: FirebaseFirestore.instance
              .collection('quizPoints')
              .orderBy('experience', descending: true)
              .snapshots(),
          builder: (context, quizPointsSnapshot) {
            if (quizPointsSnapshot.connectionState == ConnectionState.active) {
              return SafeArea(
                child: ListView.builder(
                  // The following line makes the item count for the builder the
                  // number of user entries we have on the server. The +1 is there
                  // because of the extra header widget at the start, which
                  // occupies the first index.
                  itemCount: (quizPointsSnapshot.data?.docs.length ?? 0) + 1,
                  itemBuilder: (BuildContext context, int index) {
                    // If index is first, return header, if not, return user entry.
                    if (index == 0) {
                      // Header.
                      return Row(
                        children: [
                          header("Leaderboards", context,
                              fontSize: 30, backArrow: true),
                        ],
                      );
                    } else {
                      // Current doc's data.
                      QueryDocumentSnapshot<Map<String, dynamic>>? data =
                          quizPointsSnapshot.data?.docs[index - 1];

                      // User entry.
                      return user(context,
                          username: (() {
                            try {
                              return data?['username'];
                            } on StateError {
                              return 'Error: no username';
                            }
                          }()),
                          position: index,
                          experience: (data?['experience'].isInfinite == false)
                              ? (data?['experience'].round())
                              : 0,
                          infinity: data?['experience'].isInfinite,
                          // Remove the background if the user's card is the
                          // user that's logged in. This adds a bit of visual
                          // difference and makes it easier to identify yourself.
                          removeBackground: data?.id ==
                              FirebaseAuth.instance.currentUser?.uid,
                          profilePicture: (() {
                            try {
                              return SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: fetchProfilePicture(
                                      data?['profilePicture'],
                                      data?['pfpType'],
                                      data?['username'],
                                      padding: true,
                                      customPadding: 5));
                            } on StateError {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    12.0, 0.0, 12.0, 0.0),
                                child: Icon(Icons.error,
                                    size: 30,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              );
                            }
                          }()));
                    }
                  },
                ),
              );
            } else {
              // Display loading indicator while page is loading.
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
