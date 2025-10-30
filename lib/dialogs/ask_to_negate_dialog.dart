import '../const.dart';
import 'package:flutter/material.dart';

Future<bool> showNegateDialog(
    BuildContext context, EnumCardNegate cardNegate) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: const Color.fromARGB(255, 129, 128, 108),
      content: Text(
          'Do you want to negate the German player\'s ${cardNegate.name}?',
          style: const TextStyle(fontFamily: constAppTextFont, fontSize: 25, fontWeight: FontWeight.bold)),
      actions: <Widget>[
          SizedBox(
            width: 125.0,
            height: 45.0,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, // Text and icon color
                backgroundColor: Colors.white, // Background color
                side: BorderSide(color: Colors.black,   width: 5.0,), // Border color
              ),     
              child: Align(
                  alignment: Alignment.center,
                  child: const Text(constButtonYes, 
                    style: TextStyle(
                        fontFamily: constAppTitleFont,
                        color: Colors.black,
                        fontSize: 25.0),
                  )),
              onPressed: () => Navigator.pop(context, true),
            ),
          ), 
          SizedBox(
            width: 125.0,
            height: 45.0,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, // Text and icon color
                backgroundColor: Colors.white, // Background color
                side: BorderSide(color: Colors.black,   width: 5.0,), // Border color
              ),     
              child: Align(
                  alignment: Alignment.center,
                  child: const Text(constButtonNo, 
                    style: TextStyle(
                        fontFamily: constAppTitleFont,
                        color: Colors.black,
                        fontSize: 25.0),
                  )),
              onPressed: () => Navigator.pop(context, false ),
            ),
          ), 
      ],
    ),
  );
}
