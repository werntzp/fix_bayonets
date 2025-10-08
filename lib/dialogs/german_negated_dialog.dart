import 'package:fix_bayonets/const.dart';
import 'package:flutter/material.dart';

String _message(EnumPhase phase) {
  String message = "";

  // format the type of unit killed nicely
  if (phase == EnumPhase.move) {
    message = "move";
  } else {
    message = "attack";
  }

  return message;
}

void showNegatedDialog(BuildContext context, EnumPhase gamePhase) {
  showDialog<String>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: const Color(0xffd3d3d3),
      content: Text('The German player negated your ${_message(gamePhase)}.',
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
