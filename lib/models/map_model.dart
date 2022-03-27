import 'dart:math';
import '../const.dart';
import 'unit_model.dart';

class MapSquare {
  Set<Unit> units = {};
  String terrain = gfxForest;
  bool isSelected = false;

  MapSquare();
}

class MapFactory {
  var b = List<String>.filled(64, gfxForest);
  int selectedSquare = -1;

  int _getRandomNumber(int min, int max) {
    return (min + Random().nextInt(max - min));
  }

  String _randomizeTerrain() {
    String t = gfxForest;
    int i = Random().nextInt(10);
    // 6-8 open
    if ((i > 5) && (i < 9)) {
      t = gfxOpen;
    }
    // 9-10 thick
    else if (i > 8) {
      t = gfxThick;
    }

    return t;
  }

  int _getStartingMapSquare(board, min, max) {
    int x = 0;

    // get a random number, see if there are already two units in that map square. if
    // yes, keep generating numbers until you hit one where that isn't true
    do {
      x = _getRandomNumber(min, max);
      if (board[(x - min)] == 2) {
        x = -1;
      } else {
        board[(x - min)] = board[(x - min)] + 1;
      }
    } while (x == -1);
    return x;
  }

  List<MapSquare> prepareMap(List<Unit> units) {
    List<MapSquare> _map = [];

    // add 64 map squares to list
    for (int i = 0; i < 64; i++) {
      MapSquare m = MapSquare();
      if (i < 8) {
        m.terrain = gfxUsStacked;
      } else if (i > 55) {
        m.terrain = gfxGermanStacked;
      } else {
        m.terrain = _randomizeTerrain();
      }

      _map.add(m);
    }

    // go through all the units and place them into map squares
    int x = 0;
    int min = 0;
    int max = 8;
    bool addedUnit = false;

    for (Unit u in units) {
      // top row for american units, bottom for german to start
      if (u.owner == enumUnitOwner.american) {
        min = 0;
        max = 8;
      } else {
        min = 56;
        max = 64;
      }
      // get a starting map location; if that map location already has two units in it, keep repeating until we get one
      do {
        x = _getRandomNumber(min, max);
        if (_map[x].units.length != 2) {
          _map[x].units.add(u);
          break;
        }
      } while (true);
    }

    return _map;
  }
}
