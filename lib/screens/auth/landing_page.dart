import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maths_club/screens/auth/register_page.dart';
import 'package:maths_club/screens/auth/login_page.dart';
import 'package:maths_club/screens/create_post_view.dart';
import 'package:maths_club/screens/edit_question.dart';
import 'package:maths_club/screens/home_page.dart';
import 'package:maths_club/screens/leaderboards.dart';
import 'package:maths_club/screens/quiz_view.dart';
import 'package:maths_club/screens/section_page.dart';
import 'package:maths_club/screens/settings_page.dart';

// View documentation here: https://github.com/cgs-math/app#landing-page.

/// Provides the current widget to go to based on the authentication state.
getWidget(AsyncSnapshot<DocumentSnapshot<Object?>> userDataSnapshot) {
  // If user data has an error.
  if (userDataSnapshot.hasError) {
    return Scaffold(
      body: Center(
        child: Text("Error: ${userDataSnapshot.error}"),
      ),
    );
  }

  // User does not have a document: first time sign in.
  // This means that the user snapshot has data but not a document
  if (userDataSnapshot.hasData && !userDataSnapshot.data!.exists) {
    return const RegisterPage();
  }

  // If everything else is fine, go to the home page.
  if (userDataSnapshot.connectionState == ConnectionState.active) {
    Map<String, dynamic> userData =
        userDataSnapshot.data!.data() as Map<String, dynamic>;
    return HomePage(userData: userData);
  }

  return const Scaffold(
    body: Center(
      child: CircularProgressIndicator(),
    ),
  );
}

/// This is the Auth Gate and acts as a router to redirect a user to the
/// respective page based on their status.
///
/// More documentation can be viewed [here](https://github.com/cgs-math/app#landing-page)
class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // If user state has an error.
        if (authSnapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("Error: ${authSnapshot.error}"),
            ),
          );
        }

        // User is not signed in: user state does not have data
        if (!authSnapshot.hasData) {
          return loginPage();
        }

        // User is signed in: user state has data
        if (authSnapshot.hasData) {
          CollectionReference userInfo =
              FirebaseFirestore.instance.collection('userInfo');

          return StreamBuilder<DocumentSnapshot>(
            stream: userInfo
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (BuildContext context, userDataSnapshot) {
              return AnimatedSwitcher(
                transitionBuilder: (child, animation) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;

                  final tween = Tween(begin: begin, end: end);
                  final curvedAnimation = CurvedAnimation(
                    parent: animation,
                    curve: curve,
                  );

                  return SlideTransition(
                    position: tween.animate(curvedAnimation),
                    child: child,
                  );
                },
                duration: const Duration(milliseconds: 500),
                child: getWidget(userDataSnapshot),
              );
            },
          );
        }

        // If user is signed in and all checks are passed.
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
