import 'package:flutter/material.dart';

// View documentation here: https://github.com/cgs-math/app#theme-data.

class AppThemes {
  /// light mode theme
  static ThemeData lightTheme = ThemeData(
    backgroundColor: const Color(0xfffcfcff),
    primaryColorLight: Colors.black,
    primaryColor: const Color(0xfffcfcff),
    scaffoldBackgroundColor: const Color(0xfffcfcff),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: Colors.deepPurpleAccent,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: Colors.deepPurpleAccent,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        primary: Colors.deepPurpleAccent,
      ),
    ),
    appBarTheme: AppBarTheme(
      color: Colors.deepPurple.shade400,
      elevation: 4,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20.0,
      ),
    ),
    textTheme: const TextTheme(
        headline1: TextStyle(color: Colors.black),
        headline2: TextStyle(color: Colors.black),
        headline3: TextStyle(color: Colors.black),
        headline4: TextStyle(color: Colors.black),
        bodyText2: TextStyle(color: Colors.black),
        subtitle1: TextStyle(color: Colors.black),
        button: TextStyle(color: Colors.deepPurpleAccent)),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.deepPurpleAccent),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.deepPurpleAccent,
        secondary: Colors.deepPurpleAccent,
        brightness: Brightness.light),
  );

  /// dark mode theme
  static ThemeData darkTheme = ThemeData(
    backgroundColor: Colors.black,
    primaryColorLight: const Color(0xfffcfcff),
    primaryColor: Colors.black,
    scaffoldBackgroundColor: const Color(0xff161B33),
    appBarTheme: const AppBarTheme(
      color: Color(0xff0D0C1D),
      elevation: 4,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
      ),
    ),
    colorScheme: ColorScheme.fromSwatch()
        .copyWith(secondary: Colors.indigoAccent, brightness: Brightness.dark),
    textSelectionTheme:
        const TextSelectionThemeData(cursorColor: Colors.indigoAccent),
  );
}
