import 'package:fix_bayonets/const.dart';

enum enumPhase { orders, move, fight }

class GameModel {
  int _currentRound = 1;
  enumPhase _currentPhase = enumPhase.orders;
  enumCurrentPlayer _currentPlayer = enumCurrentPlayer.american;

  GameModel();

  void advancePhase() {
    if (_currentPhase == enumPhase.orders) {
      _currentPhase = enumPhase.move;
    } else if (_currentPhase == enumPhase.move) {
      _currentPhase = enumPhase.fight;
    } else {
      _currentPhase = enumPhase.orders;
      _currentRound++;
      if (_currentPlayer == enumCurrentPlayer.american) {
        _currentPlayer = enumCurrentPlayer.german;
      } else {
        _currentPlayer = enumCurrentPlayer.american;
      }
    }
  }

  void newGame() {
    _currentRound = 1;
    _currentPhase = enumPhase.orders;
    _currentPlayer = enumCurrentPlayer.american;
  }

  void incrementRound() {
    _currentRound++;
  }

  enumPhase getPhase() {
    return _currentPhase;
  }

  int getRound() {
    return _currentRound;
  }

  void swtichPlayer() {
    if (_currentPlayer == enumCurrentPlayer.american) {
      _currentPlayer = enumCurrentPlayer.german;
    } else {
      _currentPlayer = enumCurrentPlayer.american;
    }
  }

  void incrementPhase() {
    if (_currentPhase == enumPhase.orders) {
      _currentPhase = enumPhase.move;
    } else if (_currentPhase == enumPhase.move) {
      _currentPhase = enumPhase.fight;
    } else {
      _currentPhase = enumPhase.orders;
    }
  }

  String displayPlayer() {
    if (_currentPlayer == enumCurrentPlayer.american) {
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
