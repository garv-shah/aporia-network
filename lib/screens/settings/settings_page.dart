/*
File: settings_page.dart
Description: The settings page for the app
Author: Garv Shah
Created: Tue Jul 19 21:41:22 2022
 */

import 'dart:typed_data';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:aporia_app/screens/home_page.dart';
import 'package:aporia_app/widgets/forks/editable_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:aporia_app/utils/config/config.dart' as config;
import 'package:aporia_app/utils/config/abilities.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:io' show Platform;

import '../../utils/config/config.dart';
import '../../widgets/lesson_countdown.dart';

/**
 * The following section includes functions for the settings page.
 */

/// Creates card buttons within settings, that lead to a url.
Widget settingsCard(BuildContext context,
    {required String text, Uri? url, Function? onTap}) {
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
          if (onTap == null) {
            if (url != null) {
              launchUrl(url);
            }
          } else {
            onTap.call();
          }
        },
        child: SizedBox(
          height: 60,
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(text, style: Theme.of(context).textTheme.titleLarge)
            ],
          )),
        ),
      ),
    ),
  );
}

/// extension to add .capitalise to end of string type
extension StringExtension on String {
  String capitalise() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

/**
 * The following section includes the actual settings page.
 */

/// This is the settings page.
class SettingsPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final bool isAdmin;
  final List<String> userRoles;

