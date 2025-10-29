import '../const.dart';

class GameCard {
  final int id;
  final EnumCardName name;
  final EnumCardType type;
  final int minrange;
  final int maxrange;
  final EnumPlayerUse player;
  final EnumCardNegate negate;
  final EnumUnitType useby;
  final String graphic;
  bool selected = false;

  GameCard(this.id, this.name, this.type, this.minrange, this.maxrange,
      this.player, this.negate, this.useby, this.graphic);
}

class CardFactory {
  final List<GameCard> _masterDeck = [];

  // *********************************************
  // getCardById: return just one card  
  // *********************************************
  GameCard getCardById(int id) {
    return _masterDeck.firstWhere((element) => element.id == id);

  }

  // *********************************************
  // prepareInitialDeck: create all the cards, and
  // clear all the decks for a new game 
  // *********************************************
  List<GameCard> prepareInitialDeck() { 
    int id = constStartingCardIdNumber;

    _masterDeck.clear();

    // bayonet x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(
        GameCard(
            id,
            EnumCardName.bayonet,
            EnumCardType.attack,
            1,
            1,
            EnumPlayerUse.both,
            EnumCardNegate.neither,
            EnumUnitType.all,
            gfxAttack1),
      );
    }
    // pistol x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.pistol,
          EnumCardType.attack,
          1,
          2,
          EnumPlayerUse.both,
          EnumCardNegate.neither,
          EnumUnitType.officer,
          gfxAttack2Officer));
    }
    // flamer thrower x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.flamethrower,
          EnumCardType.attack,
          2,
          3,
          EnumPlayerUse.german,
          EnumCardNegate.neither,
          EnumUnitType.heavy,
          gfxAttack23German));
    }
    // grenade x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.grenade,
          EnumCardType.attack,
          constZigZagSpace,
          constZigZagSpace,
          EnumPlayerUse.both,
          EnumCardNegate.neither,
          EnumUnitType.all,
          gfxAttackZ));
    }
    // rifle x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.rifle,
          EnumCardType.attack,
          3,
          3,
          EnumPlayerUse.both,
          EnumCardNegate.neither,
          EnumUnitType.all,
          gfxAttack3));
    } // rifle x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.rifle,
          EnumCardType.attack,
          4,
          4,
          EnumPlayerUse.both,
          EnumCardNegate.neither,
          EnumUnitType.all,
          gfxAttack4));
    } // machine gun x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.machinegun,
          EnumCardType.attack,
          4,
          5,
          EnumPlayerUse.american,
          EnumCardNegate.neither,
          EnumUnitType.heavy,
          gfxAttack45American));
    }
    // sniper x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.sniper,
          EnumCardType.attack,
          5,
          6,
          EnumPlayerUse.both,
          EnumCardNegate.neither,
          EnumUnitType.sniper,
          gfxAttack56Sniper));
    }
    // crawl x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.crawl,
          EnumCardType.move,
          1,
          1,
          EnumPlayerUse.both,
          EnumCardNegate.neither,
          EnumUnitType.all,
          gfxMove1));
    } // march x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.march,
          EnumCardType.move,
          1,
          2,
          EnumPlayerUse.both,
          EnumCardNegate.neither,
          EnumUnitType.all,
          gfxMove2));
    } // double time x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.doubletime,
          EnumCardType.move,
          1,
          3,
          EnumPlayerUse.both,
          EnumCardNegate.neither,
          EnumUnitType.all,
          gfxMove3));
    } // zig zag x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.zigzag,
          EnumCardType.move,
          constZigZagSpace,
          constZigZagSpace,
          EnumPlayerUse.both,
          EnumCardNegate.neither,
          EnumUnitType.all,
          gfxMoveZ));
    }
    // run x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.run,
          EnumCardType.move,
          1,
          4,
          EnumPlayerUse.both,
          EnumCardNegate.neither,
          EnumUnitType.all,
          gfxMove4));
    } // charge x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.charge,
          EnumCardType.move,
          1,
          5,
          EnumPlayerUse.both,
          EnumCardNegate.neither,
          EnumUnitType.all,
          gfxMove5));
    }
    // advance x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.advance,
          EnumCardType.move,
          1,
          2,
          EnumPlayerUse.german,
          EnumCardNegate.neither,
          EnumUnitType.all,
          gfxMove2German));
    }
    // counter attack
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.counterattack,
          EnumCardType.move,
          1,
          3,
          EnumPlayerUse.american,
          EnumCardNegate.neither,
          EnumUnitType.all,
          gfxMove3American));
    } // smoke x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.smoke,
          EnumCardType.negate,
          0,
          0,
          EnumPlayerUse.both,
          EnumCardNegate.attack,
          EnumUnitType.all,
          gfxNegateAttack));
    } // artillery x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.artillery,
          EnumCardType.negate,
          0,
          0,
          EnumPlayerUse.american,
          EnumCardNegate.attack,
          EnumUnitType.all,
          gfxNegateAttackAmerican));
    } // wire x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.wire,
          EnumCardType.negate,
          0,
          0,
          EnumPlayerUse.both,
          EnumCardNegate.move,
          EnumUnitType.all,
          gfxNegateMove));
    }
    // landmine x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.landmine,
          EnumCardType.negate,
          0,
          0,
          EnumPlayerUse.german,
          EnumCardNegate.move,
          EnumUnitType.all,
          gfxNegateMoveGerman));
    }

    // initial shuffle, then pass cards back out 
    _masterDeck.shuffle();
    return List.from(_masterDeck); 

  }
}
