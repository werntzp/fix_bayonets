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
  }

  String _displayRound() {
    return 'Round: ' + _gm.displayRound();
  }

  String _displayPhase() {
    return 'Phase: ' + _gm.displayPhase();
  }

  Widget _cardRow() {
    // iterate through cards to display the ones in the player's hand ...
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      for (var c in _playerHand)
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), //color of shadow
                blurRadius: 1,
                offset: const Offset(.5, .5),
              )
            ],
          ),
          height: 65.0,
          width: 60.0,
          child: Image.asset(c.graphic),
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
      body: Container(
        margin: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    child: Center(
                      child: Text(_displayRound(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                    ),
                  ),
                  Container(
                    child: Center(
                      child: Text(_displayPhase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
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
                        print("map square $index clicked");
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xff6b8e23),
                            border: Border.all(
                              width: 1,
                            ),
                          ),
                          // child: Center(child: Text('$index')),
                          child:
                              Center(child: Image.asset(_map[index].terrain))),
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
                  alignment: Alignment.topLeft, child: Text("Your hand:")),
            ),
            _cardRow()
          ],
        ),
      ),
    );
  }
}
