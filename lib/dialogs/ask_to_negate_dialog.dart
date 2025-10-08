import 'package:fix_bayonets/const.dart';
import 'package:flutter/material.dart';

Future<bool> showNegateDialog(
    BuildContext context, EnumCardNegate cardNegate) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: const Color(0xffd3d3d3),
      content: Text(
          'Do you want to negate the German player\'s ${cardNegate.name}?',
          style: const TextStyle(fontFamily: 'HeadlinerNo45', fontSize: 40)),
      actions: <Widget>[
        OutlinedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Yes',
                style: TextStyle(
                    fontFamily: 'HeadlinerNo45',
                    fontSize: 30,
                    color: Colors.black))),
        OutlinedButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('No',
                style: TextStyle(
                    fontFamily: 'HeadlinerNo45',
                    fontSize: 30,
                    color: Colors.black)))
      ],
    ),
  );
}
