/*
File: register_page.dart
Description: The page where users select their username after account creation
Author: Garv Shah
Created: Fri Jul 29 22:00:08 2022
 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aporia_app/screens/post_creation/create_post_view.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:aporia_app/utils/config/config.dart' as config;

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormFieldState> formFieldKey = GlobalKey();
  final TextEditingController _usernameController = TextEditingController();
  bool emailingList = false;
  bool submitted = false;
  late List<DocumentSnapshot> userInfoList;

  CollectionReference userInfo =
      FirebaseFirestore.instance.collection('userInfo');

  final functions = FirebaseFunctions.instanceFor(region: 'australia-southeast1');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Please enter a username:"),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 200,
                child: TextFormField(
                  controller: _usernameController,
                  key: formFieldKey,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "A username is required";
                    }

                    if (value.length > 12) {
                      return "Cannot exceed 12 characters";
                    }

                    if (userInfoList.isNotEmpty) {
                      return "Sorry! Name has been taken";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: "Username"),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: LabeledCheckbox(
                  label: "Sign up for emailing list?",
                  padding: EdgeInsets.zero,
                  value: emailingList,
                  onChanged: (value) {
                    setState(() {
                      emailingList = value;
                    });
                  }),
            ),
            const SizedBox(height: 20),
            !submitted ? OutlinedButton(
                onPressed: () async {
                  String username = _usernameController.text;
                  userInfoList = (await userInfo
                          .where("lowerUsername",
                              isEqualTo: username.toLowerCase())
                          .get())
                      .docs;
                  bool formIsValid =
                      formFieldKey.currentState?.validate() ?? false;

                  if (formIsValid) {
                    setState(() {
                      submitted = true;
                    });

                    final snackBar = SnackBar(
                      content: Text(
                        "Creating Account, hang tight!",
                        style: TextStyle(
                            color: Theme.of(context)
                                .primaryColorLight),
                      ),
                      backgroundColor: Theme.of(context)
                          .scaffoldBackgroundColor,
                    );
                    // Find the Scaffold in the widget tree and use it to show a SnackBar.
                    ScaffoldMessenger.of(context)
                        .showSnackBar(snackBar);

                    try {
                      await functions
                          .httpsCallable('updateUsername')
                          .call({'username': username, 'appID': config.appID});

                      await functions
                          .httpsCallable('updatePfp')
                          .call({'profilePicture': 'https://api.dicebear.com/7.x/avataaars/svg?seed=$username', 'pfpType': 'image/svg+xml'});
                    } on FirebaseFunctionsException catch (error) {
                      if (kDebugMode) {
                        print(error.code);
                        print(error.details);
                        print(error.message);
                      }
                    }

                    userInfo.doc(FirebaseAuth.instance.currentUser?.uid).set({
                      'email': FirebaseAuth.instance.currentUser?.email,
                      'username': username,
                      'lowerUsername': username.toLowerCase(),
                      'receiveEmails': emailingList,
                      'profilePicture': 'https://api.dicebear.com/7.x/avataaars/svg?seed=$username',
                      'pfpType': 'image/svg+xml'
                    });
                  }
                },
                child: const Text("Submit")) : const CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}
