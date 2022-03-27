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
    if (_cf.playerHand().length > 3) {
      multiselect = true;
    }

    _cf.toggleSelected(id, multiselect);

    setState(() {});
    _checkMove();
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
          if (_gm.getPhase() == enumPhase.orders) {
            _cf.drawCards();
          }
          setState(() {
            // redraw interface
          });
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
    if (_cf.isCardSelected(cardID)) {
      return Colors.yellow;
    } else {
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
    // if they have a unit selected, and if
  }

  void _setSelectedUnit(Unit unit) {
    _uf.setSelectedUnit(unit);
    _checkMove();

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
        if (_mf.selectedSquare != -1)
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
                  child: GridView.count(
                    crossAxisCount: 8,
                    children: List.generate(64, (index) {
                      return GestureDetector(
                        onTap: () {
                          _setSelectedMapSquare(index);
                        },
                        child: _drawUnitContainer(index, _map[index].terrain),
                      );
                    }),
                  ),
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
                  if (_cf.playerHand().length > 3)
                    _discardButton()
                  else
                    _nextButton(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
