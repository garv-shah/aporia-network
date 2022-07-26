import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterfire_ui/auth.dart';

// All these functions are used in the login page as utility classes for their
// respective task.

/// Creates the header for a login page using an image.
HeaderBuilder headerImage(String assetName) {
  return (context, constraints, _) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SvgPicture.asset(assetName, semanticsLabel: 'Maths Club Logo'),
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
        child: SvgPicture.asset(assetName, semanticsLabel: 'Maths Club Logo'),
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
    return '1001095842193-c8hmlfa91qd46viea2lalrt2h9pmnn5q.apps.googleusercontent.com';
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return '1001095842193-c8hmlfa91qd46viea2lalrt2h9pmnn5q.apps.googleusercontent.com';
    case TargetPlatform.iOS:
      return '1001095842193-tjjil8elv8opuf533muk1qi69atstnvj.apps.googleusercontent.com';
    case TargetPlatform.macOS:
      return '1001095842193-c8hmlfa91qd46viea2lalrt2h9pmnn5q.apps.googleusercontent.com';
    default:
      throw UnsupportedError(
        'There is no Sign-In ID for this platform.',
      );
  }
}
