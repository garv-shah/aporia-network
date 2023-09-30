/*
File: leaderboards.dart
Description: The leaderboards page for the app
Author: Garv Shah
Created: Wed Jul 20 20:11:15 2022
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:aporia_app/screens/home_page.dart';
import 'package:aporia_app/utils/components.dart';
import 'package:aporia_app/utils/config/config.dart' as config;

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
    required bool removeBackground,
    required bool isAdmin}) {
  double width = isAdmin ? 760 : 600;
  double maxWidth = (MediaQuery.of(context).size.width > width) ? width : MediaQuery.of(context).size.width;
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
        width: maxWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // profile picture and name
            SizedBox(
              width: maxWidth - 125,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                    child: profilePicture,
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 190,
                    ),
                    child: Text(
                      "$username:",
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    // If user has infinite experience somehow, render that
                    child: Text(infinity ? "Infinity" : experience.toString(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
              child: Text(position.toString(), overflow: TextOverflow.ellipsis),
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
  final bool isAdmin;

  const Leaderboards({Key? key, required this.isAdmin}) : super(key: key);

  @override
  State<Leaderboards> createState() => _LeaderboardsState();
}

class _LeaderboardsState extends State<Leaderboards> {
  @override
  Widget build(BuildContext context) {
    int counter = 0;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          // Gets the publicProfile collection ordered by the amount of experience
          // each user has.
          stream: FirebaseFirestore.instance
              .collection('publicProfile')
              .orderBy('experience', descending: true)
              .snapshots(),
          builder: (context, publicProfileSnapshot) {
            if (publicProfileSnapshot.connectionState == ConnectionState.active) {
              return SafeArea(
                child: Center(
                  child: SizedBox(
                    width: widget.isAdmin ? 760 : 600,
                    child: ListView.builder(
                      // The following line makes the item count for the builder the
                      // number of user entries we have on the server. The +1 is there
                      // because of the extra header widget at the start, which
                      // occupies the first index.
                      itemCount: (publicProfileSnapshot.data?.docs.length ?? 0) + 1,
                      itemBuilder: (BuildContext context, int index) {
                        // If index is first, return header, if not, return user entry.
                        if (index == 0) {
                          // Header.
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 50),
                                child: header("Leaderboards", context,
                                    fontSize: 30, backArrow: true),
                              ),
                            ],
                          );
                        } else {
                          // Current doc's data.
                          QueryDocumentSnapshot<Map<String, dynamic>>? data =
                          publicProfileSnapshot.data?.docs[index - 1];

                          if (widget.isAdmin || data?['userType'] == config.appID || config.appID == 'aporia_app') {
                            // User entry.
                            counter += 1;
                            return user(context,
                                username: (() {
                                  try {
                                    return data?['username'];
                                  } on StateError {
                                    return 'Error: no username';
                                  }
                                }()),
                                position: counter,
                                experience: (data?['experience'].isInfinite ==
                                    false)
                                    ? (data?['experience'].round())
                                    : 0,
                                infinity: data?['experience'].isInfinite,
                                // Remove the background if the user's card is the
                                // user that's logged in. This adds a bit of visual
                                // difference and makes it easier to identify yourself.
                                removeBackground: data?.id ==
                                    FirebaseAuth.instance.currentUser?.uid,
                                isAdmin: widget.isAdmin,
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
                                          Theme
                                              .of(context)
                                              .colorScheme
                                              .primary),
                                    );
                                  }
                                }()));
                          } else {
                            return const SizedBox.shrink();
                          }
                        }
                      },
                    ),
                  ),
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
