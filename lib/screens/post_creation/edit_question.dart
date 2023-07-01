/*
File: edit_questions.dart
Description: The page where individual questions can be edited, via Quill/VisualEditor
Author: Garv Shah
Created: Sat Jul 23 18:21:21 2022
 */

import 'dart:math';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:maths_club/utils/components.dart';
import 'package:maths_club/widgets/text_editor.dart';

/// A function that processes the image and sends a cropped version.
Future<String?> processImage(BuildContext context, Uint8List bytes, String imageName, String fileExtension) async {
  final cropController = CropController();

  double cropDialogSize = min(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height) -
      30;

  Future<String?> imageUrl = Future<String?>.value(null);

  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
            title: const Text("Crop Image"),
            children: <Widget>[
              SizedBox(
                width: cropDialogSize,
                height: cropDialogSize - 140,
                child: Crop(
                    image: bytes,
                    controller: cropController,
                    withCircleUi: true,
                    interactive: true,
                    maskColor: DialogTheme.of(context)
                        .backgroundColor ??
                        Theme.of(context)
                            .dialogBackgroundColor,
                    baseColor: DialogTheme.of(context)
                        .backgroundColor ??
                        Theme.of(context)
                            .dialogBackgroundColor,
                    cornerDotBuilder:
                        (size, edgeAlignment) => DotControl(
                        color: Theme.of(context)
                            .colorScheme
                            .primary),
                    onCropped: (image) {
                      imageUrl = uploadFile(image, imageName, fileExtension, context);
                      Navigator.pop(context);
                    }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(child: SizedBox(height: 5)),
                  ElevatedButton(
                      onPressed: () {
                        imageUrl = uploadFile(bytes, imageName, fileExtension, context);
                        Navigator.pop(context);
                      },
                      child: Text('Skip',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .primaryColorLight))),
                  const Expanded(child: SizedBox(height: 5)),
                  ElevatedButton(
                      onPressed: cropController.crop,
                      child: Text('Crop',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .primaryColorLight))),
                  const Expanded(child: SizedBox(height: 5)),
                ],
              )
            ]);
      });

  return imageUrl;
}

// Uploads files to Firebase and returns the download url
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

typedef DataCallback = void Function(Map<String,dynamic> data);
typedef TexCallback = void Function(String solution);

/// This is the page where questions can be edited.
//ignore: must_be_immutable
class EditQuestion extends StatefulWidget {
  String title;
  final bool solutionType;
  final DataCallback onSave;
  final TexCallback? onSolution;
  final String? solution;
  final Map<String,dynamic> document;
  EditQuestion({Key? key, required this.title, required this.onSave, this.solutionType = false, this.onSolution, required this.document, this.solution}) : super(key: key);

  @override
  State<EditQuestion> createState() => _EditQuestionState();
}

class _EditQuestionState extends State<EditQuestion> {
  late EditorState editorState;
  final FocusNode _focusNode = FocusNode();
  final MathFieldEditingController _mathController = MathFieldEditingController();

  @override
  void initState() {
    editorState = EditorState(document: Document.fromJson(widget.document));

    if ((widget.solution?.isNotEmpty ?? false) && widget.solution != r"\textcolor{#000000}{\cursor}") {
      var json = widget.solution!.replaceAll(
          r"\textcolor{#000000}{\cursor}", '');
      _mathController.updateValue(TeXParser(json).parse());
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MathKeyboardViewInsets(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              header(widget.title, context, fontSize: 20,
                  backArrow: true,
                  customBackLogic: () {
                    widget.onSave(editorState.document.toJson());
                    widget.onSolution?.call(
                        _mathController.root.buildTeXString(
                            cursorColor: Colors.black));
                    Navigator.of(context).pop();
                  }),
              widget.solutionType ? Padding(
                padding: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
                child: MathField(
                  controller: _mathController,
                  variables: const ['x', 'y', 'z'],
                ),
              ) : const SizedBox.shrink(),
              TextEditor(editorState: editorState, padding: const EdgeInsets.all(16.0), desktop: PlatformExtension.isDesktopOrWeb, readOnly: false),
            ],
          ),
        ),
      ),
    );
  }
}
