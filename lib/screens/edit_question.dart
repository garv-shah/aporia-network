import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../utils/components.dart';


/// This is the page where questions can be edited.
//ignore: must_be_immutable
class EditQuestion extends StatefulWidget {
  String title;
  EditQuestion({Key? key, required this.title}) : super(key: key);

  @override
  State<EditQuestion> createState() => _EditQuestionState();
}

class _EditQuestionState extends State<EditQuestion> {
  final QuillController _controller = QuillController.basic();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            header(widget.title, context, fontSize: 20, backArrow: true),
            Expanded(
              child: QuillEditor(
                scrollController: ScrollController(),
                scrollable: true,
                focusNode: _focusNode,
                autoFocus: true,
                expands: false,
                padding: const EdgeInsets.all(16.0),
                controller: _controller,
                readOnly: false,
                keyboardAppearance: Theme.of(context).brightness,
              ),
            ),
            QuillToolbar.basic(
              controller: _controller,
              showAlignmentButtons: true,
              multiRowsDisplay: false,
              iconTheme: QuillIconTheme(
                iconSelectedFillColor: Theme.of(context).colorScheme.primary,
                iconSelectedColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
