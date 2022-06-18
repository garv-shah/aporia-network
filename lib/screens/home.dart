import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'landing_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AuthGate()),
            );

          },
          child: const Icon(Icons.logout)
      ),
      appBar: AppBar(
        title: const Text('Homepage'),
      ),
      body: const Center(
        child: Text('Hello World'),
      ),
    );
  }
}