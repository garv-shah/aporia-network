import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_extensions/flutter_extensions.dart';
import 'package:flutter_svg/svg.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:visual_editor/controller/controllers/editor-controller.dart';
import 'package:visual_editor/documents/models/document.model.dart';
import 'package:visual_editor/editor/models/editor-cfg.model.dart';
import 'package:visual_editor/main.dart';

/// Where quizzes can be answered and viewed.
class QuizView extends StatefulWidget {
  final Map<String, dynamic> data;

  const QuizView({Key? key, required this.data}) : super(key: key);

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  MathFieldEditingController mathController = MathFieldEditingController();
  late Map<String, dynamic> questionData;
  // A map for question answers and an int for what question we're on respectively.
  Map<String, dynamic> questionAnswers = {};
  int questionIndex = 0;

  // The region cloud functions should be invoked from.
  final functions =
      FirebaseFunctions.instanceFor(region: 'australia-southeast1');

  @override
  void initState() {
    questionData = widget.data['questionData'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MathKeyboardViewInsets(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
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
                                questionAnswers[
                                        'Question ${questionIndex + 1}'] =
                                    mathController.root
                                        .buildTeXString(
                                            cursorColor: Colors.black)
                                        .replaceAll(
                                            r"\textcolor{#000000}{\cursor}",
                                            '');
                                mathController.clear();
                              }

                              // If previous answer is already answered, load it from map.
                              if (questionAnswers['Question $questionIndex'] !=
                                  null) {
                                try {
                                  mathController.updateValue(TeXParser(
                                          questionAnswers[
                                              'Question $questionIndex'])
                                      .parse());
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
                        label: Row(
                          children: const [
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
                              questionAnswers['Question ${questionIndex + 1}'] =
                                  mathController.root
                                      .buildTeXString(cursorColor: Colors.black)
                                      .replaceAll(
                                          r"\textcolor{#000000}{\cursor}", '');
                              mathController.clear();

                              // If next answer is already answered, load it from map.
                              if (questionAnswers[
                                      'Question ${questionIndex + 2}'] !=
                                  null) {
                                try {
                                  mathController.updateValue(TeXParser(
                                          questionAnswers[
                                              'Question ${questionIndex + 2}'])
                                      .parse());
                                } catch (error) {
                                  // Do nothing.
                                }
                              }

                              questionIndex++;
                            }
                          });
                        },
                        label: Row(
                          children: const [
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
                          semanticsLabel: "maths club icon"),
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
                                                    .headline4,
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      // Counts number of correct
                                                      // questions, if the correctedMap
                                                      // is null, this would be 0
                                                      text: (correctedMap
                                                                  ?.where((key,
                                                                          value) =>
                                                                      value ==
                                                                      true)
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
                                        return Column(
                                          children: const [
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
                            child: VisualEditor(
                              scrollController: ScrollController(),
                              focusNode: FocusNode(),
                              controller: EditorController(
                                  document: DocumentM.fromJson(questionData[
                                          'Question ${questionIndex + 1}']
                                      ['Question'])),
                              config: EditorConfigM(
                                scrollable: true,
                                autoFocus: true,
                                expands: false,
                                padding: const EdgeInsets.fromLTRB(
                                    16.0, 42.0, 16.0, 42.0),
                                readOnly: true,
                                keyboardAppearance:
                                    Theme.of(context).brightness,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
                          child: MathField(
                            controller: mathController,
                            variables: const ['x', 'y', 'z'],
                            decoration:
                                const InputDecoration(labelText: "Solution"),
                            onChanged: (String value) {},
                            onSubmitted: (String value) {},
                          ),
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
