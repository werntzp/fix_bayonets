import '../const.dart';
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

void showCardInfoDialog(BuildContext context, EnumCardName cardName, String graphic) {
  showDialog<String>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: const Color.fromARGB(255, 129, 128, 108),
      content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column: Image
            Container(
              height: 75,
              width: 65,
              margin: EdgeInsets.only(right: 16),
              child: Image.asset(graphic, fit: BoxFit.fill),
            ),
            // Right column: Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _cardDisplayMessage(cardName),
                    style: const TextStyle(fontFamily: constAppTextFont, fontSize: 25)),
                ],
              ),
            ),
          ],
      ), 
      actions: [ SizedBox(
                  width: 125.0,
                  height: 45.0,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black, // Text and icon color
                      backgroundColor: Colors.white, // Background color
                      side: BorderSide(color: Colors.black,   width: 5.0,),),     
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(constButtonOK,
                          style: TextStyle(
                              fontFamily: constAppTitleFont,
                              color: Colors.black,
                              fontSize: 25.0),
                        )),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
      ],
    ),
  );
}
