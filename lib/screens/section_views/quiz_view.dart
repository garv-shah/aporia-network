/*
File: quiz_view.dart
Description: The view for quizzes inside sections
Author: Garv Shah
Created: Fri Aug 5 22:25:21 2022
 */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:aporia_app/utils/config/config.dart' as config;
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:aporia_app/widgets/text_editor.dart';

/// Where quizzes can be answered and viewed.
class QuizView extends StatefulWidget {
  final Map<String, dynamic> data;

  const QuizView({Key? key, required this.data}) : super(key: key);

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  MathFieldEditingController mathController = MathFieldEditingController();
  TextEditingController textController = TextEditingController();
  late final _mathsFocusNode = FocusNode(debugLabel: 'Maths Focus');
  late Map<String, dynamic> questionData;
  List<Document> documents = [];
  // A map for question answers and an int for what question we're on respectively.
  Map<String, dynamic> questionAnswers = {};
  int questionIndex = 0;

  // The region cloud functions should be invoked from.
  final functions =
      FirebaseFunctions.instanceFor(region: 'australia-southeast1');

  @override
  void initState() {
    questionData = widget.data['questionData'];

    for (var i = 1; i < questionData.keys.length + 1; i++) {
      Document document = Document.blank();

      if (widget.data['appVersion'] == 1) {
        document = quillDeltaEncoder.convert(Delta.fromJson(questionData['Question $i']['Question']));
      } else if (widget.data['appVersion'] == 2) {
        document = Document.fromJson(questionData['Question $i']['Question']);
      }

      documents.add(document);
    }

    super.initState();
  }

