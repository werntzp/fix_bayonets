import 'package:fix_bayonets/const.dart';
import 'package:fix_bayonets/models/card_model.dart';
import 'package:fix_bayonets/models/map_model.dart';
import 'package:fix_bayonets/models/unit_model.dart';
import 'dart:math';

class GermanMove {
  final Unit unit;
  final int begin;
  final int end;

  GermanMove(this.unit, this.begin, this.end);
}

class GermanAttack {
  final Unit selectedUnit;
  final Unit targetUnit;
  final GameCard gameCard;

  GermanAttack(this.selectedUnit, this.targetUnit, this.gameCard);
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

  Unit _getTargetUnit(
      MapFactory mapFactory,
      List<MapSquare> mapSquares,
      int selectedUnitPos,
      Unit selectedUnit,
      int minDistance,
      int maxDistance) {
    Unit targetUnit = Unit(constInvalidUnit, EnumUnitType.all,
        EnumUnitOwner.neither, EnumUnitMoveAllowed.one);

    // figure out which spaces are in range for the selected unit
    List<int> validMoves =
        mapFactory.getValidMoves(selectedUnitPos, minDistance, maxDistance);

    // go through and see if any american units in that space
    for (int i = (validMoves.length - 1); i >= 0; i--) {
      if (validMoves[i] == constValidSpace) {
        // is there a unit in there?
        if (mapSquares[i].units.isNotEmpty) {
          if (mapSquares[i].units.first.owner == EnumUnitOwner.american) {
            targetUnit = mapSquares[i].units.first;
            break;
          }
        }
      }
    }

    // return that unit (or raise an error)
    if (targetUnit.id == constInvalidUnit) {
      throw Exception('No unit to attack');
    } else {
      return targetUnit;
    }
  }

  bool _unitIsInRange(MapFactory mapFactory, int selectedUnitPos,
      int targetUnitPos, int minDistance, int maxDistance) {
    bool isInRange = false;

    // get the list of valid moves, the figure out if the target unit is in a spot that can be attacked
    List<int> validMoves =
        mapFactory.getValidMoves(selectedUnitPos, minDistance, maxDistance);
    if (targetUnitPos > 0) {
      if (validMoves[targetUnitPos] == constValidSpace) isInRange = true;
    }
    return isInRange;
  }

  void doOrdersPhase(CardFactory cardFactory) {
    // Discard any cards that are restricted to American use
    cardFactory.discardOtherPlayersCards(EnumPlayer.american);

    // Discard any cards it can’t use (e.g., a sniper card when they don’t have a sniper unit left)
    // TODO: add logic for this
  }

