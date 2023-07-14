import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

Widget lessonCountdown(Map<String, dynamic>? profileMap) {
  // find the most recent lesson that happened
  int minDifference = 31556952000;
  bool lessonRunning = false;
  DateTime now = DateTime.now();
  List<DateTime> possibleTimes = [];

  // find the most recent lesson that happened
  for (Map<String, dynamic> job in profileMap?['jobList'] ?? []) {
    DateTime start = DateTime.parse(job['lessonTimes']['start']);
    DateTime end = DateTime.parse(job['lessonTimes']['end']);

    if (start.weekday < now.weekday) {
      // lesson has already passed in the week
      int daysBefore = now.weekday - start.weekday;
      // go back the number of days and add a week
      DateTime nextLessonTime = now.subtract(Duration(days: daysBefore)).add(const Duration(days: 7));
      // ^^^ correct day next week
      possibleTimes.add(DateTime(nextLessonTime.year, nextLessonTime.month, nextLessonTime.day, start.hour, start.minute, start.second));
    } else if (start.weekday == now.weekday) {
      // lesson is today
      DateTime startTime = DateTime(now.year, now.month, now.day, start.hour, start.minute, start.second);
      DateTime endTime = DateTime(now.year, now.month, now.day, end.hour, end.minute, end.second);
      if (startTime.isAfter(now)) {
        // lesson will be later in the day
        possibleTimes.add(startTime);
      } else if (endTime.isBefore(now)) {
        // lesson already happened today
        DateTime nextLessonTime = startTime.add(const Duration(days: 7));
        possibleTimes.add(nextLessonTime);
      }
    } else if (start.weekday > now.weekday) {
      // lesson is still to happen this week
      int daysAfter = start.weekday - now.weekday;
      // add number of days to get correct day of week
      DateTime nextLessonTime = now.add(Duration(days: daysAfter));
      possibleTimes.add(DateTime(nextLessonTime.year, nextLessonTime.month, nextLessonTime.day, start.hour, start.minute, start.second));
    }

    // if we are currently in the lesson time
    if (now.isAfter(DateTime(
        now.year, now.month, now.day, start.hour, start.minute))
        && now.isBefore(DateTime(
            now.year, now.month, now.day, end.hour,
            end.minute))) {
      lessonRunning = true;
    }
  }

  if (lessonRunning == false) {
    DateTime closestLesson = possibleTimes.reduce(
            (a, b) => a.difference(now).abs() < b.difference(now).abs() ? a : b);
    minDifference = closestLesson.difference(now).inMilliseconds;
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
}
