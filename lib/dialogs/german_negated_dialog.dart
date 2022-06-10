import 'package:fix_bayonets/const.dart';
import 'package:flutter/material.dart';

String _message(enumPhase phase) {
  String message = "";

  // format the type of unit killed nicely
  if (phase == enumPhase.move) {
    message = "move";
  } else {
    message = "attack";
  }

  return message;
}

void showNegatedDialog(BuildContext context, enumPhase gamePhase) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: const Color(0xffd3d3d3),
      content: Text(
          'The German player negated your ' + _message(gamePhase) + '.',
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
