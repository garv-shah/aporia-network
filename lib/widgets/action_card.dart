/*
File: action_card.dart
Description: An action card used on the home screen to navigate to different pages
Author: Garv Shah
Created: Wed Jul 12 10:15:00 2023
 */

import 'package:flutter/material.dart';
import 'package:aporia_app/utils/config/config_parser.dart' as parse;
import 'package:aporia_app/utils/config/abilities.dart';

import '../screens/leaderboards.dart';
import '../screens/post_creation/create_post_view.dart';
import '../screens/scheduling/availability_page.dart';
import '../screens/scheduling/create_job_view.dart';
import '../screens/scheduling/manage_jobs_view.dart';
import '../screens/scheduling/schedule_view.dart';
import '../screens/section_views/admin_view/user_list_view.dart';
import '../screens/settings/settings_page.dart';

// A function to generate the action card carousel
List<Widget> actionCardCarousel(
  BuildContext context, {
  required bool isUser,
  required bool isAdmin,
  required bool isCompany,
  required List<String> userRoles,
  required parse.Config configMap,
  required Map<String, dynamic> userData,
  required Map<String, dynamic>? profileMap,
  List<Widget> customButtons = const [],
}) {
  // initialise widgetList with any possible custom buttons
  List<Widget> widgetList = customButtons;

  // TODO: make it so no widgets have to use the depreciated isUser, isAdmin etc
  Widget nameToWidget(String name) {
    switch (name) {
      case 'leaderboards':
        return Leaderboards(
          isAdmin: isAdmin,
        );
      case 'createJob':
        return CreateJob(
          userData: userData,
        );
      case 'availability':
        return const AvailabilityPage(
          isCompany: false,
        );
      case 'manageJobs':
        return ManageJobsPage(
          userData: userData,
          isAdmin: isAdmin,
          userRoles: userRoles,
          isCompany: isCompany,
        );
      case 'adminView':
        return UsersPage();
      case 'createPost':
        return CreatePost(
          isAdmin: isAdmin
        );
      case 'settings':
        return SettingsPage(
          userData: userData,
          isAdmin: isAdmin,
          userRoles: userRoles,
        );
      case 'schedule':
        return ScheduleView(
          jobList: profileMap?['jobList'] ?? [],
          isCompany: isCompany,
          isAdmin: isAdmin,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  IconData nameToIcon(String name) {
    switch (name) {
      case 'leaderboards':
        return Icons.people;
      case 'createJob':
        return Icons.work;
      case 'availability':
        return Icons.edit_calendar;
      case 'manageJobs':
        return Icons.manage_search_rounded;
      case 'adminView':
        return Icons.admin_panel_settings;
      case 'createPost':
        return Icons.create;
      case 'settings':
        return Icons.settings;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.bug_report;
    }
  }

  for (var i = 0; i < configMap.views.length; i++) {
    parse.View view = configMap.views[i];
    PositionPadding position;

    // position padding logic
    if (i == 0 && customButtons.isEmpty) {
      position = PositionPadding.start;
    } else if (i == configMap.views.length - 1) {
      position = PositionPadding.end;
    } else {
      position = PositionPadding.middle;
    }

    // logic on whether to show or not
    bool abilityShow = false;
    if (view.show.ability != null || (view.show.ability?.isNotEmpty ?? false)) {
      for (String ability in view.show.ability!) {
        if (getComputedAbilities(userRoles).contains(ability)) {
          abilityShow = true;
        }
      }
    } else {
      abilityShow = true;
    }
    if (view.show.ability?.isEmpty ?? false) abilityShow = true;

    bool roleShow = false;
    if (view.show.role != null) {
      for (String role in view.show.role!) {
        if (userRoles.contains(role)) {
          roleShow = true;
        }
      }
    } else {
      roleShow = true;
    }
    if (view.show.role?.isEmpty ?? false) roleShow = true;

    // finally if all checks have passed, add the view
    if (abilityShow && roleShow) {
      widgetList.add(ActionCard(
        icon: nameToIcon(view.name),
        text: view.displayName,
        navigateTo: nameToWidget(view.name),
        position: position,
      ));
    }
  }

  return widgetList;
}

/// An enum for the horizontal carousel that returns padding based on position.
enum PositionPadding {
  start(EdgeInsets.fromLTRB(38.0, 8.0, 8.0, 8.0)),
  middle(EdgeInsets.all(8.0)),
  end(EdgeInsets.fromLTRB(8.00, 8.0, 38.0, 8.0));

  const PositionPadding(this.padding);
  final EdgeInsetsGeometry padding;
}

/// Creates cards within horizontal carousel that complete an action.
class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.icon,
    required this.text,
    this.navigateTo,
    this.position = PositionPadding.middle,
    this.action,
  });

  final PositionPadding position;
  final IconData icon;
  final String text;
  final Widget? navigateTo;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: position.padding,
      child: Card(
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          splashColor: Theme.of(context).colorScheme.primary.withAlpha(40),
          highlightColor: Theme.of(context).colorScheme.primary.withAlpha(20),
          onTap: () {
            // try to navigate to page
            if (navigateTo != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => navigateTo!),
              );
            } else if (action != null) {
              action!.call();
            } else {
              debugPrint("navigateTo was null");
            }
          },
          // Builds icon and text inside card
          child: SizedBox(
            height: 151,
            width: 151,
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    color: Theme.of(context).colorScheme.primary, size: 100),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(text),
                )
              ],
            )),
          ),
        ),
      ),
    );
  }
}
