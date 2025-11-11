import 'dart:math';
import '../const.dart';
import 'package:number_to_words/number_to_words.dart';
import '../models/card_model.dart';
import '../models/map_model.dart';
import '../models/unit_model.dart';

class SelectedUnit {
  final Unit unit;
  final int row;
  final int col;
  SelectedUnit(this.unit, this.row, this.col);
}

class CustomMove {
  final int unitId;
  final int destRow;
  final int destCol;  
  CustomMove(this.unitId, this.destRow, this.destCol);
}

class CustomAttack {
  final int unitId;
  final int attackRow;
  final int attackCol; 
  final EnumCardName cardName; 
  CustomAttack(this.unitId, this.attackRow, this.attackCol, this.cardName);
}

class GameModel {
  int _round = 1;
  EnumPhase _phase = EnumPhase.orders;
  EnumPlayer _player = EnumPlayer.american;
  final CardFactory _cardFactory = CardFactory();
  final List<GameCard> _americanHand = [];
  final List<GameCard> _germanHand = [];
  final List<GameCard> _discardPile = [];
  late List<GameCard> _drawPile;
  final MapFactory _mapFactory = MapFactory();
  final List<SelectedUnit> _germanUnits = []; 
  late List<List<MapHex>> _hexes;
  String _displayUnitsKilled = ""; 
  bool _skipMove = false;
  bool _skipAttack = false; 
  int _unitCount = constInitialUnitCount; 
  bool _multiSelect = false; 

  // *********************************************
  // helper function to capitalize first letter ina  word 
  // *********************************************
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  // *********************************************
  // return the phase enum
  // *********************************************
  EnumPhase phase() {
    return _phase;
  }

  // *********************************************
  // manually set if they can multi-select units for
  // movement purposes 
  // *********************************************
  void setMultiSelect(bool value) {
    _multiSelect = value;

    // if turning off, deselect all cards and units that may have been chosen
    clearAllSelectedCards();
    unselectAllUnits();

  }

  // *********************************************
  // return whether multi-select is on 
  // *********************************************
  bool getMultiSelect() {
    return _multiSelect;
  }

  // *********************************************
  // manually set phase
  // *********************************************
  void setPhase(EnumPhase phase) {
    _phase = phase;
  }

  // *********************************************
  // return the round
  // *********************************************
  int round() {
    return _round;
  }

  // *********************************************
  // return the player enum
  // *********************************************
  EnumPlayer player() {
    return _player;
  }

  // *********************************************
  // display friendly name for current player
  // *********************************************
  String displayPlayer() {
    return _capitalize(_player.name);
  }

  // *********************************************
  // display friendly name for current round
  // *********************************************
  String displayRound() {
    return _capitalize(NumberToWord().convert("en-in", _round).trimRight());
  }

  // *********************************************
  // display friendly name for current phase
  // *********************************************
  String displayPhase() {
    return _capitalize(_phase.name);
  }

  // *********************************************
  // display friendly name for each unit type
  // *********************************************
  String displayUnitName(EnumUnitType unitType) {
    String name = "";

    // special case for heavy weapon
      if (unitType == EnumUnitType.heavy) {
        name = "Heavy Weapon";
      }
      else {
        name = _capitalize(unitType.name);
      }

      return name; 
  }

  // *********************************************
  // friendly string name of the units killed for display
  // *********************************************
  String displayListOfUnitsKilled() {
    return _displayUnitsKilled; 
  }


  // *********************************************
  // does the target hex contain a german officer?
  // *********************************************
  bool isGermanOfficerInHex(int row, int col) {
    bool result = false; 

    // if we got to this function, already know the hex
    // contains german units, so don't have to check that
    for (Unit u in _hexes[row][col].units) {
      if (u.type == EnumUnitType.officer) {
        result = true;
        break; 
      }
    }

    return result; 

  }

  // *********************************************
  // return if we should skip the American move phase  
  // *********************************************
  bool skipMovePhase() {
    return _skipMove; 
  }

  // *********************************************
  // return if we should skip the American move phase  
  // *********************************************
  bool skipAttackPhase() {
    return _skipAttack; 
  }

  // *********************************************
  // tun selected on/off depending on current state 
  // *********************************************
  void toggleUnitsToMove(int row, int col, int id) {

    _hexes[row][col].units.firstWhere((element) => element.id == id).isSelected =
      !_hexes[row][col].units.firstWhere((element) => element.id == id).isSelected;
   
  }

  // *********************************************
  // move all units one hex forward  
  // *********************************************
  void moveSelectedUnitsForward(int spaces) {

    /*
    for (int r=0; r < constMapRows; r++) {
      for (int c=0; c < constMapCols; c++) {
        if (_hexes[r][c].units.isNotEmpty) {
          for (Unit u in _hexes[r][c].units) {
              _hexes[r][c].units.firstWhere(( element) => element.id == u.id).reset(); 
          }
        }
      }
    }
    */

  }

  // *********************************************
  // add a new unit to the german side 
  // *********************************************
  void addGermanReinforcement() {
    bool validSpot = false; 
    int col = 0; 
    late Unit unit; 

    // first decide where to drop it on the map 
    do {
      col = Random().nextInt(constMapCols);
      // spots needs to be empty, or already have german units in it
      if ((_hexes[constMapRows-1][col].units.isEmpty) || 
        (_hexes[constMapRows-1][col].units.first.owner == EnumUnitOwner.german)) { 
          validSpot = true; 
      }
    }
    while (!validSpot);

    // randomly decide if heavy, sniper, or soldier
    int unitChoice = Random().nextInt(10);
    if (unitChoice <= 4) {
      unit = new Unit(_unitCount++, EnumUnitType.rifleman, EnumUnitOwner.german, EnumUnitMoveAllowed.one);
    }
    else if (unitChoice < 8) {
      unit = new Unit(_unitCount++, EnumUnitType.heavy, EnumUnitOwner.german, EnumUnitMoveAllowed.one);
    }
    else {
      unit = new Unit(_unitCount++, EnumUnitType.sniper, EnumUnitOwner.german, EnumUnitMoveAllowed.one);
    }

    // finally, drop that into the hex 
    _hexes[constMapCols-1][col].units.add(unit);

  }

  // *********************************************
  // go through and find all the
  // current german units
  // *********************************************
  void _setGermanUnits() {
    // clear out anything already in the list
    _germanUnits.clear(); 

    // walk through to find active german units and get them into
    // one list so we don't have to look each time 
    for (int r=0; r < constMapRows; r++) {
      for (int c=0; c < constMapCols; c++) {
        if (_hexes[r][c].units.isNotEmpty) {
          for (Unit u in _hexes[r][c].units) {
            if (u.owner == EnumUnitOwner.german) {
              _germanUnits.add(SelectedUnit(u, r, c));
            }
          }
        }
      }
    }

  }

