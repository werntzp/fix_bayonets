import 'package:fix_bayonets/const.dart';

class GameCard {
  final int id;
  final enumCardName name;
  final enumCardType type;
  final int minrange;
  final int maxrange;
  final enumPlayerUse player;
  final enumCardNegate negate;
  final enumUnitType useby;
  final String graphic;

  GameCard(this.id, this.name, this.type, this.minrange, this.maxrange,
      this.player, this.negate, this.useby, this.graphic);
}

class CardFactory {
  final List<bool> _selected = List.filled(60, false);
  List<GameCard> _drawPile = [];
  List<GameCard> _playerHand = [];
  List<GameCard> _computerHand = [];
  List<GameCard> _discardPile = [];

  CardFactory();

  void clearSelectedCards() {
    for (int i = 0; i < _selected.length; i++) {
      _selected[i] = false;
    }
  }

  void discardCards() {
    List<GameCard> toRemove = [];

    for (int i = 0; i < _selected.length; i++) {
      if (_selected[i]) {
        _discardPile.add(_playerHand[i]);
        toRemove.add(_playerHand[i]);
      }

      _playerHand.removeWhere((c) => toRemove.contains(c));
      clearSelectedCards();
    }
  }

  void toggleSelected(int id, bool multiselect) {
    if (multiselect) {
      // allowed to have more than one card selected (b/c they need to discard)
      _selected[id] = !_selected[id];
    } else {
      // only one card allowed to be selected
      clearSelectedCards();
      _selected[id] = true;
    }
  }

  bool isCardSelected(int id) {
    return _selected[id];
  }

  List<GameCard> playerHand() {
    return _playerHand;
  }

  void drawCards() {
    // if not six cards, move cards from discard to draw and shuffle
    if (_drawPile.length < 6) {
      for (GameCard c in _discardPile) {
        _drawPile.add(c);
      }
      _discardPile.clear();
      _drawPile.shuffle();
    }

    // draw 3 cards for american and german
    for (int i = 0; i < 3; i++) {
      _playerHand.add(_drawPile[i]);
      _drawPile.remove(_drawPile[i]);
    }

    for (int i = 0; i < 3; i++) {
      _computerHand.add(_drawPile[i]);
      _drawPile.remove(_drawPile[i]);
    }
  }

  void prepareInitialDeck() {
    int id = -1;

    // bayonet x3
    for (int i = 0; i < 3; i++) {
      id++;
      _drawPile.add(GameCard(
          id,
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
      id++;
      _drawPile.add(GameCard(
          id,
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
      id++;
      _drawPile.add(GameCard(
          id,
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
      id++;
      _drawPile.add(GameCard(
          id,
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
      id++;
      _drawPile.add(GameCard(
          id,
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
      id++;
      _drawPile.add(GameCard(
          id,
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
      id++;
      _drawPile.add(GameCard(
          id,
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
      id++;
      _drawPile.add(GameCard(
          id,
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
      id++;
      _drawPile.add(GameCard(
          id,
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
      id++;
      _drawPile.add(GameCard(
          id,
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
      id++;
      _drawPile.add(GameCard(
          id,
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
      id++;
      _drawPile.add(GameCard(
          id,
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
      id++;
      _drawPile.add(GameCard(
          id,
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
      id++;
      _drawPile.add(GameCard(
          id,
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
      id++;
      _drawPile.add(GameCard(
          id,
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
      id++;
      _drawPile.add(GameCard(
          id,
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
      id++;
      _drawPile.add(GameCard(
          id,
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
      id++;
      _drawPile.add(GameCard(
          id,
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
      id++;
      _drawPile.add(GameCard(
          id,
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
      id++;
      _drawPile.add(GameCard(
          id,
          enumCardName.landmine,
          enumCardType.terrain,
          0,
          0,
          enumPlayerUse.german,
          enumCardNegate.move,
          enumUnitType.all,
          gfxNegateMoveGerman));
    }

    clearSelectedCards();
    _drawPile.shuffle();
  }
}
