import 'package:flutter/material.dart';
import 'package:math_keyboard/math_keyboard.dart';

import '../utils/components.dart';


/**
 * The following section includes functions for the quiz page.
 */



/**
 * The following section includes the actual QuizView page.
 */

/// This is the view where new posts can be created.
class QuizView extends StatefulWidget {
  const QuizView({Key? key}) : super(key: key);

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  MathFieldEditingController mathController = MathFieldEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Next'),
        icon: const Icon(Icons.arrow_forward_ios),
      ),
      body: ListView(
        children: [
          header("Problem 1", context, backArrow: true, showIcon: false),
          const Center(child: Text("Hello")),
          Padding(
            padding: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
            child: MathField(
              controller: mathController,
              variables: const ['x', 'y', 'z'],
              onChanged: (String value) {},
              onSubmitted: (String value) {},
            ),
          )
        ],
      ),
    );
  }
}
