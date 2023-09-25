/*
File: create_job_view.dart
Description: Where jobs can be created and modified
Author: Garv Shah
Created: Sat Jul 8 17:04:21 2023
 */

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:aporia_app/screens/scheduling/availability_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_extensions/flutter_extensions.dart';
import 'package:intl/intl.dart';
import 'package:aporia_app/utils/components.dart';
import 'package:uuid/uuid.dart';

/**
 * The following section includes functions for the creation of jobs.
 */

/// Extension to add hours to time of day
extension TimeOfDayExtension on TimeOfDay {
  TimeOfDay addHour(int hour) {
    return replacing(hour: this.hour + hour, minute: minute);
  }
}

TimeOfDay stringToTimeOfDay(String tod) {
  final format = DateFormat.jm(); //"6:00 AM"
  return TimeOfDay.fromDateTime(format.parse(tod));
}

String formatTimeOfDay(TimeOfDay tod) {
  final now = DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
  final format = DateFormat.jm(); //"6:00 AM"
  return format.format(dt);
}

/**
 * The following section includes the actual CreateJob page.
 */

/// This is the view where new jobs can be created.
class CreateJob extends StatefulWidget {
  final Map<String, dynamic>? jobData;
  final Map<String, dynamic> userData;

  const CreateJob({Key? key, this.jobData, required this.userData})
      : super(key: key);

  @override
  State<CreateJob> createState() => _CreateJobState();
}

class _CreateJobState extends State<CreateJob> {
  List<DropdownMenuItem<String>> possibleSubjects = [];

  // Keys for the animated list of items and the overall form.
  final _animatedListKey = GlobalKey<AnimatedListState>();
  final _formKey = GlobalKey<FormState>();

  // How many items there are in the document.
  int itemIndex = 0;

  // Data for the item selected, and the entire form respectively
  late Map<String, dynamic> requirements;
  late Map<String, dynamic> jobData;

  // ID for the job
  String? id;

  @override
  Future<void> didChangeDependencies() async {
    // Sets the form to the existing values if they are specified in jobData,
    // allowing for loading documents
    requirements = widget.jobData?['requirements'] ?? {};
    jobData = widget.jobData ?? {};
    jobData['repeatOptions'] ??= ['weekly'];
    id = widget.jobData?['ID'];

    DocumentSnapshot<Map<String, dynamic>> subjectsSnapshot =
    await FirebaseFirestore.instance
        .collection('global')
        .doc('subjects')
        .get();

    // Iterates through the documents in he collection and creates a list of dropdown menu options.
    for (String subject in (subjectsSnapshot.data()?['available'])) {
      possibleSubjects
          .add(DropdownMenuItem(value: subject, child: Text(subject)));
    }

    setState(() {});

    super.didChangeDependencies();
  }

