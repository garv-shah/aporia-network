import 'package:aporia_app/utils/theming/app_flowy/slash_menu.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:aporia_app/utils/plugins/actions/block_action_list.dart';
import 'package:aporia_app/utils/plugins/actions/option_action.dart';
import 'package:aporia_app/utils/plugins/math_equation/math_equation_block_component.dart';

Map<String, BlockComponentBuilder> getCustomBlockComponentBuilderMap(BuildContext buildContext, EditorState editorState) {
  final standardActions = [
    OptionAction.delete,
    OptionAction.duplicate,
    // OptionAction.divider,
    // OptionAction.moveUp,
    // OptionAction.moveDown,
  ];

  final configuration = BlockComponentConfiguration(
    padding: (_) => const EdgeInsets.symmetric(vertical: 5.0),
  );
  final Map<String, BlockComponentBuilder> customBlockComponentBuilderMap = {
    PageBlockKeys.type: PageBlockComponentBuilder(),
    ParagraphBlockKeys.type: TextBlockComponentBuilder(
      configuration: standardBlockComponentConfiguration.copyWith(
        placeholderText: (_) => 'Enter a / to insert a block, or start typing',
      ),
    ),
    TodoListBlockKeys.type: TodoListBlockComponentBuilder(
      configuration: standardBlockComponentConfiguration.copyWith(
        placeholderText: (_) => 'To-do',
      ),
      iconBuilder: (context, node) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              final transaction = editorState.transaction
                ..updateNode(node, {
                  TodoListBlockKeys.checked: !node.attributes[TodoListBlockKeys.checked],
                });
              return editorState.apply(transaction);
            },
            child: Stack(
              children: [
                EditorSvg(
                  width: 22,
                  height: 22,
                  color: node.attributes[TodoListBlockKeys.checked] ? Theme.of(context).colorScheme.primary : null,
                  padding: const EdgeInsets.only(right: 5.0),
                  name: node.attributes[TodoListBlockKeys.checked] ? 'check' : 'uncheck',
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: node.attributes[TodoListBlockKeys.checked] ? const EditorSvg(
                      width: 8,
                      height: 8,
                      color: Colors.white,
                      padding: EdgeInsets.only(right: 5.0),
                      name: 'checkmark',
                    ) : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
    BulletedListBlockKeys.type: BulletedListBlockComponentBuilder(
      configuration: standardBlockComponentConfiguration.copyWith(
        placeholderText: (_) => 'List',
      ),
    ),
    NumberedListBlockKeys.type: NumberedListBlockComponentBuilder(
      configuration: standardBlockComponentConfiguration.copyWith(
        placeholderText: (_) => 'List',
      ),
    ),
    QuoteBlockKeys.type: QuoteBlockComponentBuilder(
      configuration: standardBlockComponentConfiguration.copyWith(
        placeholderText: (_) => 'Quote',
      ),
      iconBuilder: (context, node) {
        return EditorSvg(
          width: 20,
          height: 20,
          padding: const EdgeInsets.only(right: 5.0),
          name: 'quote',
          color: Theme.of(context).colorScheme.primary,
        );
      },
    ),
    HeadingBlockKeys.type: HeadingBlockComponentBuilder(
      configuration: standardBlockComponentConfiguration.copyWith(
        placeholderText: (node) =>
        'Heading ${node.attributes[HeadingBlockKeys.level]}',
      ),
    ),
    ImageBlockKeys.type: ImageBlockComponentBuilder(),
    DividerBlockKeys.type: DividerBlockComponentBuilder(
      configuration: standardBlockComponentConfiguration.copyWith(
        padding: (node) => const EdgeInsets.symmetric(vertical: 8.0),
      ),
    ),
    MathEquationBlockKeys.type: MathEquationBlockComponentBuilder(
      configuration: configuration.copyWith(
        padding: (_) => const EdgeInsets.symmetric(vertical: 20),
      ),
    ),
  };

  final builders = {
    ...standardBlockComponentBuilderMap,
    ...customBlockComponentBuilderMap,
  };

  // customize the action builder. actually, we can customize them in their own builder. Put them here just for convenience.
  for (final entry in builders.entries) {
    if (entry.key == PageBlockKeys.type) {
      continue;
    }
    final builder = entry.value;

    // customize the action builder.
    final supportColorBuilderTypes = [
      ParagraphBlockKeys.type,
      HeadingBlockKeys.type,
      BulletedListBlockKeys.type,
      NumberedListBlockKeys.type,
      QuoteBlockKeys.type,
      TodoListBlockKeys.type,
      // CalloutBlockKeys.type
    ];

    final supportAlignBuilderType = [
      ImageBlockKeys.type,
    ];

    final colorAction = [
      OptionAction.divider,
      OptionAction.color,
    ];

    final alignAction = [
      OptionAction.divider,
      OptionAction.align,
    ];

    final List<OptionAction> actions = [
      ...standardActions,
      if (supportColorBuilderTypes.contains(entry.key)) ...colorAction,
      if (supportAlignBuilderType.contains(entry.key)) ...alignAction,
    ];

    builder.showActions = (_) => true;
    builder.actionBuilder = (context, state) {
      final padding = context.node.type == HeadingBlockKeys.type
          ? const EdgeInsets.only(top: 8.0)
          : const EdgeInsets.all(0);
      return Padding(
        padding: padding,
        child: BlockActionList(
          blockComponentContext: context,
          blockComponentState: state,
          editorState: editorState,
          actions: actions,
          showSlashMenu: () => slashMenu(buildContext).handler,
        ),
      );
    };
  }

  return builders;
}
