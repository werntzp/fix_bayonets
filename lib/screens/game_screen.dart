import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:hexagon/hexagon.dart';
import '../const.dart';
import '../dialogs/stacked_unit_picker_dialog.dart';
import '../dialogs/ask_to_negate_dialog.dart';
import '../dialogs/card_info_dialog.dart';
import 'game_over_screen.dart'; 
import '../models/game_model.dart';
import '../models/card_model.dart';
import '../models/unit_model.dart';

GameModel _gameModel = GameModel();
  late List<List<int>> _distanceArray; 
  bool _overlayShowing = false; 

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  OverlayEntry? _overlayEntry;
  Completer<void>? _completer; 

  @override
  void initState() {
    super.initState();
    _newGame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _phaseOverlayMessage(EnumPhase.orders);
    });

  }

  @override
  void dispose() {
    super.dispose();
  }

  // *********************************************
  // display the overlay message after killing
  // some germans 
  // *********************************************
  Future<void> _successfulKillOverlayMessage(String message) async {

    _completer = Completer<void>();

    if (_overlayEntry != null) return; // Prevent stacking

    _overlayShowing = true; 
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Align(alignment: Alignment.center,
            child: Card(
              elevation: 8.0,
              color: const Color.fromARGB(255, 129, 128, 108),
              child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                message,
                style: TextStyle(fontFamily: constAppTextFont, fontSize: 25, fontWeight: FontWeight.bold), 
                textAlign: TextAlign.center))))]));

    Overlay.of(context).insert(_overlayEntry!);

    // Remove after 1 second
    Future.delayed(Duration(seconds: 2), () {
      _overlayEntry?.remove(); 
      _completer?.complete(); 
      _overlayEntry = null; 
      _completer = null; 
      _overlayShowing = false; 
    });

    await _completer!.future; 

  }

  // *********************************************
  // show at the beginning of the german turn 
  // *********************************************
  Future<void> _germanTurnPrepOverlayMessage() async {

    _completer = Completer<void>();

    if (_overlayEntry != null) return; // Prevent stacking

    _overlayShowing = true; 
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 200,
        left: 50,
        right: 50,
        child: Material(
          elevation: 8.0,
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(constGermanTurnStart, width: 225, height: 225, fit: BoxFit.contain,),
              SizedBox(height: 12),
              Text(
                constGermanTurnPrepMessage,
                style: TextStyle(color: Colors.white, fontFamily: constAppTextFont, fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const Padding(
                padding: EdgeInsets.all(2.0),
              ),
              Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
                )
            ],
          ),
        ),
        ),
    ));

    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(Duration(seconds: 3), () {
      _overlayEntry?.remove(); 
      _completer?.complete(); 
      _overlayEntry = null; 
      _completer = null; 
      _overlayShowing = false;
    });

    await _completer!.future; 

  }

  // *********************************************
  // display the overlay message with a recap of
  // the moves/attacks the Germans made 
  // *********************************************
  Future<void> _germanTurnRecapOverlayMessage(String message) async {

    _completer = Completer<void>();

    if (_overlayEntry != null) return; // Prevent stacking

    _overlayShowing = true; 
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 200,
        left: 50,
        right: 50,
        child: Material(
          elevation: 8.0,
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(constGermanTurnStart, width: 225, height: 225, fit: BoxFit.contain,),
              SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(color: Colors.white, fontFamily: constAppTextFont, fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        ),
    ));

    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(Duration(seconds: 3), () {
      _overlayEntry?.remove(); 
      _completer?.complete(); 
      _overlayEntry = null; 
      _completer = null; 
      _overlayShowing = false; 
    });

    await _completer!.future; 

  }

  // *********************************************
  // display the overlay message when the germans
  // negate a move or attack 
  // *********************************************
  Future<void> _negateOverlayMessage(EnumPhase phase) async {
    String message = constNegateMoveMessage; 

    if (phase == EnumPhase.attack) {
      message = constNegateAttackMessage;
    }

    _completer = Completer<void>();

    if (_overlayEntry != null) return; // Prevent stacking

    _overlayShowing = true; 
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Align(alignment: Alignment.center,
            child: Card(
              elevation: 8.0,
              color: Colors.black,
              child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontFamily: constAppTextFont, fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center))))]));

    Overlay.of(context).insert(_overlayEntry!);

    // Remove after 1 second
    Future.delayed(Duration(seconds: 2), () {
      _overlayEntry?.remove(); 
      _completer?.complete(); 
      _overlayEntry = null; 
      _completer = null; 
      _overlayShowing = false;
    });

    await _completer!.future; 

  }

  // *********************************************
  // display the overlay message when changing phases 
  // *********************************************
  Future<void> _phaseOverlayMessage(EnumPhase phase) async {
    String message = constStartingOrdersPhase;
    Color color = Colors.white; 

    _completer = Completer<void>();

    // decide which to use 
    if ((phase == EnumPhase.orders) && (_gameModel.player() == EnumPlayerUse.american)) {
      // do nothing, default values are fine
    }
    if ((phase == EnumPhase.move) && (!_gameModel.skipMovePhase())) {
      message = constStartingMovePhase;
      color = Colors.green;
    }
    else if ((phase == EnumPhase.attack) && (!_gameModel.skipAttackPhase())) {
      message = constStartingAttackPhase;
      color = Colors.red; 
    }
    else if ((_gameModel.skipMovePhase()) && (_gameModel.skipAttackPhase()))  {
      message = constSkippingMoveAndAttackPhase;
      color = const Color.fromARGB(255, 129, 128, 108);
    }
    else if (_gameModel.skipMovePhase()) {
      message = constSkippingMovePhase;
      color = const Color.fromARGB(255, 129, 128, 108);
    }
    else if (_gameModel.skipAttackPhase()) {
      message = constSkippingAttackPhase;
      color = const Color.fromARGB(255, 129, 128, 108);
    }

    if (_overlayEntry != null) return; // Prevent stacking

    _overlayShowing = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Align(alignment: Alignment.center,
            child: Card(
              elevation: 8.0,              
              color: color,
              child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                message,
                style: TextStyle(fontFamily: constAppTextFont, fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center))))]));

    Overlay.of(context).insert(_overlayEntry!);

    // Remove after 1 second
    Future.delayed(Duration(seconds: 1), () {
      _overlayEntry?.remove(); 
      _completer?.complete(); 
      _overlayEntry = null; 
      _completer = null; 
      _overlayShowing = false;
    });

    await _completer!.future; 

  }

  // *********************************************
  // phase determines some of the colors used 
  // *********************************************
  Color getPhaseColor() {
    Color phaseColor = Colors.white; 

    // top colors 
    if (_gameModel.phase() == EnumPhase.orders) {
      phaseColor = Colors.white;
    }
    else if (_gameModel.phase() == EnumPhase.move) {
      phaseColor = Colors.green;
    }
    else {
      phaseColor = Colors.red; 
    }

    return phaseColor; 

  }

  // *********************************************
  // init map and all elements 
  // *********************************************
  void _newGame() async {
    _gameModel.newGame();
  }

  // *********************************************
  // what to do when user does a single tap
  // *********************************************
  void _handleTap(int row, int col) async {

    int count = 0; 
    EnumUnitOwner owner; 
    bool deselectedUnit = false; 
    bool okToProceed = true; 

    // always grab these to start 
    count = _gameModel.unitsInHexCount(row, col);
    owner = _gameModel.unitsInHexOwner(row, col);
    List<Unit> units = _gameModel.getUnitsInHex(row, col);

    // first, see if there are german units in this hex
    if ((!_gameModel.preConditionsMet(EnumPhase.move)) && 
        (!_gameModel.preConditionsMet(EnumPhase.attack)) && 
    (_gameModel.unitsInHexOwner(row, col) == EnumUnitOwner.german)) {
        // if there's an american unit adjacent to this, then you can bring up the stack
        // picker dialog to see which German units are in there
        if (_gameModel.isAmericanUnitAdjacent(row, col)) {
          await showStackedUnitPickerDialog(context, units, _gameModel);
        }
        return; 
    }    

    // *** orders phase *** 
    // if orders phase, and there's an american stack in the hex, bring up
    // the dialog so they can see them all 
    if (_gameModel.phase() == EnumPhase.orders) {
        if ((owner == EnumUnitOwner.american) && (count > 1)) {
          // we don't care about the return value
          await showStackedUnitPickerDialog(context, units, _gameModel);
        }
    }

    // *** move phase *** 
    else if (_gameModel.phase() == EnumPhase.move) {
      // if preconditions have been met and we have a selected unit,
      // move that unit to the new space 
      if (_gameModel.preConditionsMet(EnumPhase.move)) {
        try {
          // if we have a selected unit, and this spot is a valid 
          // move spot, and there aren't germans in the target spot, move the unit and jump out 
          Unit u = _gameModel.getSelectedUnit();
          GameCard card = _gameModel.getSelectedCard(); 
          int distance = _distanceArray[row][col];  
          if ((distance != constInvalidSpace) &&
            (distance >= card.minrange) &&
            (distance <= card.maxrange) &&  
            (!_gameModel.isHexOccupiedByGermans(row, col))) {
              // can the german player negate this? if yes, flip a coin if they actually want to do it 
              if (_gameModel.canNegateAction(EnumPlayer.german, EnumCardNegate.move)) {
                if (Random().nextBool()) {
                  // german decided to block the move! 
                  await _negateOverlayMessage(EnumPhase.move);
                  // also, increment the move, even if it didn't 
                  _gameModel.updateUnitStatus(u.id, EnumPhase.move);
                  // discard the negate card
                  _gameModel.discardNegateCard(EnumPlayer.german, EnumCardNegate.move);
                  // set flag
                  okToProceed = false; 
                }
              }

              // do the move 
              if (okToProceed) {
                if (_gameModel.moveUnit(u.id, row, col)) {
                  _distanceArray =  _gameModel.resetDistances(); // reset all distances 
                  _gameModel.discardCardById(card.id); // get rid of the move card
                }
                else {
                  _gameModel.deSelectUnitById(u.id);
                }
              }
              else {
                // it was negated, so we need to do a bunch of stuff:
                _distanceArray =  _gameModel.resetDistances(); // reset all distances 
                _gameModel.discardCardById(card.id); // get rid of the move card    
                _gameModel.deSelectUnitById(u.id); // deselect the unit           
              }
          }
          else {
             _gameModel.deSelectUnitById(u.id);
          }    

          setState(() {      
              _distanceArray =  _gameModel.resetDistances();          
          });
          return; 
        }
        catch (e) {
          // do nothing, 
        }
      }

      // otherwise, go through progression; first see if these are american units
      if (_gameModel.unitsInHexOwner(row, col) == EnumUnitOwner.american) {
        // next, is there just one unit? 
        if (count == 1) {
          // get the unit and validate it is eligible to move 
          if (_gameModel.unitInHexEligibleToMove(row, col)) {
            setState(() {
              _gameModel.setSelectedUnitByFirstPosition(row, col);
              if (_gameModel.preConditionsMet(EnumPhase.move)) {
                _distanceArray = _gameModel.getDistances(row, col, EnumPhase.move);
              }    
            });
          }
        } 
        else {
          // first, see if any of units are selected, and if so, toggle that off
          for (Unit u in units) {
            if (u.isSelected) {
              setState(() {
                _gameModel.deSelectUnitById(u.id);
                _distanceArray =  _gameModel.resetDistances();
                deselectedUnit = true;  
              });
              // and just break out
              break; 
            }
          }

          // bring up dialog if we didn't deselect anything, and see if they return back an id 
          if (!deselectedUnit) {
            final id = await showStackedUnitPickerDialog(context, units, _gameModel);
            if (id != null) {
              _gameModel.unselectAllUnits();
              setState(() {
                _gameModel.setSelectedUnitById(row, col, int.parse(id));
                if (_gameModel.preConditionsMet(EnumPhase.move)) {
                  _distanceArray = _gameModel.getDistances(row, col, EnumPhase.move);
                }    
              });
            }
          }
        }
      }
    }

    // finally, attack phase
    // *** attack phase ***
    else {
     if (_gameModel.preConditionsMet(EnumPhase.attack)) {
        try {
          // if we have a selected unit, and this spot is a valid 
          // attack spot, and there must be a german unit in the target spot, 
          // kill the target unit and jump out  
          Unit u = _gameModel.getSelectedUnit(); // unit initiating attack 
          GameCard card = _gameModel.getSelectedCard(); 
          int distance = _distanceArray[row][col];  
          if ((distance != constInvalidSpace) &&
            (distance >= card.minrange) &&
            (distance <= card.maxrange) &&  
            (_gameModel.isHexOccupiedByGermans(row, col))) {
              // can the german player negate this? if yes, flip a coin if they actually want to do it 
              if (_gameModel.canNegateAction(EnumPlayer.german, EnumCardNegate.attack)) {
                // first checj=k, if they can negate, and the attack is on their officer,
                // always negate!
                if (_gameModel.isGermanOfficerInHex(row, col)) {
                  okToProceed = false;
                }
                else if (Random().nextBool()) {
                  okToProceed = false;
                }
                // now actually negate it if that's the case 
                if (okToProceed == false) {
                  // german decided to block the move! 
                  await _negateOverlayMessage(EnumPhase.attack);
                  // also, increment the move, even if it didn't 
                  _gameModel.updateUnitStatus(u.id, EnumPhase.attack);
                  // discard their card
                  _gameModel.discardNegateCard(EnumPlayer.german, EnumCardNegate.attack);
                }
              }

              // do the attack 
              if (okToProceed) { 
                int numKilled = _gameModel.attackUnit(u.id, row, col, card.name); 
                if (numKilled > 0) {
                  _distanceArray =  _gameModel.resetDistances(); // reset all distances 
                  _gameModel.discardCardById(card.id); // get rid of the move card
                  // if we killed more than one, change what gets displayed 
                  String unitName = _gameModel.displayUnitName(u.type); 
                  String killNumber = numKilled.toString();
                  String killNames = _gameModel.displayListOfUnitsKilled(); 
                  String killedMessage = "";
                  if (numKilled == 1) {
                    killedMessage = "American $unitName killed a German $killNames";
                  }
                  else {
                    killedMessage = "American $unitName killed $killNumber Germans ($killNames)"; 
                  }
                  await _successfulKillOverlayMessage(killedMessage);
                }
                else {
                  _gameModel.deSelectUnitById(u.id);
                }
              }
              else {
                // it was negated, so we need to do a bunch of stuff:
                _distanceArray =  _gameModel.resetDistances(); // reset all distances 
                _gameModel.discardCardById(card.id); // get rid of the move card    
                _gameModel.deSelectUnitById(u.id); // deselect the unit           
              }
            }
            else {
              _gameModel.deSelectUnitById(u.id);
            }        
          setState(() {      
              _distanceArray =  _gameModel.resetDistances();          
          });

          // check on game ending conditions
          if (_gameModel.isGameOver(EnumPlayer.american)) {
            // go the game over dialog 
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GameOverScreen(won: true)),
            );
          }

          return; 
        }
        catch (e) {
          // do nothing, 
        }
      }

      // otherwise, go through progression; first see if these are american units
      if (_gameModel.unitsInHexOwner(row, col) == EnumUnitOwner.american) {
        // next, is there just one unit? 
        if (count == 1) {
          // get the unit and validate it is eligible to move 
          if (_gameModel.unitInHexEligibleToAttack(row, col)) {
            setState(() {
              _gameModel.setSelectedUnitByFirstPosition(row, col);
              if (_gameModel.preConditionsMet(EnumPhase.attack)) {
                _distanceArray = _gameModel.getDistances(row, col, EnumPhase.attack);
              }    
            });
          }
        } 
        else {
          // first, see if any of units are selected, and if so, toggle that off
          for (Unit u in units) {
            if (u.isSelected) {
              setState(() {
                _gameModel.deSelectUnitById(u.id);
                _distanceArray =  _gameModel.resetDistances();
                deselectedUnit = true;  
              });
              // and just break out
              break; 
            }
          }

          // bring up dialog if we didn't deselect anything, and see if they return back an id 
          if (!deselectedUnit) {
            final id = await showStackedUnitPickerDialog(context, units, _gameModel);
            if (id != null) {
              _gameModel.unselectAllUnits();
              setState(() {
                _gameModel.setSelectedUnitById(row, col, int.parse(id));
                if (_gameModel.preConditionsMet(EnumPhase.attack)) {
                  _distanceArray = _gameModel.getDistances(row, col, EnumPhase.attack);
                }    
              });
            }
          }
        }
      }

    }

    setState(() {      
      // force a repaint 
    });

  }

  // *********************************************
  // return unit graphics to be stacked on
  // top of the base terrain 
  // *********************************************
  Widget _showUnits(int row, int col) {
    String graphic = _gameModel.showUnits(row, col);

    // check for const first to see if no units there, other create a new image 
    // within a positioned object
    if (graphic == constNoUnits) {
      return Container();
    }
    else {
      return 
        Positioned(
          top:8, left: 11, child: Image.asset(graphic, width: 40, height: 40,));
    }
  }

  // *********************************************
  // if this is move/attack phase, and they've
  // selected card/unit, show where they can move that unit to, or 
  // what is open for attack  
  // *********************************************
  Widget _showValidSpace(int row, int col) {
    GameCard card; 
    int distance; 
    EnumPhase phase = _gameModel.phase();

      // first make sure we're in a move/attack phase
      try {
        if ((_gameModel.phase() == EnumPhase.orders)) {
          return Container(); 
        }
        else {
          // first do a santity check that pre-conditions have been met to check valid spaces 
          // for move/attack
          if (_gameModel.preConditionsMet(phase)) {
            card = _gameModel.getSelectedCard(); 
            distance = _distanceArray[row][col];
            if (distance == constInvalidSpace) {
                return Positioned(
                  top:15, left: 18, child: Icon(Icons.cancel, color: Colors.red, size: 30));
            }
            else if ((distance >= card.minrange) && (distance <= card.maxrange)) {
              return 
                Positioned(
                  top:15, left: 18, child: Icon(Icons.check_circle, color: Colors.green, size: 30));
            }
            else {
              return 
                Positioned(
                  top:15, left: 18, child: Icon(Icons.cancel, color: Colors.red, size: 30));
            }
          }
          else {
            return Container(); 
          }
        }
      }
      catch (e) {
          return Container(); 
      }

  }

  // *********************************************
  // decide whether to show a border
  // based on phase and if a unit is available to take
  // an action (move/attack) 
  // *********************************************
  Widget _showBorder(int row, int col) {
    Color c  = Colors.transparent; 

    // if a unit has been selected (in either move or attack phase),
    // border should be yellow 
    if ((_gameModel.phase() != EnumPhase.orders) && 
      (_gameModel.unitInHexSelected(row, col))) {
      c = Colors.yellow;
    }
    // if move phase, check in each hex to see if units are eligible to
    // move, and if so,border is green, UNLESS we've already selected a unit, then don't show
    // so they only see selected unit
    else if ((_gameModel.phase() == EnumPhase.move) && 
      (_gameModel.unitInHexEligibleToMove(row, col)) && 
      (_gameModel.unitsInHexOwner(row, col) == EnumUnitOwner.american)) {
      if (!_gameModel.isThereASelectedUnit()) {
        c = Colors.green; 
      }
    }
    // if attack phase, check in each hex to see if units are eligible to
    // attack, and if so,border is green
    else if ((_gameModel.phase() == EnumPhase.attack) && 
      (_gameModel.unitInHexEligibleToAttack(row, col)) && 
      (_gameModel.unitsInHexOwner(row, col) == EnumUnitOwner.american)) {
      c = Colors.red; 
    }    

    return 
      Positioned(top:8, left: 11, 
        child: Container(
          height: 42,
          width: 42, 
          decoration: BoxDecoration(border: Border.all(color: c, width: 3)),
          child: Container(), 
        ));

  }

  // *********************************************
  // based on which phase it is,
  // display message to the player  
  // *********************************************
  String _showPhaseMessage() {
    String s = "";

    if (_gameModel.phase() == EnumPhase.orders) {
      s = constOrdersPhaseMessage;
    }         
    else if (_gameModel.phase() == EnumPhase.move) {
      s = constMovePhaseMessage;
    }
    else {
      s = constAttackPhaseMessage;
    }

    return s;

  }

  // *********************************************
  // change card border based on whether it has been
  // selected or not  
  // *********************************************
  Color _getCardBorderColor(GameCard card) {
    Color c = Colors.black; 

    c = (card.selected) ?  Colors.yellow : Colors.black; 
    return c; 

  }

  // *********************************************
  // can only one player use this?    
  // *********************************************
  Widget _getCardPlayerRestrictions(GameCard card) {
    String flag = constAmericanFlag; 

    // if both can use, just send back an empty container 
    if (card.player == EnumPlayerUse.both) {
      return Container();
    }
    else {
      if (card.player == EnumPlayerUse.german) { flag = constGermanFlag; }
      return 
        Image.asset(flag, fit: BoxFit.fill,);

    }

  }


  // *********************************************
  // show any usage restrictions for this card   
  // *********************************************
  String _getCardUsageRestrictions(GameCard card) {
    String result = "";
    String useBy = "";
    String range = ""; 

    // is there a unit restriction? 
    if (card.useby == EnumUnitType.officer) {
      useBy = "O ";
    }
    else if (card.useby == EnumUnitType.heavy) {
      useBy = "H ";
    }
    else if (card.useby == EnumUnitType.sniper) {
      useBy = "S ";
    }

    // now tack on card range 
    
    // if zero, it is a negate card so show nothing 
    if (card.minrange == 0) {
      range = ""; 
    }
    // zig zag is weird 
    else if (card.minrange == constZigZagSpace) {
      range = "Z";
    }
    // if they are the same, just show one 
    else if (card.minrange == card.maxrange) {
      range = card.maxrange.toString();
    }
    // otherwise, show the min/max range 
    else {
      range = card.minrange.toString() + "-" + card.maxrange.toString(); 
    }

    return useBy + range; 

  }

  // *********************************************
  // pop up with more card details   
  // *********************************************
  void _showCardInfo(EnumCardName cardName, String graphic) {
    showCardInfoDialog(context, cardName, graphic);

  }

  // *********************************************
  // mark this card as selected   
  // *********************************************
  void _selectCard(int id, EnumCardType type) {

    // if we're in orders phase, they can select one or more
    // cards to discard 
    if (_gameModel.phase() == EnumPhase.orders) {
      setState(() {
        // show the card as selected 
        _gameModel.toggleSelected(id);
      });
    }
    // otherwise, if we're in move phase, see if they picked a move card 
    else if ((_gameModel.phase() == EnumPhase.move) && (type == EnumCardType.move)) {
      // next, make sure they can only pick a card that can be used by the american
      if (_gameModel.americanCanUseCard(id)) {
        setState(() {
          // show the card as selected
          _gameModel.toggleSelected(id);
          // since distance determined when a unit picked, anytime they pick a new card,
          // always reset the distance array 
          _distanceArray = _gameModel.resetDistances();
        });
      }
    }
    // finally, in attack phase
    else if ((_gameModel.phase() == EnumPhase.attack) && (type == EnumCardType.attack)) {
        if (_gameModel.americanCanUseCard(id)) {
          setState(() {
            // show the card as selected
            _gameModel.toggleSelected(id);
            // since distance determined when a unit picked, anytime they pick a new card,
            // always reset the distance array 
            _distanceArray = _gameModel.resetDistances();
        });         
      }
    }

    setState(() {
      // force a repaint
    });

  }

  // *********************************************
  // show all the current cards in the player's hand 
  // *********************************************
  Widget _showCards() {

    return SizedBox(
      height: 91, // controls vertical size of the scroll area
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: [
          //for (GameCard card in _gameModel.americanHand()) 
          for (int i = 0; i < _gameModel.americanHand().length; i++) 
            GestureDetector(
              onTap: () {
                _selectCard(_gameModel.americanHand()[i].id, _gameModel.americanHand()[i].type); 
              },
              onLongPress: () {
                _showCardInfo(_gameModel.americanHand()[i].name, _gameModel.americanHand()[i].graphic);
              },
              child: Stack(
                children: [
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.5, color: _getCardBorderColor(_gameModel.americanHand()[i]))
                    ),
                  child: SizedBox(
                    height: 91,
                    width: 80, 
                    child: Center(child: Image.asset(_gameModel.americanHand()[i].graphic, fit: BoxFit.fill,)))),
                Positioned(
                  top: -6,
                  left: -1, 
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  child: Text((i+1).toString(), style: TextStyle(fontFamily: 'RobotoMono', color: Colors.white, fontSize: 15),))
            ),
                Positioned(
                  top: 62,
                  left: 7, 
                  child: Text(_getCardUsageRestrictions(_gameModel.americanHand()[i]),
                    style: TextStyle(fontFamily: 'RobotoMono', color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),)
                ),
                Positioned(
                  top: 66,
                  left: 63, 
                  child: SizedBox(
                    height: 16,
                    width: 18, 
                    child: _getCardPlayerRestrictions(_gameModel.americanHand()[i]), 
                  )
                ),                
        ],
      ),
    )]));

  }

  // *********************************************
  // based on which phase it is,
  // set button text   
  // *********************************************
  Widget _showActionButton() {
    String s = "";

    // if orders phase, and american player  has three or more cards, show the Discard button,
    // otherwise, always  show Continue button
    s = constButtonContinue;
    if (_gameModel.phase() == EnumPhase.orders) {
      if ((_gameModel.getSelectedCardCount() > 0) || 
        (_gameModel.americanHand().length > constMaxCardsInHand)) {
        s = constButtonDiscard; 
      }
    }

      return 
        Column(
          children: [SizedBox(
          width: 160.0,
          height: 55.0,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black, // Text and icon color
              backgroundColor: Colors.white, // Background color
              side: BorderSide(color: Colors.black,   width: 3.0,), // Border color
            ),   
            child: Align(
                alignment: Alignment.center,
                child: Text(
                  s,
                  style: TextStyle(
                      fontFamily: constAppTextFont,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0),
                )),
          onPressed:  () {
              if (_overlayShowing) return; 
              _doAction();
            },                 
          ),
        )]);
  
  }

  // *********************************************
  // based on phase, execute next steps / action
  // *********************************************
  void _doAction() async {
    int moveCount = 0; 
    int attackCount = 0; 
    int tempKilled = 0; 
    int numKilled = 0; 
    String message = ""; 

    // if we're in orders phase, and there are selected cards, discard them
    if ((_gameModel.phase() == EnumPhase.orders) && (_gameModel.getSelectedCardCount() > 0)) {
      setState(() {
        _gameModel.discardSelectedCards();
      });
      return; 
    }

    // before we continue further, need to valdate the card count is down to three or less
    if ((_gameModel.phase() == EnumPhase.orders) && (_gameModel.americanHand().length > constMaxCardsInHand)) {
      // we're done, punch out 
      return; 
    }

    // advance the phase
    _gameModel.nextPhase();

    // overlay for the user 
    if (_gameModel.player() == EnumPlayer.american) {
      await _phaseOverlayMessage(_gameModel.phase());
    }

    // manually set phase if they skipped something
    if (_gameModel.player() == EnumPlayer.american) {
      if ((_gameModel.skipMovePhase()) && (_gameModel.skipAttackPhase())) {
        _gameModel.setPhase(EnumPhase.attack);
        _gameModel.nextPhase(); 
      }
      else if ((_gameModel.phase() == EnumPhase.move) && (_gameModel.skipMovePhase())) {
        _gameModel.setPhase(EnumPhase.attack);
      }
      else if  ((_gameModel.phase() == EnumPhase.attack) && (_gameModel.skipAttackPhase())) {
        _gameModel.setPhase(EnumPhase.attack);
        _gameModel.nextPhase(); 
      }
    }

    // if the german player has moves, get them so we can check for negation
    if (_gameModel.isGermanTurn()) {
      await _germanTurnPrepOverlayMessage(); 
      print("--- new german turn ---");
      // loop through each move
      for (GermanMove move in _gameModel.getGermanMoves()) {
        // check to see if player can negate
        if (_gameModel.canNegateAction(EnumPlayer.american, EnumCardNegate.move)) {
          // throw up dialog to ask 
          final negateAction = await showNegateDialog(context, EnumCardNegate.move);
          if (!negateAction) {
            // do the move
            _gameModel.moveUnit(move.unitId, move.destRow, move.destCol);
            moveCount++;
          } else { 
            _gameModel.discardNegateCard(EnumPlayer.american, EnumCardNegate.move);
          }  
        } else {
          // just do the move
          _gameModel.moveUnit(move.unitId, move.destRow, move.destCol);
          moveCount++;
        }
      }

      // loop through each move
      for (GermanAttack attack in _gameModel.getGermanAttacks()) {
        // check to see if player can negate
        if (_gameModel.canNegateAction(EnumPlayer.american, EnumCardNegate.attack)) {
          // throw up dialog to ask 
          final negateAction = await showNegateDialog(context, EnumCardNegate.attack);
          if (!negateAction) {
            // do the move
            tempKilled = _gameModel.attackUnit(attack.unitId, attack.attackRow, attack.attackCol, attack.cardName);
            numKilled += tempKilled; 
            attackCount++;
          } else { 
            _gameModel.discardNegateCard(EnumPlayer.american, EnumCardNegate.attack);
          }  
        } else {
          // just do the attack
          tempKilled = _gameModel.attackUnit(attack.unitId, attack.attackRow, attack.attackCol, attack.cardName);
          numKilled += tempKilled; 
          attackCount++;
        }
      }

      // let them know german turn ended  
      String moveTimes = "time";
      String attackTimes = "time";
      String killedUnits = _gameModel.displayListOfUnitsKilled();
      if (moveCount != 1) { moveTimes = "times"; }
      if (attackCount != 1) { attackTimes = "times"; }

      message = "The Germans successfully moved $moveCount $moveTimes and attacked $attackCount $attackTimes";
      if (numKilled > 0) {
        message += " (killing $killedUnits)";
      }
      else { 
        message += ".";
      }

      // recap what happened during German player phase
      await _germanTurnRecapOverlayMessage(message);

      // test for game over condition
      if (_gameModel.isGameOver(EnumPlayer.german)) {
        // go the game over dialog 
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GameOverScreen(won: false)),
        );
      }      

      // advance to next American orders phase 
      _gameModel.nextPhase();
      await _phaseOverlayMessage(_gameModel.phase());

    }

    setState(() {
      // force re-draw
    });

  }

  // *********************************************
  // create screen layout 
  // *********************************************
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
      backgroundColor: const Color.fromARGB(255, 129, 128, 108),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
        const Padding(padding: EdgeInsets.all(1.0),),
        const Text(appTitle,
                  style: TextStyle(fontFamily: constAppTitleFont, fontSize: 50)),
        const Padding(padding: EdgeInsets.all(0.0),),
        Center(
          child: RichText(
            textAlign: TextAlign.center, 
            text: TextSpan(
              children: [
                TextSpan(text: 'Round ',
                    style: TextStyle(fontFamily: constAppTextFont, fontSize: 20, color: Colors.black),              
                ),
                TextSpan(
                  text: _gameModel.displayRound(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontFamily: constAppTextFont, fontSize: 25, color: Colors.black),
                ),
                TextSpan(
                  text: ' - ',
                  style: TextStyle(fontFamily: constAppTextFont, fontSize: 20, color: Colors.black),
                ),                
                TextSpan(text: _gameModel.displayPhase(),
                    style: TextStyle(backgroundColor: getPhaseColor(), fontWeight: FontWeight.bold, fontFamily: constAppTextFont, fontSize: 25, color: Colors.black),              
                ),
                TextSpan(
                  text: ' Phase',
                  style: TextStyle(fontFamily: constAppTextFont, fontSize: 20, color: Colors.black),
                ),
            ],
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.all(5.0),),   
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(_showPhaseMessage(),
              style: TextStyle(fontFamily: constAppTextFont, fontSize: 20, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),  textAlign: TextAlign.center,))),
        const Padding(padding: EdgeInsets.all(5.0),),              
        HexagonOffsetGrid.oddFlat(
              color: const Color.fromARGB(255, 129, 128, 108),
              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
              columns: constMapCols,
              rows: constMapRows,
              buildTile: (col, row) => HexagonWidgetBuilder(
                        elevation: 5.0, // col.toDouble(),
                        padding: 1.0, // how close together hexes are
                        cornerRadius: null, // hex shape (vs rounded)
                        color: Colors.grey,
                        //child: Text("$row, $col"),
                        child: 
                          GestureDetector(
                            onTap: () { _handleTap(row, col); },
                          child: Stack( 
                          children: [
                            AspectRatio( // base image 
                          aspectRatio: HexagonType.FLAT.ratio,
                            child: Image.asset(
                            _gameModel.showTerrain(row, col),
                            fit: BoxFit.cover,
                        )),
                        _showUnits(row, col), // unit image
                        _showValidSpace(row, col), // valid space 
                        _showBorder(row, col), // border (top image) 
                        //Text("      $row, $col"), // for debugging  
                          ],
                        ),),
        )),
        const Padding(padding: EdgeInsets.all(5.0),),
        Text(constYourHandMessage,
          style: TextStyle(fontSize: 18, fontFamily: constAppTextFont, fontWeight: FontWeight.bold),  textAlign: TextAlign.center,),
        const Padding(padding: EdgeInsets.all(1.0),),
        _showCards(),
        const Padding(padding: EdgeInsets.all(3.0),),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
          _showActionButton(),
          SizedBox(
            width: 15.0,
            height: 5.0),
          Column(
            children: [SizedBox(
            width: 160.0,
            height: 55.0,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, // Text and icon color
                backgroundColor: Colors.white, // Background color
                side: BorderSide(color: Colors.black,   width: 3.0,), // Border color
              ),   
              child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    constButtonQuit,
                    style: TextStyle(
                        fontFamily: constAppTextFont,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0),
                  )),
                    onPressed: () { Navigator.pop(context); },                 
            ),
          )]),
        ],)
            ]
        ) 
      )) ;
  }
}
