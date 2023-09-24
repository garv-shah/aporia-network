/*
File: schedule_view.dart
Description: A view for users to see their schedules
Author: Garv Shah
Created: Tue Jul 11 14:22:21 2023
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:aporia_app/screens/scheduling/availability_page.dart';

import '../../utils/components.dart';
import 'job_view.dart';

LessonDataSource? _dataSource;

class ScheduleView extends StatefulWidget {
  final List jobList;
  final bool isCompany;
  final bool isAdmin;

  const ScheduleView({Key? key, required this.jobList, required this.isCompany, required this.isAdmin}) : super(key: key);

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  @override
  void didChangeDependencies() {
    getDataFromFireStore().then((results) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    });
    super.didChangeDependencies();
  }

  Future<void> getDataFromFireStore() async {
    List<Appointment> list = [];

    for (Map<String, dynamic> job in widget.jobList) {
      int dayOfWeek = DateTime.parse(job['lessonTimes']['start']).weekday;

      list.add(Appointment(
          subject: job['Job Title'],
          notes: job['Job Description'],
          location: "2cousins Meeting",
          id: job['ID'],
          startTime: toLocalTime(DateTime.parse(job['lessonTimes']['start']), job['timezone']),
          endTime: toLocalTime(DateTime.parse(job['lessonTimes']['end']), job['timezone']),
          color: Theme.of(context).colorScheme.primary,
          recurrenceRule: getRecurrenceRule(dayOfWeek: dayOfWeek)
      ));
    }

    setState(() {
      _dataSource = LessonDataSource(list);
    });
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) {
    if (calendarTapDetails.appointments != null) {
      print(calendarTapDetails.appointments!.first.id);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  JobView(
                      jobID: calendarTapDetails.appointments!.first.id,
                      isCompany: widget.isCompany,
                      isAdmin: widget.isAdmin
                  )
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Schedule",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).primaryColorLight),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      body: SfCalendar(
        view: CalendarView.schedule,
        firstDayOfWeek: 1,
        onTap: calendarTapped,
        viewNavigationMode: ViewNavigationMode.none,
        showCurrentTimeIndicator: false,
        headerHeight: 0,
        dataSource: _dataSource,
        scheduleViewSettings: ScheduleViewSettings(
          monthHeaderSettings: MonthHeaderSettings(
            backgroundColor: Theme.of(context).cardColor,
          )
        ),
      ),
    );
  }
}
