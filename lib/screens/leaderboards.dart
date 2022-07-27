import 'dart:typed_data';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:maths_club/screens/home_page.dart';
import 'package:maths_club/widgets/forks/editable_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/components.dart';

/**
 * The following section includes functions for the leaderboards page.
 */

/// A leaderboard position entry.
Widget user(BuildContext context,
    {required String username,
    required int position,
    ImageProvider<Object>? profilePicture}) {
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
                (profilePicture == null)
                    ? const Padding(
                      padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                      child: UserAvatar(size: 50),
                    )
                    : Padding(
                      padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
                      child: CircleAvatar(
                  backgroundImage: profilePicture,
                  radius: 20,
                ),
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
class Leaderboards extends StatelessWidget {
  const Leaderboards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // header
          Row(
            children: [
              header("Leaderboards", context,
                  fontSize: 30, backArrow: true),
            ],
          ),
          // leaderboard entries
          user(context, username: "Garv", position: 1, profilePicture: const AssetImage("assets/profile.gif")),
          user(context, username: "Garv", position: 2, profilePicture: const AssetImage("assets/profile.gif")),
          user(context, username: "Garv", position: 3, profilePicture: const AssetImage("assets/profile.gif")),
          user(context, username: "Garv", position: 4, profilePicture: const AssetImage("assets/profile.gif")),
          user(context, username: "Garv", position: 5, profilePicture: const AssetImage("assets/profile.gif")),
          user(context, username: "Garv", position: 6, profilePicture: const AssetImage("assets/profile.gif")),
          user(context, username: "Garv", position: 7, profilePicture: const AssetImage("assets/profile.gif")),
          user(context, username: "Garv", position: 8, profilePicture: const AssetImage("assets/profile.gif")),
          user(context, username: "Garv", position: 9, profilePicture: const AssetImage("assets/profile.gif")),
        ],
      ),
    );
  }
}
