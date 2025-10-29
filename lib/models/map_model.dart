import 'dart:math';
import '../const.dart';
import 'unit_model.dart';

class MapHex {
  final int row;
  final int col;
  Set<Unit> units = {};
  bool isSelected = false;
  String terrain = ""; 

  MapHex(this.row, this.col);
}

class HexCoord {
 final int x;
 final int y;
 final int z;

 // Private constructor to ensure coordinates always sum to zero,
 // though they are typically generated via conversion from offset.
 HexCoord(this.x, this.y, this.z);

 // Calculates the shortest distance (in hex steps) between two cube coordinates.
 static int distance(HexCoord a, HexCoord b) {
   // The cube distance formula is (abs(dx) + abs(dy) + abs(dz)) / 2
   return ((a.x - b.x).abs() +
           (a.y - b.y).abs() +
           (a.z - b.z).abs()) ~/
       2;
 }

 @override
 String toString() => 'Cube($x, $y, $z)';
}

class MapFactory {

  final UnitFactory _unitFactory = UnitFactory(); 
  late List<Unit> _units;
  late List<List<MapHex>> _hexes; 

  // create the underlying 2d array of each map hex  
  final List<List<MapHex>> _staticHexes = List.generate(
    constMapRows,
    (row) => List.generate(
      constMapCols,
      (col) => MapHex(row, col),
    ),
  );

  // stores distances between spaces
  final _distanceArray =
      List.generate(constMapRows, (i) => List.filled(constMapCols, 0), growable: false);

  // *********************************************
  // helper function to take row, col hex map
  // and transform into x,y, and z cube   
  // *********************************************
  HexCoord _offsetToCube(int row, int col) {
    // 1. Calculate the 'x' cube coordinate (often called 'q')
    // The expression `(row % 2)` determines the offset adjustment for odd rows.
    final int x = col - (row - (row % 2)) ~/ 2;

    // 2. The 'z' cube coordinate (often called 'r') is simply the row index.
    final int z = row;

    // 3. The 'y' cube coordinate (often called 's') must satisfy x + y + z = 0.
    // Therefore, y = -x - z.
    final int y = -x - z;

    return HexCoord(x, y, z);
  }

  // *********************************************
  // returns distance between two spots
  // on the hex grid 
  // *********************************************
  int _getDistanceBetweenHexes(int startR, int startC, int endR, int endC) {
    // Validation (optional, but good practice for an 8x8 grid)
    if (startR < 0 || startR > (constMapRows-1) || startC < 0 || startC > (constMapCols-1) ||
        endR < 0 || endR > (constMapRows-1) || endC < 0 || endC > (constMapCols-1)) {
      print('Warning: Coordinates are outside the 0-7 range.');
      // Return a value indicating an error or exceptional distance
      return constInvalidSpace;
    }

    // 1. Convert both (row, col) pairs to their 3D Cube equivalents.
    final HexCoord startCube = _offsetToCube(startC, startR);
    final HexCoord endCube = _offsetToCube(endC, endR);

    // 2. Calculate the distance using the Cube system's formula.
    return HexCoord.distance(startCube, endCube);

  }

  // *********************************************
  // helper function 
  // *********************************************
  int _getRandomNumber(int min, int max) {
    return (min + Random().nextInt(max - min));
  }

  // *********************************************
  // randomly picks terrain for each map hex
  // *********************************************
  String _getTerrainGraphic(int row, int col) {
    
    String t = ""; 
    int n = 0; 
    int c = 0; 

    // first, randomly pick between 1 - 3 (for dense, light, or crater)
    n = _getRandomNumber(1,10); 

    if (n <=5)  { // dense
      t = constDenseTerrain;
      c = _getRandomNumber(1,5);

    }
    else if ((n > 5) && (n <= 8))  { // light
      t = constLightTerrain;
      c = _getRandomNumber(1,4); 

    }
    else { // crater
      t = constCraterTerain;
      c = _getRandomNumber(1,3); 

    }

    //print("terrain chosen: $t$c.jpg");
    return "$t$c.jpg";

  }

