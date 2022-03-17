import 'map.dart';
import '../const.dart';

class Unit {
  final enumUnitType type;
  final enumUnitOwner owner;
  final enumUnitMoveAllowed move;
  bool hasMoved = false;
  bool hasAttacked = false;
  bool isAlive = true;

  void reset() {
    hasAttacked = false;
    hasMoved = false;
  }

  Unit(this.type, this.owner, this.move);
}

class UnitFactory {
  String returnUnitImage(u) {
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
    // need some logic to randomly stack units. germans in board spaces 0-6 (top row),
    // while americans in spaces 57-63; for each unit, pick a map square. also have a placeholder
    // list so when you get to 2 in that space, pick a different random number
    List<Unit> u = [];

    u.add(Unit(
        enumUnitType.officer, enumUnitOwner.german, enumUnitMoveAllowed.one));
    u.add(Unit(
        enumUnitType.officer, enumUnitOwner.german, enumUnitMoveAllowed.one));
    u.add(Unit(
        enumUnitType.rifleman, enumUnitOwner.german, enumUnitMoveAllowed.one));
    u.add(Unit(
        enumUnitType.rifleman, enumUnitOwner.german, enumUnitMoveAllowed.one));
    u.add(Unit(
        enumUnitType.rifleman, enumUnitOwner.german, enumUnitMoveAllowed.one));
    u.add(Unit(
        enumUnitType.rifleman, enumUnitOwner.german, enumUnitMoveAllowed.one));
    u.add(Unit(
        enumUnitType.rifleman, enumUnitOwner.german, enumUnitMoveAllowed.one));
    u.add(Unit(
        enumUnitType.rifleman, enumUnitOwner.german, enumUnitMoveAllowed.one));
    u.add(Unit(
        enumUnitType.rifleman, enumUnitOwner.german, enumUnitMoveAllowed.one));
    u.add(Unit(
        enumUnitType.rifleman, enumUnitOwner.german, enumUnitMoveAllowed.one));
    u.add(Unit(
        enumUnitType.rifleman, enumUnitOwner.german, enumUnitMoveAllowed.one));
    u.add(Unit(
        enumUnitType.rifleman, enumUnitOwner.german, enumUnitMoveAllowed.one));
    u.add(Unit(enumUnitType.heavyweapon, enumUnitOwner.german,
        enumUnitMoveAllowed.one));
    u.add(Unit(enumUnitType.heavyweapon, enumUnitOwner.german,
        enumUnitMoveAllowed.one));
    u.add(Unit(
        enumUnitType.sniper, enumUnitOwner.german, enumUnitMoveAllowed.one));
    u.add(Unit(
        enumUnitType.runner, enumUnitOwner.german, enumUnitMoveAllowed.two));

    u.add(Unit(
        enumUnitType.officer, enumUnitOwner.american, enumUnitMoveAllowed.one));
    u.add(Unit(
        enumUnitType.officer, enumUnitOwner.american, enumUnitMoveAllowed.one));
    u.add(Unit(enumUnitType.rifleman, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    u.add(Unit(enumUnitType.rifleman, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    u.add(Unit(enumUnitType.rifleman, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    u.add(Unit(enumUnitType.rifleman, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    u.add(Unit(enumUnitType.rifleman, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    u.add(Unit(enumUnitType.rifleman, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    u.add(Unit(enumUnitType.rifleman, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    u.add(Unit(enumUnitType.rifleman, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    u.add(Unit(enumUnitType.rifleman, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    u.add(Unit(enumUnitType.rifleman, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    u.add(Unit(enumUnitType.heavyweapon, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    u.add(Unit(enumUnitType.heavyweapon, enumUnitOwner.american,
        enumUnitMoveAllowed.one));
    u.add(Unit(
        enumUnitType.sniper, enumUnitOwner.american, enumUnitMoveAllowed.one));
    u.add(Unit(
        enumUnitType.runner, enumUnitOwner.american, enumUnitMoveAllowed.two));

    return u;
  }
}
