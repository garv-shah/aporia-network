/*
File: create_post_view.dart
Description: Where post data can be created and modified (such as title, description, etc)
Author: Garv Shah
Created: Sat Jul 23 18:21:21 2022
 */

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aporia_app/screens/post_creation/edit_question.dart';
import 'package:aporia_app/utils/components.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/src/iterable_extensions.dart';

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
  final Map<String, dynamic>? postData;
  const CreatePost({Key? key, this.postData}) : super(key: key);

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  // Stateful values for quiz checkbox and group dropdown.
  late bool createQuiz;
  String? selectedGroup;

  Map<String,dynamic> blankJson = {"document":{"type":"page","children":[{"type":"paragraph","data":{"delta":[]}}]}};

  // Controllers for the date input range.
  TextEditingController dateInputStart = TextEditingController();
  TextEditingController dateInputEnd = TextEditingController();

  // Date range for the input field.
  DateTimeRange? currentDateRange;

  // Keys for the animated list of questions and the overall form.
  final _animatedListKey = GlobalKey<AnimatedListState>();
  final _formKey = GlobalKey<FormState>();

  // How many questions there are in the document.
  int questionIndex = 0;

  // Data for the questions selected, and the entire form respectively
  late Map<String, dynamic> questionData;
  late Map<String, dynamic> formData;

  // ID for the post
  String? id;

  @override
  void initState() {
    // Sets the form to the existing values if they are specified in postData,
    // allowing for loading documents
    createQuiz = widget.postData?['createQuiz'] ?? true;
    selectedGroup = widget.postData?['Group'];
    questionData = widget.postData?['questionData'] ?? {};
    formData = widget.postData ?? {};
    id = widget.postData?['ID'];

    if (widget.postData?['Start Date'] != null && widget.postData?['End Date'] != null) {
      currentDateRange = DateTimeRange(start: widget.postData?['Start Date'].toDate(), end: widget.postData?['End Date'].toDate());
      dateInputStart.text = DateFormat('dd/MM/yyyy').format(widget.postData?['Start Date'].toDate());
      dateInputEnd.text = DateFormat('dd/MM/yyyy').format(widget.postData?['End Date'].toDate());
    } else {
      dateInputStart.text = "";
      dateInputEnd.text = "";
    }

    super.initState();
  }

  /// This is a question editing tile.
  Widget questionCard(BuildContext context,
      {required int questionNumber,
      required Animation<double> animation,
      Function? onDelete}) {
    void updateJSON(Map<String,dynamic> data, JsonType type, int questionNumber) {
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
                                .headlineSmall
                                ?.copyWith(
                                    color: Theme.of(context).primaryColorLight,
                                    fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () async {
                                  final experience = await showTextInputDialog(
                                    style: AdaptiveStyle.material,
                                    context: context,
                                    textFields: [
                                      DialogTextField(
                                        hintText: 'Experience',
                                        initialText: questionData['Question $questionNumber']['Experience'].toString(),
                                        keyboardType: TextInputType.number,
                                        validator: (value) => value!.isEmpty
                                            ? "Must provide a number"
                                            : null,
                                      ),
                                    ],
                                    title: 'Assign Experience',
                                    autoSubmit: true,
                                  );

                                  if (experience != null) {
                                    setState(() {
                                      questionData['Question $questionNumber']['Experience'] = int.parse(experience.first);
                                    });
                                  }
                                },
                                icon: Icon(Icons.people, color: Theme.of(context).hintColor)
                            ),
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
                                    color: Theme.of(context).colorScheme.error)),
                          ],
                        )
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
                                                  blankJson,
                                              onSave: (Map<String,dynamic> data) =>
                                                  updateJSON(
                                                      data,
                                                      JsonType.question,
                                                      questionNumber),
                                            )));
                              },
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.primary, minimumSize: const Size(80, 40),
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
                                                blankJson,
                                            solutionType: true,
                                            onSave: (Map<String,dynamic> data) =>
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
                                  foregroundColor: Theme.of(context).colorScheme.primary, minimumSize: const Size(80, 40),
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
                                                blankJson,
                                            onSave: (Map<String,dynamic> data) =>
                                                updateJSON(
                                                    data,
                                                    JsonType.hints,
                                                    questionNumber))));
                              },
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.primary, minimumSize: const Size(80, 40),
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
            MapEntry<String, dynamic>? incompleteQuestion = questionData.entries.firstWhereOrNull((entry) => entry.value['Solution TEX'] == null);

            // If there are no incomplete questions
            if (incompleteQuestion != null && selectedGroup != 'drafts') {
              print(questionData);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${incompleteQuestion.key} is missing a solution!',
                    style: TextStyle(color: Theme.of(context).primaryColorLight),
                  ),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
              );
            } else {
              _formKey.currentState?.save();

              formData['createQuiz'] = createQuiz;
              formData['questionData'] = questionData;
              formData['Group'] = selectedGroup;
              formData['creationTime'] = widget.postData?['creationTime'] ?? DateTime.now();
              if (createQuiz) {
                formData['Start Date'] =
                    DateFormat('dd/MM/yyyy').parse(formData['Start Date']);
                formData['End Date'] =
                    DateFormat('dd/MM/yyyy').parse(formData['End Date']);
              }

              // If the ID is null, create an ID.
              id ??= const Uuid().v4();

              FirebaseFirestore.instance.collection("posts").doc(id).set(
                  formData);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Uploading Post!",
                    style: TextStyle(color: Theme
                        .of(context)
                        .primaryColorLight),
                  ),
                  backgroundColor: Theme
                      .of(context)
                      .scaffoldBackgroundColor,
                ),
              );
            }
          }
        },
        label: const Text('Publish'),
        icon: const Icon(Icons.check),
      ),
      body: Center(
        child: SizedBox(
          width: 760,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: header("Create Quiz/Post", context, fontSize: 20, backArrow: true, customBackLogic: () {
                  showOkCancelAlertDialog(
                    okLabel: 'Confirm',
                      title: 'Save Changes',
                      message: 'Your changes have not been saved, are you sure you want to leave?',
                      context: context
                  ).then((result) {
                    if (result == OkCancelResult.ok) {
                      Navigator.pop(context);
                    }
                  });
                }),
              ),
              const SizedBox(height: 20),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // title input
                      Padding(
                        padding: const EdgeInsets.fromLTRB(36.0, 8.0, 36.0, 8.0),
                        child: TextFormField(
                          initialValue: formData['Title'],
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
                          initialValue: formData['Description'],
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
                      // group input
                      Padding(
                        padding: const EdgeInsets.fromLTRB(36.0, 8.0, 36.0, 8.0),
                        child: FutureBuilder(
                          future: FirebaseFirestore.instance.collection('postGroups').get(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> postGroupsSnapshot) {
                            if (postGroupsSnapshot.connectionState == ConnectionState.done) {
                              if (postGroupsSnapshot.hasError) {
                                return Text(postGroupsSnapshot.error.toString());
                              } else {
                                List<DropdownMenuItem<String>> groups = [];

                                // Iterates through the documents in he collection and creates a list of dropdown menu options.
                                for (QueryDocumentSnapshot<Map<String, dynamic>>? doc in (postGroupsSnapshot.data?.docs ?? [])) {
                                  groups.add(DropdownMenuItem(value: doc?.id ?? "error",child: Text(doc?['tag'] ?? "Invalid Group Name")));
                                }

                                // If there is no selected group, set it to something
                                selectedGroup ??= groups.first.value ?? 'drafts';

                                return DropdownButtonFormField(items: groups, onChanged: (String? value) {
                                  selectedGroup = value;
                                },
                                  value: selectedGroup,
                                hint: const Text("Publishing Group"),);
                              }
                            } else {
                              return DropdownButtonFormField(items: const [DropdownMenuItem(value: "Loading...", child: Text("Loading..."),)], onChanged: (String? value) {},);
                            }
                          },
                        )
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
                            initialValue: formData['Quiz Title'],
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
                            initialValue: formData['Quiz Description'],
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
                initialItemCount: questionData.length,
                itemBuilder: (context, index, animation) {
                  if (questionData['Question ${index + 1}'] == null) {
                    questionData['Question ${index + 1}'] = {};
                    questionData['Question ${index + 1}']['Experience'] = 25;
                  }

                  questionIndex = index + 1;
                  return questionCard(context,
                      questionNumber: questionIndex,
                      animation: animation, onDelete: () {
                    questionIndex -= 1;
                    questionData.remove(questionIndex);
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
        ),
      ),
    );
  }
}
