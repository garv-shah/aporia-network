import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class TextDecorationMenu extends StatefulWidget {
  const TextDecorationMenu(
      this.editorState,
      this.color,
      this.selection, {
        Key? key,
      }) : super(key: key);

  final EditorState editorState;
  final Selection selection;
  final Color color;

  @override
  State<TextDecorationMenu> createState() => _TextDecorationMenuState();
}

class _TextDecorationMenuState extends State<TextDecorationMenu> {
  final textDecorations = [
    TextDecorationUnit(
      icon: AFMobileIcons.bold,
      label: AppFlowyEditorLocalizations.current.bold,
      name: AppFlowyRichTextKeys.bold,
    ),
    TextDecorationUnit(
      icon: AFMobileIcons.italic,
      label: AppFlowyEditorLocalizations.current.italic,
      name: AppFlowyRichTextKeys.italic,
    ),
    TextDecorationUnit(
      icon: AFMobileIcons.underline,
      label: AppFlowyEditorLocalizations.current.underline,
      name: AppFlowyRichTextKeys.underline,
    ),
    TextDecorationUnit(
      icon: AFMobileIcons.strikethrough,
      label: AppFlowyEditorLocalizations.current.strikethrough,
      name: AppFlowyRichTextKeys.strikethrough,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final style = MobileToolbarStyle.of(context);
    final btnList = textDecorations.map((currentDecoration) {
      // Check current decoration is active or not
      final nodes = widget.editorState.getNodesInSelection(widget.selection);
      final isSelected = nodes.allSatisfyInSelection(widget.selection, (delta) {
        return delta.everyAttributes(
              (attributes) => attributes[currentDecoration.name] == true,
        );
      });

      return MobileToolbarItemMenuBtn(
        icon: AFMobileIcon(
          color: widget.color,
          afMobileIcons: currentDecoration.icon,
        ),
        label: Text(currentDecoration.label),
        isSelected: isSelected,
        onPressed: () {
          if (widget.selection.isCollapsed) {
            // TODO(yijing): handle collapsed selection
          } else {
            setState(() {
              widget.editorState.toggleAttribute(currentDecoration.name);
            });
          }
        },
      );
    }).toList();

    return GridView(
      shrinkWrap: true,
      gridDelegate: buildMobileToolbarMenuGridDelegate(
        mobileToolbarStyle: style,
        crossAxisCount: 2,
      ),
      children: btnList,
    );
  }
}

class TextDecorationUnit {
  final AFMobileIcons icon;
  final String label;
  final String name;

  TextDecorationUnit({
    required this.icon,
    required this.label,
    required this.name,
  });
}

MobileToolbarItem customBuildTextAndBackgroundColorMobileToolbarItem({
  List<ColorOption>? textColorOptions,
  List<ColorOption>? backgroundColorOptions,
  required Color color
}) {
  return MobileToolbarItem.withMenu(
    itemIcon: AFMobileIcon(
        afMobileIcons: AFMobileIcons.color,
        color: color
    ),
    itemMenuBuilder: (editorState, selection, _) {
      return _TextAndBackgroundColorMenu(
        editorState,
        selection,
        textColorOptions: textColorOptions,
        backgroundColorOptions: backgroundColorOptions,
      );
    },
  );
}

class _TextAndBackgroundColorMenu extends StatefulWidget {
  const _TextAndBackgroundColorMenu(
      this.editorState,
      this.selection, {
        this.textColorOptions,
        this.backgroundColorOptions,
        Key? key,
      }) : super(key: key);

  final EditorState editorState;
  final Selection selection;
  final List<ColorOption>? textColorOptions;
  final List<ColorOption>? backgroundColorOptions;

