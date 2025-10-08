import 'package:fix_bayonets/const.dart';
import 'package:flutter/material.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

String _name(EnumUnitType unitType) {
  return EnumUnitType.values[unitType.index].name.toString().capitalize();
}

String _unitKilledMessage(EnumUnitType unitType) {
  String name = "";

  // format the type of unit killed nicely
  if (unitType == EnumUnitType.heavyweapon) {
    name = "a Heavy Weapon Specialist";
  } else if (unitType == EnumUnitType.officer) {
    name = "an Officer";
  } else if (unitType == EnumUnitType.rifleman) {
    name = "a Rifleman";
  } else if (unitType == EnumUnitType.runner) {
    name = "a Runner";
  } else {
    name = "a Sniper";
  }

  return name;
}

void showUnitKilledDialog(
    BuildContext context, EnumUnitType unitType, int unitID) {
  showDialog<String>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: const Color(0xffd3d3d3),
      content: Text('You killed ${_unitKilledMessage(unitType)}!',
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
