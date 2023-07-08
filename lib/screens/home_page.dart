/*
File: home_page.dart
Description: The home page for the app
Author: Garv Shah
Created: Sat Jun 18 18:29:00 2022
 */

import 'dart:math';

import 'package:aporia_app/screens/scheduling/availability_page.dart';
import 'package:aporia_app/screens/scheduling/create_job_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:aporia_app/screens/post_creation/create_post_view.dart';
import 'package:aporia_app/screens/leaderboards.dart';
import 'package:aporia_app/screens/section_views/admin_view/user_list_view.dart';
import 'package:aporia_app/screens/section_views/section_page.dart';
import 'package:aporia_app/screens/settings_page.dart';
import 'package:aporia_app/utils/components.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aporia_app/widgets/forks/sleek_circular_slider/appearance.dart';
import 'package:aporia_app/widgets/forks/sleek_circular_slider/circular_slider.dart';
import 'package:aporia_app/utils/config.dart' as config;

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
    required String text,
    Widget? navigateTo}) {
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
          // try to navigate to page
          if (navigateTo != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => navigateTo),
            );
          } else {
            debugPrint("navigateTo was null");
          }
        },
        // Builds icon and text inside card
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
Widget sectionCard(BuildContext context, Map<String, dynamic> userData,
    String title, String? sectionID, String role) {
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
Widget userRings(BuildContext context,
    {required Widget profilePicture,
    required double experience,
    required Map<String, dynamic> levelMap}) {
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
    required bool isAdmin}) {
  return StreamBuilder<DocumentSnapshot>(
      // Stream for user's quiz points.
      stream: FirebaseFirestore.instance
          .collection('quizPoints')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, pointsSnapshot) {
        // Turn user points document to dart map.
        Map<String, dynamic>? experienceMap =
            pointsSnapshot.data?.data() as Map<String, dynamic>?;
        double experience = (experienceMap?['experience'] ?? 0).toDouble();
        Map<String, dynamic> levelMap = calculateLevel(experience);

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
              highlightColor:
                  Theme.of(context).colorScheme.primary.withAlpha(20),
              onTap: () {
                // Clicking the userInfo widget goes to the settings page.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SettingsPage(
                            userData: userData,
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
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 6.0),
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
                                          color: Theme.of(context)
                                              .primaryColorLight)),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Level',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                Text(
                                  levelMap['level'].toString(),
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
                                Text('Experience',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                Text(
                                  // If the experience is infinity, render the text "infinity", if not, get the positive experience value.
                                  (experience.isInfinite)
                                      ? "Infinity"
                                      : "${experience.abs().toInt()}/${levelMap['maxVal'].toInt()}",
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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                            width: 125,
                            height: 125,
                            child: userRings(context,
                                profilePicture: profilePicture,
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
      });
}

Widget fetchProfilePicture(
    String? profilePicture, String? pfpType, String? username,
    {bool padding = false, double? customPadding}) {
  String imageUrl = profilePicture ??
      "https://avatars.dicebear.com/api/avataaars/$username.svg";

  if (imageUrl.isEmpty) {
    return Padding(
      padding: padding
          ? EdgeInsets.all(customPadding ?? 15.0)
          : const EdgeInsets.all(0),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Center(
          child: UserAvatar(size: constraints.maxHeight),
        );
      }),
    );
  } else if (pfpType == 'image/svg+xml') {
    return Padding(
      padding: padding
          ? EdgeInsets.all(customPadding ?? 15.0)
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
          ? EdgeInsets.all(customPadding ?? 15.0)
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
      body: Column(
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
                  if (rolesSnapshot.connectionState == ConnectionState.active) {
                    // If the user is not in a role
                    if (rolesSnapshot.data?.docs.isEmpty ?? true) {
                      return const Center(
                          child: Padding(
                        padding: EdgeInsets.fromLTRB(50.0, 16.0, 50.0, 16.0),
                        child: Text(
                            "Error: you are not assigned to a role yet. Please wait a second, and if it's still not working please contact an Admin"),
                      ));
                    } else {
                      List roleList = rolesSnapshot.data!.docs
                          .map((doc) => doc['tag'])
                          .toList();
                      bool isAdmin = roleList.contains("Admin");
                      bool isCompany = roleList.contains("Company");
                      // If user is in role, return normal ListView
                      return SizedBox(
                        width: isAdmin ? 760 : 600,
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            /// user info display
                            userInfo(context,
                                userData: widget.userData,
                                isAdmin: isAdmin,
                                profilePicture: Hero(
                                    tag: '$username Profile Picture',
                                    child: fetchProfilePicture(
                                        widget.userData['profilePicture'],
                                        widget.userData['pfpType'],
                                        username,
                                        padding: true))),

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
                                        navigateTo:
                                            Leaderboards(isAdmin: isAdmin),
                                        position: PositionPadding.start),
                                    // Only show if appMap says so
                                    config.appMap[config.appID]['views'].contains('scheduling')
                                        ? (
                                        isCompany ?
                                        actionCard(context,
                                        icon: Icons.work,
                                        text: "Create Job",
                                        navigateTo: CreateJob(userData: widget.userData)) :
                                        actionCard(context,
                                            icon: Icons.edit_calendar,
                                            text: "Availability",
                                            navigateTo: AvailabilityPage(
                                                isCompany: isCompany))
                                    )
                                        : const SizedBox.shrink(),
                                    // Only show tile if user is admin
                                    isAdmin ? actionCard(context,
                                            icon: Icons.admin_panel_settings,
                                            text: "Admin View",
                                            navigateTo: UsersPage())
                                        : const SizedBox.shrink(),
                                    // Only show tile if user is admin
                                    isAdmin ? actionCard(context,
                                            icon: Icons.create,
                                            text: "Create Post",
                                            navigateTo: const CreatePost())
                                        : const SizedBox.shrink(),
                                    actionCard(context,
                                        icon: Icons.settings,
                                        text: "Settings",
                                        navigateTo: SettingsPage(
                                            userData: widget.userData,
                                            isAdmin: isAdmin),
                                        position: PositionPadding.end),
                                  ],
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
                                  if (postsGroupSnapshot.connectionState ==
                                      ConnectionState.active) {
                                    // Builds section cards based on the
                                    // postGroups a user is a part of.
                                    return ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        itemCount: postsGroupSnapshot
                                            .data?.docs.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return sectionCard(
                                              context,
                                              widget.userData,
                                              postsGroupSnapshot
                                                  .data?.docs[index]["tag"],
                                              postsGroupSnapshot
                                                  .data?.docs[index].id,
                                              rolesSnapshot.data?.docs[0]
                                                  ['tag']);
                                        });
                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                }),
                          ],
                        ),
                      );
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }),
          )
        ],
      ),
    );
  }
}
