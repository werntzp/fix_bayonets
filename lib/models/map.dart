import 'dart:math';
import 'unit.dart';
import '../const.dart';

class MapFactory {
  int _getRandomNumber(int min, int max) {
    return (min + Random().nextInt(max - min));
  }

  String _returnTerrain() {
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

  int getStartingMapSquare(board, min, max) {
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

  List<String> prepareBoard() {
    var b = List<String>.filled(64, gfxForest);

    // auto stack units in first and last row to start the game
    b[0] = gfxGermanStacked;
    b[1] = gfxGermanStacked;
    b[2] = gfxGermanStacked;
    b[3] = gfxGermanStacked;
    b[4] = gfxGermanStacked;
    b[5] = gfxGermanStacked;
    b[6] = gfxGermanStacked;
    b[7] = gfxGermanStacked;
    b[56] = gfxUsStacked;
    b[57] = gfxUsStacked;
    b[58] = gfxUsStacked;
    b[59] = gfxUsStacked;
    b[60] = gfxUsStacked;
    b[61] = gfxUsStacked;
    b[62] = gfxUsStacked;
    b[63] = gfxUsStacked;
    // then loop through to randomly add a little color
    for (int i = 8; i < 56; i++) {
      b[i] = _returnTerrain();
    }

    return b;
  }
}
