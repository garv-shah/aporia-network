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

import 'job_view.dart';

LessonDataSource? _dataSource;

class ScheduleView extends StatefulWidget {
  final List jobList;
  final bool isCompany;

  const ScheduleView({Key? key, required this.jobList, required this.isCompany}) : super(key: key);

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
      String recurrenceDay = 'MO';

      if (dayOfWeek == 1) {
        recurrenceDay = 'MO';
      } else if (dayOfWeek == 2) {
        recurrenceDay = 'TU';
      } else if (dayOfWeek == 3) {
        recurrenceDay = 'WE';
      } else if (dayOfWeek == 4) {
        recurrenceDay = 'TH';
      } else if (dayOfWeek == 5) {
        recurrenceDay = 'FR';
      } else if (dayOfWeek == 6) {
        recurrenceDay = 'SA';
      } else if (dayOfWeek == 7) {
        recurrenceDay = 'SU';
      }

      list.add(Appointment(
          subject: job['Job Title'],
          notes: job['Job Description'],
          location: "2cousins Meeting",
          id: job['ID'],
          startTimeZone: job['timezone'],
          endTimeZone: job['timezone'],
          startTime: DateTime.parse(job['lessonTimes']['start']),
          endTime: DateTime.parse(job['lessonTimes']['end']),
          color: Theme.of(context).colorScheme.primary,
          recurrenceRule: 'FREQ=WEEKLY;INTERVAL=1;BYDAY=$recurrenceDay'
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
                      isCompany: widget.isCompany
                  )
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Schedule",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
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
