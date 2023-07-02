import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:maths_club/utils/theme.dart';

class TextEditor extends StatelessWidget {
  const TextEditor({
    super.key,
    required this.editorState,
    required this.readOnly,
    required this.padding,
    required this.desktop,
    this.header,
    this.footer
  });

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
          child: AppFlowyEditor.custom(
              autoFocus: true,
              editable: false,
              shrinkWrap: true,
              header: header,
              footer: footer,
              scrollController: ScrollController(),
              focusNode: FocusNode(),
              editorState: editorState,
              blockComponentBuilders: getCustomBlockComponentBuilderMap(
                  context, editorState),
              characterShortcutEvents: getCustomCharacterShortcutEvents(
                  context),
              commandShortcutEvents: standardCommandShortcutEvents,
              editorStyle: const EditorStyle.desktop().copyWith(
                padding: padding,
                  cursorColor: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                  toolbarActiveColor: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                  toolbarElevation: 20,
                  textStyleConfiguration: TextStyleConfiguration(
                      text: TextStyle(
                        color: Theme
                            .of(context)
                            .primaryColorLight,
                      )
                  )
              )
          ),
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
            textColorItem,
            highlightColorItem
          ],
          style: FloatingToolbarStyle(
              backgroundColor: Theme
                  .of(context)
                  .brightness == Brightness.light ? Colors.black : Theme
                  .of(context)
                  .cardColor
          ),
          editorState: editorState,
          scrollController: ScrollController(),
          child: Expanded(
            child: AppFlowyEditor.custom(
                autoFocus: true,
                focusNode: FocusNode(),
                editorState: editorState,
                blockComponentBuilders: getCustomBlockComponentBuilderMap(
                    context, editorState),
                characterShortcutEvents: getCustomCharacterShortcutEvents(
                    context),
                commandShortcutEvents: standardCommandShortcutEvents,
                editorStyle: const EditorStyle.desktop().copyWith(
                  padding: padding,
                    cursorColor: Theme
                        .of(context)
                        .colorScheme
                        .primary,
                    toolbarActiveColor: Theme
                        .of(context)
                        .colorScheme
                        .primary,
                    toolbarElevation: 20,
                    textStyleConfiguration: TextStyleConfiguration(
                        text: TextStyle(
                          color: Theme
                              .of(context)
                              .primaryColorLight,
                        )
                    )
                )
            ),
          ),
        );
      } else {
        return Column(
          children: [
            Expanded(
              child: AppFlowyEditor.custom(
                  autoFocus: true,
                  focusNode: FocusNode(),
                  editorState: editorState,
                  blockComponentBuilders: getCustomBlockComponentBuilderMap(
                      context, editorState),
                  characterShortcutEvents: getCustomCharacterShortcutEvents(
                      context),
                  commandShortcutEvents: standardCommandShortcutEvents,
                  editorStyle: const EditorStyle.desktop().copyWith(
                      padding: padding,
                      cursorColor: Theme
                          .of(context)
                          .colorScheme
                          .primary,
                      toolbarActiveColor: Theme
                          .of(context)
                          .colorScheme
                          .primary,
                      toolbarElevation: 20,
                      textStyleConfiguration: TextStyleConfiguration(
                          text: TextStyle(
                            color: Theme
                                .of(context)
                                .primaryColorLight,
                          )
                      )
                  )
              ),
            ),
            MobileToolbar(editorState: editorState, toolbarItems: [
              textDecorationMobileToolbarItem,
              textAndBackgroundColorMobileToolbarItem,
              headingMobileToolbarItem,
              todoListMobileToolbarItem,
              listMobileToolbarItem,
              linkMobileToolbarItem,
              quoteMobileToolbarItem,
              codeMobileToolbarItem,
            ])
          ],
        );
      }
    }
  }
}
