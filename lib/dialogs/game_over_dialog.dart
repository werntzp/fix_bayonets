import 'package:flutter/material.dart';
import 'package:fix_bayonets/main.dart';

String _dialogText(bool won) {
  if (won) {
    return 'You won!';
  } else {
    return 'You lost!';
  }
}

void showGameOverDialog(BuildContext context, bool won) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Game Over'),
      content: Text(_dialogText(won)),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FixBayonetsHome()),
          ),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
