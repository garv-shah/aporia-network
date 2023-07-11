import 'package:aporia_app/utils/theming/app_flowy/slash_menu.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

List<CharacterShortcutEvent> getCustomCharacterShortcutEvents(BuildContext context) {
  return [
    // '\n'
    insertNewLineAfterBulletedList,
    insertNewLineAfterTodoList,
    insertNewLineAfterNumberedList,
    insertNewLine,

    // bulleted list
    formatAsteriskToBulletedList,
    formatMinusToBulletedList,

    // numbered list
    formatNumberToNumberedList,

    // quote
    formatDoubleQuoteToQuote,

    // heading
    formatSignToHeading,

    // checkbox
    // format unchecked box, [] or -[]
    formatEmptyBracketsToUncheckedBox,
    formatHyphenEmptyBracketsToUncheckedBox,

    // format checked box, [x] or -[x]
    formatFilledBracketsToCheckedBox,
    formatHyphenFilledBracketsToCheckedBox,

    // slash
    slashMenu(context),

    // divider
    convertMinusesToDivider,
    convertStarsToDivider,
    convertUnderscoreToDivider,

    // markdown syntax
    ...markdownSyntaxShortcutEvents,
  ];
}
