import 'package:fix_bayonets/const.dart';

class GameModel {
  int round = 1;
  EnumPhase phase = EnumPhase.orders;
  EnumPlayer player = EnumPlayer.american;

  GameModel();

  String getUnitFriendlyName(EnumUnitType unitType) {
    String name = "";

    // format the type of unit killed nicely
    if (unitType == EnumUnitType.heavyweapon) {
      name = "Heavy Weapon";
    } else if (unitType == EnumUnitType.officer) {
      name = "Officer";
    } else if (unitType == EnumUnitType.rifleman) {
      name = "Rifleman";
    } else if (unitType == EnumUnitType.runner) {
      name = "Runner";
    } else {
      name = "Sniper";
    }

    return name;
  }

  void incrementPhase() {
    // if we throw an error incrementing the phase, we've got too far,
    try {
      phase = EnumPhase.values[phase.index + 1];
    } catch (e) {
      phase = EnumPhase.orders;
    }

    // if we cycle through to a new orders phase,
    if (phase == EnumPhase.orders) {
      // if german player, increment the round
      if (player == EnumPlayer.german) {
        round++;
      }
      // switch the player
      player == EnumPlayer.german
          ? player = EnumPlayer.american
          : player = EnumPlayer.german;
    }
  }

  void newGame() {
    round = 1;
    phase = EnumPhase.orders;
    player = EnumPlayer.american;
  }

  void jump() {
    round++;
    phase = EnumPhase.orders;
    player = EnumPlayer.american;
  }

  String displayPlayer() {
    return player == EnumPlayer.german ? gfxGermanFlag : gfxAmericanFlag;
  }
}
