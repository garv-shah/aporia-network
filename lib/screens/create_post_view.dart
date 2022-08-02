import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maths_club/utils/components.dart';
import 'package:maths_club/screens/auth/landing_page.dart';

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

/// This is a question editing tile.
Widget questionCard(BuildContext context,
    {required int questionNumber,
    required Animation<double> animation,
    Function? onDelete}) {
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
                              AuthGate.of(context)?.push(Destination.editQuestion, input: {'title': 'Question ${questionNumber.toString()}'});
                            },
                            style: OutlinedButton.styleFrom(
                                primary: Theme.of(context).colorScheme.primary,
                                minimumSize: const Size(80, 40),
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                )),
                            child: Text(
                              'Question',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            )),
                      ),
                      // Spacer
                      const SizedBox(width: 12),
                      // Solution button.
                      Expanded(
                        child: OutlinedButton(
                            onPressed: () {
                              AuthGate.of(context)?.push(Destination.editQuestion, input: {'title': 'Q${questionNumber.toString()} Solution'});
                            },
                            style: OutlinedButton.styleFrom(
                                primary: Theme.of(context).colorScheme.primary,
                                minimumSize: const Size(80, 40),
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                )),
                            child: Text(
                              'Solution',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            )),
                      ),
                      // Spacer
                      const SizedBox(width: 12),
                      // Hints button
                      Expanded(
                        child: OutlinedButton(
                            onPressed: () {
                              AuthGate.of(context)?.push(Destination.editQuestion, input: {'title': 'Q${questionNumber.toString()} Hints'});
                            },
                            style: OutlinedButton.styleFrom(
                                primary: Theme.of(context).colorScheme.primary,
                                minimumSize: const Size(80, 40),
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                )),
                            child: Text(
                              'Hints',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
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
  int questionIndex = 0;

  @override
  void initState() {
    // Clears date input range text.
    dateInputStart.text = "";
    dateInputEnd.text = "";
    currentDateRange = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Publish'),
        icon: const Icon(Icons.check),
      ),
      body: ListView(
        children: [
          header("Create Quiz/Post", context, fontSize: 20, backArrow: true),
          const SizedBox(height: 20),
          // title input
          const Padding(
            padding: EdgeInsets.fromLTRB(36.0, 8.0, 36.0, 8.0),
            child: TextField(
              decoration: InputDecoration(labelText: "Title"),
            ),
          ),
          // description input
          const Padding(
            padding: EdgeInsets.fromLTRB(36.0, 8.0, 36.0, 8.0),
            child: TextField(
              decoration: InputDecoration(labelText: "Description"),
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
                DateTimeRange? pickedRange = await showDateRangePicker(
                  context: context,
                  initialDateRange: currentDateRange,
                  firstDate: DateTime(1950),
                  lastDate: DateTime(2100),
                  // Overrides the theme of the picker to work with dark mode.
                  builder: (context, Widget? child) => Theme(
                    data: Theme.of(context).copyWith(
                        dialogBackgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        appBarTheme: Theme.of(context).appBarTheme.copyWith(
                            iconTheme: IconThemeData(
                                color: Theme.of(context).primaryColorLight)),
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                            onPrimary: Theme.of(context).primaryColorLight,
                            primary: Theme.of(context).colorScheme.primary)),
                    child: child!,
                  ),
                );

                if (pickedRange != null) {
                  setState(() {
                    // Sets the text input boxes to the selected range.
                    currentDateRange = pickedRange;
                    dateInputStart.text =
                        DateFormat('dd/MM/yyyy').format(pickedRange.start);
                    dateInputEnd.text =
                        DateFormat('dd/MM/yyyy').format(pickedRange.end);
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(36.0, 8.0, 36.0, 8.0),
                // These two TextFields are just there for looks and cannot be
                // interacted with, rather acting as buttons that upon up the
                // DatePicker. This then writes it to their fields.
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        // Editing controller of this TextField.
                        controller: dateInputStart,
                        decoration: const InputDecoration(
                            labelText: "Start Date" //label text of field
                            ),
                        readOnly: true,
                        enabled: false,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextField(
                        // Editing controller of this TextField.
                        controller: dateInputEnd,
                        decoration: const InputDecoration(
                            labelText: "End Date" //label text of field
                            ),
                        readOnly: true,
                        enabled: false,
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
            child: const Padding(
              padding: EdgeInsets.fromLTRB(36.0, 8.0, 36.0, 8.0),
              child: TextField(
                decoration: InputDecoration(labelText: "Quiz Title"),
              ),
            ),
          ),
          // quiz description input
          Visibility(
            visible: createQuiz,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(36.0, 8.0, 36.0, 8.0),
              child: TextField(
                decoration: InputDecoration(labelText: "Quiz Description"),
              ),
            ),
          ),
          // the place where questions pop up
          AnimatedList(
            key: _animatedListKey,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index, animation) {
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
