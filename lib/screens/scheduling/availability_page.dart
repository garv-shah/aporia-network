/*
File: availability_page.dart
Description: Where users can define their availability
Author: Garv Shah
Created: Sat Jul 8 17:04:21 2023
 */

import 'package:aporia_app/screens/scheduling/job_selector_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

typedef DataCallback = void Function(List data);
LessonDataSource? _dataSource;

class LessonDataSource extends CalendarDataSource {
  LessonDataSource(List<Appointment> source){
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime;
  }

  @override
  String getSubject(int index) {
    return appointments![index].subject;
  }

  @override
  Color getColor(int index) {
    return appointments![index].color;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class AvailabilityPage extends StatefulWidget {
  final bool isCompany;
  final List? initialValue;
  final DataCallback? onSave;
  final List? restrictionZone;

  const AvailabilityPage({Key? key, required this.isCompany, this.onSave, this.initialValue, this.restrictionZone}) : super(key: key);

  @override
  State<AvailabilityPage> createState() => _AvailabilityPageState();
}

class _AvailabilityPageState extends State<AvailabilityPage> {
  @override
  void initState() {
    if (widget.restrictionZone == null) {
      getDataFromFireStore().then((results) {
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          setState(() {});
        });
      });
    } else {
      _dataSource = LessonDataSource([]);
    }
    super.initState();
  }

  Future<void> getDataFromFireStore() async {
    DocumentSnapshot availabilitySnapshot = await FirebaseFirestore.instance
        .collection("availability")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    List slots = widget.initialValue ?? ((availabilitySnapshot.data() as Map<String, dynamic>?)?['slots'] ?? []);

    List<Appointment> list = [];

    for (var slot in slots) {
      list.add(Appointment(
          subject: widget.restrictionZone == null ? 'Available!' : 'Lesson Time!',
          startTime: slot['from'] is DateTime ? slot['from'] : DateTime.parse(slot['from'].toDate().toString()),
          endTime: slot['to'] is DateTime ? slot['to'] : DateTime.parse(slot['to'].toDate().toString()),
          color: Theme.of(context).colorScheme.primary
      ));
    }

    setState(() {
      _dataSource = LessonDataSource(list);
    });
  }

  @override
  Widget build(BuildContext context) {
    void calendarTapped(CalendarTapDetails calendarTapDetails) {
      DateTime startTime = calendarTapDetails.date!;
      DateTime endTime = calendarTapDetails.date!.add(const Duration(hours: 1));
      Appointment lesson = Appointment(
          subject: widget.restrictionZone == null ? 'Available!' : 'Lesson Time!',
          startTime: startTime,
          endTime: endTime,
          color: Theme.of(context).colorScheme.primary
      );
      List? lessonsInSlot = _dataSource?.appointments?.where((element) => element.startTime == lesson.startTime).toList();
      bool filled = lessonsInSlot?.isNotEmpty ?? false;
      if (filled) {
        // remove lesson
        _dataSource?.appointments!.remove(lessonsInSlot![0]);
        _dataSource?.notifyListeners(CalendarDataSourceAction.remove, <Appointment>[lessonsInSlot![0]]);
      } else {
        // add lesson
        // if we are simply selecting availability, you should be able to select
        // multiple times. If we are selecting a specific lesson slot, then you
        // should only be able to select one time.
        if (widget.restrictionZone == null) {
          _dataSource?.appointments!.add(lesson);
          _dataSource?.notifyListeners(
              CalendarDataSourceAction.add, <Appointment>[lesson]);
        } else {
          Navigator.of(context).pop();
          widget.onSave!([{
            'from': lesson.startTime,
            'to': lesson.endTime,
          }]);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Availability Selector",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).primaryColorLight),
            onPressed: () {
              saveAvailability(true);
            }),
      ),
      body: SfCalendar(
        view: CalendarView.week,
        firstDayOfWeek: 1,
        viewNavigationMode: ViewNavigationMode.none,
        showCurrentTimeIndicator: false,
        headerHeight: 0,
        dataSource: _dataSource,
        onTap: calendarTapped,
        initialDisplayDate: DateTime(2018, 1, 1),
        specialRegions: _getTimeRegions(widget.restrictionZone ?? []),
      ),
      floatingActionButton: (widget.restrictionZone == null) ? FloatingActionButton.extended(
        onPressed: () {
          saveAvailability(false);
        },
        label: widget.isCompany ? const Text("Save") : const Text("Continue"),
        icon: widget.isCompany ? const Icon(Icons.check) : const Icon(Icons.arrow_forward),
      ) : null,
    );
  }

  List<TimeRegion> _getTimeRegions(List times) {
    final List<TimeRegion> regions = <TimeRegion>[];

    if (times.isEmpty) return regions;

    List<int> relativeTimes = [];

    for (var i = 0; i < times.length; i++) {
      relativeTimes.add(DateTime.parse(times[i]).difference(DateTime(2018, 1, 1)).inHours);
    }

    for (var i = 0; i < 168; i++) {
      if (!relativeTimes.contains(i)) {
        regions.add(TimeRegion(
          startTime: DateTime(2018, 1, 1).add(Duration(hours: i)),
          endTime: DateTime(2018, 1, 1).add(Duration(hours: i + 1)),
          enablePointerInteraction: false,
        ));
      }
    }

    return regions;
  }

  void saveAvailability(bool backArrow) {
    List slots = [];
    for (var lesson in _dataSource?.appointments as List<Appointment>) {
      slots.add({
        'from': lesson.startTime,
        'to': lesson.endTime,
      });
    }

    if (widget.onSave == null) {
      // update Firebase
      FirebaseFirestore.instance
          .collection("availability")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set({
        'slots': slots
      });
      if (!backArrow) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AvailableJobsPage(availability: slots)),
        );
      } else {
        Navigator.of(context).pop();
      }
    } else {
      widget.onSave!(slots);
      Navigator.of(context).pop();
    }
  }
}
