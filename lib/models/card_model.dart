import 'package:fix_bayonets/const.dart';
import 'package:fix_bayonets/models/game_model.dart';
import 'dart:math';

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

  void discardCards(enumPlayer player) {
    for (GameCard c in _selected) {
      _discardPile.add(c);
      if (player == enumPlayer.american) {
        _americanHand.removeWhere((element) => element.id == c.id);
      } else {
        _germanHand.removeWhere((element) => element.id == c.id);
      }
    }

    clearSelectedCards();
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

  void discardOtherPlayersCards(enumPlayer currentPlayer) {
    currentPlayer == enumPlayer.american
        ? _discardAmericanCards()
        : _discardGermanCards();
  }

  void _discardAmericanCards() {
    List<int> remove = [];
    for (GameCard card in _germanHand) {
      if (card.player == enumPlayerUse.american) {
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
      if (card.player == enumPlayerUse.german) {
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

  bool germanCanNegate(enumCardNegate phase) {
    bool canNegate = false;

    // make sure card valid for this phase, and isn't restricted to the american player
    for (GameCard card in _germanHand) {
      if ((card.negate == phase) && (card.useby != enumPlayerUse.american)) {
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

    // draw 3 cards for american
    for (int i = 0; i < 3; i++) {
      _americanHand.add(_drawPile[i]);
      _drawPile.remove(_drawPile[i]);
    }

    // check german hand -- only draw if 3 or fewer cards
    if (_germanHand.length < 3) {
      // only draw up to 3 total
      for (int i = 0; i < (constMaxCardsInHand - _germanHand.length); i++) {
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
      _masterDeck.add(GameCard(
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
      _masterDeck.add(GameCard(
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
      _masterDeck.add(GameCard(
          id,
          enumCardName.grenade,
          enumCardType.attack,
          constZigZag,
          constZigZag,
          enumPlayerUse.both,
          enumCardNegate.neither,
          enumUnitType.all,
          gfxAttackZ));
    }
    // rifle x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
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
      _masterDeck.add(GameCard(
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
      _masterDeck.add(GameCard(
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
      _masterDeck.add(GameCard(
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
      _masterDeck.add(GameCard(
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
      _masterDeck.add(GameCard(
          id,
          enumCardName.march,
          enumCardType.move,
          1,
          2,
          enumPlayerUse.both,
          enumCardNegate.neither,
          enumUnitType.all,
          gfxMove2));
    } // double time x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          enumCardName.doubletime,
          enumCardType.move,
          1,
          3,
          enumPlayerUse.both,
          enumCardNegate.neither,
          enumUnitType.all,
          gfxMove3));
    } // zig zag x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          enumCardName.zigzag,
          enumCardType.move,
          constZigZag,
          constZigZag,
          enumPlayerUse.both,
          enumCardNegate.neither,
          enumUnitType.all,
          gfxMoveZ));
    }
    // run x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          enumCardName.run,
          enumCardType.move,
          1,
          4,
          enumPlayerUse.both,
          enumCardNegate.neither,
          enumUnitType.all,
          gfxMove4));
    } // charge x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          enumCardName.charge,
          enumCardType.move,
          1,
          5,
          enumPlayerUse.both,
          enumCardNegate.neither,
          enumUnitType.all,
          gfxMove5));
    }
    // advance x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          enumCardName.advance,
          enumCardType.move,
          1,
          2,
          enumPlayerUse.german,
          enumCardNegate.neither,
          enumUnitType.all,
          gfxMove2German));
    }
    // counter attack
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          enumCardName.counterattack,
          enumCardType.move,
          1,
          3,
          enumPlayerUse.american,
          enumCardNegate.neither,
          enumUnitType.all,
          gfxMove3American));
    } // smoke x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          enumCardName.smoke,
          enumCardType.negate,
          0,
          0,
          enumPlayerUse.both,
          enumCardNegate.attack,
          enumUnitType.all,
          gfxNegateAttack));
    } // artillery x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          enumCardName.artillery,
          enumCardType.negate,
          0,
          0,
          enumPlayerUse.american,
          enumCardNegate.attack,
          enumUnitType.all,
          gfxNegateAttackAmerican));
    } // wire x3
    for (int i = 0; i < 3; i++) {
      id++;
      _masterDeck.add(GameCard(
          id,
          enumCardName.wire,
          enumCardType.negate,
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
      _masterDeck.add(GameCard(
          id,
          enumCardName.landmine,
          enumCardType.negate,
          0,
          0,
          enumPlayerUse.german,
          enumCardNegate.move,
          enumUnitType.all,
          gfxNegateMoveGerman));
    }

    _drawPile = List.from(_masterDeck);
    clearSelectedCards();
    _drawPile.shuffle();
  }
}