  // *********************************************
  // go through and reset all units so they 
  // can move and attack again 
  // *********************************************
  void _resetUnits() {

    for (int r=0; r < constMapRows; r++) {
      for (int c=0; c < constMapCols; c++) {
        if (_hexes[r][c].units.isNotEmpty) {
          for (Unit u in _hexes[r][c].units) {
              _hexes[r][c].units.firstWhere(( element) => element.id == u.id).reset(); 
          }
        }
      }
    }
  }

  // *********************************************
  // ensure no one can attack into a friendly spot, or move into an enemy spot
  // *********************************************
  List<List<int>> _identifyInvalidSpaces(List<List<int>> spaces, EnumPhase phase) {
    EnumUnitOwner owner; 

    // after we do all the distances, also need to make sure any spots with
    // german or american units in them are also marked as invalid (depending on the phase)
    if ((_player == EnumPlayer.american) && (phase == EnumPhase.move)) {
      owner = EnumUnitOwner.german; 
    }
    else if ((_player == EnumPlayer.american) && (phase == EnumPhase.attack)) {
      owner = EnumUnitOwner.american; 
    }
    else if ((_player == EnumPlayer.german) && (phase == EnumPhase.move)) {
      owner = EnumUnitOwner.american; 
    }      
    else {
      owner = EnumUnitOwner.german; 
    }

    for (int r=0; r < constMapRows; r++) {
      for (int c=0; c < constMapCols; c++) {
        if (_hexes[r][c].units.isNotEmpty) {
          if (_hexes[r][c].units.first.owner == owner) {
            spaces[r][c] = constInvalidSpace;
          }
        }
      }
    }     

    return List.from(spaces); 

  }

  // *********************************************
  // loop through the cards the german can't use and add them to the discard pile
  // *********************************************
  EnumGameOverReason isGameOver(EnumPlayer player) {
    bool result = true; 
    EnumUnitOwner playerToCheck = EnumUnitOwner.american;
    EnumGameOverReason reason = EnumGameOverReason.neither; 

    // see if both officers are still left for the other player 
    player == EnumPlayer.german
      ? playerToCheck = EnumUnitOwner.american
      : playerToCheck = EnumUnitOwner.german;

    // loop through all the units
    outerLoop: 
    for (int r=0; r < constMapRows; r++) {
      for (int c=0; c < constMapCols; c++) {
        if ((_hexes[r][c].units.isNotEmpty) && (_hexes[r][c].units.first.owner == playerToCheck))  {
            for (Unit u in _hexes[r][c].units) {
              if (u.type == EnumUnitType.officer) { 
                // once we found at least one officer, can stop counting 
                result = false; 
                break outerLoop; 
              }
            }
        }
      }
    }

    // if result is true, officers dead
    if (result) { reason = EnumGameOverReason.officers; }

    // if result is false, and player is German, also see if any of their units made the back
    // row
    if ((result == false) && (player == EnumPlayer.german)) {
        for (int c=0; c < constMapCols; c++) {
          if ((_hexes[0][c].units.isNotEmpty) && (_hexes[0][c].units.first.owner == EnumUnitOwner.german))  {
            // if we find at least one German unit in the back 
            // row, they won, so break out  
            reason = EnumGameOverReason.map;
            break; 
          }
        }
    }

    return reason; 

 }  


  // *********************************************
  // increment move on this unit or 
  // set attacked status based on phase
  // *********************************************
  void updateUnitStatus(int unitId, EnumPhase phase) {

    outerLoop:
    for (int r=0; r < constMapRows; r++) {
      for (int c=0; c < constMapCols; c++) {
        if (_hexes[r][c].units.isNotEmpty) {
          for (Unit u in _hexes[r][c].units) {
            if (u.id == unitId) {
              if (phase == EnumPhase.move) {
                _hexes[r][c].units.firstWhere((element) => element.id == unitId).numTimesMoved++;
              }
              else {
                _hexes[r][c].units.firstWhere((element) => element.id == unitId).hasAttacked = true;
              }
              break outerLoop; 
            }
          }
        }
      }
    }

  }

  // *********************************************
  // just drop two random cards from the germans
  // hand forcing them to pick up some more next go around
  // *********************************************
  void dropTwoGermanCards() {
    int cardNum = 0; 
    
    try {
      cardNum = Random().nextInt(_germanHand.length-1);
      _discardPile.add(_germanHand[cardNum]); 
      _germanHand.removeAt(cardNum);

      cardNum = Random().nextInt(_germanHand.length-1);
      _discardPile.add(_germanHand[cardNum]); 
      _germanHand.removeAt(cardNum);
    }
    catch (e) {
      // do nothing 
    }

  }


  // *********************************************
  // loop through the cards the
  // german can't use and add them to the discard pile
  // *********************************************
  void _doGermanOrdersPhase() {
    bool keep = false; 

    // loop through cards in german player's hand, and get 
    // rid of any they can't use based on unit restrictions 
    // (e.g. sniper card and they have no snipers left)
    for (int i = (_germanHand.length-1); i >= 0; i--) {
      if (_germanHand[i].useby != EnumUnitType.all) {
        keep = false; 
        for (SelectedUnit su in _germanUnits) {
          if (su.unit.type == _germanHand[i].useby) {
            keep = true;
            break;
          }
        }
        if (!keep) {
            _discardPile.add(_germanHand[i]);
            _germanHand.removeAt(i);
            // loop through the draw pile to see if there's a card we can pull into
            // german hand 
            for (int i = (_drawPile.length-1); i >= 0; i--) {
              if (_drawPile[i].player != EnumPlayerUse.american) {
                for (SelectedUnit su in _germanUnits) {
                  if (su.unit.type == _drawPile[i].useby) {
                    _germanHand.add(_drawPile[i]);
                    _drawPile.remove(_drawPile[i]);
                    break;
                  }
                }                

              }
            }
        }
      }
    }

  }

  // *********************************************
  // does the player have a valid
  // negate card to use? 
  // *********************************************
  bool canNegateAction(EnumPlayer player, EnumCardNegate phase) {
    bool result = false; 

    // based on the phase, loop through player's 
    if (player == EnumPlayer.american) { 
      for (GameCard card in _americanHand) {
        if ((card.negate == phase) && 
          ((card.player == EnumPlayerUse.both) || (card.player == EnumPlayerUse.american))) {
            result = true;
            break; 
        }
      }
    }
    else { 
      for (GameCard card in _germanHand) {
        if ((card.negate == phase) && 
          ((card.player == EnumPlayerUse.both) || (card.player == EnumPlayerUse.german))) {
            result = true;
            break; 
        }
      }
    }

    return result; 

  }

