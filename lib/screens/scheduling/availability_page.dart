/*
File: availability_page.dart
Description: Where users can define their availability
Author: Garv Shah
Created: Sat Jul 8 17:04:21 2023
 */

import 'package:aporia_app/screens/scheduling/job_selector_page.dart';
import 'package:aporia_app/utils/components.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../post_creation/create_post_view.dart';

typedef DataCallback = void Function(Map data);
LessonDataSource? _dataSource;
List<Appointment> repeatingRemoveDates = [];
List<Appointment> exceptionRemoveDates = [];
List oldSlots = [];
Set<Appointment> newDates = {};
Map<String, List> globalExceptions = {
  'add': [],
  'remove': [],
};

class RawLesson {
  const RawLesson(
      this.from,
      this.to,
      );

  final DateTime from;
  final DateTime to;

  Map<String, dynamic> toMap(){
    return {'from': from, 'to': to};
  }
}

// returns a normalised time so days can be compared
DateTime justTime(DateTime time) {
  return time.copyWith(year: 2018, month: 1, day: time.weekday);
}

DateTime toDateTime(dynamic time) {
  return time is DateTime ? time : DateTime.parse(time.toDate().toString());
}

class LessonDataSource extends CalendarDataSource {
  LessonDataSource(List<Appointment> source) {
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
  final Map<Object, Object?>? initialValue;
  final DataCallback? onSave;
  final List? restrictionZone;

  const AvailabilityPage(
      {Key? key,
      required this.isCompany,
      this.onSave,
      this.initialValue,
      this.restrictionZone})
      : super(key: key);

  @override
  State<AvailabilityPage> createState() => _AvailabilityPageState();
}

class _AvailabilityPageState extends State<AvailabilityPage> {
  bool repeatOnSave = true;
  String _headerText = DateFormat('MMMM yyyy').format(DateTime.now());
  late CalendarController _controller;

