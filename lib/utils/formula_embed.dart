import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:visual_editor/controller/controllers/editor-controller.dart';
import 'package:visual_editor/document/models/nodes/embed-node.model.dart';
import 'package:visual_editor/embeds/models/embed-builder.model.dart';
import 'package:visual_editor/shared/models/editor-dialog-theme.model.dart';
import 'package:visual_editor/shared/translations/toolbar.i18n.dart';

class FormulaEmbedBuilderM implements EmbedBuilderM {
  const FormulaEmbedBuilderM();

  final String key = 'formula';

  @override
  Widget build(
      BuildContext context,
      EditorController controller,
      EmbedNodeM node,
      bool readOnly,
      ) => Math.tex(node.value.payload, textStyle: Theme.of(context).textTheme.titleMedium);

  @override
  String get type => "formula";
}

class FormulaDialog extends StatefulWidget {
  final EditorDialogThemeM? dialogTheme;
  final String? formula;

  const FormulaDialog({
    this.dialogTheme,
    this.formula,
    Key? key,
  }) : super(key: key);

  @override
  FormulaDialogState createState() => FormulaDialogState();
}

class FormulaDialogState extends State<FormulaDialog> {
  late String _formula;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _formula = widget.formula ?? '';
    _controller = TextEditingController(
      text: _formula,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.dialogTheme?.dialogBackgroundColor,
      content: TextField(
        keyboardType: TextInputType.multiline,
        maxLines: null,
        style: widget.dialogTheme?.inputTextStyle,
        decoration: InputDecoration(
          labelText: 'Please input a LATEX formula',
          labelStyle: widget.dialogTheme?.labelTextStyle,
          floatingLabelStyle: widget.dialogTheme?.labelTextStyle,
        ),
        autofocus: true,
        onChanged: _linkFormula,
        controller: _controller,
      ),
      actions: [
        TextButton(
          onPressed: _formula.isNotEmpty && (Math.tex(_formula).parseError == null)
              ? _applyFormula
              : null,
          child: Text(
            'Ok'.i18n,
            style: widget.dialogTheme?.labelTextStyle,
          ),
        ),
      ],
    );
  }

  void _linkFormula(String value) {
    setState(() {
      _formula = value;
    });
  }

  void _applyFormula() {
    Navigator.pop(context, _formula.trim());
  }
}