  // *********************************************
  // helper function 
  // *********************************************
  bool _checkForAmericanUnit(int row, int col) {
    bool result = false; 

    if (_mapFactory.isRowColValid(row, col)) {
      if ((_hexes[row][col].units.isNotEmpty) && 
        (_hexes[row][col].units.first.owner == EnumUnitOwner.american)) {
          result = true; 
        }
    }

    return result; 

  }


  // *********************************************
  // determine if an american unit is adjacent to 
  // the row/col 
  // *********************************************
  bool isAmericanUnitAdjacent(int row, int col) {
    int destRow = 0;
    int destCol = 0; 

    // two of the six positions are always the same:
    // postion #1 
    destCol = col; 
    destRow = (row - 1); 
    if (_checkForAmericanUnit(destRow, destCol)) {
      return true; 
    }

    // position #4
    destCol = col; 
    destRow = (row + 1); 
    if (_checkForAmericanUnit(destRow, destCol)) {
      return true; 
    }

    // now, the remaining four change depending whether odd or even column
    // due to the ways rows are stacked in the hexagon 
    // position #2
    if (col.isEven) { 
      destRow = (row - 1);
    }
    else {
      destRow = row;
    }
    destCol = (col + 1);
    if (_checkForAmericanUnit(destRow, destCol)) {
      return true; 
    }

    // position #3
    if (col.isEven) { 
      destRow = row;
    }
    else {
      destRow = (row + 1);
    }
    destCol = (col + 1);
    if (_checkForAmericanUnit(destRow, destCol)) {
      return true; 
    }

    // position #5
    if (col.isEven) { 
      destRow = row;
    }
    else {
      destRow = (row + 1);
    }
    destCol = (col - 1);
    if (_checkForAmericanUnit(destRow, destCol)) {
      return true; 
    }
        
    // position #6
    if (col.isEven) { 
      destRow = (row - 1);
    }
    else {
      destRow = row;
    }
    destCol = (col - 1);
    if (_checkForAmericanUnit(destRow, destCol)) {
      return true; 
    }

    return false; 

  }


  // *********************************************
  // put together list of valid moves and return 
  // *********************************************
  List<CustomMove> getMultiSelectMoves() {
    GameCard card = getSelectedCard();
    List<CustomMove> moves = []; 
    int destRow;

    // for each selected unit, create a move to return 
    for (int r=0; r < constMapRows; r++) {
      for (int c=0; c < constMapCols; c++) {
        if (_hexes[r][c].units.isNotEmpty) {
          for (Unit u in _hexes[r][c].units) {
              if (u.isSelected) {
                destRow = (r + card.minrange);
                if (destRow <= constMapRows) {
                  moves.add(new CustomMove(u.id, destRow, c));
                }
              }
          }
        }
      }
    }

    return List.from(moves); 

  }



  // *********************************************
  // put together list of valid moves and return 
  // *********************************************
  List<CustomMove> getGermanMoves() {
    late List<List<int>> result; 
    late GameCard card;  
    late SelectedUnit unitToMove; 
    List<CustomMove> moves = []; 
    List<int> shuffledCols = []; 
    bool validUnit = false; 
    bool okToProceed = true; 
    bool multipleMoves = false; 
    bool validSpot = false; 
    int destRow = 0; 
    int numMoves = 0;

    // most up to date list of where units are at 
    _setGermanUnits();

    // loop through cards to see if there are any move cards
    for (int i = (_germanHand.length-1); i >= 0; i--) {
      multipleMoves = false; 
      card = _germanHand[i];
      okToProceed = true; 
      if (card.type == EnumCardType.move) {
        do {
          // first, see if either german officer is adjacent to an american unit,
          // and if so, try to move them first
          try {
            SelectedUnit officer1 = _germanUnits.firstWhere(((element) => element.unit.type == EnumUnitType.officer));
            if ((isAmericanUnitAdjacent(officer1.row, officer1.col) && (officer1.unit.canMove()))) {
              unitToMove = officer1; 
              validUnit = true; 
            }

            // if only one unit, will just get back the same one so validate that
            if (!validUnit) {
              SelectedUnit officer2 = _germanUnits.lastWhere(((element) => element.unit.type == EnumUnitType.officer));
              if (officer1. unit.id != officer2.unit.id) {
                // different units, so good to use this one
                if ((isAmericanUnitAdjacent(officer2.row, officer2.col) && (officer2.unit.canMove()))) {
                  unitToMove = officer2; 
                  validUnit = true; 
                }           
              }
            }
          }
          catch (e) {
            validUnit = false; 
          }

          // we don't have an officer to move
          if (validUnit == false) {
            multipleMoves = false; 
            // first, 25% chance the german wants to move multiple units
            // forward vs just one (if not a zig zag)
            if (card.minrange != constZigZagSpace) {
              int multi = Random().nextInt(4);
              if (multi == 0) {
                // yes, so go through each unit, and plot the move
                for (int i = 0; i <= _germanUnits.length - 1; i++) {
                  try {
                    // if unit can move, dest row is on the map, and not occupied by
                    // americans, add it to the list
                    if (Random().nextBool()) {
                      numMoves = 0; 
                      validSpot = false;       
                      unitToMove = _germanUnits[i];
                      destRow = (unitToMove.row - card.minrange);
                      if (destRow >= 0) {
                        if (_hexes[destRow][unitToMove.col].units.isEmpty) {
                          validSpot = true; 
                        }
                        else if (_hexes[destRow][unitToMove.col].units.first.owner == EnumUnitOwner.german) {
                          validSpot = true;
                        }
                      }
                      // conditions met for that unit to move 
                      if ((unitToMove.unit.canMove()) && (validSpot)) {
                        moves.add(CustomMove(unitToMove.unit.id, destRow, unitToMove.col));
                        numMoves++; 
                        // update the unit to show it moved (even if the move gets negated later)
                        _hexes[unitToMove.row][unitToMove.col].units.firstWhere((element) => element.id == unitToMove.unit.id).numTimesMoved++;                 
                      }  
                    }
                  }
                  catch (e) {
                    print(e); 
                  }
 
                }
                // discard the card if we did any
                if (numMoves > 0) { 
                  _discardPile.add(_germanHand[i]); 
                  // set the flags 
                  multipleMoves = true; 
                  validUnit = true; 
                }
              }
            }

            // we got here, so either a zig zag card or decided not to do multiple so, 
            // grab a random unit (that hasn't already moved)
            if (!multipleMoves) {
              int pos = Random().nextInt(_germanUnits.length);
              unitToMove = _germanUnits[pos];
              if (unitToMove.unit.canMove()) { validUnit = true; }    
            }
          }  

        } while (validUnit == false);

        // only do all this if we didn't do a bunch of moves above 
        if (!multipleMoves) {
          if (card.minrange == constZigZagSpace) {
            result = _mapFactory.getZigZagDistances(unitToMove.row, unitToMove.col);
          }
          else { 
            result = _mapFactory.getDistances(unitToMove.row, unitToMove.col);
          }
          // then, have to identify if any spaces are ineligible based on units in them
          result = _identifyInvalidSpaces(result, EnumPhase.move);
          // so pick a random spot to move the unit to (has to be valid spot, within
          // range of the move card, and not accidentally be the same spot unit started at)
          // *** cheat *** let the Germans move ONE further than on their card
          outerLoop: 
          for (int destRow=0; destRow<constMapRows; destRow++) {
            // put all the cols into an array and shuffle them
            shuffledCols = [
              for (int c=0; c<constMapCols; c++) c, 
            ];
            shuffledCols.shuffle();
            for (int destCol in shuffledCols) {
            if ((result[destRow][destCol] != constInvalidSpace) && 
                (result[destRow][destCol] >= card.minrange) &&
                (result[destRow][destCol] <= (card.maxrange + 1)) && 
                ((unitToMove.row != destRow) && (unitToMove.col != destCol))) {
                  // special case, if unit moving is an officer, don't let it move
                  // into another spot where an officer is at 
                  if ((unitToMove.unit.type == EnumUnitType.officer) &&
                    (_hexes[unitToMove.row][unitToMove.col].units.any((element) => element.type == unitToMove.unit.type))) {
                      // don't let them move
                      okToProceed = false; 
                  }
                  // the flag only gets set to false if the above happens
                  if (okToProceed) {
                    // update the unit to show it moved (even if the move gets negated later)
                    _hexes[unitToMove.row][unitToMove.col].units.firstWhere((element) => element.id == unitToMove.unit.id).numTimesMoved++;                 
                    // create a move object and add to the array
                    moves.add(CustomMove(unitToMove.unit.id, destRow, destCol));
                    // discard the card 
                    _discardPile.add(_germanHand[i]);
                    try {
                      _germanHand.removeAt(i);
                    }
                    catch (e) {
                      // do nothing
                    }
                    break outerLoop;    
                  }
              }
            }
          }
        }
      }
    }

    return List. from(moves); 
  }

