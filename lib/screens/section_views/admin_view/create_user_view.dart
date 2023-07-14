/*
File: create_user_view.dart
Description: Where users can be created
Author: Garv Shah
Created: Sat Jul 23 18:21:21 2022
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:aporia_app/utils/components.dart';

String? validateEmail(String? value) {
  const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
  final regex = RegExp(pattern);

  return value!.isNotEmpty && !regex.hasMatch(value)
      ? 'Enter a valid email address'
      : null;
}

/// This is the view where new users can be created.
class CreateUser extends StatefulWidget {

  const CreateUser({Key? key})
      : super(key: key);

  @override
  State<CreateUser> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  late List<DocumentSnapshot> userInfoList;

  CollectionReference userInfo = FirebaseFirestore.instance.collection('userInfo');
  final TextEditingController _usernameController = TextEditingController();

  // Key for the overall form.
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> userData = {};
  final functions = FirebaseFunctions.instanceFor(region: 'australia-southeast1');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          String username = _usernameController.text;
          userInfoList = (await userInfo
                  .where("lowerUsername",
              isEqualTo: username.toLowerCase())
              .get())
              .docs;

          if (_formKey.currentState!.validate()) {
            _formKey.currentState?.save();

            // create user
            functions
                .httpsCallable('manualCreateUser')
                .call(userData);

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Creating User! This will take up to 5 minutes",
                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            );
          }
        },
        label: const Text('Create'),
        icon: const Icon(Icons.check),
      ),
      body: ListView(
        children: [
          header("Create User", context, fontSize: 20, backArrow: true),
          const SizedBox(height: 20),
          Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // email input
                  Padding(
                    padding: const EdgeInsets.fromLTRB(36.0, 8.0, 36.0, 8.0),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (value) {
                        userData['email'] = value;
                      },
                      validator: validateEmail,
                      decoration: const InputDecoration(labelText: "Email"),
                    ),
                  ),
                  // username input
                  Padding(
                    padding: const EdgeInsets.fromLTRB(36.0, 8.0, 36.0, 8.0),
                    child: TextFormField(
                      controller: _usernameController,
                      onSaved: (value) {
                        userData['username'] = value;
                      },
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
                  // password input
                  Padding(
                    padding: const EdgeInsets.fromLTRB(36.0, 8.0, 36.0, 8.0),
                    child: TextFormField(
                      onSaved: (value) {
                        userData['password'] = value;
                      },
                      validator: (value) => value!.isEmpty
                          ? "Must provide a password!"
                          : null,
                      decoration: const InputDecoration(labelText: "Password"),
                    ),
                  ),
                  // user type input
                  FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    future: FirebaseFirestore.instance.collection('roles').get(),
                    builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> roleSnapshot) {
                      if (roleSnapshot.connectionState == ConnectionState.done) {
                        if (roleSnapshot.hasData) {
                          List<DropdownMenuItem<String>> possibleRoles = [];

                          List<QueryDocumentSnapshot<Map<String, dynamic>>>? roleDocs = roleSnapshot.data?.docs;
                          for (QueryDocumentSnapshot<Map<String, dynamic>> role in roleDocs!) {
                            possibleRoles
                                .add(DropdownMenuItem(value: role.id, child: Text(role.data()['tag'])));
                          }
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(36.0, 8.0, 36.0, 8.0),
                            child: DropdownButtonFormField(
                              items: possibleRoles,
                              onChanged: (String? value) {
                                userData['role'] = value;
                              },
                              validator: (value) => (value == null || value.isEmpty)
                                  ? "Must provide a role!"
                                  : null,
                              hint: const Text("User's Role"),
                            ),
                          );
                        } else {
                          return const Center(
                            child: Text("Error: The role snapshot has no data"),
                          );
                        }
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
