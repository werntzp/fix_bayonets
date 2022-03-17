import 'package:fix_bayonets/const.dart';

class GameCard {
  final enumCardName name;
  final enumCardType type;
  final int minrange;
  final int maxrange;
  final enumPlayerUse player;
  final enumCardNegate negate;
  final enumUnitType useby;
  final String graphic;

  GameCard(this.name, this.type, this.minrange, this.maxrange, this.player,
      this.negate, this.useby, this.graphic);
}

class GameCardFactory {
  List<GameCard> prepareDeck() {
    List<GameCard> c = [];

    // bayonet x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.bayonet,
          enumCardType.attack,
          1,
          1,
          enumPlayerUse.both,
          enumCardNegate.neither,
          enumUnitType.all,
          gfxAttack1));
    }
    // pistol x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.pistol,
          enumCardType.attack,
          1,
          2,
          enumPlayerUse.both,
          enumCardNegate.neither,
          enumUnitType.officer,
          gfxAttack2Officer));
    }
    // flamer thrower x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.flamethrower,
          enumCardType.attack,
          2,
          3,
          enumPlayerUse.german,
          enumCardNegate.neither,
          enumUnitType.heavyweapon,
          gfxAttack23German));
    }
    // grenade x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.grenade,
          enumCardType.attack,
          -1,
          -1,
          enumPlayerUse.both,
          enumCardNegate.neither,
          enumUnitType.all,
          gfxAttackZ));
    }
    // rifle x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.grenade,
          enumCardType.attack,
          3,
          3,
          enumPlayerUse.both,
          enumCardNegate.neither,
          enumUnitType.all,
          gfxAttack3));
    } // rifle x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.rifle,
          enumCardType.attack,
          4,
          4,
          enumPlayerUse.both,
          enumCardNegate.neither,
          enumUnitType.all,
          gfxAttack4));
    } // machine gun x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.machinegun,
          enumCardType.attack,
          4,
          5,
          enumPlayerUse.american,
          enumCardNegate.neither,
          enumUnitType.heavyweapon,
          gfxAttack45American));
    }
    // sniper x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.sniper,
          enumCardType.attack,
          5,
          6,
          enumPlayerUse.both,
          enumCardNegate.neither,
          enumUnitType.sniper,
          gfxAttack56Sniper));
    }
    // crawl x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.crawl,
          enumCardType.move,
          1,
          1,
          enumPlayerUse.both,
          enumCardNegate.neither,
          enumUnitType.all,
          gfxMove1));
    } // march x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.march,
          enumCardType.move,
          2,
          2,
          enumPlayerUse.both,
          enumCardNegate.neither,
          enumUnitType.all,
          gfxMove2));
    } // double time x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.doubletime,
          enumCardType.move,
          3,
          3,
          enumPlayerUse.both,
          enumCardNegate.neither,
          enumUnitType.all,
          gfxMove3));
    } // zig zag x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.zigzag,
          enumCardType.move,
          -1,
          -1,
          enumPlayerUse.both,
          enumCardNegate.neither,
          enumUnitType.all,
          gfxMoveZ));
    }
    // run x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.run,
          enumCardType.move,
          4,
          4,
          enumPlayerUse.both,
          enumCardNegate.neither,
          enumUnitType.all,
          gfxMove4));
    } // charge x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.charge,
          enumCardType.move,
          5,
          5,
          enumPlayerUse.both,
          enumCardNegate.neither,
          enumUnitType.all,
          gfxMove5));
    }
    // advance x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.advance,
          enumCardType.move,
          2,
          2,
          enumPlayerUse.german,
          enumCardNegate.neither,
          enumUnitType.all,
          gfxMove2German));
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
          enumUnitType.all,
          gfxMove3American));
    } // smoke x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.smoke,
          enumCardType.terrain,
          0,
          0,
          enumPlayerUse.both,
          enumCardNegate.attack,
          enumUnitType.all,
          gfxNegateAttack));
    } // artillery x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.artillery,
          enumCardType.terrain,
          0,
          0,
          enumPlayerUse.american,
          enumCardNegate.attack,
          enumUnitType.all,
          gfxNegateAttackAmerican));
    } // wire x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.wire,
          enumCardType.terrain,
          0,
          0,
          enumPlayerUse.both,
          enumCardNegate.move,
          enumUnitType.all,
          gfxNegateMove));
    }
    // landmine x3
    for (int i = 0; i < 3; i++) {
      c.add(GameCard(
          enumCardName.landmine,
          enumCardType.terrain,
          0,
          0,
          enumPlayerUse.german,
          enumCardNegate.move,
          enumUnitType.all,
          gfxNegateMoveGerman));
    }

    c.shuffle();

    return c;
  }
}
