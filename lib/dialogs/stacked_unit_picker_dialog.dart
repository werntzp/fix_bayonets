import '../const.dart';
import 'package:flutter/material.dart';
import '../models/unit_model.dart';
import '../models/game_model.dart';
import '../models/card_model.dart';

  // *********************************************
  // _selectUnit: if they picked a valid unit, then
  // pop out and close dialog 
  // *********************************************
   void _selectUnit(BuildContext context, GameModel gameModel, Unit u) {

    // see if the unit selected is eligible based on phase 
    if (gameModel.phase() == EnumPhase.move) {
      if (gameModel.unitIsEligibleToMove(u)) {
        Navigator.pop(context, u.id.toString());
      }
    }
    else if (gameModel.phase() == EnumPhase.attack) {
      if (gameModel.unitIsEligibleToAttack(u)) {
        Navigator.pop(context, u.id.toString());
      }
    }

  }

  // *********************************************
  // _pickBorder:helper function to show which unit(s)
  // are eligible to be chosen to move 
  // *********************************************
   Color _pickBorder(GameModel gameModel, Unit u, int row, int col) {
    Color c = Colors.black;

    // decide on border based on phase and eligibility 
    if (gameModel.phase() == EnumPhase.move) {
      // we're in multi-select mode, so might be some selected units in the hex
      if (gameModel.getMultiSelect()) {
        // if the unit selected, make it yellow (or if not, green)
        if (gameModel.isUnitSelected(row, col, u.id)) {
          c = Colors.yellow;
        }
        else {
          c = Colors.green;          
        }

      }
      else if (gameModel.unitIsEligibleToMove(u)) {
        c = Colors.green;
      }
    }
    else if (gameModel.phase() == EnumPhase.attack) {
      if (gameModel.unitIsEligibleToAttack(u)) {
        c = Colors.red;
      }
    }

    return c; 

  }

  // *********************************************
  // _pickTitle: helper function to return dialog title
  // based on active phase 
  // *********************************************
  String _pickTitle(GameModel gameModel, EnumUnitOwner owner) {
    String s = "";
    late GameCard card; 

    // if german units, only one message
    if (owner == EnumUnitOwner.german) {
      s = constStackedUnitPickerOrdersMessage;
    }
    else {
      // for americans, changes based on phase 
      if (gameModel.phase() == EnumPhase.orders) {
        s = constStackedUnitPickerOrdersMessage;
      } else if (gameModel.phase() == EnumPhase.move) {
        // see if we're ready for them to pick a unit
        try {
          card = gameModel.getSelectedCard(); 
          if ((card.type == EnumCardType.move) && 
            (card.player != EnumPlayerUse.german)) {
                s = constStackedUnitPickerMoveMessage;
            }
          else {
            s = constStackedUnitPickerOrdersMessage;
          }
        }
        catch (e) {
          s = constStackedUnitPickerOrdersMessage;
        }
      }
      else {
        // attack 
        s = constStackedUnitPickerAttackMessage;
      }
    }

    return s; 
  }

  // *********************************************
  // _pickButton: helper function to return button text
  // based on active phase 
  // *********************************************
  String _pickButton(EnumPhase p, EnumUnitOwner owner) {
    String s = "";

    if (owner == EnumUnitOwner.german) {
      s = constButtonOK;
    }
    else { 
      if (p == EnumPhase.orders) {
        s = constButtonOK;
      } else if (p == EnumPhase.move) {
        s = constButtonCancel;
      }
      else {
        s = constButtonCancel;
      }
    }

    return s; 
  }

Future<String?> showStackedUnitPickerDialog(
    BuildContext context, List<Unit> units, int row, int col, GameModel gameModel) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color.fromARGB(255, 129, 128, 108),
        title: Text(_pickTitle(gameModel, units.first.owner), 
        style: TextStyle(fontFamily: constAppTextFont, fontSize: 28, color: Colors.black),),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: units.map((item) {
              return GestureDetector(
                onTap: () { _selectUnit(context, gameModel, item); },
                child: Container(
                  height: 63,
                  width: 63, 
                  decoration: BoxDecoration(border: Border.all(color: _pickBorder(gameModel, item, row, col), width: 3)),
                  child: Image.asset(
                  UnitFactory.getUnitGraphic(item.type, item.owner, false),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ));
            }).toList(),
          ),
        ),
            actions: [
                SizedBox(
                  width: 160.0,
                  height: 55.0,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black, // Text and icon color
                      backgroundColor: Colors.white, // Background color
                      overlayColor: Colors.blueAccent.withValues(), // pressed ripple
                      side: BorderSide(color: Colors.black,   width: 5.0,), // Border color
                    ),     
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          _pickButton(gameModel.phase(), units.first.owner),
                          style: TextStyle(
                              fontFamily: constAppTextFont,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 25.0),
                        )),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
        ],

      );
    },
  );
}

