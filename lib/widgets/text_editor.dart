import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:maths_club/utils/theming/app_flowy/block_component_builder.dart';
import 'package:maths_club/utils/theming/app_flowy/character_shortcut_events.dart';
import 'package:maths_club/utils/theming/app_flowy/mobile_toolbar_items.dart';

class TextEditor extends StatelessWidget {
  const TextEditor(
      {super.key,
      required this.editorState,
      required this.readOnly,
      required this.padding,
      required this.desktop,
      this.header,
      this.footer});

  final EditorState editorState;
  final bool readOnly;
  final EdgeInsets? padding;
  final bool desktop;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    if (readOnly) {
      return SingleChildScrollView(
        child: IntrinsicHeight(
          child: AppFlowyEditor(
              autoFocus: true,
              editable: false,
              shrinkWrap: true,
              header: header,
              footer: footer,
              scrollController: ScrollController(),
              focusNode: FocusNode(),
              editorState: editorState,
              blockComponentBuilders:
                  getCustomBlockComponentBuilderMap(context, editorState),
              characterShortcutEvents:
                  getCustomCharacterShortcutEvents(context),
              commandShortcutEvents: standardCommandShortcutEvents,
              editorStyle: const EditorStyle.desktop().copyWith(
                  padding: padding,
                  cursorColor: Theme.of(context).colorScheme.primary,
                  textStyleConfiguration: TextStyleConfiguration(
                      text: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                  )))),
        ),
      );
    } else {
      if (desktop) {
        return FloatingToolbar(
          items: [
            paragraphItem,
            ...headingItems,
            ...markdownFormatItems,
            quoteItem,
            bulletedListItem,
            numberedListItem,
            linkItem,
            buildTextColorItem(),
            buildHighlightColorItem()
          ],
          style: FloatingToolbarStyle(
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Theme.of(context).cardColor,
            toolbarActiveColor: Theme.of(context).colorScheme.primary,
          ),
          editorState: editorState,
          scrollController: ScrollController(),
          child: Expanded(
            child: AppFlowyEditor(
              autoFocus: true,
              focusNode: FocusNode(),
              editorState: editorState,
              blockComponentBuilders:
                  getCustomBlockComponentBuilderMap(context, editorState),
              characterShortcutEvents:
                  getCustomCharacterShortcutEvents(context),
              commandShortcutEvents: standardCommandShortcutEvents,
              editorStyle: const EditorStyle.desktop().copyWith(
                padding: padding,
                cursorColor: Theme.of(context).colorScheme.primary,
                textStyleConfiguration: TextStyleConfiguration(
                  text: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                  ),
                  href: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        return Expanded(
          child: Column(
            children: [
              Expanded(
                child: AppFlowyEditor(
                  autoFocus: true,
                  focusNode: FocusNode(),
                  scrollController: ScrollController(),
                  editorState: editorState,
                  blockComponentBuilders:
                      getCustomBlockComponentBuilderMap(context, editorState),
                  characterShortcutEvents:
                      getCustomCharacterShortcutEvents(context),
                  commandShortcutEvents: standardCommandShortcutEvents,
                  editorStyle: const EditorStyle.mobile().copyWith(
                    padding: padding,
                    cursorColor: Theme.of(context).colorScheme.primary,
                    textStyleConfiguration: TextStyleConfiguration(
                      text: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                      ),
                      href: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
              MobileToolbar(
                editorState: editorState,
                backgroundColor: Theme.of(context).cardColor,
                tabbarSelectedForegroundColor: Theme.of(context).primaryColorLight,
                tabbarSelectedBackgroundColor: Colors.black26.withAlpha(50),
                foregroundColor: Theme.of(context).primaryColorLight.withAlpha(180),
                clearDiagonalLineColor: Theme.of(context).colorScheme.primary,
                itemOutlineColor: Theme.of(context).cardColor,
                itemHighlightColor: Theme.of(context).colorScheme.primary,
                toolbarItems: getMobileToolbarItems(Theme.of(context).primaryColorLight),
              )
            ],
          ),
        );
      }
    }
  }
}
