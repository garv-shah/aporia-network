/*
File: manage_user_page.dart
Description: The page where users can be managed
Author: Garv Shah
Created: Tue Jul 19 21:41:22 2022
 */

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:aporia_app/screens/home_page.dart';
import 'package:aporia_app/screens/section_views/admin_view/user_list_view.dart';
import 'package:aporia_app/widgets/forks/editable_image.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';

/**
 * The following section includes functions for the settings page.
 */

/// extension to add .capitalise to end of string type
extension StringExtension on String {
  String capitalise() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

/**
 * The following section includes the actual settings page.
 */

/// This is the page to manage an individual user.
class ManageUserPage extends StatefulWidget {
  final UserModel userInfo;

  const ManageUserPage({Key? key, required this.userInfo}) : super(key: key);

  @override
  State<ManageUserPage> createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {
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
        'profilePictures/${widget.userInfo.id}/profile.${lookupMimeType('', headerBytes: pfpFile)!.split('/')[1]}');

    // Creates a metadata object from the raw bytes of the image,
    // and then sets it to the reference above
    SettableMetadata metadata =
        SettableMetadata(contentType: lookupMimeType('', headerBytes: pfpFile));

    await ref.putData(pfpFile!, metadata);

    // Gets the URL of this newly created object
    var downloadUrl = await ref.getDownloadURL();

    // Sets the newly created URL and file type to the Firestore document.
    userInfo.doc(widget.userInfo.id).update(
        {'profilePicture': downloadUrl, 'pfpType': metadata.contentType});

    // Also calls the cloud function to update profile picture, since the user
    // can't access some directories where this should be allowed.
    await functions
        .httpsCallable('updatePfp')
        .call({'profilePicture': downloadUrl, 'pfpType': metadata.contentType, 'uid': widget.userInfo.id});
  }

  @override
  Widget build(BuildContext context) {
    late List<DocumentSnapshot> userInfoList;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Manage ${widget.userInfo.username}",
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
      body: ListView(
        children: [
          // profile picture
          Padding(
            padding: const EdgeInsets.all(26.0),
            child: SizedBox(
              height: 175,
              child: EditableImage(
                isEditable: true,
                onChange: (Uint8List file) => pfpUpdate(file),
                // If the pfp file exists, show it, if not, s
                // tay on the default image.
                image: pfpFile,
                widgetDefault: Hero(
                  tag: '${widget.userInfo.username} Profile Picture',
                  child: fetchProfilePicture(
                      widget.userInfo.profilePicture,
                      widget.userInfo.pfpType,
                      widget.userInfo.username),
                ),
                editIconBorder:
                Border.all(color: Colors.black87, width: 2.0),
                size: 175,
              ),
            ),
          ),
          // username
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.userInfo.username,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                      color: Theme.of(context)
                          .primaryColorLight)),
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
                            .call({'username': newUsername.first, 'uid': widget.userInfo.id});
                      }
                    }
                  },
                  icon: const Icon(Icons.edit))
            ],
          ),
          // Role + Company? Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('roles')
                // Roles that contain the user's UID
                    .where('members',
                    arrayContains: widget.userInfo.id)
                    .snapshots(),
                builder: (context, rolesSnapshot) {
                  if (rolesSnapshot.connectionState ==
                      ConnectionState.active) {
                    return Column(
                      children: [
                        Card(
                          elevation: 5,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Center(
                                child: (() {
                                  try {
                                    return Text(
                                      // Similar to before, this gets each of
                                      // the roles the user is in, gets its
                                      // tag, puts that into a list and
                                      // returns a string of that
                                        rolesSnapshot.data?.docs
                                            .map((doc) => doc['tag'])
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
                                } ())
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
