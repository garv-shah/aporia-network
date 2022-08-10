/*
File: edit_questions.dart
Description: The page where individual questions can be edited, via Quill/VisualEditor
Author: Garv Shah
Created: Sat Jul 23 18:21:21 2022
 */

import 'package:flutter/material.dart';
import 'package:visual_editor/visual-editor.dart';
import 'package:math_keyboard/math_keyboard.dart';

import '../../utils/components.dart';

typedef DataCallback = void Function(List<dynamic> data);
typedef TexCallback = void Function(String solution);

/// This is the page where questions can be edited.
//ignore: must_be_immutable
class EditQuestion extends StatefulWidget {
  String title;
  final bool solutionType;
  final DataCallback onSave;
  final TexCallback? onSolution;
  final String? solution;
  final List<dynamic> document;
  EditQuestion({Key? key, required this.title, required this.onSave, this.solutionType = false, this.onSolution, required this.document, this.solution}) : super(key: key);

  @override
  State<EditQuestion> createState() => _EditQuestionState();
}

class _EditQuestionState extends State<EditQuestion> {
  late EditorController _controller;
  final FocusNode _focusNode = FocusNode();
  final MathFieldEditingController _mathController = MathFieldEditingController();

  @override
  void initState() {
    _controller = EditorController(document: DocumentM.fromJson(widget.document));

    if (widget.solution != null && widget.solution != r"\textcolor{#000000}{\cursor}") {
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
              header(widget.title, context, fontSize: 20, backArrow: true, customBackLogic: () {
                widget.onSave(_controller.document.toDelta().toJson());
                widget.onSolution?.call(_mathController.root.buildTeXString(cursorColor: Colors.black));
                Navigator.of(context).pop();
              }),
              widget.solutionType ? Padding(
                padding: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
                child: MathField(
                  controller: _mathController,
                  variables: const ['x', 'y', 'z'],
                ),
              ) : const SizedBox.shrink(),
              Expanded(
                child: VisualEditor(
                  scrollController: ScrollController(),
                  focusNode: _focusNode,
                  controller: _controller,
                  config: EditorConfigM(
                    scrollable: true,
                    autoFocus: true,
                    expands: false,
                    padding: const EdgeInsets.all(16.0),
                    readOnly: false,
                    keyboardAppearance: Theme.of(context).brightness,
                  ),
                ),
              ),
              EditorToolbar.basic(
                controller: _controller,
                showAlignmentButtons: true,
                multiRowsDisplay: false,
                iconTheme: EditorIconThemeM(
                  iconSelectedFillColor: Theme.of(context).colorScheme.primary,
                  iconSelectedColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
