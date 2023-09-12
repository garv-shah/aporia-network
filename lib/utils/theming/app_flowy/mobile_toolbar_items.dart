
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:aporia_app/utils/theming/app_flowy/mobile_toolbar.dart' as mobile;

import '../../plugins/inline_math_equation/inline_math_equation_toolbar_item.dart';

List<MobileToolbarItem> getMobileToolbarItems(Color color) {
  return [
    //textDecorationMobileToolbarItem,
    MobileToolbarItem.withMenu(
      itemIcon: AFMobileIcon(
        afMobileIcons: AFMobileIcons.textDecoration,
        color: color,
      ),
      itemMenuBuilder: (editorState, selection, _) {
        return mobile.TextDecorationMenu(
            editorState,
            color,
            selection);
      },
    ),
    mobile.customBuildTextAndBackgroundColorMobileToolbarItem(color: color),
    //headingMobileToolbarItem,
    MobileToolbarItem.withMenu(
      itemIcon: AFMobileIcon(
        afMobileIcons: AFMobileIcons.heading,
        color: color,
      ),
      itemMenuBuilder: (editorState, selection, _) {
        return mobile.HeadingMenu(
          selection,
          color,
          editorState,
        );
      },
    ),
    //todoListMobileToolbarItem,
    MobileToolbarItem.action(
      itemIcon: AFMobileIcon(
        afMobileIcons: AFMobileIcons.checkbox,
        color: color,
      ),
      actionHandler: (editorState, selection) async {
        final node = editorState.getNodeAtPath(selection.start.path)!;
        final isTodoList = node.type == TodoListBlockKeys.type;

        editorState.formatNode(
          selection,
              (node) => node.copyWith(
            type: isTodoList ? ParagraphBlockKeys.type : TodoListBlockKeys.type,
            attributes: {
              TodoListBlockKeys.checked: false,
              ParagraphBlockKeys.delta: (node.delta ?? Delta()).toJson(),
            },
          ),
        );
      },
    ),
    //listMobileToolbarItem,
    MobileToolbarItem.withMenu(
      itemIcon: AFMobileIcon(
        afMobileIcons: AFMobileIcons.list,
        color: color,
      ),
      itemMenuBuilder: (editorState, selection, _) {
        return mobile.ListMenu(editorState, color, selection);
      },
    ),
    //linkMobileToolbarItem,
    MobileToolbarItem.withMenu(
      itemIcon: AFMobileIcon(
        afMobileIcons: AFMobileIcons.link,
        color: color,
      ),
      itemMenuBuilder: (editorState, selection, service) {
        final String? linkText = editorState.getDeltaAttributeValueInSelection(
          AppFlowyRichTextKeys.href,
          selection,
        );

        return mobile.MobileLinkMenu(
          editorState: editorState,
          linkText: linkText,
          onSubmitted: (value) async {
            if (value.isNotEmpty) {
              await editorState.formatDelta(selection, {
                AppFlowyRichTextKeys.href: value,
              });
            }
            service.closeItemMenu();
          },
        );
      },
    ),
    //quoteMobileToolbarItem,
    MobileToolbarItem.action(
      itemIcon: AFMobileIcon(
        afMobileIcons: AFMobileIcons.quote,
        color: color,
      ),
      actionHandler: ((editorState, selection) {
        final node = editorState.getNodeAtPath(selection.start.path)!;
        final isQuote = node.type == QuoteBlockKeys.type;
        editorState.formatNode(
          selection,
              (node) => node.copyWith(
            type: isQuote ? ParagraphBlockKeys.type : QuoteBlockKeys.type,
            attributes: {
              ParagraphBlockKeys.delta: (node.delta ?? Delta()).toJson(),
            },
          ),
        );
      }),
    ),
    //codeMobileToolbarItem,
    MobileToolbarItem.action(
      itemIcon: AFMobileIcon(
        afMobileIcons: AFMobileIcons.code,
        color: color,
      ),
      actionHandler: (editorState, selection) =>
          editorState.toggleAttribute(AppFlowyRichTextKeys.code),
    )
  ];
}
