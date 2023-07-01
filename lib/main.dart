/*
File: main.dart
Description: The file serves as the entrypoint of the Maths Club App, leading to the AuthGate
Author: Garv Shah
Created: Sat Jun 18 18:29:00 2022
Doc Link: https://github.com/cgs-math/app#adaptive-theme
 */

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:maths_club/screens/auth/landing_page.dart';
import 'package:maths_club/utils/login_functions.dart';
import 'package:maths_club/utils/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  // Initialises Firebase.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // These provide configuration for Sign-In providers.
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    GoogleProvider(
        clientId: getClientID(),
        scopes: ['profile', 'email'],
        redirectUri:
        'https://cgs-maths-club.firebaseapp.com/__/auth/handler'
    ),
    AppleProvider()
  ]);

  // Runs the app.
  runApp(MathsClubApp());
}

/// This is the root Maths Club Widget.
///
/// The whole app is wrapped with an [AdaptiveTheme] to provide easy light and
/// dark mode theming, based on the [AppThemes] class.
///
/// More documentation can be viewed [here](https://github.com/cgs-math/app#adaptive-theme)
class MathsClubApp extends StatelessWidget {
  MathsClubApp({Key? key}) : super(key: key);
  // Add Firebase Analytics
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // Creates the app theming using the Adaptive Theme package.
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
        localizationsDelegates: const [
          AppFlowyEditorLocalizations.delegate,
        ],
        home: const AuthGate(), // Leads to the AuthGate, to handle user status.
      ),
    );
  }
}
