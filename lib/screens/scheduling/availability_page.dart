/*
File: availability_page.dart
Description: Where users can define their availability
Author: Garv Shah
Created: Sat Jul 8 17:04:21 2023
 */

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

  const AvailabilityPage({Key? key, required this.isCompany, this.onSave, this.initialValue}) : super(key: key);

  @override
  State<AvailabilityPage> createState() => _AvailabilityPageState();
}

class _AvailabilityPageState extends State<AvailabilityPage> {
  @override
  void initState() {
    getDataFromFireStore().then((results) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    });
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
          eventName: 'Available!',
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
          eventName: 'Available!',
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
        _dataSource?.appointments!.add(lesson);
        _dataSource?.notifyListeners(CalendarDataSourceAction.add, <Lesson>[lesson]);
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
              saveAvailability();
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          saveAvailability();
        },
        label: widget.isCompany ? const Text("Save") : const Text("Continue"),
        icon: widget.isCompany ? const Icon(Icons.check) : const Icon(Icons.arrow_forward),
      ),
    );
  }

  void saveAvailability() {
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
    } else {
      widget.onSave!(slots);
      Navigator.of(context).pop();
    }
  }
}
