import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:maths_club/screens/post_creation/create_post_view.dart';
import 'package:maths_club/screens/leaderboards.dart';
import 'package:maths_club/screens/section_views/section_page.dart';
import 'package:maths_club/screens/settings_page.dart';
import 'package:maths_club/utils/components.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:maths_club/widgets/forks/sleek_circular_slider/appearance.dart';
import 'package:maths_club/widgets/forks/sleek_circular_slider/circular_slider.dart';

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
          if (navigateTo != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => navigateTo),
            );
          } else {
            debugPrint("action button clicked!");
          }
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
Widget sectionCard(
    BuildContext context, Map<String, dynamic> userData, String title, String? sectionID) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(38.0, 16.0, 16.0, 16.0),
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
                      MaterialPageRoute(
                          builder: (context) =>
                              SectionPage(userData: userData, title: title, id: sectionID)),
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
    initialValue: (experience.isInfinite) ? 0 : experience.abs(),
  );
}

/// Calculates a user's level and returns a map based on experience points.
Map<String, dynamic> calculateLevel(experience) {
  double y = experience; // total experience points

  if (y.isInfinite) {
    y = 0;
  } else {
    y = y.abs();
  }

  // parameters for levelling up
  double a = 75 / 2;
  double b = 175 / 2;
  double c = -125;

  double x = (-b + sqrt(pow(b, 2) - 4 * a * (c - y))) /
      (2 * a); // rearranged quadratic formula
  int level = x.floor(); // always round down to find current level

  int nextLevel = level + 1;
  double requiredExperience = a * pow(nextLevel, 2) + b * nextLevel + c;
  double lowerExperience = a * pow(level, 2) + b * level + c;

  double animDurationMultiplier = 125 / y;

  return {
    'level': level,
    'maxVal': requiredExperience,
    'minVal': lowerExperience,
    'animDurationMultiplier': animDurationMultiplier
  };
}

/// Creates card with a summary of a user's information.
Widget userInfo(BuildContext context,
    {required Map<String, dynamic> userData, required Widget profilePicture}) {
  return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('quizPoints')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, pointsSnapshot) {
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SettingsPage(
                            userData: userData,
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
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 290,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(userData['username'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4
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
                                          .subtitle1),
                                  Text(
                                    levelMap['level'].toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
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
                                          .subtitle1),
                                  Text(
                                    (experience.isInfinite)
                                        ? "Infinity"
                                        : "${experience.abs().toInt()}/${levelMap['maxVal'].toInt()}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
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
    {bool padding = true, double? customPadding}) {
  String imageUrl = profilePicture ??
      "https://avatars.dicebear.com/api/avataaars/$username.svg";

  if (imageUrl.isEmpty) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Center(
        child: UserAvatar(
            size: padding ? constraints.maxHeight - (padding ? 10 : 0) : null),
      );
    });
  } else if (pfpType == 'image/svg+xml') {
    return Center(
      child: Padding(
        padding: padding ? const EdgeInsets.all(15.0) : EdgeInsets.zero,
        child: ClipOval(
          child: SvgPicture.network(
            imageUrl,
            semanticsLabel: '$username profile picture svg',
            placeholderBuilder: (BuildContext context) => const SizedBox(
                height: 30, width: 30, child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  } else {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Center(
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: imageProvider,
            radius: constraints.maxWidth / 2 -
                (padding ? (customPadding ?? 15) : 0),
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
          /// top header, with maths club branding
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: header("Maths Club", context),
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
                      return const Center(child: Padding(
                        padding: EdgeInsets.fromLTRB(50.0, 16.0, 50.0, 16.0),
                        child: Text("Error: you are not assigned to a role yet. Please wait a second, and if it's still not working please contact an Admin"),
                      ));
                    } else {
                      return ListView(
                        padding: EdgeInsets.zero,
                        children: [

                          /// user info display
                          userInfo(context,
                              userData: widget.userData,
                              profilePicture: Hero(
                                  tag: '$username Profile Picture',
                                  child: fetchProfilePicture(
                                      widget.userData['profilePicture'],
                                      widget.userData['pfpType'],
                                      username))),

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
                                      navigateTo: const Leaderboards(),
                                      position: PositionPadding.start),
                                  // Only show tile if user is admin
                                  (rolesSnapshot.data?.docs[0]['tag'] ==
                                      'Admin')
                                      ? actionCard(context,
                                      icon: Icons.admin_panel_settings,
                                      text: "Admin View")
                                      : const SizedBox.shrink(),
                                  // Only show tile if user is admin
                                  (rolesSnapshot.data?.docs[0]['tag'] ==
                                      'Admin')
                                      ? actionCard(context,
                                      icon: Icons.create,
                                      text: "Create Post",
                                      navigateTo: const CreatePost())
                                      : const SizedBox.shrink(),
                                  actionCard(context,
                                      icon: Icons.settings,
                                      text: "Settings",
                                      navigateTo:
                                      SettingsPage(userData: widget.userData),
                                      position: PositionPadding.end),
                                ],
                              ),
                            ),
                          ),

                          /// cards leading to individual sections
                          StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('postGroups')
                                  .where('roles',
                                  arrayContains: rolesSnapshot.data?.docs[0].id)
                                  .snapshots(),
                              builder: (context, postsGroupSnapshot) {
                                if (postsGroupSnapshot.connectionState == ConnectionState.active) {
                                  return ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: postsGroupSnapshot.data?.docs.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return sectionCard(context, widget.userData, postsGroupSnapshot.data?.docs[index]["tag"], postsGroupSnapshot.data?.docs[index].id);
                                      }
                                  );
                                } else {
                                  return const Center(child: CircularProgressIndicator());
                                }
                              }
                          ),
                        ],
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
