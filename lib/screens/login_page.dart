import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

import '../utils/components.dart';
import '../utils/login_functions.dart';

// View documentation here: https://github.com/cgs-math/app#login-page.

SignInScreen LoginPage() {
  return SignInScreen(
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
    providerConfigs: [
      const EmailProviderConfiguration(),
      GoogleProviderConfiguration(
          clientId: getClientID(),
          scopes: ['profile', 'email'],
          redirectUri:
              'https://cgs-maths-club.firebaseapp.com/__/auth/handler'),
      const AppleProviderConfiguration(),
    ],
    headerBuilder: (context, constraints, _) {
      return header("Maths Club", context);
    },
    sideBuilder: sideImage('assets/app_icon.svg'),
    subtitleBuilder: (context, action) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text('Welcome to Maths Club!'),
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
