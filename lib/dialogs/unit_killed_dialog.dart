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

String _unitKilledMessage(enumUnitType unitType) {
  String name = "";

  // format the type of unit killed nicely
  if (unitType == enumUnitType.heavyweapon) {
    name = "a Heavy Weappn Specialist";
  } else if (unitType == enumUnitType.officer) {
    name = "an Officer";
  } else if (unitType == enumUnitType.rifleman) {
    name = "a Rifelman";
  } else if (unitType == enumUnitType.runner) {
    name = "a Runner";
  } else {
    name = "a Sniper";
  }

  return name;
}

void showUnitKilledDialog(
    BuildContext context, enumUnitType unitType, int unitID) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: const Color(0xffd3d3d3),
      content: Text('You killed ' + _unitKilledMessage(unitType) + '!',
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
