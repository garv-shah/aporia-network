/*
File: manage_jobs_view.dart
Description: The general page where all orders can be viewed
Author: Garv Shah
Created: Fri Aug 5 22:25:21 2022
 */

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:aporia_app/screens/scheduling/job_selector_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:algolia/algolia.dart';
import 'package:aporia_app/widgets/section_app_bar.dart';
import 'dart:ui';

import '../home_page.dart';

/// An enum for the horizontal carousel that returns padding based on position.
enum PositionPadding {
  start(EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0)),
  middle(EdgeInsets.all(8.0)),
  end(EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 8.0));

  const PositionPadding(this.padding);
  final EdgeInsetsGeometry padding;
}

/// This is the page which allows all jobs to be searched and managed
class ManageJobsPage extends StatefulWidget {
  final bool isAdmin;
  final Map<String, dynamic> userData;
  const ManageJobsPage({Key? key, required this.isAdmin, required this.userData})
      : super(key: key);

  @override
  State<ManageJobsPage> createState() => _ManageJobsPageState();
}

class _ManageJobsPageState extends State<ManageJobsPage> {
  String searchValue = '';
  List<String> searchResults = ['nothing'];

  Algolia algolia = const Algolia.init(
    applicationId: '3AX0WXX57C',
    apiKey: '7d3fc81ef87a6ade4dcf5b845e3f8984',
  );

  updateSearch(String value) async {
    searchResults = ['nothing'];
    AlgoliaQuery query = algolia.instance.index('jobs').query(value);
    List<AlgoliaObjectSnapshot> results = (await query.getObjects()).hits;

    setState(() {
      searchValue = value;

      for (var result in results) {
        searchResults.add(result.objectID);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var pixelRatio = window.devicePixelRatio;
    var logicalScreenSize = window.physicalSize / pixelRatio;
    var logicalHeight = logicalScreenSize.height;

    return Scaffold(
      /// main body
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: StreamBuilder<QuerySnapshot>(
            key: ValueKey<String>(searchValue),
            // If there has been no search done, don't filter by search results,
            // but if a search has been done, only return documents within that
            stream: (searchValue == '')
                ? FirebaseFirestore.instance.collection('jobs').snapshots()
                : FirebaseFirestore.instance
                    .collection('jobs')
                    .where(FieldPath.documentId, whereIn: searchResults)
                    .snapshots(),
            builder: (context, ordersSnapshot) {
              if (ordersSnapshot.connectionState == ConnectionState.active) {
                List<Map<String, dynamic>> jobs = [];

                for (QueryDocumentSnapshot<Object?>? doc
                    in (ordersSnapshot.data?.docs ?? [])) {
                  Map<String, dynamic> json =
                      doc?.data() as Map<String, dynamic>;
                  json['ID'] = doc?.id;
                  json['reference'] = doc?.reference;
                  jobs.add(json);
                }

                return ListView(
                  children: [
                    SectionAppBar(context,
                        title: "Manage Jobs",
                        userData: widget.userData,
                        onSearch: (String search) => updateSearch(search),
                        searchController:
                            TextEditingController(text: searchValue), isAdmin: widget.isAdmin),
                    // If no orders are found, don't try to display them!
                    (jobs.isEmpty)
                        ? SizedBox(
                            height: logicalHeight - 120,
                            child: const Center(child: Text('Nothing found!')))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          26, 16, 0, 16),
                                      child: Text("Submitted Jobs",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4
                                              ?.copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColorLight)),
                                    ),
                              ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: jobs.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return jobCard(context, isAdmin: widget.isAdmin, data: jobs[index]);
                                      }),
                            ],
                          ),
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }
}
