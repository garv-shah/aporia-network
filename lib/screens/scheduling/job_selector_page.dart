/*
File: job_selector_page.dart
Description: The page where users can select what job they would like to do
Author: Garv Shah
Created: Sat Jul 8 18:24:15 2023
 */

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:aporia_app/screens/home_page.dart';
import 'package:aporia_app/utils/components.dart';
import 'package:aporia_app/widgets/action_card.dart';
import 'availability_page.dart';
import 'job_view.dart';

/**
 * The following section includes functions for the job selector page.
 */

/// An enum for the type of order.

// Manage Jobs Card
Widget jobCard(BuildContext context,
    {PositionPadding position = PositionPadding.middle,
      required bool isAdmin,
      required bool isCompany,
      bool showAssigned = false,
      List? times,
      required Map<String, dynamic> data}) {
  Color statusColour = (() {
    if (data['status'] == 'pending_assignment') {
      return Colors.blue;
    } else if (data['status'] == 'assigned') {
      return Colors.green;
    } else {
      // some form of status error
      return Colors.red;
    }
  }());

  double screenWidth = MediaQuery.of(context).size.width;
  showAssigned = showAssigned && data['assignedTo'] != null;
  String? subtitleUser = showAssigned ? 'assignedTo' : 'createdBy';

  return Padding(
    padding: const EdgeInsets.fromLTRB(24.0, 6.0, 24.0, 6.0),
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: ClipPath(
        clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () {
            if (times != null) {
              final functions = FirebaseFunctions.instanceFor(
                  region: 'australia-southeast1');
              void claimJob(List chosenTime) {
                showOkCancelAlertDialog(
                    okLabel: 'Confirm',
                    title: 'Claim Job',
                    message:
                    'This is a commitment that you will be making to us and the company that you will complete the job to the best of your abilities. Are you sure you want to claim this job?',
                    context: context)
                    .then((result) async {
                  if (result == OkCancelResult.ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Claiming Job!",
                          style: TextStyle(color: Theme
                              .of(context)
                              .primaryColorLight),
                        ),
                        backgroundColor: Theme
                            .of(context)
                            .scaffoldBackgroundColor,
                      ),
                    );
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();

                    DateTime.now().copyWith(year: DateTime.now().year);

                    await functions
                        .httpsCallable('claimJob')
                        .call({
                      'jobID': data['Job ID'],
                      'startTime': chosenTime[0]['from'].toIso8601String().toString(),
                      'endTime': chosenTime[0]['to'].toIso8601String().toString(),
                      'timezone': timezoneNames[DateTime.now().timeZoneOffset.inMilliseconds],
                    });
                  }
                });
              }

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AvailabilityPage(
                            restrictionZone: times,
                            onSave: (slots) {
                              claimJob(slots);
                            },
                            isCompany: false,
                          )
                  ));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => JobView(jobID: data['Job ID'], isCompany: isCompany, isAdmin: isAdmin)
                  ));
            }
          },
          child: Container(
              decoration: BoxDecoration(
                border: Border(
                    right: BorderSide(
                        color: statusColour,
                        width: 15)),
              ),
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                    "${data["Job Title"]}",
                                    style: const TextStyle(
                                        fontSize: 25,
                                        overflow: TextOverflow.clip
                                    ),
                                    maxLines: 1),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: SizedBox(
                                    height: 35,
                                    child: ListView.builder(
                                        physics: const NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount: (data['requirements'].length > 2)
                                            ? (screenWidth < 500) ? 2 : 3
                                            : data['requirements'].length,
                                        itemBuilder: (BuildContext context, int itemNum) {
                                          if ((data['requirements'].length > 2 && itemNum == 2) | (screenWidth < 500 && data['requirements'].length > 1 && itemNum == 1)) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                              child: Card(
                                                color: Theme.of(context).highlightColor,
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                                                  child: Text(
                                                    "More",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          Map<String, dynamic>? requirement = data["requirements"]["Subject ${itemNum + 1}"];
                                          return Card(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(8)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                                              child: Text(
                                                "Yr${requirement?["Level"].toString() ?? '0'} ${requirement?["Subject"]}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: isCompany ? SizedBox(
                            height: 32.0,
                            width: 32.0,
                            child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  showOkCancelAlertDialog(
                                      okLabel: 'Confirm',
                                      title: 'Delete Job',
                                      message: 'Are you sure you want to delete this job?',
                                      context: context)
                                      .then((result) async {
                                    if (result == OkCancelResult.ok) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Deleting Job! This may take a couple seconds, hold on tight.",
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
                                        'jobID': data['Job ID'],
                                        'deleteOperation': true,
                                      });
                                    }
                                  });
                                },
                                child: Icon(Icons.delete,
                                    color:
                                    Theme.of(context).errorColor)),
                          ) : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    Text(
                        "${data["Job Description"]}",
                        style: const TextStyle(
                            overflow: TextOverflow.clip
                        ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(
                            height: (times?.isNotEmpty ?? false) ? 30 : 25,
                            width: (times?.isNotEmpty ?? false) ? 30 : 25,
                            child: fetchProfilePicture(
                                data[subtitleUser]['profilePicture'],
                                data[subtitleUser]['pfpType'],
                                data[subtitleUser]['username'])),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(
                                "${showAssigned ? 'Assigned to' : 'By'} ${data[subtitleUser]['username']}",
                                maxLines: 1)),
                        // how many times available counter
                        (times?.isNotEmpty ?? false) ? SizedBox(
                          height: 35,
                          child: Card(
                            color: Theme.of(context).indicatorColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                              child: Text(
                                "${times?.length ?? 0} availabilities",
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ) : const SizedBox.shrink(),
                      ],
                    ),
                  ],
                ),
              )),
        ),
      ),
    ),
  );
}

