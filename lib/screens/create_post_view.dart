import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maths_club/screens/edit_question.dart';
import 'package:maths_club/utils/components.dart';
import 'package:uuid/uuid.dart';

/**
 * The following section includes functions for the post/quiz creation page.
 */

/// A checkbox with a label.
class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    Key? key,
    required this.label,
    required this.padding,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final String label;
  final EdgeInsets padding;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 24.0,
              width: 24.0,
              child: Checkbox(
                value: value,
                onChanged: (bool? newValue) {
                  onChanged(newValue!);
                },
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}

/// Types of JSON documents.
enum JsonType { question, solution, hints }

/**
 * The following section includes the actual CreatePost page.
 */

/// This is the view where new posts can be created.
class CreatePost extends StatefulWidget {
  const CreatePost({Key? key}) : super(key: key);

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  bool createQuiz = true;
  // Controllers for the date input range.
  TextEditingController dateInputStart = TextEditingController();
  TextEditingController dateInputEnd = TextEditingController();
  DateTimeRange? currentDateRange;
  final _animatedListKey = GlobalKey<AnimatedListState>();
  final _formKey = GlobalKey<FormState>();
  int questionIndex = 0;

  Map<String, dynamic> questionData = {};
  Map<String, dynamic> formData = {};

  @override
  void initState() {
    // Clears date input range text.
    dateInputStart.text = "";
    dateInputEnd.text = "";
    currentDateRange = null;
    super.initState();
  }

