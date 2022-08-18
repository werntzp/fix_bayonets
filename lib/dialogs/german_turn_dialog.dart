import 'package:fix_bayonets/const.dart';
import 'package:flutter/material.dart';
import 'dart:async';

String _message(EnumPhase currentPhase) {
  String message = "";

  if (currentPhase == EnumPhase.orders) {
    message = "discarding cards";
  } else if (currentPhase == EnumPhase.move) {
    message = "deciding on moves";
  } else {
    message = "planning attacks";
  }

  return message;
}

void showGermanTurnDialog(BuildContext context, EnumPhase currentPhase) {
  showDialog(
      context: context,
      builder: (BuildContext builderContext) {
        Timer _timer = Timer(const Duration(seconds: 3), () {
          Navigator.of(context).pop();
        });

        return AlertDialog(
          backgroundColor: const Color(0xffd3d3d3),
          title: Text('German player ' + _message(currentPhase)),
          content: const SingleChildScrollView(
              child: LinearProgressIndicator(value: null)),
        );
      });
}
