import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../screens/auth/landing_page.dart';

/// A header to display maths club branding with logo and name.
Widget header(String title, BuildContext context,
    {double iconWidth = 80,
    double paddingWidth = 20,
    double fontSize = 38,
    bool backArrow = false}) {
  return Padding(
    padding: const EdgeInsets.all(26.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
          visible: backArrow,
          child: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).primaryColorLight),
              onPressed: () {
                AuthGate.of(context)?.pop();
              }),
        ),
        SizedBox(
          width: iconWidth,
          height: iconWidth,
          child: SvgPicture.asset('assets/app_icon.svg',
              semanticsLabel: "$title icon"),
        ),
        SizedBox(width: paddingWidth),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
        ),
      ],
    ),
  );
}
