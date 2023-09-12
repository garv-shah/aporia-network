import 'package:aporia_app/utils/plugins/extensions/flowy_tint_extension.dart';
import 'package:appflowy_editor/appflowy_editor.dart' hide FlowySvg;
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../widgets/forks/flowy_infra_ui/src/flowy_overlay/popover.dart';
import '../../../widgets/forks/flowy_infra_ui/style_widget/color_picker.dart';
import '../../../widgets/forks/flowy_infra_ui/widget/image.dart';
import '../../../widgets/forks/flowy_infra_ui/widget/popup_action.dart';
import '../../../widgets/forks/flowy_infra_ui/widget/theme_extension.dart';

enum OptionAlignType {
  left,
  center,
  right;

  static OptionAlignType fromString(String? value) {
    switch (value) {
      case 'left':
        return OptionAlignType.left;
      case 'center':
        return OptionAlignType.center;
      case 'right':
        return OptionAlignType.right;
      default:
        return OptionAlignType.center;
    }
  }

  String get assetName {
    switch (this) {
      case OptionAlignType.left:
        return 'editor/align/left';
      case OptionAlignType.center:
        return 'editor/align/center';
      case OptionAlignType.right:
        return 'editor/align/right';
    }
  }

  String get description {
    switch (this) {
      case OptionAlignType.left:
        return "Left";
      case OptionAlignType.center:
        return "Center";
      case OptionAlignType.right:
        return "Right";
    }
  }
}

class DividerOptionAction extends CustomActionCell {
  @override
  Widget buildWithContext(BuildContext context) {
    return const Divider(
      height: 1.0,
      thickness: 1.0,
    );
  }
}

class AlignOptionAction extends PopoverActionCell {
  AlignOptionAction({
    required this.editorState,
  });

  final EditorState editorState;

  @override
  Widget? leftIcon(Color iconColor) {
    return FlowySvg(
      name: align.assetName,
      size: const Size.square(12),
    ).padding(all: 2.0);
  }

  @override
  String get name {
    return "Align";
  }

  @override
  PopoverActionCellBuilder get builder =>
      (context, parentController, controller) {
        final selection = editorState.selection?.normalized;
        if (selection == null) {
          return const SizedBox.shrink();
        }
        final node = editorState.getNodeAtPath(selection.start.path);
        if (node == null) {
          return const SizedBox.shrink();
        }
        final children = buildAlignOptions(context, (align) async {
          await onAlignChanged(align);
          controller.close();
          parentController.close();
        });
        return IntrinsicHeight(
          child: IntrinsicWidth(
            child: Column(
              children: children,
            ),
          ),
        );
      };

  List<Widget> buildAlignOptions(
    BuildContext context,
    void Function(OptionAlignType) onTap,
  ) {
    return OptionAlignType.values.map((e) => OptionAlignWrapper(e)).map((e) {
      final leftIcon = e.leftIcon(Theme.of(context).colorScheme.onSurface);
      final rightIcon = e.rightIcon(Theme.of(context).colorScheme.onSurface);
      return HoverButton(
        onTap: () => onTap(e.inner),
        itemHeight: ActionListSizes.itemHeight,
        leftIcon: leftIcon,
        name: e.name,
        rightIcon: rightIcon,
      );
    }).toList();
  }

  OptionAlignType get align {
    final selection = editorState.selection;
    if (selection == null) {
      return OptionAlignType.center;
    }
    final node = editorState.getNodeAtPath(selection.start.path);
    final align = node?.attributes['align'];
    return OptionAlignType.fromString(align);
  }

  Future<void> onAlignChanged(OptionAlignType align) async {
    if (align == this.align) {
      return;
    }
    final selection = editorState.selection;
    if (selection == null) {
      return;
    }
    final node = editorState.getNodeAtPath(selection.start.path);
    if (node == null) {
      return;
    }
    final transaction = editorState.transaction;
    transaction.updateNode(node, {
      'align': align.name,
    });
    await editorState.apply(transaction);
  }
}

class ColorOptionAction extends PopoverActionCell {
  ColorOptionAction({
    required this.editorState,
  });

  final EditorState editorState;

  @override
  Widget? leftIcon(Color iconColor) {
    return const FlowySvg(
      name: 'editor/color_formatter',
      size: Size.square(12),
    ).padding(all: 2.0);
  }

  @override
  String get name => "Colour";

  @override
  Widget Function(
    BuildContext context,
    PopoverController parentController,
    PopoverController controller,
  ) get builder => (context, parentController, controller) {
        final selection = editorState.selection?.normalized;
        if (selection == null) {
          return const SizedBox.shrink();
        }
        final node = editorState.getNodeAtPath(selection.start.path);
        if (node == null) {
          return const SizedBox.shrink();
        }
        final bgColor =
            node.attributes[blockComponentBackgroundColor] as String?;
        final selectedColor = bgColor?.tryToColor();

        final colors = [
          // clear background color.
          const FlowyColorOption(
            color: Colors.transparent,
            name: "Default",
          ),
          ...FlowyTint.values.map(
            (e) => FlowyColorOption(
              color: e.color(context),
              name: e.tintName(AppFlowyEditorLocalizations.current),
            ),
          ),
        ];

        return FlowyColorPicker(
          colors: colors,
          selected: selectedColor,
          border: Border.all(
            color: Theme.of(context).colorScheme.onBackground,
            width: 1,
          ),
          onTap: (color, index) async {
            final transaction = editorState.transaction;
            final backgroundColor =
                color == Colors.transparent ? null : color.toHex();
            transaction.updateNode(node, {
              blockComponentBackgroundColor: backgroundColor,
            });
            await editorState.apply(transaction);

            controller.close();
            parentController.close();
          },
        );
      };
}

class OptionActionWrapper extends ActionCell {
  OptionActionWrapper(this.inner);

  final OptionAction inner;

  @override
  Widget? leftIcon(Color iconColor) => FlowySvg(name: inner.assetName);

  @override
  String get name => inner.description;
}

class OptionAlignWrapper extends ActionCell {
  OptionAlignWrapper(this.inner);

  final OptionAlignType inner;

  @override
  Widget? leftIcon(Color iconColor) => FlowySvg(name: inner.assetName);

  @override
  String get name => inner.description;
}

enum OptionAction {
  delete,
  duplicate,
  turnInto,
  moveUp,
  moveDown,
  color,
  divider,
  align;

  String get assetName {
    switch (this) {
      case OptionAction.delete:
        return 'editor/delete';
      case OptionAction.duplicate:
        return 'editor/duplicate';
      case OptionAction.turnInto:
        return 'editor/turn_into';
      case OptionAction.moveUp:
        return 'editor/move_up';
      case OptionAction.moveDown:
        return 'editor/move_down';
      case OptionAction.color:
        return 'editor/color';
      case OptionAction.divider:
        return 'editor/divider';
      case OptionAction.align:
        return 'editor/align/center';
    }
  }

  String get description {
    switch (this) {
      case OptionAction.delete:
        return "Delete";
      case OptionAction.duplicate:
        return "Duplicate";
      case OptionAction.turnInto:
        return "Turn into";
      case OptionAction.moveUp:
        return "Move up";
      case OptionAction.moveDown:
        return "Move down";
      case OptionAction.color:
        return "Color";
      case OptionAction.align:
        return "Align";
      case OptionAction.divider:
        throw UnsupportedError('Divider does not have description');
    }
  }
}
