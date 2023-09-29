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
  final Map<String, dynamic>? solutionType;
  final DataCallback onSave;
  final TexCallback? onSolution;
  final String? solution;
  final Map<String, dynamic>? document;
  EditQuestion(
      {Key? key,
      required this.title,
      required this.onSave,
      this.solutionType,
      this.onSolution,
      required this.document,
      this.solution})
      : super(key: key);

  @override
  State<EditQuestion> createState() => _EditQuestionState();
}

class _EditQuestionState extends State<EditQuestion> {
  late EditorState editorState;
  final MathFieldEditingController _mathController =
      MathFieldEditingController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    editorState = widget.document != null
        ? EditorState(document: Document.fromJson(widget.document!))
        : EditorState.blank(withInitialText: true);

    if ((widget.solution?.isNotEmpty ?? false) && widget.solution != r"\textcolor{#000000}{\cursor}") {
      String solution = widget.solution!.replaceAll(r"\textcolor{#000000}{\cursor}", '');
      if (widget.solutionType?['maths_mode'] == true) {
        _mathController.updateValue(TeXParser(solution).parse());
      } else {
        _textController.text = solution;
      }
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
                if (widget.solutionType != null) {
                  if (widget.solutionType?['maths_mode'] == true) {
                    widget.onSolution?.call(_mathController.root
                        .buildTeXString(cursorColor: Colors.black));
                  } else {
                    widget.onSolution?.call(_textController.text);
                  }
                }
                Navigator.of(context).pop();
              }),
              if (widget.solutionType != null)
                (() {
                  if (widget.solutionType?['maths_mode'] == true) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(64.0, 8.0, 64.0, 8.0),
                      child: MathField(
                        controller: _mathController,
                        variables: const ['x', 'y', 'z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w'],
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(64.0, 8.0, 64.0, 8.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter the solution',
                        ),
                        controller: _textController,
                      ),
                    );
                  }
                }())
              else
                const SizedBox.shrink(),
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
