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
import 'package:syncfusion_flutter_calendar/calendar.dart';

typedef DataCallback = void Function(List data);
LessonDataSource? _dataSource;

class LessonDataSource extends CalendarDataSource {
  LessonDataSource(List<Lesson> source){
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Lesson {
  Lesson({
    required this.eventName,
    required this.from,
    required this.to,
    required this.background,
    this.isAllDay = false}
  );

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
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

    List<Lesson> list = [];

    for (var slot in slots) {
      list.add(Lesson(
          eventName: widget.restrictionZone == null ? 'Available!' : 'Lesson Time!',
          from: DateTime.parse(slot['from'] is DateTime ? slot['from'] : slot['from'].toDate().toString()),
          to: DateTime.parse(slot['to'] is DateTime ? slot['to'] : slot['to'].toDate().toString()),
          background: Theme.of(context).colorScheme.primary
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
      Lesson lesson = Lesson(
          eventName: widget.restrictionZone == null ? 'Available!' : 'Lesson Time!',
          from: startTime,
          to: endTime,
          background: Theme.of(context).colorScheme.primary
      );
      List? lessonsInSlot = _dataSource?.appointments?.where((element) => element.from == lesson.from).toList();
      bool filled = lessonsInSlot?.isNotEmpty ?? false;
      if (filled) {
        // remove lesson
        _dataSource?.appointments!.remove(lessonsInSlot![0]);
        _dataSource?.notifyListeners(CalendarDataSourceAction.remove, <Lesson>[lessonsInSlot![0]]);
      } else {
        // add lesson
        // if we are simply selecting availability, you should be able to select
        // multiple times. If we are selecting a specific lesson slot, then you
        // should only be able to select one time.
        if (widget.restrictionZone == null) {
          _dataSource?.appointments!.add(lesson);
          _dataSource?.notifyListeners(
              CalendarDataSourceAction.add, <Lesson>[lesson]);
        } else {
          _dataSource?.appointments!.clear();
          _dataSource?.notifyListeners(CalendarDataSourceAction.reset, <Lesson>[lesson]);

          _dataSource?.appointments!.add(lesson);
          _dataSource?.notifyListeners(
              CalendarDataSourceAction.add, <Lesson>[lesson]);
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
              Navigator.of(context).pop();
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
        initialDisplayDate: DateTime(1990, 1, 1),
        specialRegions: _getTimeRegions(widget.restrictionZone ?? []),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          saveAvailability(false);
        },
        label: widget.isCompany ? const Text("Save") : const Text("Continue"),
        icon: widget.isCompany ? const Icon(Icons.check) : const Icon(Icons.arrow_forward),
      ),
    );
  }

  List<TimeRegion> _getTimeRegions(List times) {
    final List<TimeRegion> regions = <TimeRegion>[];

    if (times.isEmpty) return regions;

    List<int> relativeTimes = [];

    for (var i = 0; i < times.length; i++) {
      relativeTimes.add(DateTime.parse(times[i]).difference(DateTime(1990, 1, 1)).inHours);
    }

    for (var i = 0; i < 168; i++) {
      if (!relativeTimes.contains(i)) {
        regions.add(TimeRegion(
          startTime: DateTime(1990, 1, 1).add(Duration(hours: i)),
          endTime: DateTime(1990, 1, 1).add(Duration(hours: i + 1)),
          enablePointerInteraction: false,
        ));
      }
    }

    return regions;
  }

  void saveAvailability(bool backArrow) {
    List slots = [];
    for (var lesson in _dataSource?.appointments as List<Lesson>) {
      slots.add({
        'from': lesson.from,
        'to': lesson.to,
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
      }
    } else {
      widget.onSave!(slots);
      Navigator.of(context).pop();
    }
  }
}
