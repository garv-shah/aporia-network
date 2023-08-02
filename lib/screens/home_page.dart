/*
File: home_page.dart
Description: The home page for the app
Author: Garv Shah
Created: Sat Jun 18 18:29:00 2022
 */

import 'dart:math';

import 'package:maths_club/screens/scheduling/schedule_view.dart';
import 'package:maths_club/widgets/lesson_countdown.dart';
import 'package:maths_club/widgets/volunteer_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:maths_club/screens/section_views/section_page.dart';
import 'package:maths_club/screens/settings_page.dart';
import 'package:maths_club/utils/components.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:maths_club/widgets/forks/sleek_circular_slider/appearance.dart';
import 'package:maths_club/widgets/forks/sleek_circular_slider/circular_slider.dart';
import 'package:maths_club/utils/config/config.dart' as config;
import 'package:maths_club/utils/config/config_parser.dart' as parse;
import 'package:maths_club/utils/config/abilities.dart';
import 'package:maths_club/widgets/action_card.dart';

/**
 * The following section includes functions for the home page.
 */

/// Creates section based cards that lead to quizzes/posts.
Widget sectionCard(BuildContext context, Map<String, dynamic> userData,
    String title, String? sectionID, String role, List<String> userRoles) {
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
                    .headlineMedium
                    ?.copyWith(color: Theme.of(context).primaryColorLight)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: OutlinedButton(
                  onPressed: () {
                    // Navigates to section page of respective role
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SectionPage(
                              userData: userData,
                              title: title,
                              userRoles: userRoles,
                              id: sectionID,
                              role: role)),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
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

/// progress bar rings around user profile picture
Widget decoratedProfilePicture(BuildContext context,
    {required Widget profilePicture,
    required List<String> userRoles,
    required double experience,
    required Map<String, dynamic> levelMap}) {
  if (getComputedAbilities(userRoles).contains('points')) {
    return SleekCircularSlider(
      appearance: CircularSliderAppearance(
          animationEnabled: true,
          angleRange: 360.0,
          startAngle: 0.0,
          customWidths: CustomSliderWidths(
              trackWidth: 15,
              progressBarWidth: 15,
              handlerSize: 0,
              shadowWidth: 16),
          customColors: CustomSliderColors(
              trackColor: Theme.of(context).primaryColorLight.withAlpha(25),
              progressBarColors: [
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.primary
              ])),
      innerWidget: (double percentage) {
        return profilePicture;
      },
      min: levelMap['minVal'],
      max: levelMap['maxVal'],
      // If the value of experience is infinity, have the experience rendered at 0
      initialValue: (experience.isInfinite) ? 0 : experience.abs(),
    );
  } else {
    return profilePicture;
  }
}

/// Calculates a user's level and returns a map based on experience points.
Map<String, dynamic> calculateLevel(experience) {
  double y = experience; // total experience points

  // If experience is infinity, treat it as 0
  if (y.isInfinite) {
    y = 0;
  } else {
    y = y.abs();
  }

  // random parameters for levelling up (creates quadratic equation)
  double a = 75 / 2;
  double b = 175 / 2;
  double c = -125;

  double x = (-b + sqrt(pow(b, 2) - 4 * a * (c - y))) /
      (2 * a); // rearranged quadratic formula
  int level = x.floor(); // always round down to find current level

  int nextLevel = level + 1;
  // ax^2 + bx + c
  double requiredExperience = a * pow(nextLevel, 2) + b * nextLevel + c;
  double lowerExperience = a * pow(level, 2) + b * level + c;

  // return map:
  return {
    'level': level,
    'maxVal': requiredExperience,
    'minVal': lowerExperience,
  };
}

/// Creates card with a summary of a user's information.
Widget userInfo(BuildContext context,
    {required Map<String, dynamic> userData,
    required Widget profilePicture,
    required bool isAdmin,
    required bool isCompany,
    required List<String> userRoles,
    required List<String> abilities,
    required Map<String, dynamic>? profileMap,
    required parse.Config configMap}) {
  double experience = (profileMap?['experience'] ?? 0).toDouble();
  Map<String, dynamic> levelMap = calculateLevel(experience);

  Map<int, Map<String, String>> subText = {};

  // if our user is a volunteer, show different text
  if (abilities.contains('volunteering')) {
    int volunteerHours = (profileMap?['volunteerHours'] ?? 0).toInt();
    subText = {
      1: {
        'title': 'Time to Lesson',
        'text': profileMap?['volunteer'] == true ? 'Loading...' : 'N/A',
        'util': 'lessonCountdown'
      },
      2: {
        'title': 'Volunteer Hours',
        'text': '$volunteerHours ${volunteerHours == 1 ? 'Hour' : 'Hours'}',
      },
    };
  } else {
    subText = {
      1: {
        'title': 'Level',
        'text': levelMap['level'].toString(),
      },
      2: {
        'title': 'Experience',
        'text': (experience.isInfinite)
            ? "Infinity"
            : "${experience.abs().toInt()}/${levelMap['maxVal'].toInt()}"
      },
    };
  }

  return Padding(
    padding: const EdgeInsets.fromLTRB(38.0, 16.0, 38.0, 16.0),
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
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SettingsPage(
                  userData: userData,
                  userRoles: userRoles,
                  isAdmin: isAdmin,
                )),
          );
        },
        child: SizedBox(
          height: 175,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 6.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // The fitted box allows the text to resize based on how long it is.
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(userData['username'],
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                      color:
                                          Theme.of(context).primaryColorLight)),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subText[1]?['title'] ?? 'error',
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                            ),
                            (profileMap?['volunteer'] == true && subText[1]?['util'] == 'lessonCountdown')
                                ? lessonCountdown(profileMap)
                                : Text(
                                    subText[1]?['text'] ?? 'error',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                  ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subText[2]?['title'] ?? 'error',
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                            ),
                            Text(
                              // If the experience is infinity, render the text "infinity", if not, get the positive experience value.
                              subText[2]?['text'] ?? 'error',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                      width: 125,
                      height: 125,
                      child: decoratedProfilePicture(context,
                          profilePicture: profilePicture,
                          userRoles: userRoles,
                          experience: experience,
                          levelMap: levelMap)),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget fetchProfilePicture(
    String? profilePicture, String? pfpType, String? username,
    {bool padding = false, double? customPadding}) {
  String imageUrl = profilePicture ??
      "https://avatars.dicebear.com/api/avataaars/$username.svg";

  if (imageUrl.isEmpty) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Padding(
        padding: padding
            ? EdgeInsets.all(customPadding ?? 10)
            : const EdgeInsets.all(0),
        child: Center(
          child: UserAvatar(size: constraints.maxHeight),
        ),
      );
    });
  } else if (pfpType == 'image/svg+xml') {
    return Padding(
      padding: padding
          ? EdgeInsets.all(customPadding ?? 10)
          : const EdgeInsets.all(0),
      child: ClipOval(
        child: CircleAvatar(
          backgroundColor: const Color.fromRGBO(65, 65, 65, 0.4),
          child: SvgPicture.network(
            imageUrl,
            width: 1000,
            height: 1000,
            semanticsLabel: '$username profile picture svg',
            placeholderBuilder: (BuildContext context) => const SizedBox(
                height: 30, width: 30, child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  } else {
    return Padding(
      padding: padding
          ? EdgeInsets.all(customPadding ?? 10)
          : const EdgeInsets.all(0),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) => LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Center(
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: imageProvider,
              radius: 1000,
            ),
          );
        }),
        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
          child: SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(value: downloadProgress.progress),
          ),
        ),
        errorWidget: (context, url, error) => LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Center(
            child: UserAvatar(size: constraints.maxHeight - (padding ? 10 : 0)),
          );
        }),
      ),
    );
  }
}

