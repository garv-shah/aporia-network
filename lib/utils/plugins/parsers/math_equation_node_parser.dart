import 'package:maths_club/utils/plugins/math_equation/math_equation_block_component.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

class MathEquationNodeParser extends NodeParser {
  const MathEquationNodeParser();

  @override
  String get id => MathEquationBlockKeys.type;

  @override
  String transform(Node node) {
    return '\$\$${node.attributes[id]}\$\$';
  }
}
