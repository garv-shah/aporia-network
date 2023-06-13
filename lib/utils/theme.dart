/*
File: theme.dart
Description: Defines ThemeData for the rest of the app, with a utility class
Author: Garv Shah
Created: Sat Jun 18 18:29:00 2022
Doc Link: https://github.com/cgs-math/app#theme-data
 */

import 'package:flutter/material.dart';

class AppThemes {
  /// light mode theme
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
          secondary: Colors.deepPurple,
          brightness: Brightness.light).copyWith(background: const Color(0xfffcfcff)));

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
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.all(Colors.indigoAccent),
        side: const BorderSide(color: Color(0xff585858)),
      ), colorScheme: const ColorScheme.dark().copyWith(
        primary: Colors.indigoAccent,
        secondary: Colors.indigo,
        brightness: Brightness.dark).copyWith(background: Colors.black)
  );
}
