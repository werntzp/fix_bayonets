import 'package:flutter/material.dart';
import 'const.dart';
import 'models/unit_model.dart';
import 'models/game_model.dart';
import 'models/card_model.dart';
import 'models/map_model.dart';

GameModel _gm = GameModel();
CardFactory _cf = CardFactory();
UnitFactory _uf = UnitFactory();
MapFactory _mf = MapFactory();
List<Unit> _units = [];
List<MapSquare> _map = [];
bool _showMapSquaresForMove = false;
bool _showMapSquaresForAttack = false;
bool _ableToCancelAction = false;

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
    _cf.discardCards();
    setState(() {
      // redraw interface
    });
  }

  void _toggleSelectedCard(int id) {
    bool multiselect = false;

    // get the card
    GameCard card = _cf.getCardById(id);

    // if they have more than 3 cards, player is able to multi-select
    if (_cf.playerHand().length > 3) {
      multiselect = true;
    }

    // if they are trying to pick a german card during move or attack phase, just bail
    if (card.player == enumPlayerUse.german) {
      // must be during orders phase
      if (_gm.getPhase() == enumPhase.orders) {
        _cf.toggleSelected(id, multiselect);
      }
    } else {
      _cf.toggleSelected(id, multiselect);
      _checkMove();
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

  Widget _nextButton() {
    return OutlinedButton(
        child: const Text(
          "Next",
          style: TextStyle(
              fontFamily: 'HeadlinerNo45', color: Colors.black, fontSize: 30.0),
        ),
        onPressed: () {
          _gm.advancePhase();
          _cf.clearSelectedCards();
          _uf.resetSelectedUnit();
          if (_gm.getPhase() == enumPhase.orders) {
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
          if (_gm.getPhase() == enumPhase.move) {
            _cf.clearSelectedCards();
            _uf.resetSelectedUnit();
            _ableToCancelAction = false;
            _showMapSquaresForMove = false;
          }
          setState(() {});
        });
  }

  Widget _cardRow() {
    // iterate through cards to display the ones in the player's hand ...
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      const SizedBox(
        height: 68,
        width: 5,
      ),
      for (int i = 0; i < _cf.playerHand().length; i++)
        GestureDetector(
          onTap: () {
            // only allow them to select in orders phase if player hand has more than 3
            if (((_cf.playerHand().length > 3) &&
                    (_gm.getPhase() == enumPhase.orders)) ||
                (_gm.getPhase() != enumPhase.orders))
              _toggleSelectedCard(_cf.playerHand()[i].id);
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _getCardBorderColor(_cf.playerHand()[i].id),
              //border: Border.all(width: 1),
            ),
            height: 68,
            width: 58,
            child: Image.asset(_cf.playerHand()[i].graphic),
          ),
        ),
    ]);
  }

  void _setSelectedMapSquare(int pos) {
    if (_mf.selectedSquare != pos) {
      _uf.resetSelectedUnit();
    }
    _mf.selectedSquare = pos;

    setState(() {});
  }

  Color _getUnitBorderColor(int mapSquare) {
    if (_mf.selectedSquare == mapSquare) {
      return Colors.yellow;
    } else {
      return const Color(0xff6b8e23);
    }
  }

  Color _getUnitHighlightColor(Unit unit) {
    if (_uf.getSelectedUnit() == unit) {
      return Colors.yellow;
    } else {
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

  Widget _displayText(String txt) {
    return Container(
        alignment: Alignment.center,
        child: Center(
            child: Text(txt,
                style: const TextStyle(
                    fontFamily: 'HeadlinerNo45', fontSize: 30))));
  }

  String _getMoveSquareGraphic(int pos) {
    String gfx = gfxMoveGreen;

    // check distance between starting square and this one
    int distance = _mf.getDistance(_mf.selectedSquare, pos);
    if (distance > _cf.getSelectedCard().maxrange) {
      gfx = gfxMoveRed;
    } else if (distance < _cf.getSelectedCard().maxrange) {
      // also make sure destination square doesn't contain enemy unit
      try {
        for (Unit u in _map[_mf.selectedSquare].units) {
          if (u.owner == enumUnitOwner.german) {
            gfx = gfxMoveRed;
            break;
          }
        }
      } catch (e) {
        gfx = gfxMoveGreen;
      }
    }

    return gfx;
  }

  Widget _drawMapSquaresForMove(int i, String img) {
    return Stack(
      children: <Widget>[
        Image.asset(img),
        if (_mf.selectedSquare != i)
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

  void _checkMove() {
    // if they have a unit selected, and if they have selected an appropriate move card, go!
    Unit unit = _uf.getSelectedUnit();
    if (unit.owner == enumUnitOwner.american) {
      // Unit unit = _units.firstWhere((element) => element.id == selected.id);
      try {
        GameCard card = _cf.getSelectedCard();
        // must be a move card, and unit must be able to move
        if ((card.type == enumCardType.move) &&
            (card.player != enumPlayerUse.german) &&
            (!unit.hasMoved)) {
          // show valid move options
          _showMapSquaresForMove = true;
          // set flag to show cancel button
          _ableToCancelAction = true;
          setState(() {});
        }
      } catch (e) {
        // do nothing, we're just done here for now
        print('error: ' + e.toString());
        return;
      }
    }
  }

  bool _enemyUnitsInMapSquare(int pos) {
    bool enemyUnits = false;

    MapSquare mapSquare = _map[pos];
    if (mapSquare.units.isNotEmpty) {
      for (Unit u in mapSquare.units) {
        if (u.owner == enumUnitOwner.german) {
          enemyUnits = true;
          break;
        }
      }
    }

    return enemyUnits;
  }

  void _tryMove(int pos) {
    // if they got here, there's a valid selected move card and the unit can move
    // check to see if square selected (a) if not the original selected square,
    // (b) distance is valid, and (c) square doesn't contain an enemy unit
    if ((pos != _mf.selectedSquare) &&
        (_mf.getDistance(_mf.selectedSquare, pos) <=
            _cf.getSelectedCard().maxrange) &&
        (!_enemyUnitsInMapSquare(pos))) {
      // move the unit to the spot
      Unit unit = _uf.getSelectedUnit();
      unit.hasMoved = true;
      _map[_mf.selectedSquare]
          .units
          .removeWhere((element) => element.id == unit.id);
      _map[pos].units.add(unit);

      // discard the selected card
      _cf.discardSelectedCard();

      // no longer in active move
      _showMapSquaresForMove = false;
      _ableToCancelAction = false;
      _uf.resetSelectedUnit();

      setState(() {});
    }
  }

  void _setSelectedUnit(Unit unit) {
    // if not player unit, just bail
    if (unit.owner == enumUnitOwner.american) {
      _uf.setSelectedUnit(unit);
      _checkMove();
    }
    setState(() {});
  }

  Widget _unitRow() {
    // for each unit in the map square, return an image of it
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 45,
          width: 10,
        ),
        if (_mf.selectedSquare != noCardSelected)
          for (var u in _map[_mf.selectedSquare].units)
            GestureDetector(
                onTap: () {
                  _setSelectedUnit(u);
                },
                child: Container(
                    decoration: BoxDecoration(
                      color: _getUnitHighlightColor(u),
                    ),
                    height: 50,
                    width: 50,
                    child: Image.asset(_uf.returnUnitImage(u)))),
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
            // _setSelectedMapSquare(index);
          },
          // child: _drawMapSquaresForMove(index),
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
              index, _mf.getMapSquareGraphic(_uf, _map[index])),
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
          child: _drawUnitContainer(
              index, _mf.getMapSquareGraphic(_uf, _map[index])),
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
                    _displayText('Round: ' + _gm.displayRound()),
                    _displayText('Phase: ' + _gm.displayPhase()),
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
              if ((_mf.selectedSquare != noCardSelected) &&
                  (_map[_mf.selectedSquare].units.length > 1))
                _unitRow()
              else
                const SizedBox(
                  height: 45,
                  width: 10,
                ),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Cards in your hand:",
                      style: TextStyle(
                          fontFamily: "HeaderlinerNo45",
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                    )),
              ),
              _cardRow(),
              const Padding(padding: EdgeInsets.all(5.0)),
              if (_gm.getPhase() == enumPhase.orders)
                _phaseNotice(ordersNotice)
              else if (_gm.getPhase() == enumPhase.move)
                _phaseNotice(moveNotice)
              else
                _phaseNotice(attackNotice),
              const Padding(padding: EdgeInsets.all(10.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  _helpButton(),
                  if (_cf.playerHand().length > 3)
                    _discardButton()
                  else if (_ableToCancelAction)
                    _cancelButton()
                  else
                    _nextButton()
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
