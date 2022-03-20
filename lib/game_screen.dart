import 'package:flutter/material.dart';
import 'const.dart';
import 'models/unit.dart';
import 'models/card.dart';
import 'models/map.dart';
import 'models/game.dart';

GameModel _gm = GameModel();
GameCardFactory _cf = GameCardFactory();
UnitFactory _uf = UnitFactory();
MapFactory _mf = MapFactory();
List<Unit> _units = [];
List<MapSquare> _map = [];
List<GameCard> _drawPile = [];
List<GameCard> _playerHand = [];
List<GameCard> _computerHand = [];
List<GameCard> _discardPile = [];
bool _mustDiscard = false;

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
    _drawPile = _cf.prepareDeck();
    _units = _uf.prepareUnits();
    _map = _mf.prepareMap(_units);

    // draw 3 cards for american and german
    _playerHand.add(_drawPile[0]);
    _drawPile.remove(_drawPile[0]);
    _playerHand.add(_drawPile[1]);
    _drawPile.remove(_drawPile[1]);
    _playerHand.add(_drawPile[2]);
    _drawPile.remove(_drawPile[2]);
    _playerHand.add(_drawPile[3]);
    _drawPile.remove(_drawPile[3]);
    _playerHand.add(_drawPile[4]);
    _drawPile.remove(_drawPile[4]);
    _playerHand.add(_drawPile[5]);
    _drawPile.remove(_drawPile[5]);
  }

  String _displayRound() {
    return 'Round: ' + _gm.displayRound();
  }

  String _displayPhase() {
    return 'Phase: ' + _gm.displayPhase();
  }

  void _discardCards() {
    List<GameCard> toRemove = [];

    for (GameCard c in _playerHand) {
      if (_cf.isCardSelected(c.id)) {
        _discardPile.add(c);
        toRemove.add(c);
      }
    }

    _playerHand.removeWhere((c) => toRemove.contains(c));

    _cf.clearSelectedCards();

    setState(() {
      // redraw interface
    });
  }

  void _toggleSelectedCard(int id) {
    setState(() {
      _cf.toggleSelected(id);
    });
  }

  Color _getUnitBorderColor(int i) {
    if (_mf.selectedSquare == i) {
      return Colors.yellow;
    } else {
      return const Color(0xff6b8e23);
    }
  }

  Color _getCardBorderColor(int id) {
    if (_cf.isCardSelected(id)) {
      return Colors.yellow;
    } else {
      return const Color(0xffd3d3d3);
    }
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
          // next phase
        });
  }

  Widget _discardNotice() {
    // they have too many cards, so need to discard some before proceeding
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const <Widget>[
          Flexible(
            child: Text('Select cards to remove. Max is 3 in your hand.'),
          ),
        ],
      ),
    );
  }

  Widget _drawUnitContainer(int i) {
    return Container(
        decoration: BoxDecoration(
          color: _getUnitBorderColor(i),
          border: Border.all(
            width: 1,
          ),
        ),
        child: Center(child: Image.asset(_map[i].terrain)));
  }

  Widget _cardRow() {
    // iterate through cards to display the ones in the player's hand ...
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      for (int i = 0; i < _playerHand.length; i++)
        GestureDetector(
          onTap: () {
            _toggleSelectedCard(_playerHand[i].id);
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _getCardBorderColor(_playerHand[i].id),
              //border: Border.all(width: 1),
            ),
            height: 68,
            width: 58,
            child: Image.asset(_playerHand[i].graphic),
          ),
        ),
    ]);
  }

  Widget _unitRow() {
    // for each unit in the map square, return an image of it
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 45,
          width: 10,
        ),
        if (_mf.selectedSquare != -1)
          for (var u in _map[_mf.selectedSquare].units)
            Container(
              child: Image.asset(_uf.returnUnitImage(u)),
            ),
      ],
    );
  }

  void _setSelectedMapSquare(int pos) {
    setState(() {
      _mf.selectedSquare = pos;
      _unitRow;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffd3d3d3),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // const Padding(
              //     padding: EdgeInsets.all(2.0),
              //     child: Center(
              //       child: Text(
              //         "Fix Bayonets!",
              //         style: TextStyle(
              //             fontFamily: "HeaderlinerNo45",
              //             fontSize: 40,
              //             fontWeight: FontWeight.bold),
              //       ),
              //     )),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      child: Center(
                        child: Text(_displayRound(),
                            style: const TextStyle(
                                fontFamily: 'HeadlinerNo45',
                                //fontWeight: FontWeight.bold,
                                fontSize: 30)),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Center(
                        child: Text(_displayPhase(),
                            style: const TextStyle(
                                fontFamily: 'HeadlinerNo45',
                                //fontWeight: FontWeight.bold,
                                fontSize: 30)),
                      ),
                    ),
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
                          //print("map square $index clicked");
                        },
                        child: _drawUnitContainer(index),
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
                      "Your hand:",
                      style: TextStyle(
                        fontFamily: "HeaderlinerNo45",
                        fontSize: 15,
                      ),
                    )),
              ),
              _cardRow(),
              const Padding(padding: EdgeInsets.all(5.0)),
              if (_playerHand.length > 3) _discardNotice(),
              const Padding(padding: EdgeInsets.all(10.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  if (_playerHand.length > 3)
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
