import 'dart:math';
import '../const.dart';
import 'package:number_to_words/number_to_words.dart';
import '../models/card_model.dart';
import '../models/map_model.dart';
import '../models/unit_model.dart';

class GermanUnit {
  final Unit unit;
  final int row;
  final int col;
  GermanUnit(this.unit, this.row, this.col);
}

class GermanMove {
  final int unitId;
  final int destRow;
  final int destCol;  
  GermanMove(this.unitId, this.destRow, this.destCol);
}

class GermanAttack {
  final int unitId;
  final int attackRow;
  final int attackCol; 
  final EnumCardName cardName; 
  GermanAttack(this.unitId, this.attackRow, this.attackCol, this.cardName);
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
  final List<GermanUnit> _germanUnits = []; 
  late List<List<MapHex>> _hexes;

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
              _germanUnits.add(GermanUnit(u, r, c));
            }
          }
        }
      }
    }

  }

  // *********************************************
  // _resetUnits: go through and reset all units so they 
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
  // _identifyInvalidSpaces: ensure no one can attack
  // into a friendly spot, or move into an enemy spot
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
  // isGameOver - loop through the cards the
  // german can't use and add them to the discard pile
  // *********************************************
  bool isGameOver(EnumPlayer player) {
    bool result = false; 
    EnumUnitOwner playerToCheck = EnumUnitOwner.american;
    int officerCount = 0; 

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
                officerCount++;
                if (officerCount == 2) {
                  break outerLoop; 
                } 
              }
            }
        }
      }
    }

    if (officerCount == 0) {
      result = true; 
    }

    return result; 

 }  


  // *********************************************
  // updateUnitStatus - increment move on this unit or 
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
  // _doGermanOrdersPhase - loop through the cards the
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
        for (GermanUnit gu in _germanUnits) {
          if (gu.unit.type == _germanHand[i].useby) {
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
                for (GermanUnit gu in _germanUnits) {
                  if (gu.unit.type == _drawPile[i].useby) {
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
  // canNegateAction: does the player have a valid
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
  List<GermanMove> getGermanMoves() {
    late List<List<int>> result; 
    late GameCard card;  
    late GermanUnit unitToMove; 
    List<GermanMove> moves = []; 
    bool validUnit = false; 

    // most up to date list of where units are at 
    _setGermanUnits();

    // loop through cards to see if there are any move cards
    for (int i = (_germanHand.length-1); i >= 0; i--) {
      card = _germanHand[i];
      if (card.type == EnumCardType.move) {
        do {
          // grab a random unit (that hasn't already moved)
          int pos = Random().nextInt(_germanUnits.length);
          unitToMove = _germanUnits[pos];
          if (unitToMove.unit.canMove()) { validUnit = true; }          
        } while (validUnit == false);
        // get list of valid spaces 
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
          for (int destCol=0; destCol<constMapCols; destCol++) {
            if ((result[destRow][destCol] != constInvalidSpace) && 
              (result[destRow][destCol] >= card.minrange) &&
              (result[destRow][destCol] <= (card.maxrange + 1)) && 
              ((unitToMove.row != destRow) && (unitToMove.col != destCol))) {
                // update the unit to show it moved (even if the move gets negated later)
                _hexes[unitToMove.row][unitToMove.col].units.firstWhere((element) => element.id == unitToMove.unit.id).numTimesMoved++;                 
                // create a move object and add to the array
                moves.add(GermanMove(unitToMove.unit.id, destRow, destCol));
                String unitName = unitToMove.unit.type.name;  
                print("german $unitName moving to $destRow, $destCol");
                // discard the card 
                _discardPile.add(_germanHand[i]);
                try {
                  _germanHand.removeAt(i);
                }
                catch (e) {
                  print("error in getGermanMoves removing card");
                }
                break outerLoop;    
            }
          }
        }
      }
    }
    return List.from(moves); 
  }

  // *********************************************
  // getUnitsInHex: returns a list of the units in the hex 
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
  List<GermanAttack> getGermanAttacks() {
    late List<List<int>> result; 
    late GameCard card;  
    late GermanUnit unitAttacking; 
    List<GermanAttack> attacks = []; 
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
                for (int destCol=0; destCol<constMapCols; destCol++) {
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
                      attacks.add(GermanAttack(unitAttacking.unit.id, destRow, destCol, card.name));
                      String unitName = unitAttacking.unit.type.name;  
                      print("german $unitName attacking $destRow, $destCol");
                      // save where we attacked
                      prevRow = destRow;
                      prevCol = destCol; 
                      // discard the card 
                      _discardPile.add(_germanHand[i]);
                      try {
                        _germanHand.removeAt(i);
                      }
                      catch (e) {
                        print("error in getGermanAttacks removing card");
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
  // getSelectedCard: return the card that is active   
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
  // clearSelectedCards:  clear out 
  // any cards the player had selected 
  // *********************************************
  void clearAllSelectedCards() {

    for (GameCard card in _americanHand) {
      card.selected = false; 
    }

  }

  // *********************************************
  // _checkDrawPile: do we have enough cards to use?
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
  // drawCards: add cards to hands for american and
  // german player  
  // *********************************************
  void _drawCards() {

    _checkDrawPile();
 
    // draw cards for american 
    for (int i = 0; i < constMaxCardsInHand; i++) {
      _americanHand.add(_drawPile[i]);
      _drawPile.remove(_drawPile[i]);
    }

    // cheat: if german already has three, drop one just so we're
    // always picking at least one up
    if (_germanHand.length == constMaxCardsInHand ) {
      _discardPile.add(_germanHand[0]);
      _germanHand.removeAt(0);
    }

    // decide how many to draw for the german player 
    int i = 0; 
    if (_germanHand.length <= constMaxCardsInHand) {
      // draw up to three 
      do {
        _checkDrawPile();
        // cheat: only add to the german's hand if they can use it 
        if (_drawPile[i].player != EnumPlayerUse.american) {
          _germanHand.add(_drawPile[i]);
          _drawPile.remove(_drawPile[i]);
        }
        i++; 
        if (i >= _drawPile.length) { break; }
      } while (_germanHand.length <= constMaxCardsInHand);
    }

  }

  // *********************************************
  // isGermanTurn: are we going to look for their 
  // moves and attacks 
  // *********************************************
  bool isGermanTurn() {
    bool result = false; 

    if (_player == EnumPlayer.german) { result = true; }
    return result; 

  }

  // *********************************************
  // nextPhase: move to the next phase
  // *********************************************
  void nextPhase() {

    // if we throw an error incrementing the phase, we've got too far,
    try {
      _phase = EnumPhase.values[_phase.index + 1];
    } catch (e) {
      _phase = EnumPhase.orders;
    }

    // if we cycle through to a new orders phase,
    if (_phase == EnumPhase.orders) {

      // switch the player
      _player == EnumPlayer.german
          ? _player = EnumPlayer.american
          : _player = EnumPlayer.german;

      // if we flipped back to american player, also draw more cards, clear any selected, and reset all the units
      if (_player == EnumPlayer.american) { 
        _round++;
        _drawCards();
        clearAllSelectedCards();
        _resetUnits();
      }

      // prep all the units so the computer can make decisions, and discard any cards as needed
      if (_player == EnumPlayer.german) {
        _doGermanOrdersPhase();
        // advance phase so we can flip to next round 
        _phase = EnumPhase.attack;
      }
  
     }
    
  }

// *********************************************
  // unitsInHexCount: return how many units are in the selected hex 
  // *********************************************
  int unitsInHexCount(int row, int col) {
      return _hexes[row][col].units.length;
  }

  // *********************************************
  // unitsInHexOwner: return which player owns the unit(s) 
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
  // setSelectedByFirstPosition: mark unit in this hex as selected  
  // *********************************************
  void setSelectedUnitByFirstPosition(int row, int col) {
      // mark the appropriate unit as selected 
      _hexes[row][col].units.first.isSelected = true; 

  }

  // *********************************************
  // setSelectedById: mark unit in this hex as selected  
  // *********************************************
  void setSelectedUnitById(int row, int col, int id) {
      // mark the appropriate unit as selected 
      _hexes[row][col].units.firstWhere(( element) => element.id == id).isSelected = true; 

  }

  // *********************************************
  // deSelectUnitById: deselect this one unit   
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
  // isHexOccupiedByGermans - return whether there are
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
  // isThereASelectedUnit - return whether any of the units
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
  // getSelectedHex - return hex where the selected
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
  // attackUnit - attack the unit in this hex   
  // *********************************************
  int attackUnit (int id, int row, int col, EnumCardName cardName) {
    late List<Unit> units; 
    int numKilled = 0; 
    bool killAll = false; 
    int target = 0; 

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
        // remove all units 
        numKilled = _hexes[row][col].units.length;  
        _hexes[row][col].units.clear(); 
      }
      else { 
        // remove single unit from the hex
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
  // moveUnit - move the unit to a new hex   
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
  // getSelectedUnit - return actual unit  
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
  // unitInHexSelected: is there a unit selected in this hex? (even
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
  // unitInHexEligibleToMove: is there a unit eligible to move in this hex? (even
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
  // _identifyInvalidSpacesByPhase: ensure no one can attack
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
  // unitInHexEligibleToAttack: is there a unit eligible to attack in this hex? (even
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
  // preConditionsMet: do we have everything in place for
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
  // getDistances: get distance from starting hex to
  // every other hex 
  // *********************************************
  List<List<int>> getDistances(int row, int col, EnumPhase phase) {
    late List<List<int>> result;  

    // check preconditions first, and if ready, populate for real,
    // otherwise return one with all invalid spaces
    if (preConditionsMet(phase)) {
      // do we want to check entire hexagon, or the limited known spaces for zig zag?
      GameCard card = getSelectedCard();
      if (card.minrange == constZigZagSpace) {
        result = _mapFactory.getZigZagDistances(row, col);
      }
      else { 
        result = _mapFactory.getDistances(row, col);
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
  // resetDistances: reset the distance array 
  // *********************************************
  List<List<int>> resetDistances() {
    return _mapFactory.resetDistances();
  }

  // *********************************************
  // showTerrain: sends back what will render on screen
  // *********************************************
  String showTerrain(int row, int col) {
    return _hexes[row][col].terrain;
  }

  // *********************************************
  // _unselectAllUnits: loop through and clear all units 
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
  // showUnits: for american units: if more than one unit show stacked graphic,
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
            // show that unit instead of the stack 
            isStacked = true; 
            for (Unit u in _hexes[row][col].units) {
              if (u.isSelected) {
                isStacked = false; 
                graphic = UnitFactory.getUnitGraphic(u.type, EnumUnitOwner.american, false);
                break; 
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
  // discardNegateCard: go through hand, and drop 
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
  // discardCard: return this card to the 
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
  // discardSelectedCards: any cards that are marked
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
  // getSelectedCardCount: how many cards are selected   
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
  // toggleSelected: if not selected, mark card as selected,
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
  // canUseCard: can the american player utilize 
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
  // americanHand: return the cards in the american's hand 
  // *********************************************
  List<GameCard> americanHand() {
    return _americanHand;
  }


  // *********************************************
  // newGame: reset to starting values
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
      print("failed clearing decks");
    }
    _drawPile = _cardFactory.prepareInitialDeck(); // all cards into the draw pile
    _drawCards(); // initial cards to american player and german computer 
  }

}
