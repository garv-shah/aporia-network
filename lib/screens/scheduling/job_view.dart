import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:aporia_app/screens/scheduling/create_job_view.dart';
import 'package:aporia_app/screens/section_views/admin_view/user_list_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:aporia_app/screens/home_page.dart';
import 'package:aporia_app/utils/components.dart';
import 'package:flutter_extensions/flutter_extensions.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../section_views/admin_view/manage_user_page.dart';
import 'availability_page.dart';

enum StatusStates { pendingAssignment, assigned }

/// Creates cards that represent jobs.
Widget informationCard(
    {required String title,
    required String information,
    bool noSidePadding = false,
    void Function()? editAction,
    Widget? actionWidget}) {
  return Padding(
    padding: noSidePadding
        ? const EdgeInsets.fromLTRB(0, 4, 0, 4)
        : const EdgeInsets.fromLTRB(24, 4, 24, 4),
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 88,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(fontSize: 25)),
                            Text(information, softWrap: true),
                          ],
                        ),
                      );
                    }
                  ),
                  (editAction != null)
                      ? Builder(builder: (context) {
                          return SizedBox(
                            height: 32.0,
                            width: 32.0,
                            child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  editAction.call();
                                },
                                child: Icon(Icons.edit,
                                    color: Theme.of(context).hintColor)),
                          );
                        })
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            (actionWidget != null) ? actionWidget : const SizedBox.shrink()
          ],
        ),
      ),
    ),
  );
}

