import 'dart:math';
import 'package:fix_bayonets/dialogs/game_over_dialog.dart';
import 'package:fix_bayonets/dialogs/unit_killed_dialog.dart';
import 'package:fix_bayonets/dialogs/unit_killed_all_dialog.dart';
import 'package:fix_bayonets/dialogs/german_negated_dialog.dart';
import 'package:fix_bayonets/dialogs/ask_to_negate_dialog.dart';
import 'package:fix_bayonets/dialogs/card_info_dialog.dart';
import 'package:fix_bayonets/models/german_player_model.dart';
import 'package:flutter/material.dart';
import '../const.dart';
import '../models/unit_model.dart';
import '../models/game_model.dart';
import '../models/card_model.dart';
import '../models/map_model.dart';

GameModel _gm = GameModel();
CardFactory _cf = CardFactory();
UnitFactory _uf = UnitFactory();
MapFactory _mf = MapFactory();
GermanPlayer _gp = GermanPlayer();
List<Unit> _units = [];
List<MapSquare> _map = [];
bool _showMapSquaresForMove = false;
bool _showMapSquaresForAttack = false;
bool _ableToCancelAction = false;
bool _negateAction = false;
List<int> _moveOptions = List<int>.filled(64, constInvalidSpace);
List<int> _attackOptions = List<int>.filled(64, constInvalidSpace);

