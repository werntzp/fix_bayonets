const appTitle = "Fix Bayonets!";
const appSplashGraphic = "assets/images/fix_bayonets_splash.jpg";
const appVersion = "Version 2.0, November 2025";
const sdsLogo = "assets/images/sds_logo.png";
const constAppTitleFont = "UnifrakturCook";
const constAppTextFont = "Caudex";

const constMapRows = 8;
const constMapCols = 8; 
const constMaxCardsInHand = 5;
const constDrawCards = 3; 
const constStartingCardIdNumber = -1; 
const constZigZagSpace = -99;
const constInvalidSpace = -1;

// file locations
const constHelpFileLocation = "assets/pages/help.html";
const constAssetsLocation = "assets/images/";

// unit and terrain graphics 
const constDenseTerrain = "assets/images/terrain_dense";
const constLightTerrain = "assets/images/terrain_light";
const constCraterTerain = "assets/images/terrain_crater";
const constActionMove = "assets/images/action_move.jpg";
const constActionAttack = "assets/images/action_attack.jpg";
const constActionNegateMove = "assets/images/action_negate_move.jpg";
const constActionNegateAttack = "assets/images/action_negate_attack.jpg";
const constAmericanVictory = "assets/images/usa_victory.jpg";
const constGermanVictory = "assets/images/ger_victory.jpg";
const constGermanTurnStart = "assets/images/ger_turn_start.jpg";
const constAmericanFlag = "assets/images/usa_flag.png";
const constGermanFlag = "assets/images/ger_flag.jpg";

// used for unit display 
const constNoUnits = ""; 

// button text
const constButtonOK = "OK";
const constButtonCancel = "Cancel";
const constButtonContinue = "Continue";
const constButtonDiscard = "Discard";
const constButtonQuit = "Quit";
const constButtonYes = "Yes";
const constButtonNo = "No";
const constButtonHome = "Home";

// messages
const constStartingMovePhase = "Starting Move Phase";
const constSkippingMovePhase = "Skipping Move Phase";
const constStartingOrdersPhase = "Starting Orders Phase";
const constStartingAttackPhase = "Starting Attack Phase";
const constSkippingAttackPhase = "Skipping Attack Phase";
const constSkippingMoveAndAttackPhase = "Skipping Move and Attack";
const constNegateMoveMessage = "Germans negated your move!";
const constNegateAttackMessage = "Germans negated your attack!";
const constGermanTurnPrepMessage = "The Germans are planning their turn.";

const constStackedUnitPickerOrdersMessage = "Soldiers in this map hex:";
const constStackedUnitPickerMoveMessage = "Select an eligible soldier to move, or Cancel to return.";
const constStackedUnitPickerAttackMessage = "Select a soldier to attack with, or Cancel to return.";
const constOrdersPhaseMessage =
    "Review your actions. If you have more than 5, you must discard some.";
const constMovePhaseMessage =
    "Choose a Move action, select an eligible soldier, and then pick a destination hex.";
const constAttackPhaseMessage =
    "Choose an Attack action, select an eligible soldier, and then a target.";
const constYourHandMessage = "Available Actions:";
const constVictoryMessage =
    "Congratulations, you have succeeded in stopping the German attack!";
const constDefeatMessage =
    "You lost the battle! The Germans routed your forces and have overrun your postion.";

// card notes 
const constCardBayonet = "Bayonet attack card.";
const constCardPistol = "Pistol attack card. Only Officers can use.";
const constCardFlamethrower =
    "Flamethrower attack card. Only German Heavy Weapons  can use. Kills everyone in the target hex.";
const constCardGrenade = "Grenade attack card. Kills everyone in the target hex.";
const constCardRifle = "Rifle attack card.";
const constCardMachineGun =
    "Machine Gun attack card. Only American Heavy Weapons can use. Kills everyone in the target hex.";
const constCardSniper = "Sniper attack card. Only Snipers can use. ";
const constCardCrawl = "Crawl move card.";
const constCardMarch = "March move card.";
const constCardDoubletime = "Double time move card.";
const constCardZigzag = "Combat rush move card.";
const constCardRun = "Run move card.";
const constCardCharge = "Charge move card.";
const constCardAdvance = "Advance move card. Only Germans can use.";
const constCardCounterattack =
    "Counter Attack move card. Only Americans can use.";
const constCardSmoke = "Negate an attack with smoke.";
const constCardArtillery =
    "Negate an attack with artillery. Only Americans can use.";
const constCardWire = "Negate a move with wire.";
const constCardLandmine =
    "Negate a move with land mines. Only Germans can use.";

enum EnumPhase { orders, move, attack }
enum EnumMoveType { regular, zigzag }
enum EnumPlayer { american, german }
enum EnumUnitType { officer, rifleman, heavy, runner, sniper, all }
enum EnumUnitOwner { american, german, neither }
enum EnumUnitMoveAllowed { one, two }
enum EnumCardType { attack, move, negate }
enum EnumCardLocation { american, german, draw, discard }
enum EnumPlayerUse { american, german, both }
enum EnumCardNegate { move, attack, neither }
enum EnumNegateAction { yes, no }
enum EnumCardName {
  bayonet,
  pistol,
  flamethrower,
  grenade,
  rifle,
  machinegun,
  sniper,
  crawl,
  march,
  doubletime,
  zigzag,
  run,
  charge,
  advance,
  counterattack,
  smoke,
  artillery,
  wire,
  landmine
}