  // *********************************************
  // returns a list of the units in the hex 
  // *********************************************
  List<Unit> getUnitsInHex(int row, int col) {
    late List<Unit> units = []; 

        for (Unit u in _hexes[row][col].units) {
          units.add(u);
        }
        return units; 

 }

  // *********************************************
  // put together list of valid attacks and return 
  // *********************************************
  List<CustomAttack> getGermanAttacks() {
    late List<List<int>> result; 
    late GameCard card;  
    late SelectedUnit unitAttacking; 
    List<CustomAttack> attacks = []; 
    List<int> shuffledCols = []; 

    int prevRow = -1;
    int prevCol = -1; 

    // most up to date list of where units are at 
    _setGermanUnits();

    // loop through cards to see if there are any attack cards
    for (int i = (_germanHand.length-1); i>=0; i--) {
      card = _germanHand[i];
      if (card.type == EnumCardType.attack) {
        // walk through the units seeing if one can use the card, and it hasn't already attacked 
        outerLoop: 
        for (int j = (_germanUnits.length-1); j>=0; j--) {
            unitAttacking = _germanUnits[j];
            if ((card.useby == EnumUnitType.all) || (card.useby == unitAttacking.unit.type) && 
              (unitAttacking.unit.hasAttacked == false)) {
              // get list of valid spaces 
              if (card.minrange == constZigZagSpace) {
                result = _mapFactory.getZigZagDistances(unitAttacking.row, unitAttacking.col);
              }
              else { 
              result = _mapFactory.getDistances(unitAttacking.row, unitAttacking.col);
              }
              // then, have to identify if any spaces are ineligible based on units in them
              result = _identifyInvalidSpaces(result, EnumPhase.attack);
              // now, use that list to see if there's a valid attacking spot 
              // *** cheat *** let them attack one further than on their card 
              for (int destRow =0; destRow<constMapRows; destRow++) {
                // put all the cols into an array and shuffle them
                shuffledCols = [
                  for (int c=0; c<constMapCols; c++) c, 
                ];
                shuffledCols.shuffle();
                for (int destCol in shuffledCols) {
                  if ((result[destRow][destCol] != constInvalidSpace) && 
                    (result[destRow][destCol] >= card.minrange) &&
                    (result[destRow][destCol] <= (card.maxrange +1)) && 
                    (_hexes[destRow][destCol].units.isNotEmpty) && 
                    (destRow != prevRow) && 
                    (destCol != prevCol) && 
                    ((unitAttacking.row != destRow) && (unitAttacking.col != destCol))) {
                      // mark the unit as having attacked 
                      _hexes[unitAttacking.row][unitAttacking.col].units.firstWhere((element) => element.id == unitAttacking.unit.id).hasAttacked = true;    
                      // create an attack  object and add to the array
                      attacks.add(CustomAttack(unitAttacking.unit.id, destRow, destCol, card.name));
                      // save where we attacked
                      prevRow = destRow;
                      prevCol = destCol; 
                      // discard the card 
                      _discardPile.add(_germanHand[i]);
                      try {
                        _germanHand.removeAt(i);
                      }
                      catch (e) {
                        // do nothing
                      }

                      break outerLoop;         
                    }
                }
              }
            }
        }         
      }
    } 

    return List.from(attacks); 

  }

  // *********************************************
  // return the card that is active   
  // *********************************************
  GameCard getSelectedCard() {

    for (GameCard card in _americanHand) {
      if (card.selected) {
        return card;  
      }
    }

    throw Exception("No card is selected");

  }

  // *********************************************
  // clear out any cards the player had selected 
  // *********************************************
  void clearAllSelectedCards() {

    for (GameCard card in _americanHand) {
      card.selected = false; 
    }

  }

  // *********************************************
  //  do we have enough cards to use?
  // *********************************************
  void _checkDrawPile() {

      // if not at least six cards left in draw pile, move cards from discard to draw and shuffle
      if (_drawPile.length < (constMaxCardsInHand * 2)) {
        for (GameCard c in _discardPile) {
          _drawPile.add(c);
        }
        _discardPile.clear();
        _drawPile.shuffle();
      }

  }

