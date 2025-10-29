import '../const.dart';

class Unit {
  final int id;
  final EnumUnitType type;
  final EnumUnitOwner owner;
  final EnumUnitMoveAllowed move;
  bool hasAttacked = false;
  int numTimesMoved = 0;
  bool isSelected = false;

  void reset() {
    hasAttacked = false;
    numTimesMoved = 0;
    isSelected = false;
  }

  // *********************************************
  // canMove: runners have multiple move options, 
  // so this helper function puts the logic here  
  // *********************************************
  bool canMove() {
    bool result = false;
    int moveAllowed = 1; 

    if (move == EnumUnitMoveAllowed.two) { moveAllowed = 2; }
    if ((moveAllowed - numTimesMoved) > 0) {
      result = true;
    }
    return result; 

  }

  Unit(this.id, this.type, this.owner, this.move);
}

class UnitFactory {

  // *********************************************
  // getUnitGraphic: return the proper graphic for the unit based
  // on type and which player   
  // *********************************************
  static String getUnitGraphic(EnumUnitType t, EnumUnitOwner o, bool b) {
    String image = "";
    String prefix = "";
    String location = constAssetsLocation;

    // usa or ger 
    prefix = (o == EnumUnitOwner.american) ? "usa_" : "ger_";

    // decide if stacked graphic, or individual unit 
    image = b ? "stacked" : t.name;

    // return it out 
    return "$location$prefix$image.jpg";

  }

  List<Unit> prepareUnits() {
    List<Unit> units = [];

    units.add(Unit(1, EnumUnitType.officer, EnumUnitOwner.german,
        EnumUnitMoveAllowed.one));
    units.add(Unit(2, EnumUnitType.officer, EnumUnitOwner.german,
        EnumUnitMoveAllowed.one));
    units.add(Unit(3, EnumUnitType.rifleman, EnumUnitOwner.german,
        EnumUnitMoveAllowed.one));
    units.add(Unit(4, EnumUnitType.rifleman, EnumUnitOwner.german,
        EnumUnitMoveAllowed.one));
    units.add(Unit(5, EnumUnitType.rifleman, EnumUnitOwner.german,
        EnumUnitMoveAllowed.one));
    units.add(Unit(6, EnumUnitType.rifleman, EnumUnitOwner.german,
        EnumUnitMoveAllowed.one));
    units.add(Unit(7, EnumUnitType.rifleman, EnumUnitOwner.german,
        EnumUnitMoveAllowed.one));
    units.add(Unit(8, EnumUnitType.rifleman, EnumUnitOwner.german,
        EnumUnitMoveAllowed.one));
    units.add(Unit(9, EnumUnitType.rifleman, EnumUnitOwner.german,
        EnumUnitMoveAllowed.one));
    units.add(Unit(10, EnumUnitType.rifleman, EnumUnitOwner.german,
        EnumUnitMoveAllowed.one));
    units.add(Unit(11, EnumUnitType.rifleman, EnumUnitOwner.german,
        EnumUnitMoveAllowed.one));
    units.add(Unit(12, EnumUnitType.rifleman, EnumUnitOwner.german,
        EnumUnitMoveAllowed.one));
    units.add(Unit(13, EnumUnitType.heavy, EnumUnitOwner.german,
        EnumUnitMoveAllowed.one));
    units.add(Unit(14, EnumUnitType.heavy, EnumUnitOwner.german,
        EnumUnitMoveAllowed.one));
    units.add(Unit(15, EnumUnitType.sniper, EnumUnitOwner.german,
        EnumUnitMoveAllowed.one));
    units.add(Unit(16, EnumUnitType.runner, EnumUnitOwner.german,
        EnumUnitMoveAllowed.two));
    units.add(Unit(17, EnumUnitType.officer, EnumUnitOwner.american,
        EnumUnitMoveAllowed.one));
    units.add(Unit(18, EnumUnitType.officer, EnumUnitOwner.american,
        EnumUnitMoveAllowed.one));
    units.add(Unit(19, EnumUnitType.rifleman, EnumUnitOwner.american,
        EnumUnitMoveAllowed.one));
    units.add(Unit(20, EnumUnitType.rifleman, EnumUnitOwner.american,
        EnumUnitMoveAllowed.one));
    units.add(Unit(21, EnumUnitType.rifleman, EnumUnitOwner.american,
        EnumUnitMoveAllowed.one));
    units.add(Unit(22, EnumUnitType.rifleman, EnumUnitOwner.american,
        EnumUnitMoveAllowed.one));
    units.add(Unit(23, EnumUnitType.rifleman, EnumUnitOwner.american,
        EnumUnitMoveAllowed.one));
    units.add(Unit(24, EnumUnitType.rifleman, EnumUnitOwner.american,
        EnumUnitMoveAllowed.one));
    units.add(Unit(25, EnumUnitType.rifleman, EnumUnitOwner.american,
        EnumUnitMoveAllowed.one));
    units.add(Unit(26, EnumUnitType.rifleman, EnumUnitOwner.american,
        EnumUnitMoveAllowed.one));
    units.add(Unit(27, EnumUnitType.rifleman, EnumUnitOwner.american,
        EnumUnitMoveAllowed.one));
    units.add(Unit(28, EnumUnitType.rifleman, EnumUnitOwner.american,
        EnumUnitMoveAllowed.one));
    units.add(Unit(29, EnumUnitType.heavy, EnumUnitOwner.american,
        EnumUnitMoveAllowed.one));
    units.add(Unit(30, EnumUnitType.heavy, EnumUnitOwner.american,
        EnumUnitMoveAllowed.one));
    units.add(Unit(31, EnumUnitType.sniper, EnumUnitOwner.american,
        EnumUnitMoveAllowed.one));
    units.add(Unit(32, EnumUnitType.runner, EnumUnitOwner.american,
        EnumUnitMoveAllowed.two));

    return units;
  }
}
