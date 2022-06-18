import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:maths_club/screens/landing_page.dart';
import 'package:maths_club/utils/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// view documentation here: https://github.com/The-maths_club-System/maths_club_app/tree/feat-rewrite#adaptive-theme

void main() async {
  // initialise firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // creates the app theming using the Adaptive Theme package
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: AppThemes.lightTheme,
      dark: AppThemes.darkTheme,
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CGS Maths Club',
        theme: theme,
        darkTheme: darkTheme,
        home: const AuthGate(), // leads to the AuthGate, to handle user status
      ),
    );
  }
}