  // *********************************************
  // add cards to hands for american and
  // german player  
  // *********************************************
  void _drawCards() {
    int numMoveNegate = 0;
    int numAttackNegate = 0; 

    _checkDrawPile();
 
    // draw cards for american 
    for (int i = 0; i < constDrawCards; i++) {
      _americanHand.add(_drawPile[i]);
      _drawPile.remove(_drawPile[i]);
    }

    // cheat: if german has more than one move/attack negate card,
    // drop it so we focus on actual moves/attacks
    for (int i = (_germanHand.length - 1); i >= 0; i--) {
      if (_germanHand[i].negate == EnumCardNegate.move) { numMoveNegate++; }
      if (_germanHand[i].negate == EnumCardNegate.attack) { numAttackNegate++; }
      // now, check
      if (numMoveNegate > 1) { 
        numMoveNegate--;
        _discardPile.add(_germanHand[i]);
        _germanHand.remove(i);
      }
      if (numAttackNegate > 1) {
        numAttackNegate--;  
        _discardPile.add(_germanHand[i]);
        _germanHand.remove(i);
      }

    }

    // cheat: if german already has the max, drop one just so we're
    // always picking at least one up
    if (_germanHand.length >= constMaxCardsInHand ) {
      _discardPile.add(_germanHand[0]);
      _germanHand.removeAt(0);
    }

    // decide how many to draw for the german player 
    int i = 0; 
    int cardsToDraw = constMaxCardsInHand;
    // just for the first turn, start with three cards
    if (_round == 1) { cardsToDraw = 3; }
    if (_germanHand.length <= cardsToDraw) {
      // draw up to three 
      do {
        if (i >= _drawPile.length) { _checkDrawPile(); }
        
        // cheat: only add to the german's hand if they can use it 
        if (_drawPile[i].player != EnumPlayerUse.american) {
          _germanHand.add(_drawPile[i]);
          _drawPile.remove(_drawPile[i]);
        }
        i++; 
      } while (_germanHand.length < cardsToDraw);
    }

  }

  // *********************************************
  // are we going to look for their 
  // moves and attacks 
  // *********************************************
  bool isGermanTurn() {
    bool result = false; 

    if (_player == EnumPlayer.german) { result = true; }
    return result; 

  }

  // *********************************************
  // move to the next phase
  // *********************************************
  void nextPhase() {
    int moveCards = 0; 
    int attackCards = 0; 

    // always reset this
    _displayUnitsKilled = ""; // reset 

    // turn off multi-select and clear out any selected units
    setMultiSelect(false);
    unselectAllUnits();

    // always deselect any cards
    for (GameCard card in _americanHand) {
      card.selected = false; 
    }

    // if we're coming into this phase as the german player, 
    // set phase to attack so we can just flip to american orders
    if (_player == EnumPlayer.german) { _phase = EnumPhase.attack; }

    // increment phase 
    if (_phase == EnumPhase.orders) {
      _phase = EnumPhase.move;
    }
    else if (_phase == EnumPhase.move) {
      _phase = EnumPhase.attack;
    }
    else {
      _phase = EnumPhase.orders;
      // switch the player
      _player == EnumPlayer.german
          ? _player = EnumPlayer.american
          : _player = EnumPlayer.german;

      // if we flipped back to american player, also draw more cards, clear any selected, and reset all the units
      if (_player == EnumPlayer.american) { 
        _skipMove = false;
        _skipAttack = false; 
        _round++;
        _drawCards();
        clearAllSelectedCards();
        _resetUnits();
      }
      else {
        // prep all the units so the computer can make decisions, and discard any cards as needed
        _doGermanOrdersPhase();
      }
    }

    // for the american player, let's see if we have cards for move or attack
    if ((_player == EnumPlayer.american) && (_phase == EnumPhase.move)) { 
      for (GameCard card in _americanHand) {
        if ((card.type == EnumCardType.move) && (card.player != EnumPlayerUse.german)) { moveCards++; }
        if ((card.type == EnumCardType.attack) && (card.player != EnumPlayerUse.german)) { attackCards++; }        
      }
      // if no move cards, skip the move phase 
      if (moveCards == 0) { 
        _skipMove = true; 
      }
      if (attackCards == 0) {
        _skipAttack = true; 
      }
    }

  }

  // *********************************************
  // return how many units are in the selected hex 
  // *********************************************
  int unitsInHexCount(int row, int col) {
      return _hexes[row][col].units.length;
  }

  // *********************************************
  // return which player owns the unit(s) 
  // *********************************************
  EnumUnitOwner unitsInHexOwner(int row, int col) {
    late EnumUnitOwner owner;

    try {
      owner = _hexes[row][col].units.first.owner;
    }
    catch (e) {
      owner = EnumUnitOwner.neither;
    }
    return owner; 

  }

  // *********************************************
  // mark unit in this hex as selected  
  // *********************************************
  void setSelectedUnitByFirstPosition(int row, int col) {
      // mark the appropriate unit as selected 
      _hexes[row][col].units.first.isSelected = true; 

  }

  // *********************************************
  // mark unit in this hex as selected  
  // *********************************************
  void setSelectedUnitById(int row, int col, int id) {
      // mark the appropriate unit as selected 
      _hexes[row][col].units.firstWhere(( element) => element.id == id).isSelected = true; 

  }

  // *********************************************
  // deselect this one unit   
  // *********************************************
  void deSelectUnitById(int id) {

    outerLoop:
    for (int r=0; r < constMapRows; r++) {
      for (int c=0; c < constMapCols; c++) {
        if (_hexes[r][c].units.isNotEmpty) {
          for (Unit u in _hexes[r][c].units) {
            if (u.id == id) {
              _hexes[r][c].units.firstWhere(( element) => element.id == id).isSelected = false;        
              break outerLoop; 
            }
          }
        }
      }
    }

  }

  // *********************************************
  // return whether there are
  // german units in this hex
  // *********************************************
  bool isHexOccupiedByGermans(int row, int col) {
    bool result = false; 

    try {
      if (_hexes[row][col].units.first.owner == EnumUnitOwner.german) {
        result = true; 
      }
    }
    catch (e) {
      // do nothingm result is already false 
    }

    return result; 

  }



  // *********************************************
  // return whether any of the units
  // are tagged as selected 
  // *********************************************
  bool isThereASelectedUnit() {
    bool result = false; 

    outerLoop:
    for (int r=0; r < constMapRows; r++) {
      for (int c=0; c < constMapCols; c++) {
        if (_hexes[r][c].units.isEmpty) {
          for (Unit u in _hexes[r][c].units) {
            if (u.isSelected) {
              result = true;
              break outerLoop; 
            }
          }
        }
      }
    }

    return result; 

  }

  // *********************************************
  // return hex where the selected
  // unit is   
  // *********************************************
  MapHex getSelectedHex() {
    late MapHex hex; 
    bool isSelected = false; 

    outerLoop:
    for (int r=0; r < constMapRows; r++) {
      for (int c=0; c < constMapCols; c++) {
        if (_hexes[r][c].units.isNotEmpty) {
          for (Unit u in _hexes[r][c].units) {
            if (u.isSelected) {
              isSelected = true;
              hex = _hexes[r][c]; 
              break outerLoop; 
            }
          }
        }
      }
    }

    if (isSelected) {
      return hex;
    }
    else {
      throw("No hex is selected");
    }

  }

