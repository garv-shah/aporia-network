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

Future<LessonDataSource> jobListToDataSource(List<dynamic> jobList, {Color? color}) async {
  List<Appointment> list = [];

  for (Map<String, dynamic> job in jobList) {
    int dayOfWeek = DateTime.parse(job['lessonTimes']['start']).weekday;
    String repeat = job['lessonTimes']['repeat'];
    List<DateTime> recurrenceExceptionDates = [];

    // process exceptions
    if (job['lessonTimes']['exceptions'] != null) {
      for (Map<String, dynamic> exception in job['lessonTimes']['exceptions']['add']) {
        list.add(Appointment(
            subject: job['Job Title'],
            notes: job['Job Description'],
            location: "2cousins Meeting",
            id: job['ID'],
            startTime: toLocalTime(toDateTime(exception['from']), job['timezone']),
            endTime: toLocalTime(toDateTime(exception['to']), job['timezone']),
            color: color ?? Colors.indigoAccent,
        ));
      }

      for (Map<String, dynamic> exception in job['lessonTimes']['exceptions']['remove']) {
        DateTime start = toDateTime(exception['from']);
        recurrenceExceptionDates.add(start);
      }
    }

    // add the recurring lesson
    list.add(Appointment(
        subject: job['Job Title'],
        notes: job['Job Description'],
        location: "2cousins Meeting",
        id: job['ID'],
        startTime: toLocalTime(DateTime.parse(job['lessonTimes']['start']), job['timezone']),
        endTime: toLocalTime(DateTime.parse(job['lessonTimes']['end']), job['timezone']),
        color: color ?? Colors.indigoAccent,
        recurrenceRule: getRecurrenceRule(dayOfWeek: dayOfWeek, repeat: repeat),
        recurrenceExceptionDates: recurrenceExceptionDates
    ));
  }

  return LessonDataSource(list);
}

Future<Map<DateTime, Appointment>> jobListToDateTimeCollection(List<dynamic> jobList, {Color? color}) async {
  Map<DateTime, Appointment> returnMap = {};
  for (Map<String, dynamic> job in jobList) {
    int dayOfWeek = DateTime.parse(job['lessonTimes']['start']).weekday;
    String repeat = job['lessonTimes']['repeat'];
    List<DateTime> recurrenceExceptionDates = [];

    // add the recurring lesson
    String? recurrenceRule = getRecurrenceRule(dayOfWeek: dayOfWeek, repeat: repeat);
    DateTime startTime = toLocalTime(DateTime.parse(job['lessonTimes']['start']), job['timezone']);

    List<DateTime> timeList = SfCalendar.getRecurrenceDateTimeCollection(recurrenceRule ?? '', startTime);

    // process exceptions
    if (job['lessonTimes']['exceptions'] != null) {
      for (Map<String, dynamic> exception in job['lessonTimes']['exceptions']['add']) {
        timeList.add(toLocalTime(toDateTime(exception['from']), job['timezone']));
      }

      for (Map<String, dynamic> exception in job['lessonTimes']['exceptions']['remove']) {
        DateTime start = toDateTime(exception['from']);
        recurrenceExceptionDates.add(start);
      }
      timeList.removeWhere((element) => recurrenceExceptionDates.contains(element));
    }

    timeList.sort((a,b) {
      return a.compareTo(b);
    });

    for (DateTime time in timeList) {
      returnMap[time] = Appointment(
          subject: job['Job Title'],
          notes: job['Job Description'],
          location: "2cousins Meeting",
          id: job['ID'],
          startTime: time,
          endTime: time.add(const Duration(hours: 1)),
          color: color ?? Colors.indigoAccent,
      );
    }
  }

  return returnMap;
}

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
    jobListToDataSource(widget.jobList, color: Theme.of(context).colorScheme.primary).then((LessonDataSource result) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          _dataSource = result;
        });
      });
    });
    super.didChangeDependencies();
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) {
    if (calendarTapDetails.appointments != null) {
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
