/*
File: login_functions.dart
Description: Utility functions for the login page, pertaining to their respective task
Author: Garv Shah
Created: Sat Jun 18 18:29:00 2022
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:aporia_app/utils/config/config.dart' as config;

/// Creates the header for a login page using an image.
HeaderBuilder headerImage(String assetName) {
  return (context, constraints, _) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SvgPicture.asset(assetName, semanticsLabel: '${config.name} Logo'),
    );
  };
}

/// Creates the header for a login page using an icon.
HeaderBuilder headerIcon(BuildContext context, IconData icon) {
  return (context, constraints, shrinkOffset) {
    return Padding(
      padding: const EdgeInsets.all(20).copyWith(top: 40),
      child: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
        size: constraints.maxWidth / 4 * (1 - shrinkOffset),
      ),
    );
  };
}

/// Creates the side image for a login page using an image.
SideBuilder sideImage(String assetName) {
  return (context, constraints) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(constraints.maxWidth / 4),
        child: SvgPicture.asset(assetName, semanticsLabel: '${config.name} Logo'),
      ),
    );
  };
}

/// Creates the side image for a login page using an icon.
SideBuilder sideIcon(BuildContext context, IconData icon) {
  return (context, constraints) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
        size: constraints.maxWidth / 3,
      ),
    );
  };
}

/// Gets the Firebase App ID for the current user's platform.
String getClientID() {
  if (kIsWeb) {
    return '358601933529-lo264k5chj8f6f4ga3lguqnum8no3goa.apps.googleusercontent.com';
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return '358601933529-lo264k5chj8f6f4ga3lguqnum8no3goa.apps.googleusercontent.com';
    case TargetPlatform.iOS:
      return '1001095842193-tjjil8elv8opuf533muk1qi69atstnvj.apps.googleusercontent.com';
    case TargetPlatform.macOS:
      return '358601933529-lo264k5chj8f6f4ga3lguqnum8no3goa.apps.googleusercontent.com';
    default:
      throw UnsupportedError(
        'There is no Sign-In ID for this platform.',
      );
  }
}
