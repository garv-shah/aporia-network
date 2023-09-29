/*
File: components.dart
Description: Miscellaneous utility components, such as headers and footers
Author: Garv Shah
Created: Sun Jul 17 16:37:36 2022
 */

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// A header to display app branding with logo and name.
Widget header(String title, BuildContext context,
    {double iconWidth = 80,
    double paddingWidth = 20,
    double fontSize = 38,
    bool backArrow = false,
    bool showIcon = true,
    Function? customBackLogic}) {
  return Padding(
    padding: const EdgeInsets.all(26.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: backArrow,
          child: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).primaryColorLight),
              onPressed: () {
                (customBackLogic == null) ? Navigator.of(context).pop() : customBackLogic.call();
              }),
        ),
        Visibility(
          visible: showIcon,
          child: SizedBox(
            width: iconWidth,
            height: iconWidth,
            child: Hero(
              tag: '$title icon',
              child: SvgPicture.asset('assets/app_icon.svg',
                  semanticsLabel: '$title icon'),
            ),
          ),
        ),
        SizedBox(width: paddingWidth),
        Flexible(
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
          ),
        ),
      ],
    ),
  );
}

Map timezoneNames = {
  0: 'UTC',
  10800000: 'Indian/Mayotte',
  3600000: 'Europe/London',
  7200000: 'Europe/Zurich',
  -32400000: 'Pacific/Gambier',
  -28800000: 'US/Alaska',
  -14400000: 'US/Eastern',
  -10800000: 'Canada/Atlantic',
  -18000000: 'US/Central',
  -21600000: 'US/Mountain',
  -25200000: 'US/Pacific',
  -7200000: 'Atlantic/South_Georgia',
  -9000000: 'Canada/Newfoundland',
  39600000: 'Pacific/Pohnpei',
  25200000: 'Indian/Christmas',
  36000000: 'Pacific/Saipan',
  18000000: 'Indian/Maldives',
  46800000: 'Pacific/Tongatapu',
  21600000: 'Indian/Chagos',
  43200000: 'Pacific/Wallis',
  14400000: 'Indian/Reunion',
  28800000: 'Australia/Perth',
  32400000: 'Pacific/Palau',
  19800000: 'Asia/Kolkata',
  16200000: 'Asia/Kabul',
  20700000: 'Asia/Kathmandu',
  23400000: 'Indian/Cocos',
  12600000: 'Asia/Tehran',
  -3600000: 'Atlantic/Cape_Verde',
  37800000: 'Australia/Broken_Hill',
  34200000: 'Australia/Darwin',
  31500000: 'Australia/Eucla',
  49500000: 'Pacific/Chatham',
  -36000000: 'US/Hawaii',
  50400000: 'Pacific/Kiritimati',
  -34200000: 'Pacific/Marquesas',
  -39600000: 'Pacific/Pago_Pago'
};

Map timezoneToOffset = {
  'UTC': 0,
  'Indian/Mayotte': 10800000,
  'Europe/London': 3600000,
  'Europe/Zurich': 7200000,
  'Pacific/Gambier': -32400000,
  'US/Alaska': -28800000,
  'US/Eastern': -14400000,
  'Canada/Atlantic': -10800000,
  'US/Central': -18000000,
  'US/Mountain': -21600000,
  'US/Pacific': -25200000,
  'Atlantic/South_Georgia': -7200000,
  'Canada/Newfoundland': -9000000,
  'Pacific/Pohnpei': 39600000,
  'Indian/Christmas': 25200000,
  'Pacific/Saipan': 36000000,
  'Indian/Maldives': 18000000,
  'Pacific/Tongatapu': 46800000,
  'Indian/Chagos': 21600000,
  'Pacific/Wallis': 43200000,
  'Indian/Reunion': 14400000,
  'Australia/Perth': 28800000,
  'Pacific/Palau': 32400000,
  'Asia/Kolkata': 19800000,
  'Asia/Kabul': 16200000,
  'Asia/Kathmandu': 20700000,
  'Indian/Cocos': 23400000,
  'Asia/Tehran': 12600000,
  'Atlantic/Cape_Verde': -3600000,
  'Australia/Broken_Hill': 37800000,
  'Australia/Darwin': 34200000,
  'Australia/Eucla': 31500000,
  'Pacific/Chatham': 49500000,
  'US/Hawaii': -36000000,
  'Pacific/Kiritimati': 50400000,
  'Pacific/Marquesas': -34200000,
  'Pacific/Pago_Pago': -39600000
};

DateTime toLocalTime(DateTime time, String originalTimezone) {
  return time.subtract(Duration(milliseconds: timezoneToOffset[originalTimezone] - DateTime.now().timeZoneOffset.inMilliseconds));
}

String? getRecurrenceRule({required int dayOfWeek, DateTime? until, String? repeat}) {
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

  String rule = 'FREQ=WEEKLY;INTERVAL=1;BYDAY=$recurrenceDay';

  if (repeat == 'daily') {
    rule = 'FREQ=DAILY;INTERVAL=1;';
  } else if (repeat == 'weekly') {
    rule = 'FREQ=WEEKLY;INTERVAL=1;BYDAY=$recurrenceDay';
  } else if (repeat == 'fortnightly') {
    rule = 'FREQ=WEEKLY;INTERVAL=2;BYDAY=$recurrenceDay';
  } else if (repeat == 'monthly') {
    rule = 'FREQ=MONTHLY;INTERVAL=1;BYDAY=$recurrenceDay';
  } else if (repeat == 'once') {
    return null;
  }

  if (until != null) {
    rule += ';UNTIL=${until.toIso8601String()}';
  }
  return '$rule;COUNT=128';
}