  // *********************************************
  // attack the unit in this hex   
  // *********************************************
  int attackUnit (int id, int row, int col, EnumCardName cardName) {
    late List<Unit> units; 
    int numKilled = 0; 
    bool killAll = false; 
    int target = 0; 

    // if the player is american, clear out the kill message every time we call this
    if (_player == EnumPlayer.american) { _displayUnitsKilled = ""; }

    // get the units in the target hex 
    if (_hexes[row][col].units.isNotEmpty) {
      units = _hexes[row][col].units.toList();
      // normally, an attack kills one unit, however there are three cards that 
      // destroy everything in the hex 
      if ((cardName == EnumCardName.grenade) || (cardName == EnumCardName.flamethrower) ||
        (cardName == EnumCardName.machinegun)) {
          // everyone dies
          killAll = true; 
      }
      else { 
        // now, if more than one, randomly pick the one to attack/kill
        if (units.length > 1) {
          target = units[Random().nextInt(units.length)].id; 
        }
        else {
          target = units.first.id; 
        }
      }

    }

    // if we have a unit to kill, <arnold voice> do it 
    if ((target != 0) || (killAll)) {
      if (killAll) {
        // build a string with unit names
        for (Unit u in _hexes[row][col].units) {
          if ((_displayUnitsKilled.length > 0) && (_displayUnitsKilled[_displayUnitsKilled.length-1] != ",")) { _displayUnitsKilled += ", "; }
          _displayUnitsKilled += displayUnitName(u.type); 
        }

        // remove all units 
        numKilled = _hexes[row][col].units.length;  
        _hexes[row][col].units.clear(); 
      }
      else { 
        // remove single unit from the hex
        if ((_displayUnitsKilled.length > 0) && (_displayUnitsKilled[_displayUnitsKilled.length-1] != ",")) { _displayUnitsKilled += ", "; }
        _displayUnitsKilled += displayUnitName(_hexes[row][col].units.firstWhere((element) => element.id == target).type);  
        _hexes[row][col].units.removeWhere((element) => element.id == target);    
        numKilled = 1;  
      }
      // then, locate the unit that iniated the attack, and flag so they can't attack again     
      outerLoop:
      for (int r=0; r < constMapRows; r++) {
        for (int c=0; c < constMapCols; c++) {
          if (_hexes[r][c].units.isNotEmpty) {
            for (Unit u in _hexes[r][c].units) {
              if (u.id == id) {
                _hexes[r][c].units.firstWhere((element) => element.id == id).hasAttacked = true; 
                _hexes[r][c].units.firstWhere((element) => element.id == id).isSelected = false; 
                break outerLoop; 
              }
            }
          }
        }
      }
    }

    return numKilled; 

  }

  // *********************************************
  // move the unit to a new hex   
  // *********************************************
  bool moveUnit (int id, int destRow, int destCol) {
    int origRow = 0;
    int origCol = 0; 
    late Unit unit;
    bool result = false; 

    outerLoop:
    for (int r=0; r < constMapRows; r++) {
      for (int c=0; c < constMapCols; c++) {
        if (_hexes[r][c].units.isNotEmpty) {
          for (Unit u in _hexes[r][c].units) {
            if (u.id == id) {
              unit = u; 
              origRow = r;
              origCol = c; 
              break outerLoop; 
            }
          }
        }
      }
    }

    // quick test, if american unit, make sure it can't move into
    // spot occupied by germans
    if (unit.owner == EnumUnitOwner.american) {
      if ((_hexes[destRow][destCol].units.isNotEmpty) && 
        (_hexes[destRow][destCol].units.first.owner == EnumUnitOwner.german)) {
          unit.isSelected = false; 
          return false; 
        }
    }


    // add to new, remove from old; if orig and dest are the same, fail out
    if ((destRow == origRow) && (destCol == origCol)) {
      result = false; 
    }
    else {
      // only increment move if american unit (as it was done earlier for german ones)
      if (unit.owner == EnumUnitOwner.american) { unit.numTimesMoved++; } 
      unit.isSelected = false; 
      _hexes[destRow][destCol].units.add(unit);
      _hexes[origRow][origCol].units.removeWhere((element) => element.id == id);
      result = true; 
    }

    return result; 

  }

  // *********************************************
  // return actual unit  
  // *********************************************
  Unit getSelectedUnit() {
    late Unit unit; 
    bool isSelected = false; 

    outerLoop: 
    for (int r=0; r < constMapRows; r++) {
      for (int c=0; c < constMapCols; c++) {
        if (_hexes[r][c].units.isNotEmpty) {
          for (Unit u in _hexes[r][c].units) {
            if (u.isSelected) {
              isSelected = true;
              unit = u; 
              break outerLoop; 
            }
          }
        }
      }
    }

    if (isSelected) {
      return unit;
    }
    else {
      throw("No unit is selected");
    }

  }

  // *********************************************
  // is there a unit selected in this hex? (even
  // if part of a stack)
  // *********************************************
  bool unitInHexSelected(int row, int col) {
    bool isSelected = false; 




    // is there a unit in this hex that has been selected? 
    List<Unit> units = getUnitsInHex(row, col);
    for (Unit u in units) {
      if (u.isSelected) { 
        isSelected = true;
        break; 
      }
    }

    return isSelected;
  }

  // *********************************************
  // is there a unit eligible to attck in this hex? (even
  // if part of a stack)
  // *********************************************
  bool unitIsEligibleToAttack(Unit u) {
    late GameCard card; 
    bool isEligible = false; 

    if (u.owner == EnumUnitOwner.american) {
      // first, got here if they selected a card, so let's get that card 
      try {
        card = getSelectedCard();
        // for attacking, need to both check whether they've already attacked, and if
        // they can use the attack card 
        if (!u.hasAttacked) {
          if ((u.type == EnumUnitType.officer) || (u.type == EnumUnitType.heavy) || (u.type == EnumUnitType.sniper)) {
            if ((u.type == EnumUnitType.officer) && (card.useby == EnumUnitType.officer)) {
              isEligible = true; 
            }
            else if ((u.type == EnumUnitType.heavy) && (card.useby == EnumUnitType.heavy)) {
              isEligible = true; 
            }
            else if ((u.type == EnumUnitType.sniper) && (card.useby == EnumUnitType.sniper)) {
              isEligible = true; 
            }
          }
          else if (card.useby == EnumUnitType.all) {
            isEligible = true; 
          }
        }
      }
      catch (e) {
        // do nothing
      }
    }

    return isEligible;
  }