/**
 * The following section includes the actual home page.
 */

/// This is the main home page leading to other pages.
class HomePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomePage({Key? key, required this.userData}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    String username = widget.userData['username'] ?? "...";

    return Scaffold(
      /// main body
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            /// top header, with branding
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: header(config.name, context),
            ),

            /// bottom scrollable section
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('roles')
                      .where('members',
                          arrayContains: FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                  builder: (context, rolesSnapshot) {
                    if (rolesSnapshot.connectionState ==
                        ConnectionState.active) {
                      // If the user is not in a role
                      if (rolesSnapshot.data?.docs.isEmpty ?? true) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.fromLTRB(50.0, 16.0, 50.0, 16.0),
                          child: Text(
                              "Error: you are not assigned to a role yet. Please wait a second, and if it's still not working please contact an Admin"),
                        ));
                      } else {
                        // TODO: depreciate roleList and isUser, isAdmin etc
                        List roleList = rolesSnapshot.data!.docs
                            .map((doc) => doc['tag'])
                            .toList();
                        bool isUser = roleList.contains("User");
                        bool isAdmin = roleList.contains("Admin");
                        bool isCompany = roleList.contains("Company");

                        List<String> userRoles = rolesSnapshot.data!.docs
                            .map((doc) => doc.id)
                            .toList();
                        List<String> abilities =
                            getComputedAbilities(userRoles);

                        return StreamBuilder<DocumentSnapshot>(
                            // Stream for user's quiz points.
                            stream: FirebaseFirestore.instance
                                .collection('publicProfile')
                                .doc(FirebaseAuth.instance.currentUser?.uid)
                                .snapshots(),
                            builder: (context, publicProfileSnapshot) {
                              // Turn user points document to dart map.
                              Map<String, dynamic>? profileMap =
                                  publicProfileSnapshot.data?.data()
                                      as Map<String, dynamic>?;

                              // If user is in role, return normal ListView
                              return SizedBox(
                                width: isAdmin ? 760 : 600,
                                child: ListView(
                                  padding: EdgeInsets.zero,
                                  children: [
                                    /// user info display
                                    userInfo(
                                      context,
                                      userData: widget.userData,
                                      isAdmin: isAdmin,
                                      isCompany: isCompany,
                                      userRoles: userRoles,
                                      configMap: config.configMap,
                                      profileMap: profileMap,
                                      abilities: abilities,
                                      profilePicture: Hero(
                                        tag: '$username Profile Picture',
                                        child: fetchProfilePicture(
                                          widget.userData['profilePicture'],
                                          widget.userData['pfpType'],
                                          username,
                                          padding: true,
                                          customPadding:
                                              abilities.contains('points')
                                                  ? 15
                                                  : 0,
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
                                          children: actionCardCarousel(context,
                                              isUser: isUser,
                                              isAdmin: isAdmin,
                                              isCompany: isCompany,
                                              userRoles: userRoles,
                                              configMap: config.configMap,
                                              userData: widget.userData,
                                              profileMap: profileMap,
                                              customButtons: abilities
                                                      .contains('volunteering')
                                                  ? [
                                                      VolunteerButton(
                                                          jobList: profileMap?[
                                                                  'jobList'] ??
                                                              [])
                                                    ]
                                                  : []),
                                        ),
                                      ),
                                    ),

                                    /// cards leading to individual sections
                                    StreamBuilder<QuerySnapshot>(
                                        // The postGroups collection includes which roles
                                        // can access which groups. This stream gets all
                                        // postGroups where the roles includes the roles
                                        // that the user can access.
                                        stream: FirebaseFirestore.instance
                                            .collection('postGroups')
                                            // Since a user can have multiple roles, this gets all the roles a user is in
                                            .where('roles',
                                                arrayContainsAny: rolesSnapshot
                                                    .data?.docs
                                                    .map((doc) => doc.id)
                                                    .toList())
                                            .snapshots(),
                                        builder: (context, postsGroupSnapshot) {
                                          if (postsGroupSnapshot
                                                  .connectionState ==
                                              ConnectionState.active) {
                                            // Builds section cards based on the
                                            // postGroups a user is a part of.
                                            List docs = postsGroupSnapshot.data?.docs ?? [];
                                            docs.sort((a, b) => a.data()['order'].compareTo(b.data()['order']));

                                            return ListView.builder(
                                                physics: const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                padding: EdgeInsets.zero,
                                                itemCount: docs.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  Map<String, dynamic>? postData = docs[index].data() as Map<String, dynamic>?;

                                                  if ((postData?['apps'] ?? []).contains(config.appID)) {
                                                    return sectionCard(
                                                      context,
                                                      widget.userData,
                                                      postData?["tag"],
                                                      docs[index].id,
                                                      rolesSnapshot.data?.docs[0]['tag'],
                                                      userRoles,
                                                    );
                                                  } else {
                                                    return const SizedBox.shrink();
                                                  }
                                                });
                                          } else {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                        }),
                                  ],
                                ),
                              );
                            });
                      }
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
