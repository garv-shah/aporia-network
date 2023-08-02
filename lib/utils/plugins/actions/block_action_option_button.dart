import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:maths_club/widgets/forks/flowy_infra_ui/src/flowy_overlay/popover.dart';
import '../../../widgets/forks/flowy_infra_ui/widget/popup_action.dart';
import 'block_action_button.dart';
import 'option_action.dart';

class BlockOptionButton extends StatelessWidget {
  const BlockOptionButton({
    Key? key,
    required this.blockComponentContext,
    required this.blockComponentState,
    required this.actions,
    required this.editorState,
  }) : super(key: key);

  final BlockComponentContext blockComponentContext;
  final BlockComponentActionState blockComponentState;
  final List<OptionAction> actions;
  final EditorState editorState;

  @override
  Widget build(BuildContext context) {
    final popoverActions = actions.map((e) {
      switch (e) {
        case OptionAction.divider:
          return DividerOptionAction();
        case OptionAction.color:
          return ColorOptionAction(editorState: editorState);
        case OptionAction.align:
          return AlignOptionAction(editorState: editorState);
        default:
          return OptionActionWrapper(e);
      }
    }).toList();

    return PopoverActionList<PopoverAction>(
      direction: PopoverDirection.leftWithCenterAligned,
      actions: popoverActions,
      onPopupBuilder: () => blockComponentState.alwaysShowActions = true,
      onClosed: () {
        editorState.selectionType = null;
        editorState.selection = null;
        blockComponentState.alwaysShowActions = false;
      },
      onSelected: (action, controller) {
        if (action is OptionActionWrapper) {
          _onSelectAction(action.inner);
          controller.close();
        }
      },
      buildChild: (controller) => _buildOptionButton(controller),
    );
  }

  Widget _buildOptionButton(PopoverController controller) {
    return BlockActionButton(
      svgName: 'editor/option',
      richMessage: const TextSpan(
        children: [
          TextSpan(
            text: "Click",
          ),
          TextSpan(
            text: " to open menu",
          )
        ],
      ),
      onTap: () {
        controller.show();

        // update selection
        _updateBlockSelection();
      },
    );
  }

  void _updateBlockSelection() {
    final startNode = blockComponentContext.node;
    var endNode = startNode;
    while (endNode.children.isNotEmpty) {
      endNode = endNode.children.last;
    }

    final start = Position(path: startNode.path, offset: 0);
    final end = endNode.selectable?.end() ??
        Position(
          path: endNode.path,
          offset: endNode.delta?.length ?? 0,
        );

    editorState.selectionType = SelectionType.block;
    editorState.selection = Selection(
      start: start,
      end: end,
    );
  }

  void _onSelectAction(OptionAction action) {
    final node = blockComponentContext.node;
    final transaction = editorState.transaction;
    switch (action) {
      case OptionAction.delete:
        transaction.deleteNode(node);
        break;
      case OptionAction.duplicate:
        transaction.insertNode(
          node.path.next,
          node.copyWith(),
        );
        break;
      case OptionAction.turnInto:
        break;
      case OptionAction.moveUp:
        transaction.moveNode(node.path.previous, node);
        break;
      case OptionAction.moveDown:
        transaction.moveNode(node.path.next.next, node);
        break;
      case OptionAction.align:
      case OptionAction.color:
      case OptionAction.divider:
        throw UnimplementedError();
    }
    editorState.apply(transaction);
  }
}
