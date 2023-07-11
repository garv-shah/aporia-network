// Uploads files to Firebase and returns the download url
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

Future<String?> uploadFile(Uint8List file, String name, String fileExtension, BuildContext context) async {
  // Check if the file is too large
  int size = file.lengthInBytes;
  // Checks if the file is above 10mb
  bool tooBig = size > 10000000;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        tooBig ? "Files cannot be larger than 10mb!" : "Uploading file!",
        style: TextStyle(
            color:
            Theme.of(context).primaryColorLight),
      ),
      backgroundColor:
      Theme.of(context).scaffoldBackgroundColor,
    ),
  );

  if (!tooBig) {
    // Storage instance.
    final storage = FirebaseStorage.instance;

    // Sets the storage path to a folder of the user's UID inside the
    // userMedia folder, followed by the file type detected by Mime.
    // For example, if I uploaded a png, it would be
    // userMedia/123456789/image-123456789.png
    Reference ref = storage.ref(
        'userMedia/${FirebaseAuth.instance.currentUser
            ?.uid}/$name-${const Uuid().v4()}$fileExtension');

    // Creates a metadata object from the raw bytes of the image,
    // and then sets it to the reference above
    SettableMetadata metadata =
    SettableMetadata(contentType: lookupMimeType('', headerBytes: file));

    await ref.putData(file, metadata);

    // Gets the URL of this newly created object
    var downloadUrl = ref.getDownloadURL();

    return downloadUrl;
  } else {
    return null;
  }
}
