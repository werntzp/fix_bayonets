enum enumTurn { orders, move, fight }
enum enumCardType { attack, move, terrain }
enum enumCardLocation { hand, draw, discard }
enum enumPlayerUse { american, german, both }
enum enumCardNegate { move, attack, neither }
enum enumCardName {
  bayonet,
  pistol,
  flamethrower,
  grenade,
  rifle,
  machinegun,
  sniper,
  crawl,
  march,
  doubletime,
  zigzag,
  run,
  charge,
  advance,
  counterattack,
  trees,
  foxholes,
  roughground,
  holdground
}

class GameCard {
  final enumCardName name;
  final enumCardType type;
  final int minrange;
  final int maxrange;
  final enumPlayerUse player;
  final enumCardNegate negate;
  final enumCardLocation location;

  GameCard(this.name, this.type, this.minrange, this.maxrange, this.player,
      this.negate, this.location);
}

class GameCardFactory {
  List<GameCard> prepareDeck() {
    List<GameCard> c = [];

    // bayonet x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(enumCardName.bayonet, enumCardType.attack, 1, 1,
          enumPlayerUse.both, enumCardNegate.neither, enumCardLocation.draw));
    }
    // pistol x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(enumCardName.pistol, enumCardType.attack, 1, 2,
          enumPlayerUse.both, enumCardNegate.neither, enumCardLocation.draw));
    }
    // flamer thrower x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(enumCardName.flamethrower, enumCardType.attack, 2, 3,
          enumPlayerUse.german, enumCardNegate.neither, enumCardLocation.draw));
    }
    // grenade x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(enumCardName.grenade, enumCardType.attack, -1, -1,
          enumPlayerUse.both, enumCardNegate.neither, enumCardLocation.draw));
    }
    // rifle x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(enumCardName.grenade, enumCardType.attack, 3, 3,
          enumPlayerUse.both, enumCardNegate.neither, enumCardLocation.draw));
    } // rifle x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(enumCardName.rifle, enumCardType.attack, 4, 4,
          enumPlayerUse.both, enumCardNegate.neither, enumCardLocation.draw));
    } // machine gun x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.machinegun,
          enumCardType.attack,
          4,
          5,
          enumPlayerUse.american,
          enumCardNegate.neither,
          enumCardLocation.draw));
    }
    // sniper x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(enumCardName.sniper, enumCardType.attack, 5, 6,
          enumPlayerUse.both, enumCardNegate.neither, enumCardLocation.draw));
    }
    // crawl x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(enumCardName.crawl, enumCardType.move, 1, 1,
          enumPlayerUse.both, enumCardNegate.neither, enumCardLocation.draw));
    } // march x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(enumCardName.march, enumCardType.move, 2, 2,
          enumPlayerUse.both, enumCardNegate.neither, enumCardLocation.draw));
    } // double time x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(enumCardName.doubletime, enumCardType.move, 3, 3,
          enumPlayerUse.both, enumCardNegate.neither, enumCardLocation.draw));
    } // zig zag x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(enumCardName.zigzag, enumCardType.move, -1, -1,
          enumPlayerUse.both, enumCardNegate.neither, enumCardLocation.draw));
    }
    // run x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(enumCardName.run, enumCardType.move, 4, 4,
          enumPlayerUse.both, enumCardNegate.neither, enumCardLocation.draw));
    } // charge x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(enumCardName.charge, enumCardType.move, 5, 5,
          enumPlayerUse.both, enumCardNegate.neither, enumCardLocation.draw));
    }
    // advance x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(enumCardName.advance, enumCardType.move, 2, 2,
          enumPlayerUse.german, enumCardNegate.neither, enumCardLocation.draw));
    }
    // counter attack
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.counterattack,
          enumCardType.move,
          3,
          3,
          enumPlayerUse.american,
          enumCardNegate.neither,
          enumCardLocation.draw));
    } // trees x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(enumCardName.trees, enumCardType.terrain, 0, 0,
          enumPlayerUse.both, enumCardNegate.attack, enumCardLocation.draw));
    } // fox holes x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.foxholes,
          enumCardType.terrain,
          0,
          0,
          enumPlayerUse.american,
          enumCardNegate.attack,
          enumCardLocation.draw));
    } // rough ground x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(enumCardName.roughground, enumCardType.terrain, 0, 0,
          enumPlayerUse.both, enumCardNegate.move, enumCardLocation.draw));
    }
    // hold ground x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(enumCardName.holdground, enumCardType.terrain, 0, 0,
          enumPlayerUse.german, enumCardNegate.move, enumCardLocation.draw));
    }

    return c;
  }
}