  List<GermanMove> doMovePhase(CardFactory cardFactory, MapFactory mapFactory,
      List<MapSquare> mapSquares) {
    List<GermanMove> moves = [];
    List<Unit> units = [];
    bool isValidMove = false;
    int startingPos = constInvalidSpace;
    int endingPos = constInvalidSpace;
    Unit selectedUnit;

    // find every German unit and drop it into a temp list
    for (MapSquare mapSquare in mapSquares) {
      if ((mapSquare.units.isNotEmpty) &&
          (mapSquare.units.first.owner == EnumUnitOwner.german)) {
        for (Unit unit in mapSquare.units) {
          units.add(unit);
        }
      }
    }

    // does the german player have any move cards?
    for (GameCard card in cardFactory.germanHand()) {
      if ((card.player != EnumPlayerUse.american) &&
          (card.type == EnumCardType.move)) {
        // select the card
        cardFactory.toggleSelected(card.id, true);
        // pick a random unit (that hasn't already moved)
        selectedUnit = _randomUnit(units);
        // increment number of times they've moved (if only one and not runner, mark them as have moved)
        for (Unit u in units) {
          if (u.id == selectedUnit.id) {
            u.numTimesMoved++;
            if ((u.numTimesMoved == 1) && (u.type != EnumUnitType.runner)) {
              u.hasMoved = true;
            } else if ((u.numTimesMoved == 2) &&
                (u.type == EnumUnitType.runner)) {
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
        isValidMove = false;
        // only jump into the loop if there are valid moves
        if (validMoves.isNotEmpty) {
          do {
            endingPos = Random().nextInt(validMoves.length);
            // spot has to be a valid one, an empty square, one where germans
            // already are, or forward of where it was previously
            if ((validMoves[endingPos] == constValidSpace) &&
                (endingPos < startingPos) &&
                ((mapSquares[endingPos].units.isEmpty) ||
                    (mapSquares[endingPos].units.first.owner !=
                        EnumUnitOwner.american))) {
              // we have a valid move
              isValidMove = true;
            }
          } while (!isValidMove);
        }

        // add that to the list of valid moves
        if (isValidMove) {
          moves.add(GermanMove(selectedUnit, startingPos, endingPos));
        }
      }
    }

    // discard any cards used
    cardFactory.discardCards(EnumPlayer.german);

    return moves;
  }

  List<GermanAttack> doAttackPhase(CardFactory cardFactory,
      MapFactory mapFactory, List<MapSquare> mapSquares) {
    List<GermanAttack> attacks = [];
    List<Unit> germanUnits = [];
    List<Unit> americanUnits = [];
    int targetUnitPos = constInvalidSpace;
    int selectedUnitPos = constInvalidSpace;
    Unit selectedUnit = Unit(constInvalidUnit, EnumUnitType.all,
        EnumUnitOwner.neither, EnumUnitMoveAllowed.one);
    Unit targetUnit = Unit(constInvalidUnit, EnumUnitType.all,
        EnumUnitOwner.neither, EnumUnitMoveAllowed.one);
    bool addedAnAttack = false;

    // put all the units into two lists for use later
    for (MapSquare mapSquare in mapSquares) {
      if (mapSquare.units.isNotEmpty) {
        if (mapSquare.units.first.owner == EnumUnitOwner.german) {
          for (Unit unit in mapSquare.units) {
            unit.hasAttacked = false;
            germanUnits.add(unit);
          }
        } else {
          for (Unit unit in mapSquare.units) {
            americanUnits.add(unit);
          }
        }
      }
    }

    // does the german player have any attack cards?
    for (GameCard card in cardFactory.germanHand()) {
      if ((card.player != EnumPlayerUse.american) &&
          (card.type == EnumCardType.attack)) {
        // reset the flag
        addedAnAttack = false;

        // first to check -- is there an american officer in range
        // of a german unit that can use the attack card
        // look for an officer unit
        for (Unit u in americanUnits) {
          if (u.type == EnumUnitType.officer) {
            targetUnit = u;
            targetUnitPos = _getUnitPosition(mapSquares, u);
            break;
          }
        }

        // check all the german units
        for (Unit u in germanUnits) {
          // can any of them hit the american officer unit? and make sure it hasn't already attacked
          selectedUnitPos = _getUnitPosition(mapSquares, u);
          if ((_unitIsInRange(mapFactory, selectedUnitPos, targetUnitPos,
                  card.minrange, card.maxrange)) &&
              (!u.hasAttacked)) {
            // flag the unit
            u.hasAttacked = true;
            // add to the array
            attacks.add(GermanAttack(u, targetUnit, card));
            addedAnAttack = true;
            // then break out
            break;
          }
        }

        // second to check -- are there any snipers units in range
        // of a american unit that can use the attack card
        if (!addedAnAttack) {
          for (Unit u in germanUnits) {
            selectedUnit = u;
            if ((selectedUnit.type == EnumUnitType.sniper) &&
                (!selectedUnit.hasAttacked)) {
              // get position of german sniper
              selectedUnitPos = _getUnitPosition(mapSquares, selectedUnit);
              // is there a potential target unit?
              try {
                targetUnit = _getTargetUnit(
                    mapFactory,
                    mapSquares,
                    selectedUnitPos,
                    selectedUnit,
                    card.minrange,
                    card.maxrange);
                // flag this unit so it can't attack again
                u.hasAttacked = true;
                // add that to the attack array
                attacks.add(GermanAttack(u, targetUnit, card));
                addedAnAttack = true;
              } catch (e) {
                // no unit exists that can be attacked
                break;
              }
            }
          }
        }

        // third to check -- are there any machine gun units in range
        // of an american unit that can use the attack card
        if (!addedAnAttack) {
          for (Unit u in germanUnits) {
            selectedUnit = u;
            if ((selectedUnit.type == EnumUnitType.heavyweapon) &&
                (!selectedUnit.hasAttacked)) {
              // get position of german sniper
              selectedUnitPos = _getUnitPosition(mapSquares, selectedUnit);
              // is there a potential target unit?
              try {
                targetUnit = _getTargetUnit(
                    mapFactory,
                    mapSquares,
                    selectedUnitPos,
                    selectedUnit,
                    card.minrange,
                    card.maxrange);
                // flag this unit so it can't attack again
                u.hasAttacked = true;
                // add that to the attack array
                attacks.add(GermanAttack(u, targetUnit, card));
                addedAnAttack = true;
              } catch (e) {
                // no unit exists that can be attacked
                break;
              }
            }
          }
        }

        // finally -- just find an american unit that can be attacked
        if (!addedAnAttack) {
          for (Unit u in germanUnits) {
            selectedUnit = u;
            // get position of
            selectedUnitPos = _getUnitPosition(mapSquares, selectedUnit);
            // is there a potential target unit?
            try {
              targetUnit = _getTargetUnit(mapFactory, mapSquares,
                  selectedUnitPos, selectedUnit, card.minrange, card.maxrange);
              // add that to the attack array (if it hasn't already attacked)
              if (!u.hasAttacked) {
                // flag this unit so it can't attack again
                u.hasAttacked = true;
                attacks.add(GermanAttack(u, targetUnit, card));
                addedAnAttack = true;
              }
              break;
            } catch (e) {
              // no unit exists that can be attacked
            }
          }
        }

        // if the german unit actually plans to attack, select the card and set the unit's flag
        if (addedAnAttack) {
          cardFactory.toggleSelected(card.id, true);
        }
      }
    }

    // discard any cards used
    cardFactory.discardCards(EnumPlayer.german);

    return attacks;
  }
}
