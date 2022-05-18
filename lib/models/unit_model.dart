import '../const.dart';

class Unit {
  final int id;
  final enumUnitType type;
  final enumUnitOwner owner;
  final enumUnitMoveAllowed move;
  bool hasMoved = false;
  bool hasAttacked = false;
  bool isAlive = true;
  int numTimesMoved = 0;
  bool isSelected = false;

  void reset() {
    hasAttacked = false;
    hasMoved = false;
    numTimesMoved = 0;
    isSelected = false;
  }

  Unit(this.id, this.type, this.owner, this.move);
}

class UnitFactory {
  String getUnitImage(Unit u) {
    String s = gfxUsRifle;

    // return based on image type
    if ((u.type == enumUnitType.rifleman) &&
        (u.owner == enumUnitOwner.american)) {
      s = gfxUsRifle.toString();
    } else if ((u.type == enumUnitType.officer) &&
        (u.owner == enumUnitOwner.american)) {
      s = gfxUsOfficer.toString();
    } else if ((u.type == enumUnitType.heavyweapon) &&
        (u.owner == enumUnitOwner.american)) {
      s = gfxUsHeavy.toString();
    } else if ((u.type == enumUnitType.runner) &&
        (u.owner == enumUnitOwner.american)) {
      s = gfxUsRunner.toString();
    } else if ((u.type == enumUnitType.sniper) &&
        (u.owner == enumUnitOwner.american)) {
      s = gfxUsSniper.toString();
    } else if ((u.type == enumUnitType.rifleman) &&
        (u.owner == enumUnitOwner.german)) {
      s = gfxGermanRifle.toString();
    } else if ((u.type == enumUnitType.officer) &&
        (u.owner == enumUnitOwner.german)) {
      s = gfxGermanOfficer.toString();
    } else if ((u.type == enumUnitType.heavyweapon) &&
        (u.owner == enumUnitOwner.german)) {
      s = gfxGermanHeavy.toString();
    } else if ((u.type == enumUnitType.runner) &&
        (u.owner == enumUnitOwner.german)) {
      s = gfxGermanRunner.toString();
    } else if ((u.type == enumUnitType.sniper) &&
        (u.owner == enumUnitOwner.german)) {
      s = gfxGermanSniper.toString();
    }

    return s;
  }

  List<Unit> prepareUnits() {
    List<Unit> units = [];

    units.add(Unit(1, enumUnitType.officer, enumUnitOwner.german,
        enumUnitMoveAllowed.one));
    units.add(Unit(2, enumUnitType.officer, enumUnitOwner.german,
        enumUnitMoveAllowed.one));
    units.add(Unit(3, enumUnitType.rifleman, enumUnitOwner.german,
        enumUnitMoveAllowed.one));
    units.add(Unit(4, enumUnitType.rifleman, enumUnitOwner.german,
        enumUnitMoveAllowed.one));
    units.add(Unit(5, enumUnitType.rifleman, enumUnitOwner.german,
        enumUnitMoveAllowed.one));
    units.add(Unit(6, enumUnitType.rifleman, enumUnitOwner.german,
        enumUnitMoveAllowed.one));
    units.add(Unit(7, enumUnitType.rifleman, enumUnitOwner.german,
        enumUnitMoveAllowed.one));
    units.add(Unit(8, enumUnitType.rifleman, enumUnitOwner.german,
        enumUnitMoveAllowed.one));
    units.add(Unit(9, enumUnitType.rifleman, enumUnitOwner.german,
        enumUnitMoveAllowed.one));
    units.add(Unit(10, enumUnitType.rifleman, enumUnitOwner.german,
        enumUnitMoveAllowed.one));
    units.add(Unit(11, enumUnitType.rifleman, enumUnitOwner.german,
        enumUnitMoveAllowed.one));
    units.add(Unit(12, enumUnitType.rifleman, enumUnitOwner.german,
        enumUnitMoveAllowed.one));
    units.add(Unit(13, enumUnitType.heavyweapon, enumUnitOwner.german,
        enumUnitMoveAllowed.one));
    units.add(Unit(14, enumUnitType.heavyweapon, enumUnitOwner.german,
        enumUnitMoveAllowed.one));
    units.add(Unit(15, enumUnitType.sniper, enumUnitOwner.german,
        enumUnitMoveAllowed.one));
    units.add(Unit(16, enumUnitType.runner, enumUnitOwner.german,
        enumUnitMoveAllowed.two));
    units.add(Unit(17, enumUnitType.officer, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    units.add(Unit(18, enumUnitType.officer, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    units.add(Unit(19, enumUnitType.rifleman, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    units.add(Unit(20, enumUnitType.rifleman, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    units.add(Unit(21, enumUnitType.rifleman, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    units.add(Unit(22, enumUnitType.rifleman, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    units.add(Unit(23, enumUnitType.rifleman, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    units.add(Unit(24, enumUnitType.rifleman, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    units.add(Unit(25, enumUnitType.rifleman, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    units.add(Unit(26, enumUnitType.rifleman, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    units.add(Unit(27, enumUnitType.rifleman, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    units.add(Unit(28, enumUnitType.rifleman, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    units.add(Unit(29, enumUnitType.heavyweapon, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    units.add(Unit(30, enumUnitType.heavyweapon, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    units.add(Unit(31, enumUnitType.sniper, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    units.add(Unit(32, enumUnitType.runner, enumUnitOwner.american,
        enumUnitMoveAllowed.two));

    return units;
  }
}