/**
 * The following section includes the actual leaderboards page.
 */

/// This is the leaderboards page for rankings based on experience.
class AvailableJobsPage extends StatefulWidget {
  final List availability;
  const AvailableJobsPage({Key? key, required this.availability}) : super(key: key);

  @override
  State<AvailableJobsPage> createState() => _AvailableJobsPageState();
}

class _AvailableJobsPageState extends State<AvailableJobsPage> {
  @override
  Widget build(BuildContext context) {
    int availableJobsCounter = 0;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Gets the publicProfile collection ordered by the amount of experience
        // each user has.
          stream: FirebaseFirestore.instance
              .collection('jobs')
              .where('status', isEqualTo: 'pending_assignment')
              .snapshots(),
          builder: (context, jobSnapshot) {
            if (jobSnapshot.connectionState == ConnectionState.active) {
              return SafeArea(
                child: Center(
                  child: SizedBox(
                    width: 760,
                    child: ListView.builder(
                      itemCount: (jobSnapshot.data?.docs.length ?? 0) + 1,
                      itemBuilder: (BuildContext context, int index) {
                        // If index is first, return header, if not, return user entry.
                        if (index == 0) {
                          // Header.
                          if (jobSnapshot.data?.docs.isEmpty ?? true) {
                            // there are no pending_assignment jobs at all
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                header("Available Jobs", context,
                                    fontSize: 30, backArrow: true),
                                const Flexible(
                                    child: Padding(
                                      padding: EdgeInsets.all(48),
                                        child: Text(
                                            "There are currently no jobs available. Please check back later to see if we have any jobs for you!",
                                          textAlign: TextAlign.center,
                                        )
                                    )
                                )
                              ],
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: header("Available Jobs", context,
                                  fontSize: 30, backArrow: true),
                            );
                          }
                        } else {
                          QueryDocumentSnapshot<Map<String, dynamic>>? document = jobSnapshot.data?.docs[index - 1];
                          Map<String, dynamic> data = document?.data() ?? {};
                          data['Job ID'] = document?.id;
                          Iterable myAvailability = widget.availability.map((e) => e['from'].toString());
                          Iterable companyAvailability = data['availability'].map((e) => e['from'].toDate().toString());

                          List common = myAvailability.toSet().intersection(companyAvailability.toSet()).toList();

                          if (common.isNotEmpty) {
                            availableJobsCounter++;
                            return jobCard(context, data: data, isAdmin: false, isCompany: false, times: common);
                          } else {
                            if (availableJobsCounter == 0 && index == (jobSnapshot.data?.docs.length ?? 0)) {
                              return const Padding(
                                  padding: EdgeInsets.all(48),
                                  child: Text("There are no jobs currently "
                                      "available when you are free. "
                                      "Please check back later to see if "
                                      "we have any jobs for you!",
                                    textAlign: TextAlign.center,
                                  )
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }
                        }
                      },
                    ),
                  ),
                ),
              );
            } else {
              // Display loading indicator while page is loading.
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
