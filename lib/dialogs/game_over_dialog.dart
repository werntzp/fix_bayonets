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
      title: const Text('Game Over',
          style: TextStyle(fontFamily: 'HeadlinerNo45', fontSize: 40)),
      content: Text(_dialogText(won),
          style: const TextStyle(fontFamily: 'HeadlinerNo45', fontSize: 40)),
      actions: <Widget>[
        OutlinedButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK',
                style: TextStyle(
                    fontFamily: 'HeadlinerNo45',
                    fontSize: 30,
                    color: Colors.black))),
      ],
    ),
  );
}
