/*
File: main.dart
Description: The file serves as the entrypoint of the app, leading to the AuthGate
Author: Garv Shah
Created: Sat Jun 18 18:29:00 2022
Doc Link: https://github.com/garv-shah/aporia-network#adaptive-theme
 */

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:maths_club/screens/auth/landing_page.dart';
import 'package:maths_club/utils/login_functions.dart';
import 'package:maths_club/utils/theming/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:maths_club/utils/config/config.dart' as config;

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
        'https://aporia-network.firebaseapp.com/__/auth/handler'
    ),
    AppleProvider()
  ]);

  // Runs the app.
  runApp(AporiaApp());
}

/// This is the root app widget.
///
/// The whole app is wrapped with an [AdaptiveTheme] to provide easy light and
/// dark mode theming, based on the [AppThemes] class.
///
/// More documentation can be viewed [here](https://github.com/garv-shah/aporia-network#adaptive-theme)
class AporiaApp extends StatelessWidget {
  AporiaApp({Key? key}) : super(key: key);
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
        title: config.detailedName,
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
