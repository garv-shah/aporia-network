// Copyright 2021 The EditableImage Author. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

library editable_image;

import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show Platform;

/// Enum for helping to set edit icon's position.
enum Position {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// A fork of the editable_image package for added flexibility.
///
/// It can be used in profile picture or settings views to edit the image and
/// update them on Firebase.
class EditableImage extends StatelessWidget {
  const EditableImage({
    Key? key,
    required this.onChange,
    this.image,
    this.size,
    this.imageBorder,
    this.widgetDefault,
    this.imageDefault,
    this.imageDefaultColor,
    this.imageDefaultBackgroundColor,
    this.imagePickerTheme,
    this.editIcon,
    this.editIconColor,
    this.editIconBackgroundColor,
    this.editIconBorder,
    this.editIconPosition,
    this.isEditable,
  }) : super(key: key);

  /// A Function to access and override the process on
  /// change of image.
  final Function(Uint8List file) onChange;
  final bool? isEditable;

  /// An Image widget that shows the main profile picture, etc.
  final Image? image;

  /// A variable to determine the size of the EditableImage.
  final double? size;

  /// A BoxBorder to add a border to the main image.
  final Border? imageBorder;

  /// An IconData to set a default icon to be shown when there
  /// is no image.
  final IconData? imageDefault;

  /// A Color to set a default color of the icon to be shown
  /// when there is no image.
  final Color? imageDefaultColor;

  /// A Color to set a default background color of the icon to
  /// be shown when there is no image.
  final Color? imageDefaultBackgroundColor;

  /// A ThemeData to set the theme of the image picker.
  final ThemeData? imagePickerTheme;

  /// An IconData that will be shown at the bottom as a small
  /// edit icon.
  final IconData? editIcon;

  /// A Color to set the default color of the edit icon.
  final Color? editIconColor;

  /// A Color to set default background color of the edit
  /// icon.
  final Color? editIconBackgroundColor;

  final Widget? widgetDefault;

  /// A BoxBorder to add a border to the edit icon.
  final Border? editIconBorder;

  /// A Position to set edit icon's position.
  final Position? editIconPosition;

  /// A method that calls image picker package.
  /// It also calls "onChange" function.
  void _getImage(BuildContext context) async {
    late XFile? profileImage;
    late Uint8List bytes;
    if (kIsWeb) {
      profileImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    } else if (Platform.isMacOS) {
      XTypeGroup typeGroup;
      typeGroup = XTypeGroup(
          label: 'images', extensions: ['jpg', 'png', 'gif', 'jpeg']);

      profileImage = await openFile(acceptedTypeGroups: [typeGroup]);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
                title: const Text("Change Profile Picture"),
                children: <Widget>[
                  SimpleDialogOption(
                    onPressed: () async {
                      profileImage = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);

                      bytes = await profileImage!.readAsBytes();
                      if (bytes.isEmpty) return;

                      onChange(bytes);

                      Navigator.pop(context);
                    },
                    child: const Text('Pick From Gallery'),
                  ),
                  SimpleDialogOption(
                    onPressed: () async {
                      profileImage = await ImagePicker()
                          .pickImage(source: ImageSource.camera);

                      bytes = await profileImage!.readAsBytes();
                      if (bytes.isEmpty) return;

                      onChange(bytes);

                      Navigator.pop(context);
                    },
                    child: const Text('Take A New Picture'),
                  ),
                ]);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          /// Default size of the EditableImage is 140.0
          height: size ?? 140.0,
          width: size ?? 140.0,
          child: Stack(
            fit: StackFit.expand,
            children: [
              /// Builds main image.
              /// For example, profile picture.
              _buildImage(),
              (() {
                if (isEditable == true) {
                  return Align(
                    alignment: _getPosition(),
                    child: InkWell(
                      overlayColor: MaterialStateProperty.all(
                          Colors.transparent),
                      highlightColor: Colors.transparent,

                      /// When edit icon tapped, calls _getImage() method.
                      onTap: () => _getImage(context),

                      /// Builds edit icon.
                      child: _buildIcon(),
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              } ()),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds main image.
  /// For example, profile picture.
  Container _buildImage() {
    return Container(
      decoration: BoxDecoration(
        color: imageDefaultBackgroundColor ?? Colors.transparent,
        border: imageBorder ?? const Border(),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: image ?? widgetDefault ??
            Icon(
              imageDefault ?? Icons.person,
              size: size != null ? (size ?? 140.0) * 0.75 : 105.0,
              color: imageDefaultColor ?? Colors.black87,
            ),
      ),
    );
  }

  /// Returns the edit icon's position based
  /// on editIconPosition variable.
  AlignmentGeometry _getPosition() {
    switch (editIconPosition) {
      case Position.topLeft:
        return Alignment.topLeft;
      case Position.topRight:
        return Alignment.topRight;
      case Position.bottomLeft:
        return Alignment.bottomLeft;
      case Position.bottomRight:
        return Alignment.bottomRight;
      default:
        return Alignment.bottomRight;
    }
  }

  /// Builds edit icon.
  Container _buildIcon() {
    return Container(
      height: size != null ? (size ?? 140.0) * 0.25 : 35.0,
      width: size != null ? (size ?? 140.0) * 0.25 : 35.0,
      decoration: BoxDecoration(
        color: editIconBackgroundColor ?? Colors.white,
        border: editIconBorder ?? const Border(),
        shape: BoxShape.circle,
      ),
      child: Icon(
        editIcon ?? Icons.edit,
        size: size != null ? (size ?? 140.0) * 0.15 : 21.0,
        color: editIconColor ?? Colors.black87,
      ),
    );
  }
}
