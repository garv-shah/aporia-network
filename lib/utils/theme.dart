import 'package:flutter/material.dart';

// View documentation here: https://github.com/cgs-math/app#theme-data.

class AppThemes {
  /// light mode theme
  static ThemeData lightTheme = ThemeData(
    backgroundColor: const Color(0xfffcfcff),
    primaryColorLight: Colors.black,
    primaryColor: const Color(0xfffcfcff),
    scaffoldBackgroundColor: const Color(0xfffcfcff),
    appBarTheme: AppBarTheme(
      color: Colors.deepPurple.shade400,
      elevation: 4,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20.0,
      ),
    ),
    textTheme:
        const TextTheme(button: TextStyle(color: Colors.deepPurpleAccent)),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.deepPurpleAccent),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.deepPurpleAccent,
        secondary: Colors.deepPurple,
        brightness: Brightness.light),
  );

  /// dark mode theme
  static ThemeData darkTheme = ThemeData(
    backgroundColor: Colors.black,
    primaryColorLight: const Color(0xfffcfcff),
    primaryColor: Colors.black,
    scaffoldBackgroundColor: const Color(0xff12162B),
    cardColor: const Color(0xff1F2547),
    appBarTheme: const AppBarTheme(
      color: Color(0xff0D0C1D),
      elevation: 4,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
      ),
    ),
    textTheme:
    const TextTheme(button: TextStyle(color: Colors.indigoAccent)),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.indigoAccent),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.indigoAccent,
        secondary: Colors.indigo,
        brightness: Brightness.dark),
  );
}
