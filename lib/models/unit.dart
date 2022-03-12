import 'map.dart';
import '../const.dart';

enum enumPlayerType { american, german }
enum enumSoldierType { officer, rifleman, heavyweapon, runner, sniper }
enum enumUnitMoved { zero, one, two }

class Unit {
  final enumSoldierType type;
  final int boardpos;
  final enumPlayerType player;
  final enumUnitMoved moved;

  Unit(this.type, this.boardpos, this.player, this.moved);
}

class UnitFactory {
  String returnUnitImage(u) {
    String s = gfxUsRifle;

    // return based on image type
    if ((u.type == enumSoldierType.rifleman) &&
        (u.player == enumPlayerType.american)) {
      s = gfxUsRifle.toString();
    } else if ((u.type == enumSoldierType.officer) &&
        (u.player == enumPlayerType.american)) {
      s = gfxUsOfficer.toString();
    } else if ((u.type == enumSoldierType.heavyweapon) &&
        (u.player == enumPlayerType.american)) {
      s = gfxUsHeavy.toString();
    } else if ((u.type == enumSoldierType.runner) &&
        (u.player == enumPlayerType.american)) {
      s = gfxUsRunner.toString();
    } else if ((u.type == enumSoldierType.sniper) &&
        (u.player == enumPlayerType.american)) {
      s = gfxUsSniper.toString();
    } else if ((u.type == enumSoldierType.rifleman) &&
        (u.player == enumPlayerType.german)) {
      s = gfxGermanRifle.toString();
    } else if ((u.type == enumSoldierType.officer) &&
        (u.player == enumPlayerType.german)) {
      s = gfxGermanOfficer.toString();
    } else if ((u.type == enumSoldierType.heavyweapon) &&
        (u.player == enumPlayerType.german)) {
      s = gfxGermanHeavy.toString();
    } else if ((u.type == enumSoldierType.runner) &&
        (u.player == enumPlayerType.german)) {
      s = gfxGermanRunner.toString();
    } else if ((u.type == enumSoldierType.sniper) &&
        (u.player == enumPlayerType.german)) {
      s = gfxGermanSniper.toString();
    }

    return s;
  }

  List<Unit> prepareUnits() {
    // need some logic to randomly stack units. germans in board spaces 0-6 (top row),
    // while americans in spaces 57-63; for each unit, pick a map square. also have a placeholder
    // list so when you get to 2 in that space, pick a different random number
    List<Unit> u = [];
    var b = List<int>.filled(8, 0);
    int min = 0;
    int max = 0;

    MapFactory mf = MapFactory();

    // german units
    min = 0;
    max = 8;
    u.add(Unit(enumSoldierType.officer, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.german, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.officer, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.german, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.rifleman, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.german, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.rifleman, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.german, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.rifleman, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.german, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.rifleman, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.german, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.rifleman, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.german, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.rifleman, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.german, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.rifleman, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.german, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.rifleman, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.german, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.rifleman, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.german, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.rifleman, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.german, enumUnitMoved.zero));
    u.add(Unit(
        enumSoldierType.heavyweapon,
        mf.getStartingMapSquare(b, min, max),
        enumPlayerType.german,
        enumUnitMoved.zero));
    u.add(Unit(
        enumSoldierType.heavyweapon,
        mf.getStartingMapSquare(b, min, max),
        enumPlayerType.german,
        enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.sniper, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.german, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.runner, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.german, enumUnitMoved.zero));

    // us units
    min = 56;
    max = 64;
    // reset mapsquare for space tracking
    for (int i = 0; i < 8; i++) {
      b[i] = 0;
    }
    u.add(Unit(enumSoldierType.officer, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.american, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.officer, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.american, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.rifleman, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.american, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.rifleman, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.american, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.rifleman, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.american, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.rifleman, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.american, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.rifleman, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.american, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.rifleman, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.american, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.rifleman, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.american, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.rifleman, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.american, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.rifleman, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.american, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.rifleman, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.american, enumUnitMoved.zero));
    u.add(Unit(
        enumSoldierType.heavyweapon,
        mf.getStartingMapSquare(b, min, max),
        enumPlayerType.american,
        enumUnitMoved.zero));
    u.add(Unit(
        enumSoldierType.heavyweapon,
        mf.getStartingMapSquare(b, min, max),
        enumPlayerType.american,
        enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.sniper, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.american, enumUnitMoved.zero));
    u.add(Unit(enumSoldierType.runner, mf.getStartingMapSquare(b, min, max),
        enumPlayerType.american, enumUnitMoved.zero));

    return u;
  }
}
