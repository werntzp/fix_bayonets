import 'package:flutter/material.dart';
import 'const.dart';
import 'models/unit.dart';
import 'models/card.dart';
import 'models/map.dart';
import 'models/game.dart';

var _gcf = GameCardFactory();
var _uf = UnitFactory();
var _cards = _gcf.prepareDeck();
var _units = _uf.prepareUnits();
var _map = List<String>.filled(64, gfxForest); // tracks graphic to display

//List<Unit> _mapSquareUnits = List<Unit>();
//Unit _selectedUnit = null;
int _selectedMapSquare = -1;

// main class
class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameModel _model;

  String _displayRound() {
    return 'Round: ' + _model.displayRound();
  }

  String _displayTurn() {
    return 'Turn: ' + _model.displayTurn();
  }

  Widget _cardRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
            ),
          ),
          height: 90.0,
          width: 90.0,
          child: Image.asset('images/bayonet.png'),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
            ),
          ),
          height: 90.0,
          width: 90.0,
          child: Image.asset('images/bayonet.png'),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
            ),
          ),
          height: 90.0,
          width: 90.0,
          child: Image.asset('images/bayonet.png'),
        ),
      ],
    );
  }

  Widget _drawUnits(units) {
    // for each unit in the map square, return an image of it
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        for (var u in units)
          Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.black,
                ),
              ),
              child: Image.asset(_uf.returnUnitImage(_map[u.boardpos]))),
      ],
    );
  }

  void _setSelectedMapSquare(x) {
    setState(() {
      _selectedMapSquare = x;
      // clear out the stacked units list
      //_mapSquareUnits.clear();

      // see if there are any units in that square, and if so, add to list
      for (var i = 0; i < _units.length; i++) {
        if (_units[i].boardpos == x) {
          // temp array with units
          //  _mapSquareUnits.add(_units[i]);
        }
      }

      // now display them
      //_drawUnits(_mapSquareUnits);
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
                      child: Text(_displayTurn(),
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
                          child: Center(child: Image.asset(_map[index]))),
                    );
                  }),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(1.0),
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Text("Selected Square:")),
            ),
            //_drawUnits(_mapSquareUnits),
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Align(
                  alignment: Alignment.topCenter, child: Text("Your hand:")),
            ),
            _cardRow()
          ],
        ),
      ),
    );
  }
}
