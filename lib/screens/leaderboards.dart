import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:maths_club/screens/home_page.dart';
import 'package:animated_list_plus/transitions.dart';

import '../utils/components.dart';

/**
 * The following section includes functions for the leaderboards page.
 */

/// A leaderboard position entry.
Widget user(BuildContext context,
    {required String username,
    required int position,
    required Widget profilePicture}) {
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
                Text(username, style: Theme.of(context).textTheme.headline6),
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
          stream:
              FirebaseFirestore.instance.collection('quizPoints').orderBy('experience', descending: true).snapshots(),
          builder: (context, quizPointsSnapshot) {
            if (quizPointsSnapshot.connectionState == ConnectionState.active) {
              return SafeArea(
                child: ImplicitlyAnimatedReorderableList<QueryDocumentSnapshot<Map<String, dynamic>>>(
                  items: quizPointsSnapshot.data?.docs ?? [],
                  onReorderFinished: (item, from, to, newItems) {},
                  areItemsTheSame: (oldItem, newItem) => oldItem.id == newItem.id,
                  header: Row(
                    children: [
                      header("Leaderboards", context,
                          fontSize: 30, backArrow: true),
                    ],
                  ),
                  itemBuilder: (context, itemAnimation, item, index) {
                    QueryDocumentSnapshot<Map<String, dynamic>>? data =
                    quizPointsSnapshot.data?.docs[index];

                    return Reorderable(
                      key: ValueKey(data?.id),
                      child: user(context,
                          username: (() {
                            try {
                              return quizPointsSnapshot.data?.docs[index]
                              ['username'];
                            } on StateError {
                              return 'Error: no username!';
                            }
                          }()),
                          position: index + 1,
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
                                padding:
                                const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
                                child: Icon(Icons.error,
                                    size: 30,
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .primary),
                              );
                            }
                          }())),
                    );
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
