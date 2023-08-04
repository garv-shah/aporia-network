import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

import 'package:aporia_app/widgets/forks/flowy_infra_ui/widget/image.dart';
import 'inline_math_equation.dart';

final ToolbarItem inlineMathEquationItem = ToolbarItem(
  id: 'editor.inline_math_equation',
  group: 2,
  isActive: onlyShowInSingleSelectionAndTextType,
  builder: (context, editorState, highlightColor) {
    final selection = editorState.selection!;
    final nodes = editorState.getNodesInSelection(selection);
    final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
      return delta.everyAttributes(
            (attributes) => attributes[InlineMathEquationKeys.formula] != null,
      );
    });
    return SVGIconItemWidget(
      iconBuilder: (_) => svgWidget(
        'editor/math',
        size: const Size.square(16),
        color: isHighlight ? highlightColor : Colors.white,
      ),
      isHighlight: isHighlight,
      highlightColor: highlightColor,
      tooltip: "Create equation",
      onPressed: () async {
        final selection = editorState.selection;
        if (selection == null || selection.isCollapsed) {
          return;
        }
        final node = editorState.getNodeAtPath(selection.start.path);
        final delta = node?.delta;
        if (node == null || delta == null) {
          return;
        }

        final transaction = editorState.transaction;
        if (isHighlight) {
          final formula = delta
              .slice(selection.startIndex, selection.endIndex)
              .whereType<TextInsert>()
              .firstOrNull
              ?.attributes?[InlineMathEquationKeys.formula];
          assert(formula != null);
          if (formula == null) {
            return;
          }
          // clear the format
          transaction.replaceText(
            node,
            selection.startIndex,
            selection.length,
            formula,
            attributes: {},
          );
        } else {
          final text = editorState.getTextInSelection(selection).join();
          transaction.replaceText(
            node,
            selection.startIndex,
            selection.length,
            '\$',
            attributes: {
              InlineMathEquationKeys.formula: text,
            },
          );
        }
        await editorState.apply(transaction);
      },
    );
  },
);
