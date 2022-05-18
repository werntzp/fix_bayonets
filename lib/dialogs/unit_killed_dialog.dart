import 'package:fix_bayonets/const.dart';
import 'package:flutter/material.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

String _name(enumUnitType unitType) {
  return enumUnitType.values[unitType.index].name.toString().capitalize();
}

void showUnitKilledDialog(
    BuildContext context, enumUnitType unitType, int unitID) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Unit Killed!'),
      content: Text('You killed a ' + _name(unitType) + ' unit.'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