  const SettingsPage({Key? key, required this.userData, required this.isAdmin, required this.userRoles}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // The region cloud functions should be invoked from.
  final functions =
      FirebaseFunctions.instanceFor(region: 'australia-southeast1');

  // The variable for the selected profile picture.
  Uint8List? pfpFile;

  /// The function to update profile picture on selection.
  void pfpUpdate(Uint8List file) async {
    // Sets the pfp file to the new file locally first so tha the user sees an
    // immediate change before uploading.
    pfpFile = file;
    setState(() {});

    // Storage and Firestore instances.
    final storage = FirebaseStorage.instance;
    CollectionReference userInfo =
        FirebaseFirestore.instance.collection('userInfo');

    // Sets the storage path to a folder of the user's UID inside the
    // profilePictures folder, followed by the file type detected by Mime.
    // For example, if I uploaded a png, it would be
    // profilePictures/123456789/profile.png
    Reference ref = storage.ref(
        'profilePictures/${FirebaseAuth.instance.currentUser?.uid}/profile.${lookupMimeType('', headerBytes: pfpFile)!.split('/')[1]}');

    // Creates a metadata object from the raw bytes of the image,
    // and then sets it to the reference above
    SettableMetadata metadata =
        SettableMetadata(contentType: lookupMimeType('', headerBytes: pfpFile));

    await ref.putData(pfpFile!, metadata);

    // Gets the URL of this newly created object
    var downloadUrl = await ref.getDownloadURL();

    // Sets the newly created URL and file type to the Firestore document.
    userInfo.doc(FirebaseAuth.instance.currentUser?.uid).update(
        {'profilePicture': downloadUrl, 'pfpType': metadata.contentType});

    // Also calls the cloud function to update profile picture, since the user
    // can't access some directories where this should be allowed.
    await functions
        .httpsCallable('updatePfp')
        .call({'profilePicture': downloadUrl, 'pfpType': metadata.contentType});
  }

  @override
  Widget build(BuildContext context) {
    Widget about = Scaffold(
      appBar: AppBar(
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back,
                  color:
                  Theme.of(context).primaryColorLight)),
          backgroundColor: Colors.transparent),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
          child: Center(
            child: ListView(
              children: [
                const SizedBox(height: 60,),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(36),
                    child: SizedBox(
                      height: 300,
                      width: 300,
                      child: SvgPicture.asset('assets/app_icon.svg',
                          semanticsLabel: 'app logo'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, packageInfo) {
                        if (packageInfo.connectionState == ConnectionState.done) {
                          try {
                            return Text(
                                "Platform: ${Platform.operatingSystem} | App Version: ${packageInfo.data!.version} (${packageInfo.data!.buildNumber})");
                          } catch (err) {
                            try {
                              if (packageInfo.data!.buildNumber == "") {
                                return Text(
                                    "Platform: N/A | App Version: ${packageInfo.data!.version}");
                              }
                              return Text(
                                  "Platform: N/A | App Version: ${packageInfo.data!.version} (${packageInfo.data!.buildNumber})");
                            } catch (err) {
                              return const Text(
                                  "Platform: N/A | App Version: N/A)");
                            }
                          }
                        }
                        return const Text("");
                      }),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                const Padding(
                  padding:  EdgeInsets.fromLTRB(22, 10, 22, 10),
                  child:  Text(
                    config.detailedName,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding:  const EdgeInsets.fromLTRB(22, 10, 22, 20),
                  child:  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Powered by ',
                          style: TextStyle(
                              color:
                              Theme.of(context).primaryColorLight),
                        ),
                        TextSpan(
                          text: 'Aporia',
                          style: const TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrlString('https://github.com/garv-shah/aporia-network');
                            },
                        ),
                        TextSpan(
                          text: ', an open-source education platform created by ',
                          style: TextStyle(
                              color:
                              Theme.of(context).primaryColorLight),
                        ),
                        TextSpan(
                          text: 'Garv Shah',
                          style: const TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrlString('https://garv-shah.github.io/');
                            },
                        ),
                        TextSpan(
                          text: '.',
                          style: TextStyle(
                              color:
                              Theme.of(context).primaryColorLight),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 85,
                  width: 85,
                  child: SvgPicture.asset('assets/aporia_icon.svg',
                      semanticsLabel: 'aporia logo'),
                ),
              ],
            ),
          )),
    );

    String username = widget.userData['username'] ?? "...";
    late List<DocumentSnapshot> userInfoList;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).primaryColorLight),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      // Similar to before, gets the amount of points a user has!
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('publicProfile')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, publicProfileSnapshot) {
            Map<String, dynamic>? profileMap =
                publicProfileSnapshot.data?.data() as Map<String, dynamic>?;
            double experience = (profileMap?['experience'] ?? 0).toDouble();
            Map<String, dynamic> levelMap = calculateLevel(experience);

            Map<int, Map<String, String>> subText = {};

            // if our user is a volunteer, show different text
            if (getComputedAbilities(widget.userRoles).contains('volunteering')) {
              int volunteerHours = ((profileMap?['processedVolunteerHours'] ?? profileMap?['volunteerHours']) ?? 0).toInt();
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

            return Center(
              child: SizedBox(
                width: widget.isAdmin ? 760 : 600,
                child: ListView(
                  children: [
                    // profile picture
                    Padding(
                      padding: const EdgeInsets.all(26.0),
                      child: SizedBox(
                        height: 175,
                        child: decoratedProfilePicture(context,
                            profilePicture: EditableImage(
                              isEditable: true,
                              onChange: (Uint8List file) => pfpUpdate(file),
                              // If the pfp file exists, show it, if not, s
                              // tay on the default image.
                              image: pfpFile,
                              widgetDefault: Hero(
                                tag: '$username Profile Picture',
                                child: fetchProfilePicture(
                                    widget.userData['profilePicture'],
                                    widget.userData['pfpType'],
                                    username,
                                    padding: true,
                                    customPadding: getComputedAbilities(widget.userRoles).contains('points') ? 15 : 0,
                                ),
                              ),
                              editIconBorder:
                                  Border.all(color: Colors.black87, width: 2.0),
                              size: 175,
                            ),
                            userRoles: widget.userRoles,
                            experience: experience,
                            levelMap: levelMap),
                      ),
                    ),
                    // username
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(username,
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Theme.of(context).primaryColorLight,
                                fontWeight: FontWeight.w300)),
                        IconButton(
                            onPressed: () async {
                              // Dialog to get new username.
                              final newUsername = await showTextInputDialog(
                                style: AdaptiveStyle.material,
                                context: context,
                                textFields: [
                                  DialogTextField(
                                    hintText: 'Username',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "A username is required";
                                      }

                                      if (value.length > 12) {
                                        return "Cannot exceed 12 characters";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                                title: 'Change Username',
                                autoSubmit: true,
                              );

                              // If username is not empty (which it shouldn't be),
                              // go back to homepage and send it to the server.
                              if (newUsername != null) {
                                String username = newUsername.first;

                                // username's that are the same as the one the user entered
                                userInfoList = (await FirebaseFirestore.instance.collection('userInfo')
                                    .where("lowerUsername",
                                    isEqualTo: username.toLowerCase())
                                    .get())
                                    .docs;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      userInfoList.isEmpty ? "Updating Username! (this might take a second)" : "Sorry this name is already taken, please try again!",
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColorLight),
                                    ),
                                    backgroundColor:
                                        Theme.of(context).scaffoldBackgroundColor,
                                  ),
                                );

                                if (userInfoList.isEmpty) {
                                  Navigator.pop(context);

                                  await functions
                                      .httpsCallable('updateUsername')
                                      .call({'username': newUsername.first, 'appID': config.appID});
                                }
                              }
                            },
                            icon: const Icon(Icons.edit))
                      ],
                    ),
                    // experience card
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(subText[1]?['title'] ?? 'error',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                16, 0, 16, 0),
                                            child: (profileMap?['volunteer'] == true && subText[1]?['util'] == 'lessonCountdown')
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
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                        height: 35,
                                        child: VerticalDivider(
                                            thickness: 2,
                                            color: Theme.of(context)
                                                .primaryColorLight)),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(subText[2]?['title'] ?? 'error',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                16, 0, 16, 0),
                                            child: Text(
                                              // If level if infinity, render text
                                              // to say so, if not get the positive
                                              // value and show how far to next level
                                              subText[2]?['text'] ?? 'error',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                // Displays the user's role
                                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                    stream: FirebaseFirestore.instance
                                        .collection('roles')
                                        // Roles that contain the user's UID
                                        .where('members',
                                            arrayContains: FirebaseAuth
                                                .instance.currentUser?.uid)
                                        .snapshots(),
                                    builder: (context, rolesSnapshot) {
                                      if (rolesSnapshot.connectionState ==
                                          ConnectionState.active) {
                                        try {
                                          return Text(
                                            // Similar to before, this gets each of
                                            // the roles the user is in, gets its
                                            // tag, puts that into a list and
                                            // returns a string of that
                                              rolesSnapshot.data?.docs
                                                      .map((doc) => configString[appID]['roles'][doc.id]['name'] ?? doc['tag'])
                                                      .toList()
                                                      .join(', ') ??
                                                  "Error: couldn't map roles",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium);
                                        } on StateError {
                                          return Text(
                                              'Error: Firestore key not found!',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium);
                                        }
                                      } else {
                                        return Text("Loading...",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium);
                                      }
                                    })
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
                                // Gets the current theme from AdaptiveTheme.
                                ValueListenableBuilder(
                                  valueListenable:
                                      AdaptiveTheme.of(context).modeChangeNotifier,
                                  builder: (_, mode, child) {
                                    // update your UI
                                    return RichText(
                                      text: TextSpan(
                                        text: 'Theme: ',
                                        style:
                                            Theme.of(context).textTheme.titleLarge,
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: mode
                                                  .toString()
                                                  .split(".")[1]
                                                  .capitalise(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      fontWeight: FontWeight.w300)),
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
                    getComputedAbilities(widget.userRoles).contains('volunteering') ? settingsCard(context,
                        text: "Generate Certificate",
                        onTap: () {
                          final snackBar = SnackBar(
                            content: Text(
                              "Generating a certificate, hold tight!",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .primaryColorLight),
                            ),
                            backgroundColor: Theme.of(context)
                                .scaffoldBackgroundColor,
                          );
                          // Find the Scaffold in the widget tree and use it to show a SnackBar.
                          ScaffoldMessenger.of(context)
                              .showSnackBar(snackBar);

                          functions
                              .httpsCallable('generateCertificate')
                              .call().then((_) {
                            final storageRef = FirebaseStorage.instance.ref();
                            final certificateRef = storageRef.child('certificates/${FirebaseAuth.instance.currentUser?.uid}/certificate.pdf');
                            certificateRef.getDownloadURL().then((url) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                  content: Text(
                                    "Certificate Generated!",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColorLight),
                                  ),
                                  backgroundColor: Theme.of(context)
                                      .scaffoldBackgroundColor,
                                )
                              );

                              // go to download url
                              launchUrl(Uri.parse(url));
                            });
                          })
                          .catchError((err) {
                            FirebaseFunctionsException error = err;
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                      title: const Text('Error while generating certificate'),
                                      content: Text((error.message ?? "We're not sure what the error was, sorry!").toString()),
                                      actions: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .labelLarge,
                                          ),
                                          child: const Text('Okay'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ]);
                                });
                          });
                        }) : const SizedBox.shrink(),
                    settingsCard(context,
                        text: "About",
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => about));
                        }),
                    // Delete Account and Logout Buttons
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
                                  showOkCancelAlertDialog(
                                      okLabel: 'Confirm',
                                      title: 'Delete Account?',
                                      message:
                                      'Are you sure you want to delete your account? This is a permanent action and cannot be undone.',
                                      context: context)
                                      .then((result) {
                                    if (result == OkCancelResult.ok) {
                                      if (FirebaseAuth.instance.currentUser != null) {
                                        FirebaseAuth.instance.currentUser?.delete().then((_) {
                                          Navigator.pop(context);
                                        })
                                            .onError((error, stackTrace) {
                                          final snackBar = SnackBar(
                                            content: Text(
                                              error.toString(),
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorLight),
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                          );
                                          // Find the Scaffold in the widget tree and use it to show a SnackBar.
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                        });
                                      }
                                    }
                                  });
                                },
                                style: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all<Color>(
                                      Colors.white),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(Colors.red),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6.0),
                                          side:
                                              const BorderSide(color: Colors.red))),
                                ),
                                child: const Text('Delete Account'),
                              ),
                            ),
                          ),
                          SizedBox(
                              height: 20,
                              child: VerticalDivider(
                                  thickness: 1,
                                  color: Theme.of(context)
                                      .primaryColorLight
                                      .withAlpha(100))),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: OutlinedButton(
                                onPressed: () {
                                  FirebaseAuth.instance.signOut();
                                  Navigator.pop(context);
                                },
                                style: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all<Color>(
                                      Colors.white),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(Colors.red),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6.0),
                                          side:
                                              const BorderSide(color: Colors.red))),
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
              ),
            );
          }),
    );
  }
}
