/*
File: login_page.dart
Description: The login page, where users can register or sign in
Author: Garv Shah
Created: Sat Jun 18 18:29:00 2022
Doc Link: https://github.com/garv-shah/aporia-network#login-page
 */

import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:aporia_app/utils/components.dart';
import 'package:aporia_app/utils/login_functions.dart';
import 'package:aporia_app/utils/config/config.dart' as config;

/// This is the login page for users.
///
/// Utilising the FlutterFire UI [SignInScreen] class, it handles all logins,
/// registering and forgotten passwords.
///
/// More documentation can be viewed [here](https://github.com/garv-shah/aporia-network#login-page)
SignInScreen loginPage() {
  return SignInScreen(
    // These are actions such as forgot password.
    actions: [
      ForgotPasswordAction((context, email) {
        Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => ForgotPasswordScreen(
                email: email,
                headerMaxExtent: 200,
                headerBuilder: headerIcon(context, Icons.lock),
                sideBuilder: sideIcon(context, Icons.lock),
              ),
            ));
      }),
    ],
    // Images and headers are built using the utility functions found in the
    // login_functions file.
    headerBuilder: (context, constraints, _) {
      return header(config.name, context);
    },
    sideBuilder: sideImage('assets/app_icon.svg'),
    subtitleBuilder: (context, action) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text('Welcome to ${config.name}!'),
      );
    },
    footerBuilder: (context, action) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            action == AuthAction.signIn
                ? 'By signing in, you agree to our terms and conditions.'
                : 'By registering, you agree to our terms and conditions.',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    },
  );
}
