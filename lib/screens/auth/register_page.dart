import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maths_club/screens/create_post_view.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormFieldState> formFieldKey = GlobalKey();
  final TextEditingController _usernameController = TextEditingController();
  bool emailingList = false;
  late List<DocumentSnapshot> userInfoList;

  CollectionReference userInfo =
      FirebaseFirestore.instance.collection('userInfo');

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
            OutlinedButton(
                onPressed: () async {
                  String username = _usernameController.text;
                  userInfoList = (await userInfo
                          .where("lowerUsername", isEqualTo: username.toLowerCase())
                          .get())
                      .docs;
                  bool formIsValid =
                      formFieldKey.currentState?.validate() ?? false;

                  if (formIsValid) {
                    userInfo.doc(FirebaseAuth.instance.currentUser?.uid).set({
                      'email': FirebaseAuth.instance.currentUser?.email,
                      'username': username,
                      'lowerUsername': username.toLowerCase(),
                      'receiveEmails': emailingList,
                      'profilePicture': "https://avatars.dicebear.com/api/avataaars/$username.svg"
                    });
                  }
                },
                child: const Text("Submit"))
          ],
        ),
      ),
    );
  }
}
