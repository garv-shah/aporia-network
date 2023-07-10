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