  @override
  void dispose() {
    mathController.dispose();
    textController.dispose();
    _mathsFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return MathKeyboardViewInsets(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              // AnimatedSwitcher so it animates in and out
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                // Don't show back button on first page.
                child: (questionIndex != 0)
                    ? FloatingActionButton.extended(
                        key: const ValueKey<String>("Back Button"),
                        onPressed: () {
                          setState(() {
                            if (questionIndex != 0) {
                              // If not on the last page, save current page answer to map.
                              if (questionData.keys.length != questionIndex) {
                                if (questionData['Question ${questionIndex + 1}']['maths_mode'] == true) {
                                  questionAnswers['Question ${questionIndex +
                                      1}'] =
                                      mathController.root.buildTeXString(
                                          cursorColor: Colors.black)
                                          .replaceAll(
                                          r"\textcolor{#000000}{\cursor}", '');
                                  mathController.clear();
                                } else {
                                  questionAnswers['Question ${questionIndex + 1}'] = textController.text;
                                  textController.clear();
                                }
                              }

                              // if previous answer in not maths, unfocus the maths keyboard
                              if (questionData['Question $questionIndex'] == null || questionData['Question $questionIndex']['maths_mode'] == false) {
                                _mathsFocusNode.unfocus();
                              }

                              // If previous answer is already answered, load it from map.
                              if (questionAnswers['Question $questionIndex'] !=
                                  null) {
                                try {
                                  if (questionData['Question $questionIndex']['maths_mode'] == true) {
                                    mathController.updateValue(TeXParser(
                                        questionAnswers[
                                        'Question $questionIndex'])
                                        .parse());
                                  } else {
                                    textController.text = questionAnswers['Question $questionIndex'];
                                  }
                                } catch (error) {
                                  // Do nothing.
                                }
                              }

                              questionIndex--;
                            }
                          });
                        },
                        label: const Text('Back'),
                        icon: const Icon(Icons.arrow_back_ios),
                      )
                    : const SizedBox.shrink(),
              ),
              // Next/Finish Button
              // AnimatedSwitcher so it animates between the two
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: (questionData.keys.length == questionIndex)
                    ? FloatingActionButton.extended(
                        key: const ValueKey<String>("Finish Button"),
                        onPressed: () {
                          setState(() {
                            // Will go back to the home page.
                            Navigator.pop(context);
                            Navigator.pop(context);
                          });
                        },
                        label: const Row(
                          children: [
                            Text('Finish'),
                            SizedBox(width: 10),
                            Icon(Icons.done)
                          ],
                        ),
                      )
                    : FloatingActionButton.extended(
                        key: const ValueKey<String>("Next Button"),
                        onPressed: () {
                          setState(() {
                            if (questionData.keys.length > questionIndex) {
                              // Saves current answer to map.
                              if (questionData['Question ${questionIndex + 1}']['maths_mode'] == true) {
                                questionAnswers['Question ${questionIndex +
                                    1}'] =
                                    mathController.root
                                        .buildTeXString(
                                        cursorColor: Colors.black)
                                        .replaceAll(
                                        r"\textcolor{#000000}{\cursor}", '');
                                mathController.clear();
                              } else {
                                questionAnswers['Question ${questionIndex + 1}'] = textController.text;
                                textController.clear();
                              }

                              if (questionData['Question ${questionIndex + 2}'] == null || questionData['Question ${questionIndex + 2}']['maths_mode'] == false) {
                                _mathsFocusNode.unfocus();
                              }

                              // If next answer is already answered, load it from map.
                              if (questionAnswers['Question ${questionIndex + 2}'] != null) {
                                try {
                                  if (questionData['Question ${questionIndex + 2}']['maths_mode'] == true) {
                                    mathController.updateValue(TeXParser(
                                        questionAnswers[
                                        'Question ${questionIndex + 2}'])
                                        .parse());
                                  } else {
                                    textController.text = questionAnswers['Question ${questionIndex + 2}'];
                                  }
                                } catch (error) {
                                  // Do nothing.
                                }
                              }

                              questionIndex++;
                            }
                          });
                        },
                        label: const Row(
                          children: [
                            Text('Next'),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward_ios)
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
        // Main questions
        // AnimatedSwitcher so the questions will animate when changed
        body: AnimatedSwitcher(
          transitionBuilder: (child, animation) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween = Tween(begin: begin, end: end);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: child,
            );
          },
          duration: const Duration(milliseconds: 500),
          child: ListView(
            key: ValueKey<int>(questionIndex),
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 32.0, 8.0, 32.0),
                child: Column(
                  children: [
                    // Heading Title
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
                          (questionData.keys.length == questionIndex)
                              ? "Quiz Complete!"
                              : "Problem ${questionIndex + 1}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 38),
                        ),
                        // Extra sized box to make the title in the center
                        const SizedBox(height: 48, width: 48)
                      ],
                    ),
                    // padding
                    const SizedBox(height: 8),
                    // Quiz Title
                    Center(
                        child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                      child: Text(
                        widget.data['Quiz Title'],
                        textAlign: TextAlign.center,
                      ),
                    )),
                    // padding
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 65,
                      height: 65,
                      child: SvgPicture.asset('assets/app_icon.svg',
                          semanticsLabel: "${config.name} icon"),
                    ),
                  ],
                ),
              ),
              // If the question is the final page, show final page, if not
              // show questions like normal
              (questionData.keys.length == questionIndex)
                  ? Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 48.0),
                          child: SvgPicture.asset('assets/party-popper.svg',
                              height: 200,
                              width: 200,
                              semanticsLabel: 'Party Popper'),
                        ),
                        // Card with results
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(22.0, 16.0, 22.0, 16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: Card(
                              elevation: 5,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16.0, 42.0, 16.0, 42.0),
                                // Gets results from cloud function and displays them
                                child: FutureBuilder<
                                        HttpsCallableResult<
                                            Map<String, dynamic>>>(
                                    future: functions
                                        .httpsCallable('markQuestions')
                                        .call<Map<String, dynamic>>({
                                      'questionAnswers': questionAnswers,
                                      'quizID': widget.data['ID']
                                    }),
                                    builder: (context, resultSnapshot) {
                                      if (resultSnapshot.connectionState ==
                                          ConnectionState.done) {
                                        Map<String, dynamic>? correctedMap =
                                            resultSnapshot.data?.data;

                                        return Column(
                                          children: [
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 16.0),
                                              child: Text("You got:"),
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium,
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      // Counts number of correct
                                                      // questions, if the correctedMap
                                                      // is null, this would be 0
                                                      text: (correctedMap
                                                                  ?.entries.where((entry) => entry.value == true)
                                                                  .length ??
                                                              0)
                                                          .toString(),
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary)),
                                                  const TextSpan(text: ' / '),
                                                  TextSpan(
                                                      // Count's how many questions
                                                      // there are. This takes away
                                                      // one, because experience will
                                                      // be one of the keys, so it
                                                      // counts the keys and then
                                                      // takes away what would be
                                                      // experience.
                                                      text: ((correctedMap
                                                                      ?.length ??
                                                                  1) -
                                                              1)
                                                          .toString()),
                                                ],
                                              ),
                                            ),
                                            // Amount of experience gained
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 16.0),
                                              child: DefaultTextStyle(
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary),
                                                  // If no experience is gained,
                                                  // say so, if not display how
                                                  // much was gained
                                                  child: ((correctedMap?[
                                                                  'Experience'] ??
                                                              0) >
                                                          0)
                                                      ? Text(
                                                          '+${correctedMap?['Experience']} Experience')
                                                      : const Text(
                                                          'No Experience Gained')),
                                            )
                                          ],
                                        );
                                      } else {
                                        return const Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 32.0),
                                              child: Text("Loading Results..."),
                                            ),
                                            CircularProgressIndicator()
                                          ],
                                        );
                                      }
                                    }),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(22.0, 16.0, 22.0, 16.0),
                          child: Card(
                            elevation: 5,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            // Displays question from Delta
                            child: TextEditor(
                              editorState: EditorState(document: documents[questionIndex]),
                              readOnly: true,
                              padding: const EdgeInsets.fromLTRB(16.0, 42.0, 16.0, 42.0),
                              desktop: PlatformExtension.isDesktopOrWeb,
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
                          child: (() {
                            if (questionData['Question ${questionIndex + 1}']['maths_mode'] != true) {
                              return TextField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Solution',
                                ),
                                controller: textController,
                              );
                            } else {
                              return MathField(
                                controller: mathController,
                                variables: const ['x', 'y', 'z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w'],
                                decoration: const InputDecoration(labelText: "Solution"),
                                focusNode: _mathsFocusNode,
                                onChanged: (String value) {},
                                onSubmitted: (String value) {},
                              );
                            }
                          } ()),
                        )
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }
}
