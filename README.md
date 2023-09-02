# CGS Maths Club

The CGS Maths Club app!t

# Cloning

To get started with Aporia, begin with the following setups:

1. Fork the repository
2. Install the Flutter rename package
   - `flutter pub global activate rename`
3. Rename the app name and id globally
   - `flutter pub global run rename --bundleId com.example.app`
   - `flutter pub global run rename --appname "Example App"`
4. Replace all instances of `maths_club` and `Aporia Network Display Name` with your Flutter app name with your chosen IDE and run `flutter pub get`
5. Replace the config values in `lib/utils/config.dart`
6. Replace the app assets in `assets`
7. Replace the `adaptive_background_color`, `color` and `description` in `pubspec.yaml`
8. Run `flutter pub get` and then `dart run icons_launcher:create` and `dart run flutter_native_splash:create`
9. Run `flutter clean` and then `flutter pub get`
10. Run `flutterfire configure`
11. Update the directory in the [`gh-pages.yml`](./.github/workflows/gh-pages.yml) workflow

All done!

# Documentation

## Frontend: Flutter

The application has been created using Flutter, a framework by Google to create cross-platform applications. Programmed
in Dart, the framework allows for the singular codebase above to compile to most popular platforms.

The entrypoint of the codebase is the `main.dart` file, with the first function called being the `main()` function.
Flutter is a widget based framework, meaning that almost everything is a "widget", the UI being comprised widgets inside
more widgets. As such, the `main.dart` file creates a custom implementation of a widget, which is presented as our app.
To read more about how Flutter works, read the documentation [here](https://docs.flutter.dev).

## Backend: Firebase

The backend for the app, as with many others, is Firebase, an SDK by Google that allows for an easy backend
implementation for mobile applications. Firebase helps us handle our user authentication, our user's data, and much,
much more. You can read more about Firebase and what it does [here](https://firebase.google.com/docs)

## Modules:

For convenience’s sake, the documentation of the app will be split up into multiple smaller modules, explaining
individual functionality of certain features. Skip to any section as you like to read more about how it works.

### Theming

The Aporia Network follows the [Material UI](https://material.io/design) design standard, utilising a combination of
Flutter's built in theming tools, and the [Adaptive Theme](https://pub.dev/packages/adaptive_theme) package to handle
light and dark mode changes.

#### [Theme Data](lib/utils/theming/theme.dart)

To start with, the `theme.dart` defines our global themes. It's a relatively short file, using Flutter's built in
ThemeData class to define both a light and dark mode colour palette, which can be used throughout the app dynamically.
You can read more about the ThemeData class [here](https://api.flutter.dev/flutter/material/ThemeData-class.html)

#### [Adaptive Theme](lib/main.dart)

The second element of the app's theming is the [Adaptive Theme](https://pub.dev/packages/adaptive_theme) package, which
allows for dynamically setting the theme based on light and dark mode, extending upon the functionality already built
into Flutter. Namely, the package takes the themes from the `theme.dart` file above and feeds them into the light and
dark input values of AdaptiveTheme, allowing for control over if the theme is light, dark, or system at any given
moment.

### Login System

The login system is powered by Firebase and the [FlutterFire UI](https://pub.dev/packages/flutterfire_ui) package, which
provides pre-built widgets and utilities which help integrate the login system with minimal setup.

#### [Landing Page](lib/screens/auth/landing_page.dart)

After Firebase is initialised from the `main.dart` file, we are taken to the AuthGate class, residing in
the `landing_page.dart` file. This essentially acts as a router and a gate to direct traffic based on the current user's
status. The class listens to FirebaseAuth, and if the user is logged in, will send them to the home page, and if not,
will send them to the login page.

#### [Login Page](lib/screens/auth/login_page.dart)

As the name suggests, this page is made for log-ins of users, but also for creating new accounts and resetting
passwords. The LoginPage function just returns an instance of SignInScreen, a class available from FlutterFire UI that
almost does everything for us. The [documentation](https://firebase.flutter.dev/docs/ui/overview/) is quite helpful, and
the app just uses the screen
from [this guide](https://firebase.flutter.dev/docs/ui/auth/integrating-your-first-screen) for the login
page. [This website](https://flutterfire-ui.web.app/) is quite nice to visualise what all the different widgets do and
how they can be customised. Currently, the app just uses Google and Apple as sign-in providers, and our logo at the top
to make the login page look a slight bit more customised.