  // *********************************************
  // is there a unit eligible to move in this hex? (even
  // if part of a stack)
  // *********************************************
  bool unitIsEligibleToMove(Unit u) {
    late GameCard card; 
    bool isEligible = false; 

    // first, got here if they selected a card, so let's get that card 
    if (u.owner == EnumUnitOwner.american) {
      try {
        card = getSelectedCard();
        // can they still move, and use this card 
        if (u.canMove()) {
          if (card.useby != EnumUnitType.all) {
            if (card.useby == u.type) {
              isEligible = true; 
            }
          }
          else {
            // ok, everyone can use 
            isEligible = true; 
          }
        }
      }
      catch (e) {
        // do nothing 
      }
    }

    return isEligible;
  }

  // *********************************************
  // is there a unit eligible to move in this hex? (even
  // if part of a stack)
  // *********************************************
  bool isUnitSelected(int row, int col, int id) {

    return _hexes[row][col].units.firstWhere((element) => element.id == id).isSelected;

  }

  // *********************************************
  // is there a unit eligible to move in this hex? (even
  // if part of a stack)
  // *********************************************
  bool unitInHexEligibleToMove(int row, int col) {
    late GameCard card; 
    Set<Unit> units; 
    bool isEligible = false; 

    // first, got here if they selected a card, so let's get that card 
    try {
      card = getSelectedCard();
      units = _hexes[row][col].units; 
      // loop through units 
      for (Unit u in units) {
        if (u.canMove()) {
          if (card.useby != EnumUnitType.all) {
            if (card.useby == u.type) {
              isEligible = true; 
            }
          }
          else {
            // ok, everyone can use 
            isEligible = true; 
          }
        }
      }
    }
    catch (e) {
      // do nothing
    }

    return isEligible;
  }

  // *********************************************
  // ensure no one can attack
  // into a friendly spot, or move into an enemy spot
  // *********************************************
  List<List<int>> _identifyInvalidSpacesByPhase(List<List<int>> spaces, EnumPhase phase) {
    EnumUnitOwner owner; 

    // after we do all the distances, also need to make sure any spots with
    // german or american units in them are also marked as invalid (depending on the phase)
    if ((_player == EnumPlayer.american) && (phase == EnumPhase.move)) {
      owner = EnumUnitOwner.german; 
    }
    else if ((_player == EnumPlayer.american) && (phase == EnumPhase.attack)) {
      owner = EnumUnitOwner.american; 
    }
    else if ((_player == EnumPlayer.german) && (phase == EnumPhase.move)) {
      owner = EnumUnitOwner.american; 
    }      
    else {
      owner = EnumUnitOwner.german; 
    }

    for (int r=0; r < constMapRows; r++) {
      for (int c=0; c < constMapCols; c++) {
        if (_hexes[r][c].units.isNotEmpty) {
          if (_hexes[r][c].units.first.owner == owner) {
            spaces[r][c] = constInvalidSpace;
          }
        }
      }
    }     

    return List.from(spaces); 

  }


  // *********************************************
  // is there a unit eligible to attack in this hex? (even
  // if part of a stack)
  // *********************************************
  bool unitInHexEligibleToAttack(int row, int col) {
    GameCard card; 
    Set<Unit> units; 
    bool isEligible = false; 

    // first, got here if they selected a card, so let's get that card 
    try {
      card = getSelectedCard();
      units = _hexes[row][col].units; 
      // loop through units 
      for (Unit u in units) {
        if (!u.hasAttacked) {
      if (!u.hasAttacked) {
        if ((u.type == EnumUnitType.officer) || (u.type == EnumUnitType.heavy) || (u.type == EnumUnitType.sniper)) {
          if ((u.type == EnumUnitType.officer) && (card.useby == EnumUnitType.officer)) {
            isEligible = true; 
          }
          else if ((u.type == EnumUnitType.heavy) && (card.useby == EnumUnitType.heavy)) {
            isEligible = true; 
          }
          else if ((u.type == EnumUnitType.sniper) && (card.useby == EnumUnitType.sniper)) {
            isEligible = true; 
          }
        }
        else if (card.useby == EnumUnitType.all) {
          isEligible = true; 
        }
      }
        }
      }
    }
    catch (e) {
      // do nothing 
    }

    return isEligible;

  }

  // *********************************************
  // do we have everything in place for
  // a move or attack? 
  // *********************************************
  bool preConditionsMet(EnumPhase phase) {
    bool result = false; 
    Unit unit; 
    GameCard card; 
    bool okToProceed = false; 

    try {
      card = getSelectedCard();
      unit = getSelectedUnit();
      if (phase == EnumPhase.move) {
        if (card.type == EnumCardType.move) {
          okToProceed = true; 
        }
      }
      else {
        if (card.type == EnumCardType.attack) {
          okToProceed = true; 
        }        
      }

      if (okToProceed) {
        if ((card.player == EnumPlayerUse.american) || (card.player == EnumPlayerUse.both)) {
          // can it be used by all, or is the selected unit allowed to use? 
          if ((card.useby == EnumUnitType.all) || (card.useby == unit.type)) {
            result = true; 
          }
        }

      }


    }
    catch (e) { 
      // do nothing as we're already set to false
    }

    return result; 

  }

  // *********************************************
  // get distance from starting hex to
  // *********************************************
  List<List<int>> getForwardOnlyMoves(int range) {

    // start with an invalid list
    List<List<int>> result =  _mapFactory.resetDistances();  

    // now, iterate through each hex looking for any selected units, 
    // and then based on that, populate very specific spots in the array
    for (int r=0; r < constMapRows; r++) {
      for (int c=0; c < constMapCols; c++) {
        if (_hexes[r][c].units.isNotEmpty) {
          for (Unit u in _hexes[r][c].units) {
            if (u.isSelected) {
              // if we don't end up off the map, that's a valid spot 
              if ((r + range) <= constMapRows) {
                result[r + range][c] = range;
              }
            }
          }
        }
      }
    }    

    return List.from(result);

  }

  // *********************************************
  // get distance from starting hex to
  // every other hex 
  // *********************************************
  List<List<int>> getDistances(int row, int col, EnumPhase phase) {
    late List<List<int>> result;  

    // check preconditions first, and if ready, populate for real,
    // otherwise return one with all invalid spaces
    if (preConditionsMet(phase)) {
      
      GameCard card = getSelectedCard();

      // if in move phase, and multi-select, need to build a custom array
      if ((phase == EnumPhase.move) && (getMultiSelect())) {
        // go build a custom array 
        result = getForwardOnlyMoves(card.minrange); 

      }
      else { 
        // do we want to check entire hexagon, or the limited known spaces for zig zag?
        if (card.minrange == constZigZagSpace) {
          result = _mapFactory.getZigZagDistances(row, col);
        }
        else { 
          result = _mapFactory.getDistances(row, col);
        }
      }
      // after we do all the distances, also need to make sure any spots with
      // german or american units in them are also marked as invalid (depending on the phase)
      result = _identifyInvalidSpacesByPhase(result, phase);

    }
    else {
      result = _mapFactory.resetDistances();

    }

     return List.from(result);

  }

