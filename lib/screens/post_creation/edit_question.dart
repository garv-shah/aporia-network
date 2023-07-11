/*
File: edit_questions.dart
Description: The page where individual questions can be edited, via Quill/VisualEditor
Author: Garv Shah
Created: Sat Jul 23 18:21:21 2022
 */

import 'package:flutter/material.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:aporia_app/utils/components.dart';
import 'package:aporia_app/widgets/text_editor.dart';

typedef DataCallback = void Function(Map<String, dynamic> data);
typedef TexCallback = void Function(String solution);

/// This is the page where questions can be edited.
//ignore: must_be_immutable
class EditQuestion extends StatefulWidget {
  String title;
  final bool solutionType;
  final DataCallback onSave;
  final TexCallback? onSolution;
  final String? solution;
  final Map<String, dynamic> document;
  EditQuestion(
      {Key? key,
      required this.title,
      required this.onSave,
      this.solutionType = false,
      this.onSolution,
      required this.document,
      this.solution})
      : super(key: key);

  @override
  State<EditQuestion> createState() => _EditQuestionState();
}

class _EditQuestionState extends State<EditQuestion> {
  late EditorState editorState;
  final FocusNode _focusNode = FocusNode();
  final MathFieldEditingController _mathController =
      MathFieldEditingController();

  @override
  void initState() {
    editorState = EditorState(document: Document.fromJson(widget.document));

    if ((widget.solution?.isNotEmpty ?? false) &&
        widget.solution != r"\textcolor{#000000}{\cursor}") {
      var json =
          widget.solution!.replaceAll(r"\textcolor{#000000}{\cursor}", '');
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
            mainAxisSize: MainAxisSize.min,
            children: [
              header(widget.title, context, fontSize: 20, backArrow: true,
                  customBackLogic: () {
                widget.onSave(editorState.document.toJson());
                widget.onSolution?.call(_mathController.root
                    .buildTeXString(cursorColor: Colors.black));
                Navigator.of(context).pop();
              }),
              widget.solutionType
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
                      child: MathField(
                        controller: _mathController,
                        variables: const ['x', 'y', 'z'],
                      ),
                    )
                  : const SizedBox.shrink(),
              TextEditor(
                  editorState: editorState,
                  padding: const EdgeInsets.all(16.0),
                  desktop: PlatformExtension.isDesktopOrWeb,
                  readOnly: false),
            ],
          ),
        ),
      ),
    );
  }
}
