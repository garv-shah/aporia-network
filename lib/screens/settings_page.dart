import 'dart:typed_data';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:maths_club/screens/home_page.dart';
import 'package:maths_club/widgets/forks/editable_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

/**
 * The following section includes functions for the settings page.
 */

/// Creates card buttons within settings.
Widget settingsCard(BuildContext context, {required String text, required Uri url}) {
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
        onTap: () {
          launchUrl(url);
        },
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

/**
 * The following section includes the actual settings page.
 */

/// This is the main home page leading to other pages.
class SettingsPage extends StatefulWidget {
  String level;
  double experience;
  String role;
  final Map<String, dynamic> userData;

  SettingsPage(
      {Key? key,
      required this.level,
      required this.experience,
      required this.role,
      required this.userData})
      : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    String username = widget.userData['username'] ?? "...";

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
      body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(26.0),
              child: EditableImage(
                isEditable: true,
                onChange: (Uint8List file) {},
                widgetDefault: fetchProfilePicture(widget.userData['profilePicture'], username, padding: false),
                editIconBorder: Border.all(color: Colors.black87, width: 2.0),
                size: 175,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(username,
                    style: Theme.of(context).textTheme.headline2?.copyWith(
                        color: Theme.of(context).primaryColorLight,
                        fontWeight: FontWeight.w300)),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1),
                                  Text(
                                    widget.level,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                height: 35,
                                child: VerticalDivider(
                                    thickness: 2,
                                    color:
                                        Theme.of(context).primaryColorLight)),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Experience',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1),
                                  Text(
                                    "${widget.experience.toInt()}/4000",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(widget.role, style: Theme.of(context).textTheme.subtitle1)
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // This is the theme toggle.
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
              child: Card(
                elevation: 5,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  splashColor:
                      Theme.of(context).colorScheme.primary.withAlpha(40),
                  highlightColor:
                      Theme.of(context).colorScheme.primary.withAlpha(20),
                  onTap: () {
                    AdaptiveTheme.of(context).toggleThemeMode();
                  },
                  child: SizedBox(
                    height: 60,
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ValueListenableBuilder(
                          valueListenable:
                              AdaptiveTheme.of(context).modeChangeNotifier,
                          builder: (_, mode, child) {
                            // update your UI
                            return RichText(
                              text: TextSpan(
                                text: 'Theme: ',
                                style: Theme.of(context).textTheme.headline6,
                                children: <TextSpan>[
                                  TextSpan(text: mode.toString().split(".")[1]
                                      .capitalize(), style: Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w300)),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    )),
                  ),
                ),
              ),
            ),
            settingsCard(context, text: "About", url: Uri.parse("https://garv-shah.github.io")),
            settingsCard(context, text: "GitHub", url: Uri.parse("https://github.com/cgs-math/app")),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: OutlinedButton(
                          onPressed: () async {
                            if (FirebaseAuth.instance.currentUser != null) {
                              await FirebaseAuth.instance.currentUser?.delete().then((value) {
                                Navigator.pop(context);
                              });
                            }
                          },
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                    side: const BorderSide(color: Colors.red)
                                )
                            ),
                          ),
                          child: const Text('Delete Account'),
                        ),
                    ),
                  ),
                  SizedBox(
                      height: 20,
                      child: VerticalDivider(
                          thickness: 1,
                          color:
                          Theme.of(context).primaryColorLight.withAlpha(100))),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: OutlinedButton(
                        onPressed: () {
                          FirebaseAuth.instance.signOut().then((value) {
                            Navigator.pop(context);
                          });
                        },
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                  side: const BorderSide(color: Colors.red)
                              )
                          ),
                        ),
                        child: const Text('Logout'),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
    );
  }
}