  /// This is a question editing tile.
  Widget questionCard(BuildContext context,
      {required int questionNumber,
      required Animation<double> animation,
      Function? onDelete}) {
    void updateJSON(List<dynamic> data, JsonType type, int questionNumber) {
      setState(() {
        if (type == JsonType.question) {
          questionData['Question $questionNumber']['Question'] = data;
        } else if (type == JsonType.solution) {
          questionData['Question $questionNumber']['Solution'] = data;
        } else if (type == JsonType.hints) {
          questionData['Question $questionNumber']['Hints'] = data;
        }
      });
    }

    // SizeTransition to allow for animating the questionCard.
    return SizeTransition(
      sizeFactor: animation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(36.0, 6.0, 36.0, 6.0),
        child: Card(
          elevation: 5,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: SizedBox(
            height: 115,
            child: Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The first row (title and delete button).
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Question ${questionNumber.toString()}",
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                ?.copyWith(
                                    color: Theme.of(context).primaryColorLight,
                                    fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis),
                        IconButton(
                            onPressed: () {
                              // Removes this item from the AnimatedList
                              AnimatedList.of(context).removeItem(
                                  questionNumber - 1, (context, animation) {
                                // Calls the onDelete function if it exists.
                                onDelete?.call();
                                // Removed the question from the JSON data
                                questionData.remove('Question $questionNumber');
                                // The temporary widget to display while deleting.
                                return questionCard(context,
                                    questionNumber: questionNumber,
                                    animation: animation);
                              });
                            },
                            icon: Icon(Icons.delete,
                                color: Theme.of(context).errorColor))
                      ],
                    ),
                  ),
                  // The second row (page options).
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 8.0),
                    child: Row(
                      children: [
                        // Question button.
                        Expanded(
                          child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditQuestion(
                                              title:
                                                  'Question ${questionNumber.toString()}',
                                              document: questionData[
                                                          'Question $questionNumber']
                                                      ['Question'] ??
                                                  [
                                                    {"insert": "\n"}
                                                  ],
                                              onSave: (List<dynamic> data) =>
                                                  updateJSON(
                                                      data,
                                                      JsonType.question,
                                                      questionNumber),
                                            )));
                              },
                              style: OutlinedButton.styleFrom(
                                  primary:
                                      Theme.of(context).colorScheme.primary,
                                  minimumSize: const Size(80, 40),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  )),
                              child: Text(
                                'Question',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              )),
                        ),
                        // Spacer
                        const SizedBox(width: 12),
                        // Solution button.
                        Expanded(
                          child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditQuestion(
                                            title:
                                                'Q${questionNumber.toString()} Solution',
                                            document: questionData[
                                                        'Question $questionNumber']
                                                    ['Solution'] ??
                                                [
                                                  {"insert": "\n"}
                                                ],
                                            solutionType: true,
                                            onSave: (List<dynamic> data) =>
                                                updateJSON(
                                                    data,
                                                    JsonType.solution,
                                                    questionNumber),
                                            solution: questionData[
                                                    'Question $questionNumber']
                                                ['Solution TEX'],
                                            onSolution: (String solution) {
                                              setState(() {
                                                questionData[
                                                            'Question $questionNumber']
                                                        ['Solution TEX'] =
                                                    solution.replaceAll(
                                                        r"\textcolor{#000000}{\cursor}",
                                                        '');
                                              });
                                            },
                                          )),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                  primary:
                                      Theme.of(context).colorScheme.primary,
                                  minimumSize: const Size(80, 40),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  )),
                              child: Text(
                                'Solution',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              )),
                        ),
                        // Spacer
                        const SizedBox(width: 12),
                        // Hints button
                        Expanded(
                          child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditQuestion(
                                            title:
                                                'Q${questionNumber.toString()} Hints',
                                            document: questionData[
                                                        'Question $questionNumber']
                                                    ['Hints'] ??
                                                [
                                                  {"insert": "\n"}
                                                ],
                                            onSave: (List<dynamic> data) =>
                                                updateJSON(
                                                    data,
                                                    JsonType.question,
                                                    questionNumber))));
                              },
                              style: OutlinedButton.styleFrom(
                                  primary:
                                      Theme.of(context).colorScheme.primary,
                                  minimumSize: const Size(80, 40),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  )),
                              child: Text(
                                'Hints',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              )),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState?.save();

            formData['createQuiz'] = createQuiz;
            formData['questionData'] = questionData;
            formData['creationTime'] = DateTime.now();
            formData['Start Date'] =
                DateFormat('dd/MM/yyyy').parse(formData['Start Date']);
            formData['End Date'] =
                DateFormat('dd/MM/yyyy').parse(formData['End Date']);

            FirebaseFirestore.instance.collection("posts").doc(const Uuid().v4()).set(formData);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Uploading Post!",
                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            );
          }
        },
        label: const Text('Publish'),
        icon: const Icon(Icons.check),
      ),
      body: ListView(
        children: [
          header("Create Quiz/Post", context, fontSize: 20, backArrow: true),
          const SizedBox(height: 20),
          Form(
              key: _formKey,
              child: Column(
                children: [
                  // title input
                  Padding(
                    padding: const EdgeInsets.fromLTRB(36.0, 8.0, 36.0, 8.0),
                    child: TextFormField(
                      onSaved: (value) {
                        formData['Title'] = value;
                      },
                      decoration: const InputDecoration(labelText: "Title"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title!';
                        }
                        return null;
                      },
                    ),
                  ),
                  // description input
                  Padding(
                    padding: const EdgeInsets.fromLTRB(36.0, 8.0, 36.0, 8.0),
                    child: TextFormField(
                      onSaved: (value) {
                        formData['Description'] = value;
                      },
                      decoration:
                          const InputDecoration(labelText: "Description"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description!';
                        }
                        return null;
                      },
                    ),
                  ),
                  // create quiz checkbox
                  LabeledCheckbox(
                    label: "Create Quiz From Post",
                    value: createQuiz,
                    onChanged: (value) {
                      setState(() {
                        createQuiz = value;
                      });
                    },
                    padding: const EdgeInsets.fromLTRB(36.0, 8.0, 36.0, 8.0),
                  ),
                  // date range
                  Visibility(
                    visible: createQuiz,
                    child: InkWell(
                      onTap: () async {
                        // Hides keyboard since it was giving me an overflow.
                        FocusManager.instance.primaryFocus?.unfocus();

                        DateTimeRange? pickedRange = await showDateRangePicker(
                          context: context,
                          initialDateRange: currentDateRange,
                          firstDate: DateTime(1950),
                          lastDate: DateTime(2100),
                          // Overrides the theme of the picker to work with dark mode.
                          builder: (context, Widget? child) => Theme(
                            data: Theme.of(context).copyWith(
                                dialogBackgroundColor: Theme.of(context)
                                    .scaffoldBackgroundColor,
                                appBarTheme: Theme.of(context)
                                    .appBarTheme
                                    .copyWith(
                                        iconTheme: IconThemeData(
                                            color:
                                                Theme.of(context)
                                                    .primaryColorLight)),
                                colorScheme: Theme.of(context)
                                    .colorScheme
                                    .copyWith(
                                        onPrimary:
                                            Theme.of(context).primaryColorLight,
                                        primary: Theme.of(context)
                                            .colorScheme
                                            .primary)),
                            child: child!,
                          ),
                        );

                        if (pickedRange != null) {
                          setState(() {
                            // Sets the text input boxes to the selected range.
                            currentDateRange = pickedRange;
                            dateInputStart.text = DateFormat('dd/MM/yyyy')
                                .format(pickedRange.start);
                            dateInputEnd.text = DateFormat('dd/MM/yyyy')
                                .format(pickedRange.end);
                          });
                        }
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(36.0, 8.0, 36.0, 8.0),
                        // These two TextFields are just there for looks and cannot be
                        // interacted with, rather acting as buttons that upon up the
                        // DatePicker. This then writes it to their fields.
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                onSaved: (value) {
                                  formData['Start Date'] = value;
                                },
                                // Editing controller of this TextField.
                                controller: dateInputStart,
                                decoration: const InputDecoration(
                                    labelText:
                                        "Start Date" //label text of field
                                    ),
                                readOnly: true,
                                enabled: false,
                                validator: (value) {
                                  if ((value == null || value.isEmpty) &&
                                      createQuiz) {
                                    return 'Please enter a start date!';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                onSaved: (value) {
                                  formData['End Date'] = value;
                                },
                                // Editing controller of this TextField.
                                controller: dateInputEnd,
                                decoration: const InputDecoration(
                                    labelText: "End Date" //label text of field
                                    ),
                                readOnly: true,
                                enabled: false,
                                validator: (value) {
                                  if ((value == null || value.isEmpty) &&
                                      createQuiz) {
                                    return 'Please enter an end date!';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // quiz title input
                  Visibility(
                    visible: createQuiz,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(36.0, 8.0, 36.0, 8.0),
                      child: TextFormField(
                        decoration:
                            const InputDecoration(labelText: "Quiz Title"),
                        onSaved: (value) {
                          formData['Quiz Title'] = value;
                        },
                        validator: (value) {
                          if ((value == null || value.isEmpty) && createQuiz) {
                            return 'Please enter a quiz title!';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  // quiz description input
                  Visibility(
                    visible: createQuiz,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(36.0, 8.0, 36.0, 8.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                            labelText: "Quiz Description"),
                        onSaved: (value) {
                          formData['Quiz Description'] = value;
                        },
                        validator: (value) {
                          if ((value == null || value.isEmpty) && createQuiz) {
                            return 'Please enter a quiz description!';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              )),
          // the place where questions pop up
          AnimatedList(
            key: _animatedListKey,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index, animation) {
              if (questionData['Question ${index + 1}'] == null) {
                questionData['Question ${index + 1}'] = {};
              }

              questionIndex = index + 1;
              return questionCard(context,
                  questionNumber: index + 1,
                  animation: animation, onDelete: () {
                questionIndex -= 1;
              });
            },
          ),
          // add questions button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  child: OutlinedButton(
                    onPressed: () {
                      // This inserts a question into the animated list.
                      _animatedListKey.currentState?.insertItem(questionIndex);
                    },
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).colorScheme.primary),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                              side: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.primary))),
                    ),
                    child: const Text('Add Question'),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