String ordinal(int number) {
  if (!(number >= 1 && number <= 100)) {
    //here you change the range
    throw Exception('Invalid number');
  }

  if (number >= 11 && number <= 13) {
    return 'th';
  }

  switch (number % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

// the following function creates a string from lesson times and a frequency
String lessonTimeString(
    dynamic start, dynamic end, String timezone, String repeatTag) {
  DateTime startTime = DateTime.parse(start);
  startTime = toLocalTime(startTime, timezone);
  String prefix = "";
  var formatter = DateFormat('dd/MM/yyyy');

  if (repeatTag == "daily") {
    prefix = "Every day";
  } else if (repeatTag == "weekly") {
    prefix = "Every ${DateFormat('EEEE').format(startTime)}";
  } else if (repeatTag == "fortnightly") {
    prefix = "Every 2nd ${DateFormat('EEEE').format(startTime)}";
  } else if (repeatTag == "monthly") {
    prefix = "${ordinal(startTime.day)} of every month";
  } else if (repeatTag == "once") {
    prefix = formatter.format(startTime);
  }

  DateTime endTime = DateTime.parse(end);
  endTime = toLocalTime(endTime, timezone);
  return "$prefix ${DateFormat('h:mm a').format(startTime)} - ${DateFormat('h:mm a').format(endTime)}";
}

/**
 * The following section includes the actual JobView page.
 */

/// This is the view where orders can be seen.
class JobView extends StatefulWidget {
  final String jobID;
  final bool isCompany;
  final bool isAdmin;
  const JobView(
      {Key? key,
      required this.jobID,
      required this.isCompany,
      required this.isAdmin})
      : super(key: key);

  @override
  State<JobView> createState() => _JobViewState();
}

class _JobViewState extends State<JobView> {
  StatusStates? selectedStatus;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? data;
    bool assignedToMe = false;
    bool createdByMe = false;

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .doc(widget.jobID)
            .snapshots(),
        builder: (context, jobSnapshot) {
          if (jobSnapshot.connectionState == ConnectionState.active) {
            data = jobSnapshot.data?.data() as Map<String, dynamic>;
            data?['ID'] = jobSnapshot.data?.id;

            if (data?['assignedTo'] != null) {
              assignedToMe = data?['assignedTo']['id'] ==
                  FirebaseAuth.instance.currentUser!.uid;
            }

            if (data?['createdBy'] != null) {
              createdByMe = data?['createdBy']['id'] ==
                  FirebaseAuth.instance.currentUser!.uid;
            }

            selectedStatus = (() {
              if (data?['status'] == 'pending_assignment') {
                return StatusStates.pendingAssignment;
              } else if (data?['status'] == 'assigned') {
                return StatusStates.assigned;
              } else {
                // something has gone terribly wrong
                return StatusStates.assigned;
              }
            }());

            Map<String, dynamic> personData;
            bool showAssignedTo =
                widget.isCompany && data?['status'] == 'assigned';
            if (showAssignedTo) {
              personData = data?['assignedTo'];
            } else {
              personData = data?['createdBy'];
            }

            return Scaffold(
              floatingActionButton: assignedToMe ||
                      createdByMe ||
                      widget.isAdmin
                  ? FloatingActionButton.extended(
                      onPressed: () {
                        if (createdByMe || widget.isAdmin) {
                          // go to edit the job
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreateJob(
                                      jobData: data,
                                      userData: data?['createdBy'])));
                        } else {
                          // show confirmation dialog
                          showOkCancelAlertDialog(
                                  okLabel: 'Confirm',
                                  title: 'Leave Job?',
                                  message:
                                      'Leaving this job will delete it from your calendar and make it once again available for other volunteers to claim. Are you sure you want to leave this job?',
                                  context: context)
                              .then((result) async {
                            if (result == OkCancelResult.ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Leaving Job! This may take a couple seconds, hold on tight.",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColorLight),
                                  ),
                                  backgroundColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                ),
                              );

                              await FirebaseFunctions.instanceFor(
                                      region: 'australia-southeast1')
                                  .httpsCallable('unassignJob')
                                  .call({
                                'jobID': data?['ID'],
                                'deleteOperation': false,
                              });
                            }
                          });
                        }
                      },
                      backgroundColor: (createdByMe || widget.isAdmin) ? Theme.of(context).floatingActionButtonTheme.backgroundColor : Colors.red,
                      label: (createdByMe || widget.isAdmin)
                          ? const Text("Edit")
                          : const Text("Leave Job"),
                      icon: (createdByMe || widget.isAdmin)
                          ? const Icon(Icons.edit)
                          : const Icon(Icons.exit_to_app),
                    )
                  : null,
              body: ListView(children: [
                // heading
                header("View Job", context, fontSize: 20, backArrow: true),
                // row with client name and assignment status
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 4, 40, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(40.0),
                          onTap: () async {
                            FirebaseFirestore.instance
                                .collection('roles')
                                .get()
                                .then((QuerySnapshot<Map<String, dynamic>>
                                    roles) {
                              String userRole = "Unknown Role";

                              for (var role in roles.docs) {
                                if (role
                                        .data()['members']
                                        .contains(personData['id']) &&
                                    userRole == "Unknown Role") {
                                  userRole = role.data()['tag'];
                                }
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ManageUserPage(
                                    userInfo: UserModel(
                                      username: personData['username'],
                                      role: userRole,
                                      email: personData['email'],
                                      profilePicture:
                                          personData['profilePicture'],
                                      pfpType: personData['pfpType'],
                                      userType: personData['userType'],
                                      id: personData['id'],
                                    ),
                                    canEdit: widget.isAdmin,
                                  ),
                                ),
                              );
                            });
                          },
                          child: Row(children: [
                            Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: SizedBox(
                                      height: 75,
                                      width: 75,
                                      child: fetchProfilePicture(
                                          personData['profilePicture'],
                                          personData['pfpType'],
                                          personData['username'])),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ), child: const Padding(
                                    padding: EdgeInsets.all(6.0),
                                    child: Icon(
                                      Icons.email,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  )),
                                )
                              ],
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 325,
                                    child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(personData['username'],
                                            style: const TextStyle(
                                                fontSize: 30)))),
                                Text(showAssignedTo ? "Volunteer" : "Company"),
                              ],
                            ),
                          ]),
                        ),
                      ),
                      Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: Material(
                              color: (() {
                                if (data?['status'] == 'pending_assignment') {
                                  return Colors.blue;
                                } else if (data?['status'] == 'assigned') {
                                  return Colors.green;
                                } else {
                                  return Colors.green;
                                }
                              }()),
                              child: PopupMenuButton(
                                tooltip: "Change Order Status",
                                enableFeedback: true,
                                enabled: widget.isCompany || widget.isAdmin,
                                initialValue: selectedStatus,
                                onSelected: (StatusStates status) async {
                                  if (status == StatusStates.assigned) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                              title: const Text('Error!'),
                                              content: const Text(
                                                  'You cannot manually set the status to assigned! A volunteer must select this job themselves'),
                                              actions: [
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .labelLarge,
                                                  ),
                                                  child: const Text('Okay'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ]);
                                        });
                                  } else if (status ==
                                      StatusStates.pendingAssignment) {
                                    // show confirmation dialog
                                    showOkCancelAlertDialog(
                                            okLabel: 'Confirm',
                                            title: 'Unassign Job?',
                                            message:
                                                'Unassigning this job will delete it from the calendar and make it once again available for other volunteers to claim. Are you sure you want to unassign this job?',
                                            context: context)
                                        .then((result) async {
                                      if (result == OkCancelResult.ok) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Unassigning Job! This may take a couple seconds, hold on tight.",
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorLight),
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                          ),
                                        );

                                        await FirebaseFunctions.instanceFor(
                                                region: 'australia-southeast1')
                                            .httpsCallable('unassignJob')
                                            .call({
                                          'jobID': data?['ID'],
                                          'deleteOperation': false,
                                        });
                                      }
                                    });
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<StatusStates>>[
                                  if (widget.isCompany || widget.isAdmin)
                                    const PopupMenuItem<StatusStates>(
                                      value: StatusStates.pendingAssignment,
                                      textStyle: TextStyle(color: Colors.blue),
                                      child: Text('Pending Assignment'),
                                    ),
                                  const PopupMenuItem<StatusStates>(
                                    value: StatusStates.assigned,
                                    textStyle: TextStyle(color: Colors.green),
                                    child: Text('Assigned!'),
                                  ),
                                ],
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                      (() {
                                        if (data?['status'] ==
                                            'pending_assignment') {
                                          return 'Pending\nAssignment';
                                        } else if (data?['status'] ==
                                            'assigned') {
                                          return 'Assigned!';
                                        } else {
                                          return 'Error :/';
                                        }
                                      }()),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                          ))
                    ],
                  ),
                ),

                (data?['status'] != "pending_assignment")
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(40, 12, 40, 4),
                        child: OutlinedButton(
                            onPressed: () async {
                              final uri = Uri.parse(data?['meetUrl']);
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            },
                            style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.primary,
                                side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                minimumSize: const Size(80, 40),
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                )),
                            child: Text(
                              'Join Lesson',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            )),
                      )
                    : const SizedBox.shrink(),

                // Job Details
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 16, 24, 4),
                  child: Text("Job Details",
                      style: Theme.of(context).textTheme.displaySmall),
                ),
                informationCard(
                    title: "Job Title", information: data?["Job Title"]),
                informationCard(
                    title: "Job Description",
                    information: data?["Job Description"]),
                data?['status'] == 'assigned'
                    ? informationCard(
                        title: "Lesson Times",
                        information: lessonTimeString(
                            data?["lessonTimes"]["start"],
                            data?["lessonTimes"]["end"],
                            data?["timezone"],
                            data?["lessonTimes"]['repeat']),
                        editAction: () {
                          Map<String, dynamic> lessonData = data?['lessonTimes'];
                          lessonData['timezone'] = data?['timezone'];
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AvailabilityPage(
                                    isCompany: true,
                                    modifyingSchedule: true,
                                    initialValue: lessonData,
                                    onSave: (slots) async {
                                      // add the exceptions onto Firebase
                                      if (data != null) {
                                        FirebaseFirestore.instance.collection('jobs').doc(widget.jobID).update({
                                          'lessonTimes': {
                                            'exceptions': slots['exceptions'],
                                            'start': lessonData['start'],
                                            'end': lessonData['end'],
                                            'repeat': lessonData['repeat'],
                                          }
                                        });

                                        await FirebaseFunctions.instanceFor(region: 'australia-southeast1')
                                            .httpsCallable('updateJob')
                                            .call({'jobID': widget.jobID});
                                      }
                                    },
                                  )
                              ));
                        })
                    : const SizedBox.shrink(),

                // Requirements
                (data?['requirements'].length != 0)
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(40, 16, 24, 4),
                        child: Text("Requirements",
                            style: Theme.of(context).textTheme.displaySmall),
                      )
                    : const SizedBox.shrink(),
                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: data?['requirements'].length,
                    itemBuilder: (BuildContext context, int itemNum) {
                      Map<String, dynamic>? requirement =
                          data?["requirements"]["Subject ${itemNum + 1}"];

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Yr${requirement?["Level"].toString() ?? '0'} ${requirement?["Subject"]}",
                                    style: const TextStyle(fontSize: 18)),
                                (requirement?["Extra Notes"] == null ||
                                        requirement?["Extra Notes"].isEmpty)
                                    ? const SizedBox.shrink()
                                    : Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child:
                                            Text(requirement?["Extra Notes"]),
                                      )
                              ],
                            ),
                          ),
                        ),
                      );
                    })
              ]),
            );
          } else {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
        });
  }
}
