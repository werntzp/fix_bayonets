import 'package:fix_bayonets/models/card.dart';

import '../const.dart';

class GameModel {
  final int currenRound = 1;
  final enumTurn currentTurn = enumTurn.orders;

  GameModel();

  String displayRound() {
    return currenRound.toString();
  }

  String displayTurn() {
    String t = 'Orders';

    if (currentTurn == enumTurn.orders) {
      t = 'Orders';
    } else if (currentTurn == enumTurn.fight) {
      t = 'Fight';
    } else {
      t = 'Move';
    }

    return t;
  }
}
