import 'package:flutter/material.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:visual_editor/controller/controllers/editor-controller.dart';
import 'package:visual_editor/documents/models/document.model.dart';
import 'package:visual_editor/editor/models/editor-cfg.model.dart';
import 'package:visual_editor/main.dart';

import '../../utils/components.dart';


/**
 * The following section includes functions for the post page.
 */



/**
 * The following section includes the actual PostView page.
 */

/// This is the view where new posts can be created.
class PostView extends StatefulWidget {
  Map<String, dynamic> data;
  PostView({Key? key, required this.data}) : super(key: key);

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: widget.data['questionData'].keys.length + 1,
        itemBuilder: (BuildContext context, int index) {
          // If index is the first, then create header
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 32.0, 8.0, 32.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: Theme.of(context).primaryColorLight),
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                      Text(
                        widget.data['Title'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 38),
                      ),
                      // Extra sized box to make the title in the center
                      const SizedBox(height: 48, width: 48)
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                    child: Text(widget.data['Description'], textAlign: TextAlign.center,),
                  )),
                ],
              ),
            );
          } else {
            Map<String, dynamic> questionData = widget.data['questionData']['Question $index'];
            return Padding(
              padding: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Question $index", style: Theme.of(context).textTheme.headline4?.copyWith(color: Theme.of(context).primaryColorLight)),
                  VisualEditor(
                    scrollController: ScrollController(),
                    focusNode: FocusNode(),
                    controller: EditorController(document: DocumentM.fromJson(questionData['Question'])),
                    config: EditorConfigM(
                      scrollable: true,
                      autoFocus: true,
                      expands: false,
                      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                      readOnly: true,
                      keyboardAppearance: Theme.of(context).brightness,
                    ),
                  ),
                  Row(
                    children: [
                      (questionData['Hints'] != null) ? Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                        child: OutlinedButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SimpleDialog(
                                        title: const Text("Hints"),
                                        children: <Widget>[
                                          VisualEditor(
                                            scrollController: ScrollController(),
                                            focusNode: FocusNode(),
                                            controller: EditorController(document: DocumentM.fromJson(questionData['Hints'])),
                                            config: EditorConfigM(
                                              scrollable: true,
                                              autoFocus: true,
                                              expands: false,
                                              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 12.0),
                                              readOnly: true,
                                              keyboardAppearance: Theme.of(context).brightness,
                                            ),
                                          )
                                        ]);
                                  });
                            },
                            style: OutlinedButton.styleFrom(
                                primary: Theme.of(context).colorScheme.primary,
                                side: BorderSide(
                                    color: Theme.of(context).colorScheme.primary),
                                minimumSize: const Size(80, 40),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                )),
                            child: Text(
                              'Hints',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            )),
                      ) : const SizedBox.shrink(),
                      const SizedBox(width: 10),
                      (questionData['Solution'] != null) ? Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                        child: OutlinedButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SimpleDialog(
                                        title: const Text("Solution"),
                                        children: <Widget>[
                                          VisualEditor(
                                            scrollController: ScrollController(),
                                            focusNode: FocusNode(),
                                            controller: EditorController(document: DocumentM.fromJson(questionData['Solution'])),
                                            config: EditorConfigM(
                                              scrollable: true,
                                              autoFocus: true,
                                              expands: false,
                                              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 12.0),
                                              readOnly: true,
                                              keyboardAppearance: Theme.of(context).brightness,
                                            ),
                                          )
                                        ]);
                                  });
                            },
                            style: OutlinedButton.styleFrom(
                                primary: Theme.of(context).colorScheme.primary,
                                side: BorderSide(
                                    color: Theme.of(context).colorScheme.primary),
                                minimumSize: const Size(80, 40),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                )),
                            child: Text(
                              'Solution',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            )),
                      ) : const SizedBox.shrink()
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
