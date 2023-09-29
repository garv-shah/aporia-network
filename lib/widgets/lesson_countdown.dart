import 'package:aporia_app/screens/scheduling/schedule_view.dart';
import 'package:aporia_app/widgets/forks/flutter_calendar/calendar/appointment_engine/recurrence_helper.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../screens/scheduling/availability_page.dart';
import '../utils/components.dart';

Widget lessonCountdown(Map<String, dynamic>? profileMap) {
  // find the most recent lesson that happened
  int minDifference = 31556952000;
  bool lessonRunning = false;
  DateTime now = DateTime.now();

  // find the most recent lesson that happened
  // List<Appointment> upcomingLessons = [];
  // for (Map<String, dynamic> job in profileMap?['jobList'] ?? []) {
  //   // DateTime start = DateTime.parse(job['lessonTimes']['start']);
  //   // DateTime end = DateTime.parse(job['lessonTimes']['end']);
  //   //
  //   // if (start.weekday < now.weekday) {
  //   //   // lesson has already passed in the week
  //   //   int daysBefore = now.weekday - start.weekday;
  //   //   // go back the number of days and add a week
  //   //   DateTime nextLessonTime = now.subtract(Duration(days: daysBefore)).add(const Duration(days: 7));
  //   //   // ^^^ correct day next week
  //   //   possibleTimes.add(DateTime(nextLessonTime.year, nextLessonTime.month, nextLessonTime.day, start.hour, start.minute, start.second));
  //   // } else if (start.weekday == now.weekday) {
  //   //   // lesson is today
  //   //   DateTime startTime = DateTime(now.year, now.month, now.day, start.hour, start.minute, start.second);
  //   //   DateTime endTime = DateTime(now.year, now.month, now.day, end.hour, end.minute, end.second);
  //   //   if (startTime.isAfter(now)) {
  //   //     // lesson will be later in the day
  //   //     possibleTimes.add(startTime);
  //   //   } else if (endTime.isBefore(now)) {
  //   //     // lesson already happened today
  //   //     DateTime nextLessonTime = startTime.add(const Duration(days: 7));
  //   //     possibleTimes.add(nextLessonTime);
  //   //   }
  //   // } else if (start.weekday > now.weekday) {
  //   //   // lesson is still to happen this week
  //   //   int daysAfter = start.weekday - now.weekday;
  //   //   // add number of days to get correct day of week
  //   //   DateTime nextLessonTime = now.add(Duration(days: daysAfter));
  //   //   possibleTimes.add(DateTime(nextLessonTime.year, nextLessonTime.month, nextLessonTime.day, start.hour, start.minute, start.second));
  //   // }
  //   //
  //   // // if we are currently in the lesson time
  //   // if (now.isAfter(DateTime(
  //   //     now.year, now.month, now.day, start.hour, start.minute))
  //   //     && now.isBefore(DateTime(
  //   //         now.year, now.month, now.day, end.hour,
  //   //         end.minute))) {
  //   //   lessonRunning = true;
  //   // }
  // }

  return FutureBuilder<Map<DateTime, Appointment>>(future: jobListToDateTimeCollection(profileMap?['jobList'] ?? []), builder: (context, snapshot) {
    if (snapshot.hasData) {
      Map<DateTime, Appointment> lessonMap = snapshot.data ?? {};

      List<DateTime> upcomingTimes = lessonMap.keys.toList();

      if (upcomingTimes.isEmpty) {
        return Builder(
            builder: (context) {
              return Text(
                "No upcoming lessons",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .primary),
                overflow: TextOverflow.fade,
                softWrap: false,
              );
            }
        );
      }

      DateTime closestTime = upcomingTimes.first;
      Appointment closestLesson = lessonMap[closestTime]!;

      for (DateTime startTime in upcomingTimes) {
        Appointment lesson = lessonMap[startTime]!;
        if (now.isBefore(lesson.endTime)) {
          closestLesson = lesson;
          break;
        }
      }

      if (now.isAfter(closestLesson.startTime) && now.isBefore(closestLesson.endTime)) {
        lessonRunning = true;
      } else {
        minDifference = closestLesson.startTime.difference(now).inMilliseconds;
      }

      final StopWatchTimer stopWatchTimer = StopWatchTimer(
        mode: StopWatchMode.countDown,
        presetMillisecond: minDifference, // millisecond => minute.
      );

      stopWatchTimer.onStartTimer();

      return StreamBuilder<int>(
          stream: stopWatchTimer.rawTime,
          builder: (context, snapshot) {
            final value = snapshot.data ?? 0;
            String displayTime = "";

            bool seconds = true;
            bool minutes = true;
            bool hours = true;

            int numHours = StopWatchTimer.getRawHours(value);
            int numMinutes = StopWatchTimer.getRawMinute(value);
            int numSeconds = StopWatchTimer.getRawSecond(value);

            if (numHours == 0) {
              hours = false;
              if (numMinutes == 0) {
                minutes = false;
                if (numSeconds == 0) {
                  seconds = false;
                }
              }
            }

            displayTime = StopWatchTimer.getDisplayTime(
              value,
              hours: hours,
              hoursRightBreak: (numHours == 1) ? ' Hour, ' : ' Hours, ',
              minute: minutes,
              minuteRightBreak: (numMinutes == 1) ? ' Minute, ' : ' Minutes, ',
              second: seconds,
              milliSecond: false,
            ) + ((numSeconds == 1) ? ' Second' : ' Seconds');

            if (numHours > 24) {
              int days = numHours ~/ 24;
              displayTime = "$days ${days > 1 ? "Days" : "Day"}";
            }

            if (seconds == false || lessonRunning == true) {
              displayTime = "Now!";
            }

            return Text(
              displayTime,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .primary),
              overflow: TextOverflow.fade,
              softWrap: false,
            );
          }
      );
    } else {
      return Text(
        "Loading...",
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(
            color: Theme.of(context)
                .colorScheme
                .primary),
        overflow: TextOverflow.fade,
        softWrap: false,
      );
    }
  });
}
