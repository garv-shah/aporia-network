import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:aporia_app/screens/scheduling/create_job_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:aporia_app/screens/home_page.dart';
import 'package:aporia_app/utils/components.dart';
import 'package:url_launcher/url_launcher.dart';

enum StatusStates { pendingAssignment, assigned }

/// Creates cards that represent jobs.
Widget informationCard(
    {required String title,
    required String information,
    bool noSidePadding = false,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 25)),
                  Text(information),
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

/**
 * The following section includes the actual OrderView page.
 */

/// This is the view where orders can be seen.
class JobView extends StatefulWidget {
  final String jobID;
  final bool isCompany;
  const JobView({Key? key, required this.jobID, required this.isCompany})
      : super(key: key);

  @override
  State<JobView> createState() => _JobViewState();
}

class _JobViewState extends State<JobView> {
  StatusStates? selectedStatus;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? data;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.isCompany) {
            // go to edit the job
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateJob(
                        jobData: data, userData: data?['createdBy'])));
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
                      style: TextStyle(color: Theme
                          .of(context)
                          .primaryColorLight),
                    ),
                    backgroundColor: Theme
                        .of(context)
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
        child: (widget.isCompany)
            ? const Icon(Icons.edit)
            : const Icon(Icons.exit_to_app),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('jobs')
              .doc(widget.jobID)
              .snapshots(),
          builder: (context, jobSnapshot) {
            if (jobSnapshot.connectionState == ConnectionState.active) {
              data = jobSnapshot.data?.data() as Map<String, dynamic>;
              data?['ID'] = jobSnapshot.data?.id;

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

              return ListView(children: [
                // heading
                header("View Job", context, fontSize: 20, backArrow: true),
                // row with client name and assignment status
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 4, 40, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(children: [
                          SizedBox(
                              height: 75,
                              width: 75,
                              child: fetchProfilePicture(
                                  personData['profilePicture'],
                                  personData['pfpType'],
                                  personData['username'])),
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
                                          style:
                                              const TextStyle(fontSize: 30)))),
                              Text(showAssignedTo ? "Volunteer" : "Company"),
                            ],
                          ),
                        ]),
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
                                enabled: widget.isCompany,
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
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Unassigning Job! This may take a couple seconds, hold on tight.",
                                              style: TextStyle(color: Theme
                                                  .of(context)
                                                  .primaryColorLight),
                                            ),
                                            backgroundColor: Theme
                                                .of(context)
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
                                  if (widget.isCompany)
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

                // pickup
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

                // items
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
              ]);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
