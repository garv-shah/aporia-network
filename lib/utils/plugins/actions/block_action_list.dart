import 'package:flutter/material.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

import 'block_action_add_button.dart';
import 'block_action_option_button.dart';
import 'option_action.dart';

class BlockActionList extends StatelessWidget {
  const BlockActionList({
    super.key,
    required this.blockComponentContext,
    required this.blockComponentState,
    required this.editorState,
    required this.actions,
    required this.showSlashMenu,
  });

  final BlockComponentContext blockComponentContext;
  final BlockComponentActionState blockComponentState;
  final List<OptionAction> actions;
  final VoidCallback showSlashMenu;
  final EditorState editorState;

  @override
  Widget build(BuildContext context) {
    if (editorState.editable) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          BlockAddButton(
            blockComponentContext: blockComponentContext,
            blockComponentState: blockComponentState,
            editorState: editorState,
            showSlashMenu: showSlashMenu,
          ),
          const SizedBox(width: 4.0),
          BlockOptionButton(
            blockComponentContext: blockComponentContext,
            blockComponentState: blockComponentState,
            actions: actions,
            editorState: editorState,
          ),
          const SizedBox(width: 4.0),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
