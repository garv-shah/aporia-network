import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

import 'search_bar.dart';

/// This is a widget that creates a custom app bar for the section view
class SectionAppBar extends StatefulWidget {
  final TextEditingController searchController = TextEditingController();
  bool hideTitle = false;
  bool fadeTitle = false;

  final String title;
  final ImageProvider<Object>? profilePicture;

  SectionAppBar(BuildContext context,
      {Key? key, required this.title, this.profilePicture})
      : super(key: key);

  @override
  State<SectionAppBar> createState() => _SectionAppBarState();
}

class _SectionAppBarState extends State<SectionAppBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      child: Card(
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: SizedBox(
          // defines the height of the card for the app bar
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // this is the row with the back icon and the title
              AnimatedOpacity(
                opacity: widget.fadeTitle ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Visibility(
                  visible: !widget.hideTitle,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                        child: BackButton(
                            color: Theme.of(context)
                                .primaryColorLight
                                .withAlpha(100)),
                      ),
                      Text(widget.title,
                          style: Theme.of(context).textTheme.headline6)
                    ],
                  ),
                ),
              ),
              // this is the row with the action icons
              Row(
                children: [
                  AnimSearchBar(
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
                      debugPrint("The user searched for $value");

                      await Future.delayed(const Duration(milliseconds: 350),
                          () {
                        setState(() {
                          widget.hideTitle = false;
                          widget.fadeTitle = false;
                        });
                      });
                    },
                    onSuffixTap: () async {
                      await Future.delayed(const Duration(milliseconds: 350),
                          () {
                        setState(() {
                          widget.hideTitle = false;
                          widget.fadeTitle = false;
                        });
                      });
                    },
                    onOpen: () async {
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
                        debugPrint("Leaderboards Clicked");
                      },
                      icon: Icon(Icons.people,
                          color: Theme.of(context)
                              .primaryColorLight
                              .withAlpha(100))),
                  const SizedBox(width: 8),
                  InkWell(
                    splashColor: Theme.of(context).colorScheme.primary.withAlpha(40),
                    highlightColor: Theme.of(context).colorScheme.primary.withAlpha(20),
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    onTap: () {
                      debugPrint('Profile Image Clicked');
                    },
                    child: (widget.profilePicture == null)
                        ? UserAvatar(
                            size: 25,
                            placeholderColor: Theme.of(context)
                                .primaryColorLight
                                .withAlpha(100))
                        : CircleAvatar(
                            backgroundImage: widget.profilePicture,
                            radius: 16,
                          ),
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
