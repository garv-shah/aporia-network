import 'package:cloud_firestore/cloud_firestore.dart';
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
    required int experience}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
    child: Card(
      elevation: 3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // profile picture and name
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                  child: profilePicture,
                ),
                Text("$username:",
                    style: Theme.of(context).textTheme.headline6),
                const SizedBox(width: 10),
                Text(experience.toString(),
                    style: Theme.of(context).textTheme.headline6?.copyWith(
                        color: Theme.of(context).colorScheme.primary),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    maxLines: 1),
              ],
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
                      QueryDocumentSnapshot<Map<String, dynamic>>? data =
                          quizPointsSnapshot.data?.docs[index - 1];

                      // User entry.
                      return user(context,
                          username: (() {
                            try {
                              return data?['username'];
                            } on StateError {
                              return 'Error: no username!';
                            }
                          }()),
                          position: index,
                          experience: data?['experience'],
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
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
