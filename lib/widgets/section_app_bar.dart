/*
File: section_app_bar.dart
Description: App bar with search ui for the individual section pages, utilising a fork of AnimSearchBar
Author: Garv Shah
Created: Mon Jul 18 21:25:01 2022
 */

import 'package:flutter/material.dart';
import 'package:aporia_app/screens/home_page.dart';
import 'package:aporia_app/screens/leaderboards.dart';
import 'package:aporia_app/screens/settings_page.dart';
import 'package:aporia_app/widgets/forks/search_bar.dart';

typedef StringCallback = Future<void> Function(String string);

/// This is a widget that creates a custom app bar for the section view
//ignore: must_be_immutable
class SectionAppBar extends StatefulWidget {
  final TextEditingController searchController;

  // These are stateful booleans to control what the bar displays.
  bool hideTitle = false;
  bool fadeTitle = false;

  final String title;
  Map<String, dynamic> userData;

  final StringCallback onSearch;

  final bool isAdmin;

  SectionAppBar(BuildContext context,
      {Key? key,
      required this.title,
      required this.userData,
      required this.onSearch,
      required this.isAdmin,
      required this.searchController})
      : super(key: key);

  @override
  State<SectionAppBar> createState() => _SectionAppBarState();
}

class _SectionAppBarState extends State<SectionAppBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      // This is the card that the whole app bar is inside.
      child: Card(
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: SizedBox(
          // This defines the height of the card for the app bar.
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // This is the row with the back icon and the title.
              // It has an animated opacity and visibility to control its
              // presence through the stateful variables.
              AnimatedOpacity(
                opacity: widget.fadeTitle ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Visibility(
                  visible: !widget.hideTitle,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          color: Theme.of(context)
                              .primaryColorLight
                              .withAlpha(100),
                          icon: const Icon(Icons.arrow_back_ios_new),
                        ),
                      ),
                      Text(widget.title,
                          style: Theme.of(context).textTheme.titleLarge)
                    ],
                  ),
                ),
              ),
              // this is the row with the action icons
              Row(
                children: [
                  // This is the animated search bar, a fork of the package.
                  AnimSearchBar(
                    autoFocus: true,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight),
                    width: MediaQuery.of(context).size.width - 152,
                    textController: widget.searchController,
                    textFieldColor: Theme.of(context).cardColor,
                    color: Theme.of(context).cardColor,
                    textFieldIconColor:
                        Theme.of(context).primaryColorLight.withAlpha(100),
                    searchIconColor:
                        Theme.of(context).primaryColorLight.withAlpha(100),
                    helpTextColor:
                        Theme.of(context).primaryColorLight.withAlpha(200),
                    onSubmitted: (String value) async {
                      await widget.onSearch(value);

                      await Future.delayed(const Duration(milliseconds: 200),
                          () {
                        setState(() {
                          // Goes back to normal on submit.
                          widget.hideTitle = false;
                          widget.fadeTitle = false;
                        });
                      });
                    },
                    onSuffixTap: () async {
                      if (widget.searchController.text.isNotEmpty) {
                        widget.searchController.clear();
                      } else {
                        await Future.delayed(const Duration(milliseconds: 250),
                            () {
                          setState(() {
                            // Goes back to normal if back button press.
                            widget.hideTitle = false;
                            widget.fadeTitle = false;
                          });
                        });
                      }
                    },
                    onOpen: () async {
                      // First fades the title away and then removes it from
                      // the widget tree once the fade is complete.
                      setState(() {
                        widget.fadeTitle = true;
                      });

                      await Future.delayed(const Duration(milliseconds: 198),
                          () {
                        setState(() {
                          widget.hideTitle = true;
                        });
                      });
                    },
                    onClose: () async {
                      // Hides the keyboard and goes back to normal after a
                      // delay.
                      FocusManager.instance.primaryFocus?.unfocus();
                      await Future.delayed(const Duration(milliseconds: 350),
                          () {
                        setState(() {
                          widget.hideTitle = false;
                          widget.fadeTitle = false;
                        });
                      });
                    },
                    boxShadow: false,
                  ),
                  IconButton(
                      splashRadius: 20,
                      onPressed: () {
                        // Goes to the leaderboards when the icon is tapped.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Leaderboards(isAdmin: widget.isAdmin)),
                        );
                      },
                      icon: Icon(Icons.people,
                          color: Theme.of(context)
                              .primaryColorLight
                              .withAlpha(100))),
                  const SizedBox(width: 8),
                  InkWell(
                    splashColor:
                        Theme.of(context).colorScheme.primary.withAlpha(40),
                    highlightColor:
                        Theme.of(context).colorScheme.primary.withAlpha(20),
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    onTap: () {
                      // Goes to the settings page when the profile picture is
                      // tapped.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SettingsPage(userData: widget.userData, isAdmin: widget.isAdmin)),
                      );
                    },
                    // If the profile picture exists, show it, if not show a
                    // placeholder image.
                    child: SizedBox(
                        height: 30,
                        width: 30,
                        child: Hero(
                          tag: '${widget.userData['username']} Profile Picture',
                          child: fetchProfilePicture(
                              widget.userData['profilePicture'],
                              widget.userData['pfpType'],
                              widget.userData['username'],
                              padding: false),
                        )),
                  ),
                  const SizedBox(width: 16)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
