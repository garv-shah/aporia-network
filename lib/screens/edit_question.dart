import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          header(widget.title, context, fontSize: 20, backArrow: true),
          QuillToolbar.basic(
            controller: _controller,
            showAlignmentButtons: true,
            iconTheme: QuillIconTheme(
              iconSelectedFillColor: Theme.of(context).colorScheme.primary,
              iconSelectedColor: Theme.of(context).primaryColorLight,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: QuillEditor.basic(
                controller: _controller,
                readOnly: false, // true for view only mode
              ),
            ),
          )
        ],
      ),
    );
  }
}
