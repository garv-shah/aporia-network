import 'package:flutter/material.dart';

// view documentation here: https://github.com/The-maths_club-System/maths_club_app/tree/feat-rewrite#theme-data

class AppThemes {
  /// light mode theme
  static ThemeData lightTheme = ThemeData(
    backgroundColor: const Color(0xfffcfcff),
    primaryColorLight: Colors.black,
    primaryColor: const Color(0xfffcfcff),
    scaffoldBackgroundColor: const Color(0xfffcfcff),
    appBarTheme: const AppBarTheme(
      color: Colors.indigo,
      elevation: 4,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.indigo, brightness: Brightness.light),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.indigo),
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
    textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.indigoAccent),
  );
}
