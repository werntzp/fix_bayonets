import 'package:fix_bayonets/const.dart';

enum enumPhase { orders, move, fight }

class GameModel {
  int _currentRound = 1;
  enumPhase _currentPhase = enumPhase.orders;
  enumCurrentPlayer currentPlayer = enumCurrentPlayer.american;
  bool _bottomOfRound = true;

  GameModel();

  void incrementPhase() {
    if (_currentPhase == enumPhase.orders) {
      _currentPhase = enumPhase.move;
    } else if (_currentPhase == enumPhase.move) {
      _currentPhase = enumPhase.fight;
    } else {
      _currentPhase = enumPhase.orders;
      // if we're in the bottom of the round (american), set flag to false,
      // otherwise, set back to bottom and then switch player
      if (_bottomOfRound) {
        _bottomOfRound = false;
        currentPlayer = enumCurrentPlayer.german;
      } else {
        _bottomOfRound = true;
        currentPlayer = enumCurrentPlayer.american;
        _currentRound++;
      }
    }
  }

  void jump() {
    _currentRound++;
    _bottomOfRound = true;
    _currentPhase = enumPhase.orders;
    currentPlayer = enumCurrentPlayer.american;
  }

  void newGame() {
    _currentRound = 1;
    _currentPhase = enumPhase.orders;
    currentPlayer = enumCurrentPlayer.american;
    _bottomOfRound = true;
  }

  void incrementRound() {
    _currentRound++;
    _bottomOfRound = true;
  }

  enumPhase getPhase() {
    return _currentPhase;
  }

  int getRound() {
    return _currentRound;
  }

  String displayPlayer() {
    if (currentPlayer == enumCurrentPlayer.american) {
      return gfxAmericanFlag;
    } else {
      return gfxGermanFlag;
    }
  }

  String displayRound() {
    return _currentRound.toString();
  }

  String displayPhase() {
    String t = 'Orders';

    if (_currentPhase == enumPhase.orders) {
      t = 'Orders';
    } else if (_currentPhase == enumPhase.fight) {
      t = 'Fight';
    } else {
      t = 'Move';
    }

    return t;
  }
}