  /// This is a item editing tile.
  Widget itemCard(BuildContext context,
      {required int itemNumber,
        required Animation<double> animation,
        Function? onDelete}) {
    double screenWidth = MediaQuery.of(context).size.width;

    // SizeTransition to allow for animating the itemCard.
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
            height: 170,
            child: Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The first row (title and delete button).
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 16.0, 8.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 64,
                          width: screenWidth >= 760 ? 760 - 205 : screenWidth - 205,
                          child: DropdownButtonFormField(
                            value: (requirements['Subject $itemNumber'] == null ||
                                requirements['Subject $itemNumber']['Subject'] ==
                                    null)
                                ? null
                                : requirements['Subject $itemNumber']['Subject']
                                .toString(),
                            items: possibleSubjects,
                            onChanged: (String? value) {
                              requirements['Subject $itemNumber']['Subject'] = value;
                            },
                            validator: (value) => value!.isEmpty
                                ? "Must provide a subject"
                                : null,
                            hint: Text("Subject ${itemNumber.toString()}"),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () async {
                                  final level = await showTextInputDialog(
                                    style: AdaptiveStyle.material,
                                    context: context,
                                    textFields: [
                                      DialogTextField(
                                        hintText: 'Level',
                                        initialText:
                                        requirements['Subject $itemNumber']
                                        ['Level']
                                            .toString(),
                                        keyboardType: TextInputType.number,
                                        validator: (value) => value!.isEmpty
                                            ? "Must provide a number"
                                            : null,
                                      ),
                                    ],
                                    title: 'Level of Ability (Grade)',
                                    autoSubmit: true,
                                  );

                                  if (level != null) {
                                    setState(() {
                                      requirements['Subject $itemNumber']['Level'] =
                                          int.parse(level.first);
                                    });
                                  }
                                },
                                icon: Icon(Icons.military_tech,
                                    color: Theme.of(context).hintColor)),
                            IconButton(
                                onPressed: () {
                                  // Removes this item from the AnimatedList
                                  AnimatedList.of(context).removeItem(
                                      itemNumber - 1, (context, animation) {
                                    // Calls the onDelete function if it exists.
                                    onDelete?.call();
                                    // Removed the item from the JSON data
                                    requirements.remove('Subject $itemNumber');
                                    // The temporary widget to display while deleting.
                                    return itemCard(context,
                                        itemNumber: itemNumber,
                                        animation: animation);
                                  });
                                },
                                icon: Icon(Icons.delete,
                                    color: Theme.of(context).errorColor)),
                            const SizedBox(width: 8)
                          ],
                        )
                      ],
                    ),
                  ),
                  // Extra Notes
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 16, 0),
                    child: TextFormField(
                      initialValue:
                      requirements['Subject $itemNumber']?['Extra Notes'] ?? '',
                      onChanged: (value) {
                        requirements['Subject $itemNumber']['Extra Notes'] = value;
                      },
                      decoration:
                      const InputDecoration(labelText: "Extra Notes"),
                    ),
                  ),
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
    void handleRepeatClick(bool active, String repeat) {
      if (active) {
        jobData['repeatOptions'].add(repeat);
      } else {
        jobData['repeatOptions'].remove(repeat);
      }
    }
    List<Widget> repeatDialogueList = [
      const Padding(
        padding: EdgeInsets.fromLTRB(25, 0, 25, 10),
        child: SizedBox(
          width: 200,
          child:
          Text("If multiple options are selected, it will be up to the volunteer to decide."),
        ),
      ),
      BoolDialogueOption(title: "Daily", id: 'daily', initialValue: jobData['repeatOptions'].contains('daily'), onTap: handleRepeatClick),
      BoolDialogueOption(title: "Weekly", id: 'weekly', initialValue: jobData['repeatOptions'].contains('weekly'), onTap: handleRepeatClick),
      BoolDialogueOption(title: "Fortnightly", id: 'fortnightly', initialValue: jobData['repeatOptions'].contains('fortnightly'), onTap: handleRepeatClick),
      BoolDialogueOption(title: "Monthly", id: 'monthly', initialValue: jobData['repeatOptions'].contains('monthly'), onTap: handleRepeatClick),
      BoolDialogueOption(title: "Once Off", id: 'once', initialValue: jobData['repeatOptions'].contains('once'), onTap: handleRepeatClick),
    ];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState?.save();

            jobData['requirements'] = requirements;
            jobData['creationTime'] = DateTime.now();
            jobData['createdBy'] = widget.userData;
            jobData['createdBy']['id'] = FirebaseAuth.instance.currentUser?.uid ?? 'null';
            jobData['status'] ??= "pending_assignment";

            // If the ID is null, create an ID.
            id ??= const Uuid().v4();

            FirebaseFirestore.instance
                .collection("jobs")
                .doc(id)
                .set(jobData);

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Uploading Job!",
                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            );
          }
        },
        label: const Text('Send'),
        icon: const Icon(Icons.check),
      ),
      body: Center(
        child: SizedBox(
          width: 760,
          child: ListView(
            children: [
              header("Create Job", context, fontSize: 20, backArrow: true,
                  customBackLogic: () {
                    showOkCancelAlertDialog(
                        okLabel: 'Confirm',
                        title: 'Save Changes',
                        message:
                        'Your changes have not been saved, are you sure you want to leave?',
                        context: context)
                        .then((result) {
                      if (result == OkCancelResult.ok) {
                        Navigator.pop(context);
                      }
                    });
                  }),
              const SizedBox(height: 20),
              Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // pickup title
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 0, 24, 4),
                        child: Text("Job Information",
                            style: Theme.of(context).textTheme.headline3),
                      ),
                      // job title input
                      Padding(
                        padding: const EdgeInsets.fromLTRB(36.0, 8.0, 36.0, 8.0),
                        child: TextFormField(
                          initialValue: jobData['Job Title'],
                          onSaved: (value) {
                            jobData['Job Title'] = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a job title!';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(labelText: "Job Title"),
                        ),
                      ),
                      // job description input
                      Padding(
                        padding: const EdgeInsets.fromLTRB(36.0, 8.0, 36.0, 8.0),
                        child: TextFormField(
                          initialValue: jobData['Job Description'],
                          onSaved: (value) {
                            jobData['Job Description'] = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a job description!';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(labelText: "Job Description"),
                        ),
                      ),
                      // availability button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AvailabilityPage(
                                            isCompany: true,
                                            initialValue: jobData['availability'],
                                            onSave: (slots) {
                                              jobData['availability'] = slots;
                                            },
                                        )
                                    ));
                              },
                              style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4.0),
                                        side: BorderSide(
                                            color:
                                            Theme.of(context).colorScheme.primary))),
                              ),
                              child: const Text('Define Availability'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: OutlinedButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SimpleDialog(
                                          title: const Text("Repeat Frequency Preference"),
                                          children: repeatDialogueList
                                      );
                                    });
                              },
                              style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4.0),
                                        side: BorderSide(
                                            color:
                                            Theme.of(context).colorScheme.primary))),
                              ),
                              child: const Text('Choose Repeat Frequency'),
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
              // requirements title
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 16, 24, 4),
                child: Text("Requirements",
                    style: Theme.of(context).textTheme.displaySmall),
              ),
              // the place where the cards pop up
              AnimatedList(
                key: _animatedListKey,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                initialItemCount: requirements.length,
                itemBuilder: (context, index, animation) {
                  if (requirements['Subject ${index + 1}'] == null) {
                    requirements['Subject ${index + 1}'] = {};
                    requirements['Subject ${index + 1}']['Level'] = 1;
                  }

                  itemIndex = index + 1;
                  return itemCard(context,
                      itemNumber: itemIndex, animation: animation, onDelete: () {
                        itemIndex -= 1;
                        requirements.remove(itemIndex);
                      });
                },
              ),
              // add item button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      child: OutlinedButton(
                        onPressed: () {
                          // This inserts a item into the animated list.
                          _animatedListKey.currentState?.insertItem(itemIndex);
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
                        child: const Text('Add Requirement'),
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

class BoolDialogueOption extends StatefulWidget {
  const BoolDialogueOption({
    super.key,
    required this.title,
    required this.id,
    required this.initialValue,
    required this.onTap,
  });

  final String title;
  final String id;
  final bool initialValue;
  final Function(bool active, String repeat) onTap;

  @override
  State<BoolDialogueOption> createState() => _BoolDialogueOptionState();
}

class _BoolDialogueOptionState extends State<BoolDialogueOption> {
  late bool active;

  @override
  void initState() {
    super.initState();
    active = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: () async {
        setState(() {
          active = !active;
        });

        widget.onTap.call(active, widget.id);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.title),
          active ? const Icon(Icons.check) : const SizedBox.shrink()
        ],
      ),
    );
  }
}
