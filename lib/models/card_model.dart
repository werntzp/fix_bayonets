import 'package:fix_bayonets/const.dart';
import 'dart:math';

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

  GameCard(this.id, this.name, this.type, this.minrange, this.maxrange,
      this.player, this.negate, this.useby, this.graphic);
}

class CardFactory {
  List<GameCard> _masterDeck = [];
  List<GameCard> _drawPile = [];
  List<GameCard> _americanHand = [];
  List<GameCard> _germanHand = [];
  List<GameCard> _discardPile = [];
  List<GameCard> _selected = [];

  CardFactory();

  void clearSelectedCards() {
    _selected.clear();
  }

  void discardCards(EnumPlayer player) {
    for (GameCard c in _selected) {
      _discardPile.add(c);
      if (player == EnumPlayer.american) {
        _americanHand.removeWhere((element) => element.id == c.id);
      } else {
        _germanHand.removeWhere((element) => element.id == c.id);
      }
    }

    clearSelectedCards();
  }

  EnumCardName getCardNameById(int id) {
    return _masterDeck.firstWhere((element) => element.id == id).name;
  }

  GameCard getCardById(int id) {
    return _masterDeck.firstWhere((element) => element.id == id);
  }

  void discardSelectedCard() {
    _discardPile.add(_selected[0]);
    _americanHand.removeWhere((element) => element.id == _selected[0].id);
    clearSelectedCards();
  }

  GameCard getSelectedCard() {
    if (_selected.isNotEmpty) {
      return _selected[0];
    } else {
      throw Exception('No card has been selected');
    }
  }

  void toggleSelected(int id, bool multiselect) {
    if (multiselect) {
      // if they are picking a card that's already selected, clear it
      GameCard card = _masterDeck[id];
      if (_selected.contains(card)) {
        _selected.removeWhere((element) => element.id == id);
      } else {
        // allowed to have more than one card selected (b/c they need to discard)
        _selected.add(_masterDeck.firstWhere((element) => element.id == id));
      }
    } else {
      clearSelectedCards();
      _selected.add(_masterDeck.singleWhere((element) => element.id == id));
    }
  }

  bool isCardSelected(int id) {
    try {
      GameCard card = _masterDeck.firstWhere((element) => element.id == id);
      return _selected.contains(card);
    } catch (e) {
      print('error ' + e.toString());
      throw Exception('No card has been selected');
    }
  }

  List<GameCard> americanHand() {
    return _americanHand;
  }

  List<GameCard> germanHand() {
    return _germanHand;
  }

  bool cardsSelected() {
    return _selected.isNotEmpty;
  }

  void discardOtherPlayersCards(EnumPlayer currentPlayer) {
    currentPlayer == EnumPlayer.american
        ? _discardAmericanCards()
        : _discardGermanCards();
  }

  void _discardAmericanCards() {
    List<int> remove = [];
    for (GameCard card in _germanHand) {
      if (card.player == EnumPlayerUse.american) {
        // move that card to the discard pile
        _discardPile.add(card);
        remove.add(card.id);
      }
    }

    // remove any cards now
    for (int i = 0; i < remove.length; i++) {
      _germanHand.removeWhere((element) => element.id == remove[i]);
    }
  }

  void _discardGermanCards() {
    List<int> remove = [];
    for (GameCard card in _americanHand) {
      if (card.player == EnumPlayerUse.german) {
        // move that card to the discard pile
        _discardPile.add(card);
        remove.add(card.id);
      }
    }

    // remove any cards now
    for (int i = 0; i < remove.length; i++) {
      _germanHand.removeWhere((element) => element.id == remove[i]);
    }
  }

  bool germanCanNegate(EnumCardNegate phase) {
    bool canNegate = false;

    // make sure card valid for this phase, and isn't restricted to the american player
    for (GameCard card in _germanHand) {
      if ((card.negate == phase) && (card.useby != EnumPlayerUse.american)) {
        // instead of always negating when they can, make it a 30% shot
        if (Random().nextInt(3) == 0) {
          // set the flag
          canNegate = true;
          // move that card to the discard pile
          _discardPile.add(card);
          _germanHand.removeWhere((element) => element.id == card.id);
          break;
        }
      }
    }

    return canNegate;
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

    // draw cards for american
    for (int i = 0; i < constAmericanMaxCardsInHand; i++) {
      _americanHand.add(_drawPile[i]);
      _drawPile.remove(_drawPile[i]);
    }

    // check german hand -- only draw if 3 or fewer cards
    int diff = _germanHand.length;
    if (diff < constGermanMaxCardsInHand) {
      // draw up
      for (int i = 0; i < (constGermanMaxCardsInHand - diff); i++) {
        _germanHand.add(_drawPile[i]);
        _drawPile.remove(_drawPile[i]);
      }
    }
  }

  void prepareInitialDeck() {
    int id = constNoCardSelected;

    // bayonet x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.bayonet,
          EnumCardType.attack,
          1,
          1,
          EnumPlayerUse.both,
          EnumCardNegate.neither,
          EnumUnitType.all,
          gfxAttack1));
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
          EnumUnitType.heavyweapon,
          gfxAttack23German));
    }
    // grenade x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          EnumCardName.grenade,
          EnumCardType.attack,
          constZigZag,
          constZigZag,
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
          EnumCardName.grenade,
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
          EnumUnitType.heavyweapon,
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
          constZigZag,
          constZigZag,
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

    _drawPile = List.from(_masterDeck);
    clearSelectedCards();
    _drawPile.shuffle();
  }
}
