import 'package:fix_bayonets/const.dart';

enum enumPhase { orders, move, fight }

class GameModel {
  int round = 1;
  enumPhase phase = enumPhase.orders;
  enumPlayer player = enumPlayer.american;

  GameModel();

  void incrementPhase() {
    // if we throw an error incrementing the phase, we've got too far,
    try {
      phase = enumPhase.values[phase.index + 1];
    } catch (e) {
      phase = enumPhase.orders;
    }

    // if we cycle through to a new orders phase,
    if (phase == enumPhase.orders) {
      // if german player, increment the round
      if (player == enumPlayer.german) {
        round++;
      }
      // switch the player
      player == enumPlayer.german
          ? player = enumPlayer.american
          : player = enumPlayer.german;
    }
  }

  void newGame() {
    round = 1;
    phase = enumPhase.orders;
    player = enumPlayer.american;
  }

  void jump() {
    round++;
    phase = enumPhase.orders;
    player = enumPlayer.american;
  }

  String displayPlayer() {
    return player == enumPlayer.german ? gfxGermanFlag : gfxAmericanFlag;
  }
}
