import 'package:fix_bayonets/const.dart';
import 'package:fix_bayonets/models/card_model.dart';
import 'package:fix_bayonets/models/map_model.dart';
import 'package:fix_bayonets/models/unit_model.dart';
import '../dialogs/german_turn_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class GermanMove {
  final Unit unit;
  final int begin;
  final int end;

  GermanMove(this.unit, this.begin, this.end);
}

class GermanAttack {
  final Unit unit;
  final int target;

  GermanAttack(this.unit, this.target);
}

class GermanPlayer {
  // get the starting square for the unit
  int _getUnitPosition(List<MapSquare> mapSquares, Unit selectedUnit) {
    int mapPos = -1;
    MapSquare mapSquare;

    for (int i = 0; i < mapSquares.length; i++) {
      mapSquare = mapSquares[i];
      if (mapSquare.units.isNotEmpty) {
        for (Unit unit in mapSquare.units) {
          if (unit.id == selectedUnit.id) {
            mapPos = i;
          }
        }
      }
    }

    return mapPos;
  }

  // return a valid unit back to try and move
  Unit _randomUnit(List<Unit> units) {
    bool isValidUnit = false;
    Unit unitToMove;

    do {
      unitToMove = units[Random().nextInt(units.length)];
      if (!unitToMove.hasMoved) {
        isValidUnit = true;
      }
    } while (!isValidUnit);

    return unitToMove;
  }

  void doOrdersPhase(BuildContext context, CardFactory cardFactory) {
    // Discard any cards that are restricted to American use
    cardFactory.discardOtherPlayersCards(enumPlayer.american);

    // Discard any cards it can’t use (e.g., a sniper card when they don’t have a sniper unit left)
    // TODO: add logic for this

    // throw up a dialog just so they know what's going on
    showGermanTurnDialog(context, enumPhase.orders);
  }

  List<GermanMove> doMovePhase(BuildContext context, CardFactory cardFactory,
      MapFactory mapFactory, List<MapSquare> mapSquares) {
    List<GermanMove> moves = [];
    List<Unit> units = [];
    bool isValidMove = false;
    int startingPos = constInvalidSpace;
    int endingPos = constInvalidSpace;
    Unit selectedUnit;

    // find every German unit and drop it into a temp list
    for (MapSquare mapSquare in mapSquares) {
      if ((mapSquare.units.isNotEmpty) &&
          (mapSquare.units.first.owner == enumUnitOwner.german)) {
        for (Unit unit in mapSquare.units) {
          units.add(unit);
        }
      }
    }

    // does the german player have any move cards?
    for (GameCard card in cardFactory.germanHand()) {
      if ((card.player != enumPlayerUse.american) &&
          (card.type == enumCardType.move)) {
        // select the card
        cardFactory.toggleSelected(card.id, false);
        // pick a random unit (that hasn't already moved)
        selectedUnit = _randomUnit(units);
        // increment number of times they've moved (if only one and not runner, mark them as have moved)
        for (Unit u in units) {
          if (u.id == selectedUnit.id) {
            u.numTimesMoved++;
            if ((u.numTimesMoved == 1) && (u.type != enumUnitType.runner)) {
              u.hasMoved = true;
            } else if ((u.numTimesMoved == 2) &&
                (u.type == enumUnitType.runner)) {
              u.hasMoved = true;
            }
          }
        }
        // get where that unit is
        startingPos = _getUnitPosition(mapSquares, selectedUnit);
        // get the list of valid moves now
        List<int> validMoves =
            mapFactory.getValidMoves(startingPos, card.minrange, card.maxrange);
        // use that list to find a spot where there are no enemy units so it can move
        do {
          endingPos = Random().nextInt(validMoves.length);
          if ((validMoves[endingPos] == constValidSpace) &&
              ((mapSquares[endingPos].units.isEmpty) ||
                  (mapSquares[endingPos].units.first.owner ==
                      enumUnitOwner.german))) {
            // we have a valid move
            isValidMove = true;
          }
        } while (!isValidMove);

        // add that to the list of valid moves
        moves.add(GermanMove(selectedUnit, startingPos, endingPos));
      }
    }

    // discard any cards used
    cardFactory.discardCards(enumPlayer.german);

    return moves;
  }

  List<GermanAttack> doAttackPhase(
      BuildContext context,
      CardFactory cardFactory,
      MapFactory mapFactory,
      List<MapSquare> mapSquares) {
    List<GermanAttack> attacks = [];
    List<Unit> units = [];
    bool isValidMove = false;
    int startingPos = constInvalidSpace;
    int endingPos = constInvalidSpace;
    Unit selectedUnit;

    // find every German unit and drop it into a temp list
    for (MapSquare mapSquare in mapSquares) {
      if ((mapSquare.units.isNotEmpty) &&
          (mapSquare.units.first.owner == enumUnitOwner.german)) {
        for (Unit unit in mapSquare.units) {
          units.add(unit);
        }
      }
    }

    // does the german player have any move cards?
    for (GameCard card in cardFactory.germanHand()) {
      if ((card.player != enumPlayerUse.american) &&
          (card.type == enumCardType.move)) {
        // select the card
        cardFactory.toggleSelected(card.id, false);
        // pick a random unit (that hasn't already moved)
        selectedUnit = _randomUnit(units);
        // increment number of times they've moved (if only one and not runner, mark them as have moved)
        for (Unit u in units) {
          if (u.id == selectedUnit.id) {
            u.numTimesMoved++;
            if ((u.numTimesMoved == 1) && (u.type != enumUnitType.runner)) {
              u.hasMoved = true;
            } else if ((u.numTimesMoved == 2) &&
                (u.type == enumUnitType.runner)) {
              u.hasMoved = true;
            }
          }
        }
        // get where that unit is
        startingPos = _getUnitPosition(mapSquares, selectedUnit);
        // get the list of valid moves now
        List<int> validMoves =
            mapFactory.getValidMoves(startingPos, card.minrange, card.maxrange);
        // use that list to find a spot where there are no enemy units so it can move
        do {
          endingPos = Random().nextInt(validMoves.length);
          if ((validMoves[endingPos] == constValidSpace) &&
              ((mapSquares[endingPos].units.isEmpty) ||
                  (mapSquares[endingPos].units.first.owner ==
                      enumUnitOwner.german))) {
            // we have a valid move
            isValidMove = true;
          }
        } while (!isValidMove);

        // add that to the list of valid moves
        moves.add(GermanMove(selectedUnit, startingPos, endingPos));
      }
    }

    // discard any cards used
    cardFactory.discardCards(enumPlayer.german);

    return attacks;
  }
}
