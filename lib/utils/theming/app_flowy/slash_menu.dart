
import 'dart:convert';
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:aporia_app/utils/plugins/math_equation/math_equation_block_component.dart';
import 'package:http/http.dart' as http;
import 'package:appflowy_editor/src/service/default_text_operations/format_rich_text_style.dart';
import 'package:universal_io/io.dart';
import 'package:aporia_app/utils/upload_file.dart';
import 'package:string_validator/string_validator.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

CharacterShortcutEvent slashMenu(BuildContext parentContext) {
  return customSlashCommand([
    SelectionMenuItem(
      name: AppFlowyEditorLocalizations.current.text,
      icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
        name: 'text',
        isSelected: isSelected,
        style: style,
      ),
      keywords: ['text'],
      handler: (editorState, _, __) {
        insertNodeAfterSelection(editorState, paragraphNode());
      },
    ),
    SelectionMenuItem(
      name: AppFlowyEditorLocalizations.current.heading1,
      icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
        name: 'h1',
        isSelected: isSelected,
        style: style,
      ),
      keywords: ['heading 1, h1'],
      handler: (editorState, _, __) {
        insertHeadingAfterSelection(editorState, 1);
      },
    ),
    SelectionMenuItem(
      name: AppFlowyEditorLocalizations.current.heading2,
      icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
        name: 'h2',
        isSelected: isSelected,
        style: style,
      ),
      keywords: ['heading 2, h2'],
      handler: (editorState, _, __) {
        insertHeadingAfterSelection(editorState, 2);
      },
    ),
    SelectionMenuItem(
      name: AppFlowyEditorLocalizations.current.heading3,
      icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
        name: 'h3',
        isSelected: isSelected,
        style: style,
      ),
      keywords: ['heading 3, h3'],
      handler: (editorState, _, __) {
        insertHeadingAfterSelection(editorState, 3);
      },
    ),
    SelectionMenuItem(
      name: AppFlowyEditorLocalizations.current.image,
      icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
        name: 'image',
        isSelected: isSelected,
        style: style,
      ),
      keywords: ['image'],
      handler: (editorState, menuService, context) {
        final container = Overlay.of(context);
        showImageMenu(container, editorState, menuService,
            onInsertImage: (imageUrl) async {
              final regex = RegExp('^(http|https)://');
              http.Response res;
              if (regex.hasMatch(imageUrl)) {
                // is a url
                res = await http.get(Uri.parse(imageUrl));
                // if status code of remote image is 200, then insert it!
                if (res.statusCode == 200) editorState.insertImageNode(imageUrl);
              } else {
                // file is either local or raw bytes
                Uint8List bytes;
                String ext;
                if (isBase64(imageUrl)) {
                  // is raw base64 data
                  bytes = base64Decode(imageUrl);
                  var mime = lookupMimeType('', headerBytes: bytes);
                  ext = extensionFromMime(mime!);
                } else {
                  File file = File(imageUrl);
                  bytes = file.readAsBytesSync();
                  ext = extension(imageUrl);
                }

                // upload to firebase
                String uuid = const Uuid().v4();
                String? remoteUrl = await uploadFile(bytes, uuid, ext, parentContext);
                if (remoteUrl != null) editorState.insertImageNode(remoteUrl);
              }
            }
        );
      },
    ),
    SelectionMenuItem(
      name: AppFlowyEditorLocalizations.current.bulletedList,
      icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
        name: 'bulleted_list',
        isSelected: isSelected,
        style: style,
      ),
      keywords: ['bulleted list', 'list', 'unordered list'],
      handler: (editorState, _, __) {
        insertBulletedListAfterSelection(editorState);
      },
    ),
    SelectionMenuItem(
      name: AppFlowyEditorLocalizations.current.numberedList,
      icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
        name: 'number',
        isSelected: isSelected,
        style: style,
      ),
      keywords: ['numbered list', 'list', 'ordered list'],
      handler: (editorState, _, __) {
        insertNumberedListAfterSelection(editorState);
      },
    ),
    SelectionMenuItem(
      name: AppFlowyEditorLocalizations.current.checkbox,
      icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
        name: 'checkbox',
        isSelected: isSelected,
        style: style,
      ),
      keywords: ['todo list', 'list', 'checkbox list'],
      handler: (editorState, _, __) {
        insertCheckboxAfterSelection(editorState);
      },
    ),
    SelectionMenuItem(
      name: AppFlowyEditorLocalizations.current.quote,
      icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
        name: 'quote',
        isSelected: isSelected,
        style: style,
      ),
      keywords: ['quote', 'refer'],
      handler: (editorState, _, __) {
        insertQuoteAfterSelection(editorState);
      },
    ),
    dividerMenuItem,
    SelectionMenuItem.node(
      name: 'MathEquation',
      iconData: Icons.text_fields_rounded,
      keywords: ['tex, latex, katex', 'math equation', 'formula'],
      nodeBuilder: (editorState, context) => mathEquationNode(),
      replace: (_, node) => node.delta?.isEmpty ?? false,
      updateSelection: (editorState, path, __, ___) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          final mathEquationState =
              editorState.getNodeAtPath(path)?.key.currentState;
          if (mathEquationState != null &&
              mathEquationState is MathEquationBlockComponentWidgetState) {
            mathEquationState.showEditingDialog();
          }
        });
        return null;
      },
    ),
  ],
      style: SelectionMenuStyle(
          selectionMenuBackgroundColor: Theme.of(parentContext).cardColor,
          selectionMenuItemTextColor: Theme.of(parentContext).primaryColorLight,
          selectionMenuItemIconColor: Theme.of(parentContext).primaryColorLight,
          selectionMenuItemSelectedTextColor: Theme.of(parentContext).colorScheme.primary,
          selectionMenuItemSelectedIconColor: Theme.of(parentContext).colorScheme.primary,
          selectionMenuItemSelectedColor: Theme.of(parentContext).colorScheme.primary.withAlpha(45))
  );
}
