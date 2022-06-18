import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/functions.dart';

// view documentation here: https://github.com/The-maths_club-System/maths_club_app/tree/feat-rewrite#login-page

SignInScreen LoginPage() {
  return SignInScreen(
    actions: [
      ForgotPasswordAction((context, email) {
        Navigator.push(context, MaterialPageRoute<void>(
          builder: (BuildContext context) => ForgotPasswordScreen(
            email: email,
            headerMaxExtent: 200,
            headerBuilder: headerIcon(Icons.lock),
            sideBuilder: sideIcon(Icons.lock),
          ),
        ));
      }),
    ],
    providerConfigs: [
      const EmailProviderConfiguration(),
      GoogleProviderConfiguration(
        clientId: getClientID(),
      ),
      const AppleProviderConfiguration(),
    ],
    headerBuilder: (context, constraints, _) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: SvgPicture.asset('assets/app_icon.svg',
                    semanticsLabel: 'maths_club System logo'),
              ),
              const SizedBox(width: 15),
              SizedBox(
                width: MediaQuery.of(context).size.width - 130,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "The maths_club System",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 32),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
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