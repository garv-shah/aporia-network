import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:maths_club/screens/home_page.dart';
import 'package:maths_club/widgets/editable_image.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

/**
 * The following section includes functions for the home page.
 */

/// Creates card buttons within settings.
Widget settingsCard(BuildContext context,
    {required String text}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
    child: Card(
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        splashColor: Theme.of(context).colorScheme.primary.withAlpha(40),
        highlightColor: Theme.of(context).colorScheme.primary.withAlpha(20),
        onTap: () {},
        child: SizedBox(
          height: 60,
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(text, style: Theme.of(context).textTheme.headline6)
                ],
              )),
        ),
      ),
    ),
  );
}

/**
 * The following section includes the actual home page.
 */

/// This is the main home page leading to other pages.
class SettingsPage extends StatelessWidget {
  String username;
  String level;
  double experience;
  String role;
  ImageProvider<Object>? profilePicture;

  SettingsPage(
      {Key? key,
      required this.username,
      required this.level,
      required this.experience,
      required this.role,
      this.profilePicture})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: Theme.of(context).textTheme.headline6,
        ),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).primaryColorLight),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Center(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(26.0),
              child: EditableImage(
                isEditable: true,
                onChange: (Uint8List file) {},
                widgetDefault: userRings(context,
                    experience: experience, profilePicture: profilePicture),
                editIconBorder: Border.all(color: Colors.black87, width: 2.0),
                size: 175,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(username, style: Theme.of(context).textTheme.headline2?.copyWith(color: Theme.of(context).primaryColorLight, fontWeight: FontWeight.w300)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit))
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 5,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: SizedBox(
                  height: 110,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                            ),
                            SizedBox(height: 35, child: VerticalDivider(thickness: 2, color: Theme.of(context).primaryColorLight)),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                            ),
                          ],
                        ),
                        Text(role, style: Theme.of(context).textTheme.subtitle1)
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            settingsCard(context, text: "Theme"),
            settingsCard(context, text: "About"),
            settingsCard(context, text: "GitHub"),
          ],
        ),
      ),
    );
  }
}
