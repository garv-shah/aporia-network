import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// A header to display maths club branding with logo and name.
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
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
        ),
      ],
    ),
  );
}