  @override
  State<_TextAndBackgroundColorMenu> createState() =>
      _TextAndBackgroundColorMenuState();
}

class _TextAndBackgroundColorMenuState
    extends State<_TextAndBackgroundColorMenu> {
  @override
  Widget build(BuildContext context) {
    final style = MobileToolbarStyle.of(context);
    List<Tab> myTabs = <Tab>[
      Tab(
        text: AppFlowyEditorLocalizations.current.textColor,
      ),
      Tab(text: AppFlowyEditorLocalizations.current.backgroundColor),
    ];

    return DefaultTabController(
      length: myTabs.length,
      child: Column(
        children: [
          SizedBox(
            height: style.buttonHeight,
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: myTabs,
              labelColor: style.tabbarSelectedForegroundColor,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(style.borderRadius),
                color: style.tabbarSelectedBackgroundColor,
              ),
              // remove the bottom line of TabBar
              dividerColor: Colors.transparent,
            ),
          ),
          SizedBox(
            // 3 lines of buttons
            height: 3 * style.buttonHeight + 4 * style.buttonSpacing,
            child: TabBarView(
              children: [
                TextColorOptionsWidgets(
                  widget.editorState,
                  widget.selection,
                  textColorOptions: widget.textColorOptions,
                ),
                BackgroundColorOptionsWidgets(
                  widget.editorState,
                  widget.selection,
                  backgroundColorOptions: widget.backgroundColorOptions,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HeadingMenu extends StatefulWidget {
  const HeadingMenu(
      this.selection,
      this.color,
      this.editorState, {
        Key? key,
      }) : super(key: key);

  final Selection selection;
  final Color color;
  final EditorState editorState;

  @override
  State<HeadingMenu> createState() => _HeadingMenuState();
}

class _HeadingMenuState extends State<HeadingMenu> {
  final headings = [
    HeadingUnit(
      icon: AFMobileIcons.h1,
      label: AppFlowyEditorLocalizations.current.mobileHeading1,
      level: 1,
    ),
    HeadingUnit(
      icon: AFMobileIcons.h2,
      label: AppFlowyEditorLocalizations.current.mobileHeading2,
      level: 2,
    ),
    HeadingUnit(
      icon: AFMobileIcons.h3,
      label: AppFlowyEditorLocalizations.current.mobileHeading3,
      level: 3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final style = MobileToolbarStyle.of(context);
    final btnList = headings.map((currentHeading) {
      // Check if current node is heading and its level
      final node =
      widget.editorState.getNodeAtPath(widget.selection.start.path)!;
      final isSelected = node.type == HeadingBlockKeys.type &&
          node.attributes[HeadingBlockKeys.level] == currentHeading.level;

      return MobileToolbarItemMenuBtn(
        icon: AFMobileIcon(
            afMobileIcons: currentHeading.icon,
            color: widget.color
        ),
        label: Text(currentHeading.label),
        isSelected: isSelected,
        onPressed: () {
          setState(() {
            widget.editorState.formatNode(
              widget.selection,
                  (node) => node.copyWith(
                type: isSelected
                    ? ParagraphBlockKeys.type
                    : HeadingBlockKeys.type,
                attributes: {
                  HeadingBlockKeys.level: currentHeading.level,
                  HeadingBlockKeys.backgroundColor:
                  node.attributes[blockComponentBackgroundColor],
                  ParagraphBlockKeys.delta: (node.delta ?? Delta()).toJson(),
                },
              ),
            );
          });
        },
      );
    }).toList();

    return GridView(
      shrinkWrap: true,
      gridDelegate: buildMobileToolbarMenuGridDelegate(
        mobileToolbarStyle: style,
        crossAxisCount: 3,
      ),
      children: btnList,
    );
  }
}

class HeadingUnit {
  final AFMobileIcons icon;
  final String label;
  final int level;

  HeadingUnit({
    required this.icon,
    required this.label,
    required this.level,
  });
}

class ListMenu extends StatefulWidget {
  const ListMenu(
      this.editorState,
      this.color,
      this.selection, {
        Key? key,
      }) : super(key: key);

  final Selection selection;
  final EditorState editorState;
  final Color color;

  @override
  State<ListMenu> createState() => _ListMenuState();
}

class _ListMenuState extends State<ListMenu> {
  final lists = [
    ListUnit(
      icon: AFMobileIcons.bulletedList,
      label: AppFlowyEditorLocalizations.current.bulletedList,
      name: 'bulleted_list',
    ),
    ListUnit(
      icon: AFMobileIcons.numberedList,
      label: AppFlowyEditorLocalizations.current.numberedList,
      name: 'numbered_list',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final btnList = lists.map((currentList) {
      // Check if current node is list and its type
      final node =
      widget.editorState.getNodeAtPath(widget.selection.start.path)!;
      final isSelected = node.type == currentList.name;

      return MobileToolbarItemMenuBtn(
        icon: AFMobileIcon(
          afMobileIcons: currentList.icon,
          color: widget.color,
        ),
        label: Text(currentList.label),
        isSelected: isSelected,
        onPressed: () {
          setState(() {
            widget.editorState.formatNode(
              widget.selection,
                  (node) => node.copyWith(
                type: isSelected ? ParagraphBlockKeys.type : currentList.name,
                attributes: {
                  ParagraphBlockKeys.delta: (node.delta ?? Delta()).toJson(),
                },
              ),
            );
          });
        },
      );
    }).toList();

    return GridView(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 5,
      ),
      children: btnList,
    );
  }
}

class ListUnit {
  final AFMobileIcons icon;
  final String label;
  final String name;

  ListUnit({
    required this.icon,
    required this.label,
    required this.name,
  });
}

class MobileLinkMenu extends StatefulWidget {
  const MobileLinkMenu({
    this.linkText,
    required this.editorState,
    required this.onSubmitted,
  });

  final String? linkText;
  final EditorState editorState;
  final void Function(String) onSubmitted;

  @override
  State<MobileLinkMenu> createState() => _MobileLinkMenuState();
}

class _MobileLinkMenuState extends State<MobileLinkMenu> {
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.linkText ?? '');
    _focusNode = FocusNode()..requestFocus();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = MobileToolbarStyle.of(context);
    return Material(
      // TextField widget needs to be wrapped in a Material widget to provide a visual appearance
      color: style.backgroundColor,
      child: SizedBox(
        height: style.toolbarHeight,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: TextField(
                  focusNode: _focusNode,
                  controller: _textEditingController,
                  keyboardType: TextInputType.url,
                  onSubmitted: widget.onSubmitted,
                  cursorColor: style.foregroundColor,
                  decoration: InputDecoration(
                    hintText: 'URL',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 8,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: style.itemOutlineColor,
                      ),
                      borderRadius: BorderRadius.circular(style.borderRadius),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: style.itemOutlineColor,
                      ),
                      borderRadius: BorderRadius.circular(style.borderRadius),
                    ),
                    suffixIcon: IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      icon: Icon(
                        Icons.clear_rounded,
                        color: style.foregroundColor,
                      ),
                      onPressed: _textEditingController.clear,
                      splashRadius: 5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSubmitted.call(_textEditingController.text);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    style.itemHighlightColor,
                  ),
                  elevation: MaterialStateProperty.all(0),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(style.borderRadius),
                    ),
                  ),
                ),
                child: Text(AppFlowyEditorLocalizations.current.done),
              ),
            )
            // TODO(yijing): edit link?
          ],
        ),
      ),
    );
  }
}
