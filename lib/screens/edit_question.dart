import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:maths_club/utils/universal_ui/universal_ui.dart';

import '../utils/components.dart';


/**
 * The following section includes the actual home page.
 */

/// This is the main home page leading to other pages.

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
                embedBuilder: defaultEmbedBuilderWeb,
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