// main class
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

  void _newGame() async {
    _gm.newGame();
    _cf.prepareInitialDeck();
    _cf.drawCards();
    _units = _uf.prepareUnits();
    _map = _mf.prepareMap(_units);
  }

  void _discardCards() {
    _cf.discardCards(EnumPlayer.american);
    setState(() {});
  }

  void _resetUnitFlags() {
    // for any units on the map, reset their move/attack flags
    for (MapSquare ms in _map) {
      for (Unit u in ms.units) {
        u.hasAttacked = false;
        u.hasMoved = false;
        u.numTimesMoved = 0;
      }
    }
  }

  Unit _getSelectedUnit() {
    for (MapSquare mapSquare in _map) {
      if (mapSquare.units.isNotEmpty) {
        for (Unit unit in mapSquare.units) {
          if (unit.isSelected) {
            return unit;
          }
        }
      }
    }
    // if we got here, no map square is selected so throw an error to be handled
    throw Exception('No unit selected');
  }

  int _getMapSquarePosition(MapSquare mapSquare) {
    for (int i = 0; i < _map.length; i++) {
      if (_map[i] == mapSquare) {
        return i;
      }
    }
    throw Exception('No map square found');
  }

  MapSquare _getSelectedSquare() {
    for (MapSquare mapSquare in _map) {
      if (mapSquare.isSelected) {
        return mapSquare;
      }
    }
    // if we got here, no map square is selected so throw an error to be handled
    throw Exception('No map square selected');
  }

  void _toggleSelectedCard(int id) {
    bool multiselect = false;

    // get the card
    GameCard card = _cf.getCardById(id);

    // if they have more than 3 cards, player is able to multi-select
    if (_gm.phase == EnumPhase.orders) {
      multiselect = true;
    }

    // if they are trying to pick a german card during move or attack phase, just bail
    if (card.player == EnumPlayerUse.german) {
      // must be during orders phase
      if (_gm.phase == EnumPhase.orders) {
        _cf.toggleSelected(id, multiselect);
      } else {
        print(
            '_toggleSelectedCard() - tried to pick german card outside orders');
      }
      // they selected an american card
    } else {
      // make sure they are selecting card based on phase
      if ((_gm.phase == EnumPhase.move) && (card.type == EnumCardType.move)) {
        _cf.toggleSelected(id, multiselect);
        _checkMove();
      } else if ((_gm.phase == EnumPhase.attack) &&
          (card.type == EnumCardType.attack)) {
        _cf.toggleSelected(id, multiselect);
        _checkAttack();
      } else if (_gm.phase == EnumPhase.orders) {
        _cf.toggleSelected(id, multiselect);
      } else {
        print('_toggleSelectedCard() - card not allowed for this situation');
      }
    }

    setState(() {});
  }

  Widget _discardButton() {
    return OutlinedButton(
        child: const Text(
          "Discard",
          style: TextStyle(
              fontFamily: 'HeadlinerNo45', color: Colors.black, fontSize: 30.0),
        ),
        onPressed: () {
          _discardCards();
        });
  }

  Widget _helpButton() {
    return OutlinedButton(
        child: const Text(
          "Help",
          style: TextStyle(
              fontFamily: 'HeadlinerNo45', color: Colors.black, fontSize: 30.0),
        ),
        onPressed: () {
          // TODO: bring up help screen
        });
  }

  bool _playerCanNegate(EnumCardNegate negate) {
    bool canNegate = false;

    for (GameCard card in _cf.americanHand()) {
      if ((card.type == EnumCardType.negate) && (card.negate == negate)) {
        canNegate = true;
        break;
      }
    }

    return canNegate;
  }

  void _resetSelectedSquare() {
    for (MapSquare mapSquare in _map) {
      mapSquare.isSelected = false;
    }
  }

  void _resetSelectedUnit() {
    for (Unit unit in _units) {
      unit.isSelected = false;
    }
  }

  Widget _nextButton() {
    return OutlinedButton(
        child: const Text(
          "Next",
          style: TextStyle(
              fontFamily: 'HeadlinerNo45', color: Colors.black, fontSize: 30.0),
        ),
        onPressed: () {
          _gm.incrementPhase();
          setState(() {
            // redraw interface
          });
          _cf.clearSelectedCards();
          _resetSelectedUnit();
          _resetSelectedSquare();
          // if it is an orders phase (regardless of player), reset all the move/attack flags
          if (_gm.phase == EnumPhase.orders) {
            _resetUnitFlags();
          }

          // if now the german turn, do different stuff
          if (_gm.player == EnumPlayer.german) {
            // orders phase
            _gp.doOrdersPhase(context, _cf);

            // move phase
            List<GermanMove> moves = _gp.doMovePhase(context, _cf, _mf, _map);

            if (moves.isNotEmpty) {
              // go through each one
              for (GermanMove move in moves) {
                if (_playerCanNegate(EnumCardNegate.move)) {
                  showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Negate the German move?'),
                      content:
                          const Text('Do you want to negate the German move?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Yes'),
                        ),
                        TextButton(
                          onPressed: () {
                            _map[move.end].units.add(move.unit);
                            _map[move.begin].units.remove(move.unit);
                            Navigator.pop(context, false);
                          },
                          child: const Text('No'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // no negate cards
                  _map[move.end].units.add(move.unit);
                  _map[move.begin].units.remove(move.unit);
                }
              }
            }

            // attack phase
            List<GermanAttack> attacks =
                _gp.doAttackPhase(context, _cf, _mf, _map);
            if (attacks.isNotEmpty) {
              // go through each one
              for (GermanAttack attack in attacks) {
                if (_playerCanNegate(EnumCardNegate.attack)) {
                  showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Negate the German attack?'),
                      content: const Text(
                          'Do you want to negate the German attack?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Yes'),
                        ),
                        TextButton(
                          onPressed: () {
                            // loop through to find where the unit is on the map
                            for (int i = 0; i < _map.length; i++) {
                              if (_map[i].units.isNotEmpty) {
                                if (_map[i].units.contains(attack.targetUnit)) {
                                  // unit is in that map square; depending on the weapon used,
                                  // it may kill all units in there
                                  if ((attack.gameCard.name ==
                                          EnumCardName.grenade) ||
                                      (attack.gameCard.name ==
                                          EnumCardName.flamethrower) ||
                                      (attack.gameCard.name ==
                                          EnumCardName.machinegun)) {
                                    _map[i].units.clear();
                                  } else {
                                    _map[i].units.remove(attack.targetUnit);
                                  }
                                }
                              }
                            }
                            Navigator.pop(context, false);
                          },
                          // TODO: set the selected unit so it attacked
                          child: const Text('No'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // loop through to find where the unit is on the map
                  for (int i = 0; i < _map.length; i++) {
                    if (_map[i].units.isNotEmpty) {
                      if (_map[i].units.contains(attack.targetUnit)) {
                        // unit is in that map square; depending on the weapon used,
                        // it may kill all units in there
                        if ((attack.gameCard.name == EnumCardName.grenade) ||
                            (attack.gameCard.name ==
                                EnumCardName.flamethrower) ||
                            (attack.gameCard.name == EnumCardName.machinegun)) {
                          _map[i].units.clear();
                        } else {
                          _map[i].units.remove(attack.targetUnit);
                        }
                      }
                    }
                  }
                  // TODO: set the selected unit so it attacked
                }
              }
            }

            // TODO: is the game over? are both officers dead?

            _gm.jump();
          }

          // draw up cards for both if orders phase
          if (_gm.phase == EnumPhase.orders) {
            _cf.drawCards();
          }

          setState(() {
            // redraw interface
          });
        });
  }

  Widget _cancelButton() {
    return OutlinedButton(
        child: const Text(
          "Cancel",
          style: TextStyle(
              fontFamily: 'HeadlinerNo45', color: Colors.black, fontSize: 30.0),
        ),
        onPressed: () {
          // cancel move or attack (depending on phase)
          if ((_gm.phase == EnumPhase.move) ||
              (_gm.phase == EnumPhase.attack)) {
            _cf.clearSelectedCards();
            _resetSelectedUnit();
            _ableToCancelAction = false;
            _showMapSquaresForMove = false;
            _showMapSquaresForAttack = false;
          }
          setState(() {});
        });
  }

  Widget _cardRow() {
    // iterate through cards to display the ones in the player's hand ...
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      const SizedBox(
        height: 60.0,
        width: 5.0,
      ),
      for (int i = 0; i < _cf.americanHand().length; i++)
        GestureDetector(
          onTap: () {
            _toggleSelectedCard(_cf.americanHand()[i].id);
          },
          onLongPress: () {
            showCardInfoDialog(
                context, _cf.getCardNameById(_cf.americanHand()[i].id));
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _getCardBorderColor(_cf.americanHand()[i].id),
              //border: Border.all(width: 1),
            ),
            height: 68,
            width: 58,
            child: Image.asset(_cf.americanHand()[i].graphic),
          ),
        ),
    ]);
  }

  void _setSelectedMapSquare(int pos) {
    // clear any other selections
    _resetSelectedSquare();
    _resetSelectedUnit();

    // set the new selected square
    _map[pos].isSelected = true;

    // if there's a single unit in the square, go ahead and select it
    if ((_map[pos].units.isNotEmpty) && (_map[pos].units.length == 1)) {
      _setSelectedUnit(_map[pos].units.first);
    }

    setState(() {});
  }

  Color _getUnitBorderColor(int pos) {
    if (_map[pos].isSelected) {
      return Colors.yellow;
    } else {
      return const Color(0xff6b8e23);
    }
  }

  Color _getUnitHighlightColor(Unit unit) {
    try {
      if (_getSelectedUnit() == unit) {
        return Colors.yellow;
      } else {
        return const Color(0xffd3d3d3);
      }
    } catch (e) {
      return const Color(0xffd3d3d3);
    }
  }

  Color _getCardBorderColor(int cardID) {
    try {
      if (_cf.isCardSelected(cardID)) {
        return Colors.yellow;
      } else {
        return const Color(0xffd3d3d3);
      }
    } catch (e) {
      return const Color(0xffd3d3d3);
    }
  }

  Widget _displayPlayer(String img) {
    return Container(
        alignment: Alignment.center,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text('Player:',
                  style: TextStyle(fontFamily: 'HeadlinerNo45', fontSize: 30)),
              const Padding(padding: EdgeInsets.all(2.0)),
              Align(alignment: Alignment.topCenter, child: Image.asset(img)),
            ]));
  }

  Widget _labelOrders() {
    return Container(
        color: Colors.white,
        alignment: Alignment.center,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          const SizedBox(width: 5),
          Text(_gm.phase.name.toUpperCase(),
              style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'HeadlinerNo45',
                  fontSize: 30)),
          const SizedBox(width: 5),
        ]));
  }

  Widget _labelMove() {
    return Container(
        color: Colors.green,
        alignment: Alignment.center,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          const SizedBox(width: 5),
          Text(_gm.phase.name.toUpperCase(),
              style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'HeadlinerNo45',
                  fontSize: 30)),
          const SizedBox(width: 5),
        ]));
  }

  Widget _labelAttack() {
    return Container(
        color: Colors.red,
        alignment: Alignment.center,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          const SizedBox(width: 5),
          Text(_gm.phase.name.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'HeadlinerNo45',
                  fontSize: 30)),
          const SizedBox(width: 5),
        ]));
  }

  Widget _displayPhase() {
    if (_gm.phase == EnumPhase.orders) {
      return _labelOrders();
    } else if (_gm.phase == EnumPhase.move) {
      return _labelMove();
    } else {
      return _labelAttack();
    }
  }

  Widget _displayText(String txt) {
    return Container(
        alignment: Alignment.center,
        child: Center(
            child: Text(txt,
                style: const TextStyle(
                    fontFamily: 'HeadlinerNo45', fontSize: 30))));
  }

  String _getAttackSquareGraphic(int pos) {
    String graphic = gfxMoveRed;

    // green - if move is in range and there's an enemy unit in the target spot
    if ((_attackOptions[pos] == constValidSpace) &&
        (_enemyUnitsInMapSquare(pos))) {
      graphic = gfxMoveGreen;
    }

    return graphic;
  }

  String _getMoveSquareGraphic(int pos) {
    String graphic = gfxMoveRed;

    // green - if move is in range and no enemy unit in the target spot
    if ((_moveOptions[pos] == constValidSpace) &&
        (!_enemyUnitsInMapSquare(pos))) {
      graphic = gfxMoveGreen;
    }

    return graphic;
  }

  bool _isThereASelectedSquare() {
    try {
      MapSquare mapSquare = _getSelectedSquare();
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _drawMapSquaresForAttack(int i, String image) {
    return Stack(
      children: <Widget>[
        Image.asset(image),
        if (_isThereASelectedSquare())
          Opacity(opacity: .60, child: Image.asset(_getAttackSquareGraphic(i)))
      ],
    );
  }

  Widget _drawMapSquaresForMove(int i, String image) {
    return Stack(
      children: <Widget>[
        Image.asset(image),
        if (_isThereASelectedSquare())
          Opacity(opacity: .60, child: Image.asset(_getMoveSquareGraphic(i)))
      ],
    );
  }

  Widget _drawUnitContainer(int i, String img) {
    return Container(
        decoration: BoxDecoration(
          color: _getUnitBorderColor(i),
          border: Border.all(
            width: 1,
          ),
        ),
        child: Center(child: Image.asset(img)));
  }

  Widget _phaseNotice(String txt) {
    // they have too many cards, so need to discard some before proceeding
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Flexible(
          child: Text(txt),
        ),
      ],
    );
  }

  void _checkAttack() {
    // if they have a unit selected, and if they have selected an appropriate attack card, go!
    try {
      Unit unit = _getSelectedUnit();
      if (unit.owner == EnumUnitOwner.american) {
        GameCard card = _cf.getSelectedCard();
        // must be an attack card, and unit must be able to attack
        if ((card.type == EnumCardType.attack) &&
            (card.player != EnumPlayerUse.german) &&
            (!unit.hasAttacked)) {
          // we got this far, let's see if there are other attack restrictions
          if ((card.useby != unit.type) && (card.useby != EnumUnitType.all)) {
            _cf.clearSelectedCards();
            setState(() {});
            return;
          }

          // show valid move options
          _showMapSquaresForAttack = true;
          // set flag to show cancel button
          _ableToCancelAction = true;
          // go get the array of valid move spaces (based on the unit selected)
          _attackOptions = _mf.getValidMoves(
              _getMapSquarePosition(_getSelectedSquare()),
              card.minrange,
              card.maxrange);
          setState(() {});
        }
      }
    } catch (e) {
      // do nothing, we're just done here for now
      print('_checkAttack() error: ' + e.toString());
      setState(() {});
      return;
    }
  }

  void _checkMove() {
    // if they have a unit selected, and if they have selected an appropriate move card, go!
    try {
      Unit unit = _getSelectedUnit();
      if (unit.owner == EnumUnitOwner.american) {
        GameCard card = _cf.getSelectedCard();
        // must be a move card, and unit must be able to move
        if ((card.type == EnumCardType.move) &&
            (card.player != EnumPlayerUse.german) &&
            (!unit.hasMoved)) {
          // show valid move options
          _showMapSquaresForMove = true;
          // set flag to show cancel button
          _ableToCancelAction = true;
          // go get the array of valid move spaces (based on the unit selected)
          _moveOptions = _mf.getValidMoves(
              _getMapSquarePosition(_getSelectedSquare()),
              card.minrange,
              card.maxrange);
          setState(() {});
        }
      }
    } catch (e) {
      // do nothing, we're just done here for now
      print('_checkMove() error: ' + e.toString());
      setState(() {});
      return;
    }
  }

  bool _isGameOver() {
    // loop through all the german units to see if both officer units still exist
    int officerCount = 0;
    for (int i = 0; i < _map.length; i++) {
      if (_map[i].units.isNotEmpty) {
        for (Unit unit in _map[i].units) {
          if ((unit.owner == EnumUnitOwner.german) &&
              (unit.type == EnumUnitType.officer)) {
            officerCount++;
          }
        }
      }
    }

    // if 0, game over, otherwise keep going
    return officerCount == 0 ? true : false;
  }

  bool _enemyUnitsInMapSquare(int pos) {
    bool enemyUnits = false;

    MapSquare mapSquare = _map[pos];
    if (mapSquare.units.isNotEmpty) {
      for (Unit u in mapSquare.units) {
        if (u.owner == EnumUnitOwner.german) {
          enemyUnits = true;
          break;
        }
      }
    }

    return enemyUnits;
  }

  bool _germanNegates(EnumCardNegate cardNegate) {
    return _cf.germanCanNegate(cardNegate);
  }

  void _tryAttack(int pos) {
    // check to see if square selected (a) if not the original selected square,
    // (b) spot they chose is valid, and (c) square contains an enemy unit
    if ((pos != _getMapSquarePosition(_getSelectedSquare())) &&
        (_attackOptions[pos] == constValidSpace) &&
        (_enemyUnitsInMapSquare(pos))) {
      // so yes an attack can occur, but check first to see if german player negates it
      if (!_germanNegates(EnumCardNegate.attack)) {
        // if attack was with grenade, machine gun, or flame thrower, kill every unit
        // otherwise,
        // if there's only one unit in the spot, eliminate it
        GameCard gameCard = _cf.getSelectedCard();
        if ((gameCard.name == EnumCardName.grenade) ||
            (gameCard.name == EnumCardName.flamethrower) ||
            (gameCard.name == EnumCardName.machinegun)) {
          // every unit in square dies
          _map[pos].units.clear();
          if (_isGameOver()) showUnitKilledAllDialog(context);
        } else {
          Unit unit;
          int unitCount = _map[pos].units.length;

          if (unitCount == 1) {
            unit = _map[pos].units.first;
          } else {
            // pick a unit at random to kill
            int unitToKill = Random().nextInt(unitCount);
            unit = _map[pos].units.elementAt(unitToKill);
          }
          // remove the destroyed unit from the map square
          _map[pos].units.remove(unit);

          // throw up dialog with unit info (unless end of game conditions were met)
          if (_isGameOver()) showUnitKilledDialog(context, unit.type, unit.id);
        }
      } else {
        // german negated
        showNegatedDialog(context, _gm.phase);
      }

      // the unit that just attacked, cannot attack again
      _map[_getMapSquarePosition(_getSelectedSquare())]
          .units
          .firstWhere((element) => element.id == _getSelectedUnit().id)
          .hasAttacked = true;

      // check to see if game end conditions have been met
      if (_isGameOver()) {
        showGameOverDialog(context, true);
      }

      // discard the selected card
      _cf.discardSelectedCard();

      // no longer in active attack
      _showMapSquaresForAttack = false;
      _ableToCancelAction = false;
      _resetSelectedUnit();
      _resetSelectedSquare();

      setState(() {});
    }
  }

  void _tryMove(int pos) {
    // check to see if square selected (a) if not the original selected square,
    // (b) spot they chose is valid, and (c) square doesn't contain an enemy unit
    if ((pos != _getMapSquarePosition(_getSelectedSquare())) &&
        (_moveOptions[pos] == constValidSpace) &&
        (!_enemyUnitsInMapSquare(pos))) {
      Unit unit = _getSelectedUnit();
      // before actually making the move, decide if the german player can negate it
      if (!_germanNegates(EnumCardNegate.move)) {
        // move the unit to the new square
        _map[_getMapSquarePosition(_getSelectedSquare())]
            .units
            .removeWhere((element) => element.id == unit.id);
        _map[pos].units.add(unit);
      } else {
        showNegatedDialog(context, _gm.phase);
      }

      // no longer in active move
      _showMapSquaresForMove = false;
      _ableToCancelAction = false;
      _resetSelectedUnit();
      _resetSelectedSquare();
      // discard
      _cf.discardSelectedCard();
      // move the unit to the spot
      unit.numTimesMoved++;
      // if runner unit, then don't set hasMoved until times == 2
      if ((unit.type == EnumUnitType.runner) && (unit.numTimesMoved == 2)) {
        unit.hasMoved = true;
      } else if (unit.type != EnumUnitType.runner) {
        unit.hasMoved = true;
      }

      setState(() {});
    }
  }

  void _setSelectedUnit(Unit selectedUnit) {
    // if not player unit, just bail
    if (selectedUnit.owner == EnumUnitOwner.american) {
      for (int i = 0; i < _map.length; i++) {
        if (_map[i].units.isNotEmpty) {
          for (Unit unit in _map[i].units) {
            if (unit == selectedUnit) {
              _map[i]
                  .units
                  .firstWhere((element) => element.id == selectedUnit.id)
                  .isSelected = true;
              break;
            }
          }
        }
      }
      if (_gm.phase == EnumPhase.move) {
        _checkMove();
      } else if (_gm.phase == EnumPhase.attack) {
        _checkAttack();
      }
      setState(() {});
    }
  }

  bool _unitsToShow() {
    // check if there is more than one unit in the map square
    bool showUnits = false;

    try {
      // is there at least one unit in the square?
      if (_map[_getMapSquarePosition(_getSelectedSquare())].units.length > 1) {
        // if yes, make sure it isn't a german unit
        if (_map[_getMapSquarePosition(_getSelectedSquare())]
                .units
                .first
                .owner ==
            EnumUnitOwner.american) {
          showUnits = true;
        }
      }
    } catch (e) {
      // do nothing
    }

    return showUnits;
  }

  Widget _unitRow() {
    // for each unit in the map square, return an image of it
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 50, width: 5),
        if (_unitsToShow())
          for (var u in _map[_getMapSquarePosition(_getSelectedSquare())].units)
            GestureDetector(
                onTap: () {
                  if (_gm.phase != EnumPhase.orders) _setSelectedUnit(u);
                },
                child: Container(
                    decoration: BoxDecoration(
                      color: _getUnitHighlightColor(u),
                    ),
                    height: 50,
                    width: 50,
                    child: Image.asset(_uf.getUnitImage(u)))),
      ],
    );
  }

  Widget _whichGrid() {
    if (_showMapSquaresForMove) {
      return _gridViewMove();
    } else if (_showMapSquaresForAttack) {
      return _gridViewAttack();
    } else {
      return _gridViewMap();
    }
  }

  Widget _gridViewAttack() {
    return GridView.count(
      crossAxisCount: 8,
      children: List.generate(64, (index) {
        return GestureDetector(
          onTap: () {
            _tryAttack(index);
          },
          child: _drawMapSquaresForAttack(
              index, _mf.getMapSquareGraphic(_map[index])),
        );
      }),
    );
  }

  Widget _gridViewMove() {
    return GridView.count(
      crossAxisCount: 8,
      children: List.generate(64, (index) {
        return GestureDetector(
          onTap: () {
            _tryMove(index);
          },
          child: _drawMapSquaresForMove(
              index, _mf.getMapSquareGraphic(_map[index])),
        );
      }),
    );
  }

  Widget _gridViewMap() {
    return GridView.count(
      crossAxisCount: 8,
      children: List.generate(64, (index) {
        return GestureDetector(
          onTap: () {
            _setSelectedMapSquare(index);
          },
          child:
              _drawUnitContainer(index, _mf.getMapSquareGraphic(_map[index])),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffd3d3d3),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(10.0),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _displayPlayer(_gm.displayPlayer()),
                    _displayText('Round: ' + _gm.round.toString()),
                    const Text("Phase: ",
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'HeadlinerNo45',
                            fontSize: 30)),
                    _displayPhase(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                    ),
                  ),
                  height: 370.0,
                  child: _whichGrid(),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(1.0),
              ),
              _unitRow(),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      constYourHand,
                      style: TextStyle(
                          fontFamily: "HeaderlinerNo45",
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                    )),
              ),
              _cardRow(),
              const Padding(padding: EdgeInsets.all(5.0)),
              if (_gm.phase == EnumPhase.orders)
                _phaseNotice(ordersNotice)
              else if (_gm.phase == EnumPhase.move)
                _phaseNotice(moveNotice)
              else
                _phaseNotice(attackNotice),
              const Padding(padding: EdgeInsets.all(10.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  if ((_cf.cardsSelected()) && (_gm.phase == EnumPhase.orders))
                    _discardButton()
                  else if (_ableToCancelAction)
                    _cancelButton()
                  else
                    _nextButton(),
                  const SizedBox(width: 5.0, height: 10.0),
                  _helpButton()
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
