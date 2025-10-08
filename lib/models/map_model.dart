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
  var b = List<String>.filled((constMapSize + 1), gfxForest);
  final _distanceArray =
      List.generate(8, (i) => List.filled(8, 0), growable: false);

  int _getRandomNumber(int min, int max) {
    return (min + Random().nextInt(max - min));
  }

  bool _checkAdjacent(int row, int col, List<MapSquare> map) {
    int pos;
    bool isAdjacent = false;

    if (_checkRowCol(row, col) == constValidSpace) {
      pos = _distanceArray[row][col];
      if ((map[pos].units.isNotEmpty) &&
          (map[pos].units.first.owner == EnumUnitOwner.american)) {
        isAdjacent = true;
      }
    }

    return isAdjacent;
  }

  bool isAmericanUnitAdjacent(List<MapSquare> map, int index) {
    // first, figure out where we are at on the 2x2 grid
    int startRow = 0;
    int startCol = 0;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (_distanceArray[row][col] == index) {
          startRow = row;
          startCol = col;
          break;
        }
      }
    }

    // now, look "around" that map square to see if (a) it is a valid
    // location and (b) whether there's an american unit next to it
    // position #1
    if ((_checkAdjacent(startRow, startCol - 1, map)) ||
        (_checkAdjacent(startRow, startCol + 1, map)) ||
        (_checkAdjacent(startRow - 1, startCol - 1, map)) ||
        (_checkAdjacent(startRow - 1, startCol, map)) ||
        (_checkAdjacent(startRow - 1, startCol + 1, map)) ||
        (_checkAdjacent(startRow + 1, startCol - 1, map)) ||
        (_checkAdjacent(startRow + 1, startCol, map)) ||
        (_checkAdjacent(startRow + 1, startCol + 1, map))) {
      return true;
    } else {
      return false;
    }
  }

  String getMapSquareGraphic(List<MapSquare> map, int index) {
    String graphic = gfxForest;
    UnitFactory unitFactory = UnitFactory();

    // grab the current mapSquare from the index pos
    MapSquare mapSquare = map[index];

    // decide on which terrain to return
    if (mapSquare.units.isEmpty) {
      // no units, retain underlying terrain
      graphic = mapSquare.terrain;
    } else {
      if (mapSquare.units.length == 1) {
        // only one unit, so if american, show the unit
        if (mapSquare.units.first.owner == EnumUnitOwner.american) {
          graphic = unitFactory.getUnitImage(mapSquare.units.first);
        } else {
          // it is german, so show single german unit icon unless there
          // is an american unit adjacent to it
          if (isAmericanUnitAdjacent(map, index)) {
            graphic = unitFactory.getUnitImage(mapSquare.units.first);
          } else {
            graphic = gfxGermanSingle;
          }
        }
      } else {
        // stacked units, so decide whether to show US or German icon
        if (mapSquare.units.first.owner == EnumUnitOwner.american) {
          graphic = gfxUsStacked;
        } else {
          graphic = gfxGermanStacked;
        }
      }
    }

    return graphic;
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

  int _checkRowCol(int destRow, int destCol) {
    if (((destRow >= 0) && (destRow <= 7)) &&
        ((destCol >= 0) && (destCol <= 7))) {
      return constValidSpace;
    } else {
      return constInvalidSpace;
    }
  }

  List<int> getValidMoves(int start, int minDistance, int maxDistance) {
    var moves = List<int>.filled((constMapSize + 1), constInvalidSpace);

    int startRow = 0;
    int startCol = 0;
    int diffRow = 0;
    int diffCol = 0;
    int numSteps = 0;
    int destRow = 0;
    int destCol = 0;
    int mapPos = 0;

    // find where we're starting from
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (_distanceArray[row][col] == start) {
          startRow = row;
          startCol = col;
          break;
        }
      }
    }

    // if regular move type, need to iterate over the array and check the distance
    if (minDistance != constZigZag) {
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          // make sure we're not in the same spot
          if ((row != startRow) || (col != startCol)) {
            diffRow = (startRow - row).abs();
            diffCol = (startCol - col).abs();
            numSteps = max(
                diffRow, diffCol); //max is returning the higher value of both
            if ((numSteps <= maxDistance) && (numSteps >= minDistance)) {
              // find the actual map square at row,col
              mapPos = _distanceArray[row][col];
              moves[mapPos] = constValidSpace;
            }
          }
        }
      }
    } else {
      // zig-zag move type so easier to figure out valid squares
      // 8 options to try

      // position #1
      destRow = startRow - 2;
      destCol = startCol - 1;
      if (_checkRowCol(destRow, destCol) == constValidSpace) {
        moves[_distanceArray[destRow][destCol]] = constValidSpace;
      }

      // position #2
      destRow = startRow - 1;
      destCol = startCol - 2;
      if (_checkRowCol(destRow, destCol) == constValidSpace) {
        moves[_distanceArray[destRow][destCol]] = constValidSpace;
      }

      // position #3
      destRow = startRow + 1;
      destCol = startCol - 2;
      if (_checkRowCol(destRow, destCol) == constValidSpace) {
        moves[_distanceArray[destRow][destCol]] = constValidSpace;
      }

      // position #4
      destRow = startRow + 2;
      destCol = startCol - 1;
      if (_checkRowCol(destRow, destCol) == constValidSpace) {
        moves[_distanceArray[destRow][destCol]] = constValidSpace;
      }

      // position #5
      destRow = startRow - 2;
      destCol = startCol + 1;
      if (_checkRowCol(destRow, destCol) == constValidSpace) {
        moves[_distanceArray[destRow][destCol]] = constValidSpace;
      }

      // position #6
      destRow = startRow - 1;
      destCol = startCol + 2;
      if (_checkRowCol(destRow, destCol) == constValidSpace) {
        moves[_distanceArray[destRow][destCol]] = constValidSpace;
      }

      // position #7
      destRow = startRow + 1;
      destCol = startCol + 2;
      if (_checkRowCol(destRow, destCol) == constValidSpace) {
        moves[_distanceArray[destRow][destCol]] = constValidSpace;
      }

      // position #8
      destRow = startRow + 2;
      destCol = startCol + 1;
      if (_checkRowCol(destRow, destCol) == constValidSpace) {
        moves[_distanceArray[destRow][destCol]] = constValidSpace;
      }
    }

    return moves;
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
    List<MapSquare> map = [];

    // add 64 map squares to list
    for (int i = 0; i <= constMapSize; i++) {
      MapSquare m = MapSquare();
      m.terrain = _randomizeTerrain();
      map.add(m);
    }

    // also build up a 2d array for distance checking later
    int ctr = 0;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        _distanceArray[row][col] = ctr;
        ctr++;
      }
    }

    // go through all the units and place them into map squares
    int x = 0;
    int min = 0;
    int max = 8;

    for (Unit u in units) {
      // top row for american units, bottom for german to start
      if (u.owner == EnumUnitOwner.american) {
        min = 0;
        max = 8;
      } else {
        min = 56;
        max = (constMapSize + 1);
      }
      // get a starting map location; if that map location already has two units in it, keep repeating until we get one
      do {
        x = _getRandomNumber(min, max);
        if (map[x].units.length != 2) {
          map[x].units.add(u);
          break;
        }
      } while (true);
    }

    return map;
  }
}
