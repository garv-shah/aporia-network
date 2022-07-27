import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          CollectionReference users = FirebaseFirestore.instance.collection('users');

          return FutureBuilder<DocumentSnapshot>(
            future: users.doc(FirebaseAuth.instance.currentUser!.uid).get(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userDataSnapshot) {

              // If user data has an error.
              if (userDataSnapshot.hasError) {
                return const Text("Something went wrong");
              }

              // User does not have a document: first time sign in.
              // This means that the user snapshot has data but not a document
              if (userDataSnapshot.hasData && !userDataSnapshot.data!.exists) {
                return const Text("Register Page");
              }

              // If everything else is fine, go to the home page.
              if (userDataSnapshot.connectionState ==
                  ConnectionState.done) {
                return const HomePage();
              }

              return const Text("Loading 1");
            },
          );
        }

        // If user is signed in and all checks are passed.
        return const Text("Loading 2");
      },
    );
  }
}
