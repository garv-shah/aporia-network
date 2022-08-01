import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maths_club/screens/auth/register_page.dart';
import 'package:maths_club/screens/auth/login_page.dart';
import 'package:maths_club/screens/create_post_view.dart';
import 'package:maths_club/screens/edit_question.dart';
import 'package:maths_club/screens/home_page.dart';
import 'package:maths_club/screens/leaderboards.dart';
import 'package:maths_club/screens/section_page.dart';
import 'package:maths_club/screens/settings_page.dart';

// View documentation here: https://github.com/cgs-math/app#landing-page.

/// This is an enum of possible routes you can go to, for convenience of typing.
enum Destination {
  home,
  settings,
  createPost,
  editQuestion,
  leaderboards,
  section
}

/// This function takes in a destination from the enum above and returns a
/// widget with the correct input parameters.
///
/// The function must specify which entries of the input map correspond to what
/// input parameters, and userData can be added as an extra.
getDestination(Destination destination, Map<String, dynamic> userData,
    Map<String, dynamic> input) {
  if (destination == Destination.settings) {
    return SettingsPage(
      role: input['role'],
      userData: userData,
    );
  } else if (destination == Destination.createPost) {
    return const CreatePost();
  } else if (destination == Destination.editQuestion) {
    return EditQuestion(title: input['title']);
  } else if (destination == Destination.leaderboards) {
    return const Leaderboards();
  } else if (destination == Destination.section) {
    return SectionPage(userData: userData);
  } else {
    return HomePage(userData: userData);
  }
}

/// Provides the current widget to go to based on the authentication state.
getWidget(AsyncSnapshot<DocumentSnapshot<Object?>> userDataSnapshot,
    Destination destination, Map<String, dynamic> input) {
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
    return getDestination(destination, userData, input);
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

  // This line allows us to call AuthGate.of(context) outside of the AuthGate,
  // and returns the instance of state below, allowing us to call functions
  // inside the state widget.
  static _AuthGateState? of(BuildContext context) =>
      context.findAncestorStateOfType<_AuthGateState>();

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // A list of destinations the user has been to and their input parameters
  List<Destination> destination = [Destination.home];
  List<Map<String, dynamic>> childInput = [{}];

  /// A function that can be called to "push" a new route onto the router stack.
  push(Destination newDestination, {Map<String, dynamic>? input}) {
    setState(() {
      destination.add(newDestination);
      childInput.add(input ?? {});
    });
  }

  /// A function that can be called to "pop" a route off the router stack.
  pop() {
    setState(() {
      destination.removeLast();
      childInput.removeLast();
    });
  }

  /// A function that can be called the clear the stack.
  clearHistory() {
    setState(() {
      destination = [Destination.home];
      childInput = [{}];
    });
  }

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
                child: getWidget(
                    userDataSnapshot, destination.last, childInput.last),
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
