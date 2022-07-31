import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:maths_club/screens/auth/landing_page.dart';
import 'package:maths_club/screens/create_post_view.dart';
import 'package:maths_club/screens/leaderboards.dart';
import 'package:maths_club/screens/section_page.dart';
import 'package:maths_club/screens/settings_page.dart';
import 'package:maths_club/utils/components.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    Destination? navigateTo,
      Map<String, dynamic>? navigationInput}) {
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
            AuthGate.of(context)?.push(navigateTo, input: navigationInput);
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
Widget sectionCard(BuildContext context, Map<String, dynamic> userData, String title) {
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
                    .headline4
                    ?.copyWith(color: Theme.of(context).primaryColorLight)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: OutlinedButton(
                  onPressed: () {
                    AuthGate.of(context)?.push(Destination.section);
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
    {required double experience, required Widget profilePicture}) {
  return SleekCircularSlider(
    appearance: CircularSliderAppearance(
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
    min: 0,
    max: 4000,
    initialValue: experience,
  );
}

/// Creates card with a summary of a user's information.
Widget userInfo(BuildContext context,
    {required Map<String, dynamic> userData,
    required String level,
    required double experience,
    required Widget profilePicture}) {
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
          AuthGate.of(context)?.push(Destination.settings, input: {'level': '3', 'experience': 2418.0, 'role': 'Admin'});
        },
        child: SizedBox(
          height: 175,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 6.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userData['username'],
                          style: Theme.of(context).textTheme.headline4?.copyWith(
                              color: Theme.of(context).primaryColorLight)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Level',
                              style: Theme.of(context).textTheme.subtitle1),
                          Text(
                            level,
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                ?.copyWith(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Experience',
                              style: Theme.of(context).textTheme.subtitle1),
                          Text(
                            "${experience.toInt()}/4000",
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                ?.copyWith(
                                color: Theme.of(context).colorScheme.primary),
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
                          experience: experience,
                          profilePicture: profilePicture)),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget fetchProfilePicture(String? profilePicture, String? username, {bool padding = true}) {
  String imageUrl = profilePicture ?? "https://avatars.dicebear.com/api/avataaars/$username.svg";

  if (imageUrl.isEmpty) {
    return LayoutBuilder(
        builder: (BuildContext context,
            BoxConstraints constraints) {
          return Center(
            child: UserAvatar(size: padding ? constraints.maxHeight - (padding ? 10 : 0) : null),
          );
        }
    );
  } else if (imageUrl.split('.').last == 'svg') {
    return Center(
      child: Padding(
        padding: padding ? const EdgeInsets.all(15.0) : EdgeInsets.zero,
        child: ClipOval(
          child: SvgPicture.network(
            imageUrl,
            semanticsLabel: '$username profile picture',
            placeholderBuilder: (BuildContext context) => const SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  } else {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) =>
          LayoutBuilder(
              builder: (BuildContext context,
                  BoxConstraints constraints) {
                return Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: imageProvider,
                    radius: constraints.maxWidth / 2 - (padding ? 15 : 0),
                  ),
                );
              }
          ),
      progressIndicatorBuilder: (context, url,
          downloadProgress) =>
          Center(
            child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(value: downloadProgress
                  .progress),
            ),
          ),
      errorWidget: (context, url, error) =>
          LayoutBuilder(
              builder: (BuildContext context,
                  BoxConstraints constraints) {
                return Center(
                  child: UserAvatar(size: constraints.maxHeight - (padding ? 10 : 0)),
                );
              }
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
                userInfo(context,
                    userData: widget.userData,
                    level: "3",
                    experience: 2418,
                    profilePicture: fetchProfilePicture(widget.userData['profilePicture'], username)),

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
                            navigateTo: Destination.leaderboards,
                            position: PositionPadding.start),
                        actionCard(context,
                            icon: Icons.admin_panel_settings,
                            text: "Admin View"),
                        actionCard(context,
                            icon: Icons.create,
                            text: "Create Post",
                            navigateTo: Destination.createPost),
                        actionCard(context,
                            icon: Icons.settings,
                            text: "Settings",
                            navigateTo: Destination.settings,
                            navigationInput: {'level': '3', 'experience': 2418.0, 'role': 'Admin'},
                            position: PositionPadding.end),
                      ],
                    ),
                  ),
                ),

                /// cards leading to individual sections
                sectionCard(context, widget.userData, "Junior"),
                sectionCard(context, widget.userData, "Senior"),
              ],
            ),
          )
        ],
      ),
    );
  }
}
