import 'package:fix_bayonets/const.dart';
import 'package:flutter/material.dart';

String _cardDisplayMessage(EnumCardName cardName) {
  String name = "";

  // format the type of unit killed nicely
  if (cardName == EnumCardName.bayonet) {
    name = constCardBayonet;
  } else if (cardName == EnumCardName.pistol) {
    name = constCardPistol;
  } else if (cardName == EnumCardName.flamethrower) {
    name = constCardFlamethrower;
  } else if (cardName == EnumCardName.grenade) {
    name = constCardGrenade;
  } else if (cardName == EnumCardName.rifle) {
    name = constCardRifle;
  } else if (cardName == EnumCardName.machinegun) {
    name = constCardMachineGun;
  } else if (cardName == EnumCardName.sniper) {
    name = constCardSniper;
  } else if (cardName == EnumCardName.crawl) {
    name = constCardCrawl;
  } else if (cardName == EnumCardName.march) {
    name = constCardMarch;
  } else if (cardName == EnumCardName.doubletime) {
    name = constCardDoubletime;
  } else if (cardName == EnumCardName.zigzag) {
    name = constCardZigzag;
  } else if (cardName == EnumCardName.run) {
    name = constCardRun;
  } else if (cardName == EnumCardName.charge) {
    name = constCardCharge;
  } else if (cardName == EnumCardName.advance) {
    name = constCardAdvance;
  } else if (cardName == EnumCardName.counterattack) {
    name = constCardCounterattack;
  } else if (cardName == EnumCardName.smoke) {
    name = constCardSmoke;
  } else if (cardName == EnumCardName.artillery) {
    name = constCardArtillery;
  } else if (cardName == EnumCardName.wire) {
    name = constCardWire;
  } else {
    name = constCardLandmine;
  }

  return name;
}

void showCardInfoDialog(BuildContext context, EnumCardName cardName) {
  showDialog<String>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: const Color(0xffd3d3d3),
      content: Text(_cardDisplayMessage(cardName),
          style: const TextStyle(fontFamily: 'HeadlinerNo45', fontSize: 25)),
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