  // *********************************************
  // reset the distance array 
  // *********************************************
  List<List<int>> resetDistances() {
    return _mapFactory.resetDistances();
  }

  // *********************************************
  // sends back what will render on screen
  // *********************************************
  String showTerrain(int row, int col) {
    return _hexes[row][col].terrain;
  }

  // *********************************************
  // loop through and clear all units 
  // in case any had been selected 
  // *********************************************
  void unselectAllUnits() {

    for (int r=0; r < constMapRows; r++) {
      for (int c=0; c < constMapCols; c++) {
        if (_hexes[r][c].units.isNotEmpty) {
          for (Unit u in _hexes[r][c].units) {
            u.isSelected = false; 
          }

        }
      }
    }

    // 

    
  }


  // *********************************************
  // for american units: if more than one unit show stacked graphic,
  // otherwise, show actual unit; for germain units: show stacked graphic unless
  // there's only one unit and an american unit is adjacent  
  // *********************************************
  String showUnits(int row, int col) {
    String graphic = constNoUnits;
    bool isStacked = false; 

    // see if we have any units in this hex
    if (_hexes[row][col].units.isEmpty) {
      // just use the empty string above 
    }
    else {
        // are the units american or german? 
        Unit u = _hexes[row][col].units.first;
        if (u.owner == EnumUnitOwner.american) {
          // figure out what to show (stacked or individual )
          if (_hexes[row][col].units.length > 1) {
            // so there's more than one, which normally would equate to a stack, BUT
            // if we're in move/attack phase and one of those units is selected, then
            // show that unit instead of the stack , UNLESS we are doing a multi-select
            // move so even though one or units are selected, we still show the stack
            isStacked = true; 
            for (Unit u in _hexes[row][col].units) {
              if (u.isSelected) {
                if (getMultiSelect()) {
                  isStacked = true;
                  break; 
                }
                else {
                  isStacked = false; 
                  graphic = UnitFactory.getUnitGraphic(u.type, EnumUnitOwner.american, false);
                  break; 
                }
              }
            }
            // if we got here and stacked is still true, then no unit was selected
            if (isStacked) {
              graphic = UnitFactory.getUnitGraphic(u.type, EnumUnitOwner.american, isStacked);
            }

          }
          else {
            // only one unit, so just show it 
            graphic = UnitFactory.getUnitGraphic(u.type, EnumUnitOwner.american, false);
          }
        }
        else {
          // for now, just always show germans as stacked (regardless)
          graphic = UnitFactory.getUnitGraphic(u.type, EnumUnitOwner.german, true);
        }

    }

    return graphic; 

  }


  // *********************************************
  // go through hand, and drop 
  // first negate card of this type    
  // *********************************************
  void discardNegateCard(EnumPlayer player, EnumCardNegate action) {
    int id = 0; 

    if (player == EnumPlayer.american) {
      for (GameCard card in _americanHand) {
        if ((card.type == EnumCardType.negate) && (card.negate == action )) {
          _discardPile.add(card);
          id = card.id;
          break; 
        }
      }
      _americanHand.removeWhere((element) => element.id == id);
    }
    else { 
      for (GameCard card in _germanHand) {
        if ((card.type == EnumCardType.negate) && (card.negate == action )) {
          _discardPile.add(card);
          id = card.id;
          break; 
        }
      }
      _germanHand.removeWhere((element) => element.id == id);
    }
  }

  // *********************************************
  // return this card to the 
  // discard pile for future use   
  // *********************************************
  void discardCardById(int id) {

    // deselect all cards
    clearAllSelectedCards();

    // then move this one
    for (int i = 0; i < _americanHand.length; i++) {
      if (_americanHand[i].id == id) {
        _drawPile.add(_americanHand[i]);
        _americanHand.remove(_americanHand[i]);
      }
    }

  }



  // *********************************************
  // any cards that are marked
  // as selected should go into the discard pile  
  // *********************************************
  void discardSelectedCards() {

    for (int i = (_americanHand.length -1); i >=0; i--) {
      if (_americanHand[i].selected) {
        _americanHand[i].selected = false; 
        _discardPile.add(_americanHand[i]);
        _americanHand.removeAt(i);
        //_americanHand.removeWhere((element) => element.id ==  _americanHand[i].id);
      }
    }

  }

  // *********************************************
  // how many cards are selected   
  // *********************************************
  int getSelectedCardCount() {
    int count = 0; 

    for (GameCard card in _americanHand) {
      if (card.selected) {
        count++; 
      }
    }

    return count; 

  }

  // *********************************************
  // how many units are in the hex?
  // *********************************************
  int getUnitCountInHex(int row, int col) {
    int unitCount = constNoUnitsInHex; 

    if (_hexes[row][col].units.isNotEmpty) {
      unitCount = _hexes[row][col].units.length;
    }

    return unitCount;

  }


  // *********************************************
  // if not selected, mark card as selected,
  // but if already selected, take that attribute off   
  // *********************************************
  void toggleSelected(int id) {
    bool wasSelected = _americanHand.firstWhere((element) => element.id == id).selected; 

    // if we're not in orders phase, always clear any selected cards first 
    if (_phase != EnumPhase.orders) {
      clearAllSelectedCards(); 
    }
    _americanHand.firstWhere((element) => element.id == id).selected = !wasSelected; 

    // if wasSelected was true, then we also want to safely clear any units that maybe
    // had been selected as well 
    if (wasSelected) {
      unselectAllUnits();
    }
      
  }

  // *********************************************
  // return the card based on id
  // *********************************************
  GameCard getCardById(int id) {

    return _cardFactory.getCardById(id);

  }

  // *********************************************
  // can the american player utilize 
  // the card?    
  // *********************************************
  bool americanCanUseCard(int id) {
    bool result = false; 
    GameCard card; 

    card = _cardFactory.getCardById(id);
    if ((card.player == EnumPlayerUse.american) || (card.player == EnumPlayerUse.both)) {
      result = true; 
    }

    return result; 

  }

  // *********************************************
  // return the cards in the american's hand 
  // *********************************************
  List<GameCard> americanHand() {
    return _americanHand;
  }


  // *********************************************
  // reset to starting values
  // *********************************************
  void newGame() {
    _round = 1;
    _phase = EnumPhase.orders;
    _player = EnumPlayer.american;
    _hexes = _mapFactory.prepareMap(); // get our randomized map w/units 
    // clear out decks 
    try {
      _americanHand.clear();
      _germanHand.clear(); 
      _discardPile.clear(); 
      _drawPile.clear(); 
    }
    catch (e) {
      // this will fail on very first launch and that's fine
    }
    _drawPile = _cardFactory.prepareInitialDeck(); // all cards into the draw pile
    _drawCards(); // initial cards to american player and german computer 
  }

}
