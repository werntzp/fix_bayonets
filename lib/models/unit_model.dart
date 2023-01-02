import '../const.dart';

class Unit {
  final int id;
  final EnumUnitType type;
  final EnumUnitOwner owner;
  final EnumUnitMoveAllowed move;
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
  String _getUnitImageModifiers(String file, Unit u) {
    String modifier = "";

    // can they move? runners are a little odd
    if (u.type == EnumUnitType.runner) {
      if (u.numTimesMoved == 0) {
        modifier = "_m_m";
      } else if (u.numTimesMoved == 1) {
        modifier = "_m";
      }
    } else {
      if (!u.hasMoved) {
        modifier += "_m";
      }
    }

    // can they attack?
    if (!u.hasAttacked) {
      modifier += "_a";
    }

    return modifier;
  }

  String getUnitImage(Unit u) {
    String s = gfxUsRifle;
    String image = "";

    // return based on image type
    if ((u.type == EnumUnitType.rifleman) &&
        (u.owner == EnumUnitOwner.american)) {
      s = gfxUsRifle.toString();
    } else if ((u.type == EnumUnitType.officer) &&
        (u.owner == EnumUnitOwner.american)) {
      s = gfxUsOfficer.toString();
    } else if ((u.type == EnumUnitType.heavyweapon) &&
        (u.owner == EnumUnitOwner.american)) {
      s = gfxUsHeavy.toString();
    } else if ((u.type == EnumUnitType.runner) &&
        (u.owner == EnumUnitOwner.american)) {
      s = gfxUsRunner.toString();
    } else if ((u.type == EnumUnitType.sniper) &&
        (u.owner == EnumUnitOwner.american)) {
      s = gfxUsSniper.toString();
    } else if ((u.type == EnumUnitType.rifleman) &&
        (u.owner == EnumUnitOwner.german)) {
      s = gfxGermanRifle.toString();
    } else if ((u.type == EnumUnitType.officer) &&
        (u.owner == EnumUnitOwner.german)) {
      s = gfxGermanOfficer.toString();
    } else if ((u.type == EnumUnitType.heavyweapon) &&
        (u.owner == EnumUnitOwner.german)) {
      s = gfxGermanHeavy.toString();
    } else if ((u.type == EnumUnitType.runner) &&
        (u.owner == EnumUnitOwner.german)) {
      s = gfxGermanRunner.toString();
    } else if ((u.type == EnumUnitType.sniper) &&
        (u.owner == EnumUnitOwner.german)) {
      s = gfxGermanSniper.toString();
    }

    // now that we have the base graphic, time to add any modifiers (only if american!)
    if (u.owner == EnumUnitOwner.american) {
      image = s + _getUnitImageModifiers(s, u) + gfxImageType.toString();
    } else {
      image = s + gfxImageType.toString();
    }

    return image;
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
    units.add(Unit(13, EnumUnitType.heavyweapon, EnumUnitOwner.german,
        EnumUnitMoveAllowed.one));
    units.add(Unit(14, EnumUnitType.heavyweapon, EnumUnitOwner.german,
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
    units.add(Unit(29, EnumUnitType.heavyweapon, EnumUnitOwner.american,
        EnumUnitMoveAllowed.one));
    units.add(Unit(30, EnumUnitType.heavyweapon, EnumUnitOwner.american,
        EnumUnitMoveAllowed.one));
    units.add(Unit(31, EnumUnitType.sniper, EnumUnitOwner.american,
        EnumUnitMoveAllowed.one));
    units.add(Unit(32, EnumUnitType.runner, EnumUnitOwner.american,
        EnumUnitMoveAllowed.two));

    return units;
  }
}