  @override
  void initState() {
    _controller = CalendarController();
    _headerText = DateFormat('MMMM yyyy').format(DateTime.now());
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

    Map<String, dynamic>? snapshotData =
        availabilitySnapshot.data() as Map<String, dynamic>?;

    List slots = widget.initialValue?['slots'] ?? (snapshotData?['slots'] ?? []);
    oldSlots = slots;
    Map exceptions = widget.initialValue?['exceptions'] ?? (snapshotData?['exceptions'] ?? {
      'add': [],
      'remove': [],
    });

    // key is the bare time, value is the actual time
    Map<DateTime, List<DateTime>> exceptionsRemove = {};
    exceptions['remove'].forEach((element) {
      DateTime start = toDateTime(element['from']);
      if (exceptionsRemove[justTime(start)] == null) {
        exceptionsRemove[justTime(start)] = [];
      }
      exceptionsRemove[justTime(start)]?.add(start);
    });
    globalExceptions['remove'] = exceptions['remove'];

    List<Appointment> list = [];

    void addLesson(dynamic lesson, bool repeating) {
      DateTime start = toDateTime(lesson['from']);
      DateTime end = toDateTime(lesson['to']);
      List<DateTime>? recurrenceExceptionDates;

      if (exceptionsRemove.keys.contains(start) && repeating) {
        recurrenceExceptionDates = exceptionsRemove[start];
      }

      list.add(Appointment(
          subject: widget.restrictionZone == null ? '' : 'Lesson Time!',
          startTime: start,
          endTime: end,
          color: Theme.of(context).colorScheme.primary,
          recurrenceRule: repeating ? getRecurrenceRule(dayOfWeek: start.weekday) : null,
          recurrenceExceptionDates: recurrenceExceptionDates));
    }

    for (var slot in slots) {
      addLesson(slot, true);
    }

    List toAdd = [];
    for (var onceOff in exceptions['add']) {
      toAdd.add(onceOff);
      addLesson(onceOff, false);
    }
    globalExceptions['add']?.addAll(toAdd);

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
          subject: widget.restrictionZone == null ? '' : 'Lesson Time!',
          startTime: startTime,
          endTime: endTime,
          color: Theme.of(context).colorScheme.primary);
      List? lessonsInSlot = _dataSource?.appointments
          ?.where((element) =>
              justTime(element.startTime) == justTime(lesson.startTime))
          .toList();
      bool filled = lessonsInSlot?.isNotEmpty ?? false;
      if (filled) {
        // remove lesson
        Appointment currLesson = lessonsInSlot![0];
        _dataSource?.appointments!.remove(currLesson);
        _dataSource?.notifyListeners(
            CalendarDataSourceAction.remove, <Appointment>[currLesson]);

        newDates.remove(lesson);
        if (currLesson.recurrenceRule != null) {
          // repeating lesson
          repeatingRemoveDates.add(lesson);
        } else {
          exceptionRemoveDates.add(lesson);
        }
      } else {
        // add lesson
        // if we are simply selecting availability, you should be able to select
        // multiple times. If we are selecting a specific lesson slot, then you
        // should only be able to select one time.
        if (widget.restrictionZone == null) {
          _dataSource?.appointments!.add(lesson);
          newDates.add(lesson);
          _dataSource?.notifyListeners(
              CalendarDataSourceAction.add, <Appointment>[lesson]);

          repeatingRemoveDates.removeWhere((element) =>
              justTime(element.startTime) == justTime(lesson.startTime));
          exceptionRemoveDates.removeWhere((element) =>
              justTime(element.startTime) == justTime(lesson.startTime));
        } else {
          Navigator.of(context).pop();
          widget.onSave!({
              'from': lesson.startTime,
              'to': lesson.endTime,
            });
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
      body: Column(
        children: [
          // the header
          SizedBox(
            height: 40,
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      _controller.backward!();
                    },
                    icon: const Icon(Icons.arrow_back_ios_new),iconSize: 15, splashRadius: 15),
                IconButton(
                    onPressed: () {
                      _controller.forward!();
                    },
                    icon: const Icon(Icons.arrow_forward_ios),iconSize: 15, splashRadius: 15),
                Text(_headerText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextButton(
                        onPressed: () {
                          _controller.displayDate = DateTime.now();
                        },
                        child: const Text('Today'),),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: SfCalendar(
              view: PlatformExtension.isDesktopOrWeb ? CalendarView.week : CalendarView.day,
              firstDayOfWeek: 1,
              viewNavigationMode: ViewNavigationMode.snap,
              controller: _controller,
              cellEndPadding: 0,
              headerHeight: 0,
              dataSource: _dataSource,
              onViewChanged: (ViewChangedDetails details) {
                SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                  setState(() {
                    _headerText = DateFormat('MMMM yyyy').format(details.visibleDates.first);
                  });
                });
              },
              onTap: calendarTapped,
              specialRegions: _getTimeRegions(widget.restrictionZone ?? []),
            ),
          ),
          (widget.restrictionZone == null) ? Tooltip(
            message:
                "Checking this box changes your general preferred availability for all weeks. If you wish to only change your availability for this current week, leave this box unchecked.",
            child: LabeledCheckbox(
              label: "Apply changes to all weeks",
              value: repeatOnSave,
              onChanged: (value) {
                setState(() {
                  repeatOnSave = value;
                });
              },
              padding: const EdgeInsets.fromLTRB(36.0, 8.0, 0.0, 8.0),
            ),
          ) : const Text("this is where you change frequency"),
        ],
      ),
      floatingActionButton: (widget.restrictionZone == null)
          ? FloatingActionButton.extended(
              onPressed: () {
                saveAvailability(false);
              },
              label: widget.isCompany
                  ? const Text("Save")
                  : const Text("Continue"),
              icon: widget.isCompany
                  ? const Icon(Icons.check)
                  : const Icon(Icons.arrow_forward),
            )
          : null,
    );
  }

  List<TimeRegion> _getTimeRegions(List times) {
    final List<TimeRegion> regions = <TimeRegion>[];

    if (times.isEmpty) return regions;

    // process exception days
    List<DateTime> exceptionDates = [];
    Map<String, List> initialExceptions = widget.initialValue!['exceptions'] as Map<String, List>;
    for (var time in initialExceptions['add'] ?? []) {
      DateTime date = toDateTime(time['from']);

      regions.add(TimeRegion(
        startTime: justTime(date),
        endTime: justTime(date).add(const Duration(hours: 1)),
        color: Colors.redAccent.withOpacity(0.6),
        text: "Future Conflict!",
        enablePointerInteraction: true,
        recurrenceRule: getRecurrenceRule(dayOfWeek: date.weekday, until: date),
      ));
    }
    for (var time in initialExceptions['remove'] ?? []) {
      DateTime date = toDateTime(time['from']);

      regions.add(TimeRegion(
        startTime: justTime(date),
        endTime: justTime(date).add(const Duration(hours: 1)),
        color: Colors.redAccent.withOpacity(0.6),
        text: "Future Conflict!",
        enablePointerInteraction: true,
        recurrenceRule: getRecurrenceRule(dayOfWeek: date.weekday, until: date.subtract(const Duration(hours: 1))),
      ));

      // since you are not free on that day specifically, it should also be a removed time region
      regions.add(TimeRegion(
        startTime: date,
        endTime: date.add(const Duration(hours: 1)),
        enablePointerInteraction: false,
      ));
    }

    // the following is done to get the "inverse" of the common times, such that they are the only ones that can be selected
    List<int> relativeTimes = [];

    for (var i = 0; i < times.length; i++) {
      relativeTimes.add(
          DateTime.parse(times[i]).difference(DateTime(2018, 1, 1)).inHours);
    }

    for (var i = 0; i < 168; i++) {
      if (!relativeTimes.contains(i)) {
        regions.add(TimeRegion(
          startTime: DateTime(2018, 1, 1).add(Duration(hours: i)),
          endTime: DateTime(2018, 1, 1).add(Duration(hours: i + 1)),
          enablePointerInteraction: false,
          recurrenceRule: getRecurrenceRule(dayOfWeek: DateTime(2018, 1, 1).add(Duration(hours: i)).weekday),
        ));
      }
    }

    return regions;
  }

  void saveAvailability(bool backArrow) {
    List newSlots = [];

    if (widget.restrictionZone == null) {
      List<DateTime> usedTimes = [];
      for (var lesson in _dataSource?.appointments as List<Appointment>) {
        if (repeatOnSave) {
          if (newDates.contains(lesson)) {
            DateTime start = lesson.startTime;
            DateTime end = lesson.endTime;
            if (!usedTimes.contains(start)) {
              usedTimes.add(start);

              newSlots.add({
                'from': start,
                'to': end,
              });

              // also remove it from the exceptions
              globalExceptions['remove']?.removeWhere((element) => toDateTime(element['from']) == start);
            }
          }
        } else {
          if (lesson.recurrenceRule == null && newDates.contains(lesson)) {
            // a new lesson was added
            DateTime start = lesson.startTime;
            DateTime end = lesson.endTime;

            globalExceptions['add']?.add({
              'from': start,
              'to': end,
            });
          }
        }
      }

      List removeDuplicates(List input) {
        Set seen = {};
        List returnList = [];
        for (var value in input) {
          DateTime start = toDateTime(value['from']);
          if (!seen.contains(start)) {
            seen.add(start);
            returnList.add(value);
          }
        }

        return returnList;
      }

      // make sure there are no duplicates
      globalExceptions = {
        'add': removeDuplicates(globalExceptions['add']!),
        'remove': removeDuplicates(globalExceptions['remove']!),
      };

      if (exceptionRemoveDates.isNotEmpty) {
        // some of the repeating lessons were removed
        for (Appointment lesson in exceptionRemoveDates) {
          DateTime start = lesson.startTime;
          globalExceptions['add']?.removeWhere((lesson) => toDateTime(lesson['from']) == start);
        }
      }

      // remove recurring dates that are in the global exceptions
      List globalAddList = [];
      for (var entry in globalExceptions['add']!) {
        DateTime start = toDateTime(entry['from']);
        globalAddList.add(start);
      }
      List toRemove = [];
      for (var slot in newSlots) {
        DateTime start = toDateTime(slot['from']);
        if (globalAddList.contains(start)) {
          toRemove.add(slot);
        }
      }
      newSlots.removeWhere( (e) => toRemove.contains(e));
      // convert new slots into 2018 format
      List slots = oldSlots;
      for (var slot in newSlots) {
        DateTime start = justTime(slot['from']);
        DateTime end = justTime(slot['to']);
        slots.add({
          'from': start,
          'to': end,
        });
      }

      if (repeatingRemoveDates.isNotEmpty) {
        // some of the repeating lessons were removed
        for (Appointment lesson in repeatingRemoveDates) {
          DateTime start = lesson.startTime;
          DateTime end = lesson.endTime;

          // if this is repeating, it should be removed from all slots
          // if not, it is an exception
          if (repeatOnSave) {
            slots.removeWhere((element) => toDateTime(element['from']) == justTime(start));
          } else {
            globalExceptions['remove']?.add({
              'from': start,
              'to': end,
            });
          }
        }
      }

      Map<Object, Object?> availability = {
        'slots': slots,
        'exceptions': globalExceptions,
      };
      if (widget.onSave == null) {
        // update Firebase
        FirebaseFirestore.instance
            .collection("availability")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update(availability);
        if (!backArrow) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AvailableJobsPage(availability: availability)),
          );
        } else {
          Navigator.of(context).pop();
        }
      } else {
        widget.onSave!(availability);
        Navigator.of(context).pop();
      }
    } else {
      // go back to home page to avoid an issue where the availability is wiped
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }
}