  // *********************************************
  // does the heavy lifting to set map terrain,
  // create the distance array (used later), and randomly place
  // all the starting units  
  // *********************************************
 List<List<MapHex>> prepareMap() {

    // always start with a clean array
    _hexes = List.from(_staticHexes);

    // randomly set terrain for each hex, and also build up a 2d array
    // for distance checking later
    int ctr = 0;
    for (int row = 0; row < constMapRows; row++) {
      for (int col = 0; col < constMapCols; col++) {
        _hexes[row][col].units.clear();
        _hexes[row][col].terrain = _getTerrainGraphic(row, col);    
        _distanceArray[row][col] = ctr;
        ctr++;
      }
    }

    // create the unit model so we can work with that in here too
    _units = _unitFactory.prepareUnits();

    // go through all the units and place them into map squares
    int row = 0; 
    int col = 0;

    for (Unit u in _units) {
      // top row for american units, bottom for german to start
      if (u.owner == EnumUnitOwner.american) {
        row = 0; 
      } else {
        row = (constMapRows - 1);
      }
      // get a starting map location; if that map location already has two units in it, keep repeating until we get one
      do {
        col = _getRandomNumber(0, constMapCols);
        if (_hexes[row][col].units.length != 2) {
          _hexes[row][col].units.add(u);
          break;
        }
      } while (true);
    }

    return _hexes; 

  }

  // *********************************************
  // reset the distance array 
  // *********************************************
  List<List<int>> resetDistances() {

    for (int row = 0; row < constMapRows; row++) {
      for (int col = 0; col < constMapCols; col ++) {
        _distanceArray[row][col] = constInvalidSpace;
      }
    }

    return List.from(_distanceArray);
  }

  // *********************************************
  // return 2x2 array with distances
  // between starting hex and every other hex on the map
  // *********************************************
  List<List<int>> getDistances(int row, int col) {
    int startRow = row; 
    int startCol = col; 

    for (int destRow = 0; destRow < constMapRows; destRow++) {
      for (int destCol = 0; destCol < constMapCols; destCol++) {
        _distanceArray[destRow][destCol] = _getDistanceBetweenHexes(startRow, startCol, destRow, destCol);
      }
    }

    return List.from(_distanceArray); 

  }

  // *********************************************
  // helper function to make sure 
  // any row/col combo isn't out of bounds 
  // *********************************************
  bool isRowColValid(int row, int col) {
    bool result = true; 

    if (row < 0 || row >= (constMapRows) || col < 0 || col >= (constMapCols)) {
      result = false; // out of bounds 
    }

    return result; 

  } 

  // *********************************************
  // return 2x2 array with distances
  // between starting hex and every other hex on the map
  // *********************************************
  List<List<int>> getZigZagDistances(int row, int col) {
    int startRow = row; 
    int startCol = col; 
    int destRow = 0;
    int destCol = 0;

    // set eveerything as invalid to start 
    resetDistances();

    // two of the six positions are always the same:
    // postion #2 
    destCol = (startCol + 2); 
    destRow = startRow; 
    if (isRowColValid(destRow, destCol)) { _distanceArray[destRow][destCol] = constZigZagSpace; }

    // position #5 
    destCol = (startCol  - 2); 
    destRow = startRow; 
    if (isRowColValid(destRow, destCol)) { _distanceArray[destRow][destCol] = constZigZagSpace; }

    // now, the remaining four change depending whether odd or even column
    // due to the ways rows are stacked in the hexagon 
    
    // position #1 
    if (startCol.isEven) { 
      destRow = (startRow - 2);
    }
    else {
      destRow = (startRow - 1);
    }
    destCol = startCol + 1;
    if (isRowColValid(destRow, destCol)) { _distanceArray[destRow][destCol] = constZigZagSpace; }

    // position #3
    if (startCol.isEven) { 
      destRow = (startRow + 1);
    }
    else {
      destRow = (startRow + 2);
    }
    destCol = startCol + 1;
    if (isRowColValid(destRow, destCol)) { _distanceArray[destRow][destCol] = constZigZagSpace; }

    // position #4
    if (startCol.isEven) { 
      destRow = (startRow + 1);
    }
    else {
      destRow = (startRow + 2);
    }
    destCol = startCol - 1;
    if (isRowColValid(destRow, destCol)) { _distanceArray[destRow][destCol] = constZigZagSpace; }
        
    // position #6
    if (startCol.isEven) { 
      destRow = (startRow - 2);
    }
    else {
      destRow = (startRow - 1);
    }
    destCol = startCol - 1;
    if (isRowColValid(destRow, destCol)) { _distanceArray[destRow][destCol] = constZigZagSpace; }

    return List.from(_distanceArray); 

  }

}
