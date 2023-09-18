/*
File: theme.dart
Description: Defines ThemeData for the rest of the app, with a utility class
Author: Garv Shah
Created: Sat Jun 18 18:29:00 2022
Doc Link: https://github.com/garv-shah/aporia-network#theme-data
 */

import 'package:flutter/material.dart';
import 'package:aporia_app/widgets/forks/flowy_infra_ui/widget/theme_extension.dart';

TextStyle _getFontStyle({
  String? fontFamily,
  double? fontSize,
  FontWeight? fontWeight,
  Color? fontColor,
  double? letterSpacing,
  double? lineHeight,
}) =>
    TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize ?? 12,
      color: fontColor,
      fontWeight: fontWeight ?? FontWeight.w500,
      fontFamilyFallback: const ["Noto Color Emoji"],
      letterSpacing: (fontSize ?? 12) * (letterSpacing ?? 0.005),
      height: lineHeight,
    );

class AppThemes {
  static ThemeData lightTheme = ThemeData(
      primaryColorLight: Colors.black,
      primaryColor: const Color(0xfffcfcff),
      scaffoldBackgroundColor: const Color(0xfffcfcff),
      canvasColor: const Color(0xfffcfcff),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white
      ),
      appBarTheme: AppBarTheme(
        color: Colors.deepPurple.shade100,
        elevation: 4,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20.0,
        ),
      ),
      textTheme:
          const TextTheme(
              labelLarge: TextStyle(color: Colors.deepPurpleAccent),
            bodyMedium: TextStyle(color: Colors.black)
          ),
      inputDecorationTheme: InputDecorationTheme(
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black38),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black38),
          borderRadius: BorderRadius.circular(8),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.deepPurpleAccent),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.all(Colors.deepPurpleAccent),
        side: const BorderSide(color: Color(0xff585858)),
      ), colorScheme: const ColorScheme.light().copyWith(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.deepPurpleAccent.shade200,
          tertiaryContainer: Colors.deepPurpleAccent.shade100.withAlpha(60),
          brightness: Brightness.light).copyWith(background: const Color(0xfffcfcff)),
    extensions: [
      AFThemeExtension(
        warning: const Color(0xffffd667),
        success: const Color(0xff66cf80),
        tint1: const Color(0xffe8e0ff),
        tint2: const Color(0xffffe7fd),
        tint3: const Color(0xffffe7ee),
        tint4: const Color(0xffffefe3),
        tint5: const Color(0xfffff2cd),
        tint6: const Color(0xfff5ffdc),
        tint7: const Color(0xffddffd6),
        tint8: const Color(0xffdefff1),
        tint9: const Color(0xffe1fbff),
        textColor: const Color(0xff333333),
        greyHover: const Color(0xffedeef2),
        greySelect: const Color(0xffe2e4eb),
        lightGreyHover: const Color(0xfff2f2f2),
        toggleOffFill: const Color(0xffe0e0e0),
        progressBarBGColor: const Color(0xffe1fbff),
        toggleButtonBGColor: const Color(0xffe0e0e0),
        code: _getFontStyle(
          fontColor: const Color(0xff828282),
        ),
        callout: _getFontStyle(
          fontSize: 11,
          fontColor: const Color(0xff828282),
        ),
        caption: _getFontStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          fontColor: const Color(0xff828282),
        ),
      ),
    ]
  );

  /// dark mode theme
  static ThemeData darkTheme = ThemeData(
    primaryColorLight: const Color(0xfffcfcff),
    primaryColor: Colors.black,
    scaffoldBackgroundColor: const Color(0xff12162B),
    canvasColor: const Color(0xff12162B),
    cardColor: const Color(0xff1F2547),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.indigoAccent,
          foregroundColor: Colors.white
      ),
    appBarTheme: const AppBarTheme(
      color: Color(0xff1F2547),
      elevation: 4,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
      ),
    ),
    textTheme: const TextTheme(labelLarge: TextStyle(color: Colors.indigoAccent)),
    inputDecorationTheme: InputDecorationTheme(
      disabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white38),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white38),
        borderRadius: BorderRadius.circular(8),
      ),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.indigoAccent),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
      checkboxTheme: const CheckboxThemeData(
        side: BorderSide(color: Color(0xff585858)),
      ), colorScheme: const ColorScheme.dark().copyWith(
        primary: Colors.indigoAccent,
        secondary: Colors.indigo,
        tertiaryContainer: Colors.indigoAccent.shade100.withAlpha(60),
        brightness: Brightness.dark).copyWith(background: Colors.black),
      extensions: [
        AFThemeExtension(
          warning: const Color(0xffF7CF46),
          success: const Color(0xff66CF80),
          tint1: const Color(0xff8738F5),
          tint2: const Color(0xffE6336E),
          tint3: const Color(0xffFF2D9E),
          tint4: const Color(0xffE9973E),
          tint5: const Color(0xffFBF000),
          tint6: const Color(0xffC0F000),
          tint7: const Color(0xff15F74E),
          tint8: const Color(0xff00F0E2),
          tint9: const Color(0xff00BCF0),
          textColor: const Color(0xffBBC3CD),
          greyHover: const Color(0xff00BCF0), // dark main
          greySelect: const Color(0xff00BCF0),
          lightGreyHover: const Color(0xff363D49),
          toggleOffFill: const Color(0xffBBC3CD),
          progressBarBGColor: const Color(0xff363D49),
          toggleButtonBGColor: const Color(0xffe0e0e0),
          code: _getFontStyle(
            fontColor: const Color(0xff363D49),
          ),
          callout: _getFontStyle(
            fontSize: 11,
            fontColor: const Color(0xff363D49),
          ),
          caption: _getFontStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            fontColor: const Color(0xffBBC3CD),
          ),
        ),
      ]
  );
}
