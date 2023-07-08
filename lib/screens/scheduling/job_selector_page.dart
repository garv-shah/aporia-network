/*
File: job_selector_page.dart
Description: The page where users can select what job they would like to do
Author: Garv Shah
Created: Sat Jul 8 18:24:15 2023
 */

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aporia_app/screens/home_page.dart';
import 'package:aporia_app/utils/components.dart';

import 'availability_page.dart';

/**
 * The following section includes functions for the job selector page.
 */

/// An enum for the type of order.
enum JobState {
  inactive,
  active;
}

// Manage Jobs Card
Widget availableJobCard(BuildContext context,
    {PositionPadding position = PositionPadding.middle,
      required JobState type,
      required bool isAdmin,
      required List times,
      required Map<String, dynamic> data}) {
  Color statusColour = (() {
    if (data['status'] == 'pending_assignment') {
      return Colors.blue;
    } else if (data['status'] == 'not_started') {
      return Colors.red;
    } else if (data['status'] == 'in_progress') {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }());

  double screenWidth = MediaQuery.of(context).size.width;

  return Padding(
    padding: (type == JobState.active)
        ? position.padding
        : const EdgeInsets.fromLTRB(24.0, 6.0, 24.0, 6.0),
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
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AvailabilityPage(
                      restrictionZone: times,
                      onSave: (slots) {
                        print(slots);
                      },
                      isCompany: false,
                    )
                ));
          },
          child: Container(
              decoration: BoxDecoration(
                border: Border(
                    right: BorderSide(
                        color: (type == JobState.active)
                            ? Colors.transparent
                            : statusColour,
                        width: (type == JobState.active) ? 0 : 15)),
              ),
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: (type == JobState.active) ? 165 : null,
                width: (type == JobState.active) ? 165 : null,
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
                                      style: TextStyle(
                                          fontSize:
                                          (type == JobState.active) ? 16 : 25,
                                          overflow: (type == JobState.active)
                                              ? TextOverflow.ellipsis
                                              : TextOverflow.clip),
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
                                              color: Theme.of(context).highlightColor,
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
                            child: (type == JobState.active)
                                ? Container(
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(
                                color: statusColour,
                                border: const Border(),
                                shape: BoxShape.circle,
                              ),
                            )
                                : isAdmin ? SizedBox(
                              height: 32.0,
                              width: 32.0,
                              child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    showOkCancelAlertDialog(
                                        okLabel: 'Confirm',
                                        title: 'Delete Order',
                                        message:
                                        'Are you sure you want to delete this job?',
                                        context: context)
                                        .then((result) async {
                                      if (result == OkCancelResult.ok) {
                                        await FirebaseFirestore.instance
                                            .runTransaction((Transaction
                                        myTransaction) async {
                                          myTransaction
                                              .delete(data['reference']);
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
                          style: TextStyle(
                              overflow: (type == JobState.active)
                                  ? TextOverflow.ellipsis
                                  : TextOverflow.clip),
                          maxLines: (type == JobState.active) ? 1: null),
                      (type == JobState.inactive) ? const SizedBox(height: 10) : const Expanded(child: SizedBox.shrink()),
                      Row(
                        children: [
                          SizedBox(
                              height: 25,
                              width: 25,
                              child: fetchProfilePicture(
                                  data['createdBy']['profilePicture'],
                                  data['createdBy']['pfpType'],
                                  data['createdBy']['username'])),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(
                                  "By ${data['createdBy']['username']}",
                                  maxLines: 1)),
                          (type == JobState.inactive)
                              ? const SizedBox.shrink()
                              : SizedBox(
                            height: 32.0,
                            width: 32.0,
                            child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  showOkCancelAlertDialog(
                                      okLabel: 'Confirm',
                                      title: 'Delete Order',
                                      message:
                                      'Are you sure you want to delete this order?',
                                      context: context)
                                      .then((result) async {
                                    if (result == OkCancelResult.ok) {
                                      await FirebaseFirestore.instance
                                          .runTransaction((Transaction
                                      myTransaction) async {
                                        myTransaction
                                            .delete(data['reference']);
                                      });
                                    }
                                  });
                                },
                                child: Icon(Icons.delete,
                                    color: Theme.of(context).errorColor)),
                          ),
                        ],
                      )
                    ],
                  ),
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
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Gets the quizPoints collection ordered by the amount of experience
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
                          return Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: header("Available Jobs", context,
                                fontSize: 30, backArrow: true),
                          );
                        } else {
                          QueryDocumentSnapshot<Map<String, dynamic>>? document = jobSnapshot.data?.docs[index - 1];
                          Map<String, dynamic> data = document?.data() ?? {};
                          Iterable myAvailability = widget.availability.map((e) => e['from'].toString());
                          Iterable companyAvailability = data['availability'].map((e) => e['from'].toDate().toString());

                          List common = myAvailability.toSet().intersection(companyAvailability.toSet()).toList();

                          if (common.isNotEmpty) {
                            return availableJobCard(
                                context, type: JobState.inactive, data: data, isAdmin: false, times: common);
                          } else {
                            return const SizedBox.shrink();
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
