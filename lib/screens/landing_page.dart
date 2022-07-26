import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';
import 'login_page.dart';

// View documentation here: https://github.com/cgs-math/app#landing-page.

/// This is the Auth Gate and acts as a router to redirect a user to the
/// respective page based on their status.
///
/// More documentation can be viewed [here](https://github.com/cgs-math/app#landing-page)
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // User is not signed in.
            if (!snapshot.hasData) {
              return loginPage();
            }

            // If user is signed in and all checks are passed.
            return const HomePage();
          },
        );
      },
    );
  }
}
