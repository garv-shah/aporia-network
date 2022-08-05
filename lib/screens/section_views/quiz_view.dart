import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:visual_editor/controller/controllers/editor-controller.dart';
import 'package:visual_editor/documents/models/document.model.dart';
import 'package:visual_editor/editor/models/editor-cfg.model.dart';
import 'package:visual_editor/main.dart';

import '../../utils/components.dart';


/**
 * The following section includes functions for the quiz page.
 */



/**
 * The following section includes the actual QuizView page.
 */

/// This is the view where new posts can be created.
class QuizView extends StatefulWidget {
  Map<String, dynamic> data;
  QuizView({Key? key, required this.data}) : super(key: key);

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  MathFieldEditingController mathController = MathFieldEditingController();
  late Map<String, dynamic> questionData;
  int questionIndex = 0;

  @override
  void initState() {
    questionData = widget.data['questionData'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {

        },
        label: const Text('Next'),
        icon: const Icon(Icons.arrow_forward_ios),
      ),
      body: ListView(
        children: [
          Padding(
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
                      "Problem ${questionIndex + 1}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 38),
                    ),
                    // Extra sized box to make the title in the center
                    const SizedBox(height: 48, width: 48)
                  ],
                ),
                const SizedBox(height: 8),
                Center(child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                  child: Text(widget.data['Quiz Title'], textAlign: TextAlign.center,),
                )),
                const SizedBox(height: 16),
                SizedBox(
                  width: 65,
                  height: 65,
                  child: SvgPicture.asset('assets/app_icon.svg',
                      semanticsLabel: "maths club icon"),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22.0, 16.0, 22.0, 16.0),
            child: Card(
              elevation: 5,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: VisualEditor(
                scrollController: ScrollController(),
                focusNode: FocusNode(),
                controller: EditorController(document: DocumentM.fromJson(questionData['Question ${questionIndex + 1}']['Question'])),
                config: EditorConfigM(
                  scrollable: true,
                  autoFocus: true,
                  expands: false,
                  padding: const EdgeInsets.fromLTRB(16.0, 42.0, 16.0, 42.0),
                  readOnly: true,
                  keyboardAppearance: Theme.of(context).brightness,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
            child: MathField(
              controller: mathController,
              variables: const ['x', 'y', 'z'],
              decoration: const InputDecoration(labelText: "Solution"),
              onChanged: (String value) {},
              onSubmitted: (String value) {},
            ),
          )
        ],
      ),
    );
  }
}
