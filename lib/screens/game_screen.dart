import 'package:flutter/material.dart';
import 'dart:math';
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
  Color _phaseColor = Colors.white; 

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    _newGame();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // *********************************************
  // init map and all elements 
  // *********************************************
  void _newGame() async {
    _gameModel.newGame();
    _phaseColor = Colors.white; 
  }

  // *********************************************
  // helper function for all snack
  // bar messages 
  // *********************************************
  void _displaySnackBar(String message, int duration)  {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: duration),),
    );  
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
                  _displaySnackBar("The Germans negated your move!", 1);
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
                  String unitName = _gameModel.displayUnitName(u.type);
                  _displaySnackBar("$unitName moved successfully.", 1);
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
                if (Random().nextBool()) {
                  // german decided to block the move! 
                  _displaySnackBar("The Germans negated your attack!", 1);
                  // also, increment the move, even if it didn't 
                  _gameModel.updateUnitStatus(u.id, EnumPhase.attack);
                  // discard their card
                  _gameModel.discardNegateCard(EnumPlayer.german, EnumCardNegate.attack);
                  // set flag
                  okToProceed = false; 
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
                  String killed = numKilled.toString();
                  String killedMessage = "";
                  String cardName = card.name.name;
                  if (numKilled == 1) {
                    killedMessage = "$unitName killed one German unit in that hex with $cardName.";
                  }
                  else {
                    killedMessage = "$unitName killed $killed units in that hex with $cardName."; 
                  }
                  _displaySnackBar(killedMessage, 1);
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
              print('User selected: unit $id');
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
  // _showUnits: return unit graphics to be stacked on
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
  // _showValidSpace: if this is move/attack phase, and they've
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
  // _showBorder: decide whether to show a border
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
  // _showPhaseMessage: based on which phase it is,
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
  // _getCardBorderColor: show all the current cards in
  // the player's hand  
  // *********************************************
  Color _getCardBorderColor(GameCard card) {
    Color c = Colors.black; 

    c = (card.selected) ?  Colors.yellow : Colors.black; 
    return c; 

  }

  // *********************************************
  // _showCardInfo: pop up with more card details   
  // *********************************************
  void _showCardInfo(EnumCardName cardName, String graphic) {
    showCardInfoDialog(context, cardName, graphic);

  }

  // *********************************************
  // _selectCard: mark this card as selected   
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
  // show all the current cards in
  // the player's hand  
  // *********************************************
  Widget _showCards() {

    return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      SizedBox(width: 5,),
      Text(constYourHandMessage,
        style: TextStyle(fontSize: 18 , fontFamily: constAppTextFont),  textAlign: TextAlign.center,),
      SizedBox(width: 1, height: 85,),
      for (GameCard card in _gameModel.americanHand())
        GestureDetector(
          onTap: () {
            _selectCard(card.id, card.type); 
          },
          onLongPress: () {
            _showCardInfo(card.name, card.graphic);
          },
          child: Padding(
            padding: EdgeInsets.all(2.0),
            child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(border: Border.all(color: _getCardBorderColor(card), width: 1)),
            height: 80,
            width: 54,
            child: Image.asset(card.graphic, fit: BoxFit.fill,),
          ),
        ),
        ),

    ]);
  }

  // *********************************************
  // _showActionButton: based on which phase it is,
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
          width: 125.0,
          height: 45.0,
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
                      fontFamily: constAppTitleFont,
                      color: Colors.black,
                      fontSize: 20.0),
                )),
                  onPressed: () {
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
    // if the german player has moves, get them so we can check for negation
    if (_gameModel.isGermanTurn()) {
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

      // test for game over condition
      if (_gameModel.isGameOver(EnumPlayer.german)) {
        // go the game over dialog 
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GameOverScreen(won: false)),
        );
      }      

      // let them know german turn ended  
      message = "The Germans have completed all moves and attacks. They successfully moved $moveCount times and attacked $attackCount times";
      if (numKilled > 0) {
        message += " (killing $numKilled units).";
      }
      else { 
        message += ".";
      }
      _displaySnackBar(message, 3);

      // advance to next phase
      _gameModel.nextPhase();

    }

    setState(() {
      if (_gameModel.phase() == EnumPhase.orders) {
        _phaseColor = Colors.white;
      }
      else if (_gameModel.phase() == EnumPhase.move) {
        _phaseColor = Colors.green;
      }
      else {
        _phaseColor = Colors.red; 
      }

      String displayPhase = _gameModel.displayPhase();  
      _displaySnackBar("Starting $displayPhase phase.", 1);
    
    });


  }

  // *********************************************
  // build: create screen layout 
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
            text: TextSpan(
              children: [
                TextSpan(text: _gameModel.displayPlayer(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontFamily: constAppTextFont, fontSize: 25, color: Colors.black),              
                ),
                TextSpan(
                  text: ' player',
                  style: TextStyle(fontFamily: constAppTextFont, fontSize: 20, color: Colors.black),
                ),
            ],
            ),
          ),
        ), 
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
                    style: TextStyle(backgroundColor: _phaseColor, fontWeight: FontWeight.bold, fontFamily: constAppTextFont, fontSize: 25, color: Colors.black),              
                ),
                TextSpan(
                  text: ' Phase',
                  style: TextStyle(fontFamily: constAppTextFont, fontSize: 20, color: Colors.black),
                ),
            ],
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(_showPhaseMessage(),
              style: TextStyle(fontFamily: constAppTextFont, fontSize: 20, fontStyle: FontStyle.italic),  textAlign: TextAlign.center,))),
        const Padding(padding: EdgeInsets.all(1.0),),              
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
                        Text("      $row, $col"), // for debugging  
                          ],
                        ),),
        )),
        const Padding(padding: EdgeInsets.all(3.0),),
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
            width: 125.0,
            height: 45.0,
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
                        fontFamily: constAppTitleFont,
                        color: Colors.black,
                        fontSize: 20.0),
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
