enum enumPhase { orders, move, fight }

class GameModel {
  int _currentRound = 1;
  enumPhase _currentPhase = enumPhase.orders;

  GameModel();

  void newGame() {
    _currentRound = 1;
    _currentPhase = enumPhase.orders;
  }

  void incrementRound() {
    _currentRound++;
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
