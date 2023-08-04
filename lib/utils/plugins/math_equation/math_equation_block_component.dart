import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';

import '../../../widgets/forks/flowy_infra_ui/style_widget/text.dart';
import '../../../widgets/forks/flowy_infra_ui/widget/buttons/primary_button.dart';
import '../../../widgets/forks/flowy_infra_ui/widget/buttons/secondary_button.dart';

Node mathEquationNode({
  String formula = '',
}) {
  final attributes = {
    MathEquationBlockKeys.formula: formula,
  };
  return Node(
    type: MathEquationBlockKeys.type,
    attributes: attributes,
  );
}

class MathEquationBlockComponentBuilder extends BlockComponentBuilder {
  MathEquationBlockComponentBuilder({
    this.configuration = const BlockComponentConfiguration(),
  });

  @override
  final BlockComponentConfiguration configuration;

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return MathEquationBlockComponentWidget(
      key: node.key,
      node: node,
      configuration: configuration,
      showActions: showActions(node),
      actionBuilder: (context, state) => actionBuilder(
        blockComponentContext,
        state,
      ),
    );
  }

  @override
  bool validate(Node node) =>
      node.children.isEmpty &&
          node.attributes[MathEquationBlockKeys.formula] is String;
}

class MathEquationBlockComponentWidget extends BlockComponentStatefulWidget {
  const MathEquationBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

  @override
  State<MathEquationBlockComponentWidget> createState() =>
      MathEquationBlockComponentWidgetState();
}

class MathEquationBlockComponentWidgetState
    extends State<MathEquationBlockComponentWidget>
    with BlockComponentConfigurable {
  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  Node get node => widget.node;

  bool isHover = false;
  String get formula =>
      widget.node.attributes[MathEquationBlockKeys.formula] as String;

  late final editorState = context.read<EditorState>();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (value) => setState(() => isHover = value),
      onTap: showEditingDialog,
      child: _buildMathEquation(context),
    );
  }

  Widget _buildMathEquation(BuildContext context) {
    Widget child = Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 50, minWidth: double.infinity),
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        color: isHover || formula.isEmpty
            ? Theme.of(context).colorScheme.tertiaryContainer
            : Colors.transparent,
      ),
      child: Center(
        child: formula.isEmpty
            ? const FlowyText.medium(
          "Add Math Equation",
          fontSize: 16,
        )
            : Math.tex(
          formula,
          textStyle: const TextStyle(fontSize: 20),
          mathStyle: MathStyle.display,
        ),
      ),
    );

    if (widget.actionBuilder != null) {
      child = BlockComponentActionWrapper(
        node: node,
        actionBuilder: widget.actionBuilder!,
        child: child,
      );
    }

    return child;
  }

  void showEditingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: formula);
        return AlertDialog(
          backgroundColor: Theme.of(context).canvasColor,
          title: const Text(
            "Edit Math Equation",
          ),
          content: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (key) {
              if (key is! RawKeyDownEvent) return;
              if (key.logicalKey == LogicalKeyboardKey.enter &&
                  !key.isShiftPressed) {
                updateMathEquation(controller.text, context);
              } else if (key.logicalKey == LogicalKeyboardKey.escape) {
                dismiss(context);
              }
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: TextField(
                autofocus: true,
                controller: controller,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'E = MC^2',
                ),
              ),
            ),
          ),
          actions: [
            SecondaryTextButton(
              "Cancel",
              onPressed: () => dismiss(context),
            ),
            PrimaryTextButton(
              "Done",
              onPressed: () => updateMathEquation(controller.text, context),
            ),
          ],
          actionsPadding: const EdgeInsets.only(bottom: 20),
          actionsAlignment: MainAxisAlignment.spaceAround,
        );
      },
    );
  }

  void updateMathEquation(String mathEquation, BuildContext context) {
    if (mathEquation == formula) {
      dismiss(context);
      return;
    }
    final transaction = editorState.transaction
      ..updateNode(
        widget.node,
        {
          MathEquationBlockKeys.formula: mathEquation,
        },
      );
    editorState.apply(transaction);
    dismiss(context);
  }

  void dismiss(BuildContext context) {
    Navigator.of(context).pop();
  }
}

class MathEquationBlockKeys {
  const MathEquationBlockKeys._();

  static const String type = 'math_equation';

  /// The content of a math equation block.
  ///
  /// The value is a String.
  static const String formula = 'formula';
}
