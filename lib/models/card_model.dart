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
  final EnumSpecialCard special;

  GameCard(this.id, this.name, this.type, this.minrange, this.maxrange,
      this.player, this.negate, this.useby, this.graphic, this.special);
}

class CardFactory {
  final List<GameCard> _masterDeck = [];
  List<GameCard> _drawPile = [];
  final List<GameCard> _americanHand = [];
  final List<GameCard> _germanHand = [];
  final List<GameCard> _discardPile = [];
  final List<GameCard> _selected = [];
  bool _toggleSpecialMove = false;
  bool _toggleSpecialAttack = false;

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

    // if german player, also see if we need to discard their special cards
    if (player == EnumPlayer.german) {
      if (_toggleSpecialMove) {
        _germanHand.removeWhere((element) => element.id == constSpecialMove);
        _toggleSpecialMove = false;
      }
      if (_toggleSpecialAttack) {
        _germanHand.removeWhere((element) => element.id == constSpecialAttack);
        _toggleSpecialAttack = false;
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

  void _discardSpecialGermanCard(int id) {
    // special card, so just drop it (doesn't go to discard pile)
    _germanHand.removeWhere((element) => element.id == id);
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
    // first check, are either of these the german special cards?
    if (id == constSpecialMove) {
      _toggleSpecialMove = true;
      return;
    }
    if (id == constSpecialAttack) {
      _toggleSpecialAttack = true;
      return;
    }

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
      try {
        _selected.add(_masterDeck.singleWhere((element) => element.id == id));
      } catch (e) {
        // do nothing
      }
    }
  }

  bool isCardSelected(int id) {
    try {
      GameCard card = _masterDeck.firstWhere((element) => element.id == id);
      return _selected.contains(card);
    } catch (e) {
      print('error $e');
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

    // discard any american cards in the german hand
    for (int i = 0; i < _germanHand.length; i++) {
      if (_germanHand[i].player == EnumPlayerUse.american) {
        _germanHand.removeAt(i);
      }
    }

    // if we still have 3, just drop one so they are always picking up
    if (_germanHand.length == constGermanMaxCardsInHand) {
      _germanHand.removeAt(0);
    }

    int diff = _germanHand.length;

    if (diff < constGermanMaxCardsInHand) {
      // draw up
      for (int i = 0; i < (constGermanMaxCardsInHand - diff); i++) {
        _germanHand.add(_drawPile[i]);
        _drawPile.remove(_drawPile[i]);
      }
    }

    // add two special cards so German always has a move and an attack
    // unless they are already in the german player's hand
    bool hasSpecialMove = false;
    bool hasSpecialAttack = false;

    for (GameCard card in _germanHand) {
      if ((card.special == EnumSpecialCard.yes) &&
          (card.type == EnumCardType.move)) {
        hasSpecialMove = true;
        break;
      }
    }

    for (GameCard card in _germanHand) {
      if ((card.special == EnumSpecialCard.yes) &&
          (card.type == EnumCardType.attack)) {
        hasSpecialAttack = true;
        break;
      }
    }

    if (!hasSpecialMove) {
      _germanHand.add(GameCard(
          constSpecialMove,
          EnumCardName.run,
          EnumCardType.move,
          1,
          Random().nextInt(4) + 1,
          EnumPlayerUse.german,
          EnumCardNegate.neither,
          EnumUnitType.all,
          gfxMove4,
          EnumSpecialCard.yes));
    }

    if (!hasSpecialAttack) {
      _germanHand.add(GameCard(
          constSpecialAttack,
          EnumCardName.rifle,
          EnumCardType.attack,
          1,
          Random().nextInt(2) + 1,
          EnumPlayerUse.german,
          EnumCardNegate.neither,
          EnumUnitType.all,
          gfxAttack3,
          EnumSpecialCard.yes));
    }

    // all done
  }

  void prepareInitialDeck() {
    int id = constNoCardSelected;

    _masterDeck.clear();
    _drawPile.clear();
    _americanHand.clear();
    _germanHand.clear();
    _discardPile.clear();
    _selected.clear();

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
            gfxAttack1,
            EnumSpecialCard.no),
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
          gfxAttack2Officer,
          EnumSpecialCard.no));
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
          gfxAttack23German,
          EnumSpecialCard.no));
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
          gfxAttackZ,
          EnumSpecialCard.no));
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
          gfxAttack3,
          EnumSpecialCard.no));
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
          gfxAttack4,
          EnumSpecialCard.no));
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
          gfxAttack45American,
          EnumSpecialCard.no));
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
          gfxAttack56Sniper,
          EnumSpecialCard.no));
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
          gfxMove1,
          EnumSpecialCard.no));
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
          gfxMove2,
          EnumSpecialCard.no));
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
          gfxMove3,
          EnumSpecialCard.no));
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
          gfxMoveZ,
          EnumSpecialCard.no));
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
          gfxMove4,
          EnumSpecialCard.no));
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
          gfxMove5,
          EnumSpecialCard.no));
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
          gfxMove2German,
          EnumSpecialCard.no));
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
          gfxMove3American,
          EnumSpecialCard.no));
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
          gfxNegateAttack,
          EnumSpecialCard.no));
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
          gfxNegateAttackAmerican,
          EnumSpecialCard.no));
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
          gfxNegateMove,
          EnumSpecialCard.no));
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
          gfxNegateMoveGerman,
          EnumSpecialCard.no));
    }

    _drawPile = List.from(_masterDeck);
    clearSelectedCards();
    _drawPile.shuffle();
  }
}
