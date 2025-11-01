const appTitle = "Fix Bayonets!";
const appSplashGraphic = "assets/images/fix_bayonets_splash.jpg";
const appVersion = "Version 2.0, November 2025";
const sdsLogo = "assets/images/sds_logo.png";
const constAppTitleFont = "UnifrakturCook";
const constAppTextFont = "Caudex";

const constMapRows = 8;
const constMapCols = 8; 
const constMapSize = 63;
const constInvalidUnit = -99;
const constMaxCardsInHand = 3;
const constNoCardSelected = -1;
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
const gfxAttack1 = "assets/images/card_attack_1.png";
const gfxAttack2Officer = "assets/images/card_attack_2_officer.png";
const gfxAttack23German = "assets/images/card_attack_2-3_ger.png";
const gfxAttack3 = "assets/images/card_attack_3.png";
const gfxAttack4 = "assets/images/card_attack_4.png";
const gfxAttack5 = "assets/images/card_attack_5.png";
const gfxAttackZ = "assets/images/card_attack_z.png";
const gfxAttack45American = "assets/images/card_attack_4-5_usa.png";
const gfxAttack56Sniper = "assets/images/card_attack_5-6_sniper.png";
const gfxMove1 = "assets/images/card_move_1.png";
const gfxMove2 = "assets/images/card_move_2.png";
const gfxMove3 = "assets/images/card_move_3.png";
const gfxMove4 = "assets/images/card_move_4.png";
const gfxMove5 = "assets/images/card_move_5.png";
const gfxMoveZ = "assets/images/card_move_z.png";
const gfxMove2German = "assets/images/card_move_2_ger.png";
const gfxMove3American = "assets/images/card_move_3_usa.png";
const gfxNegateMove = "assets/images/card_negate_move.jpg";
const gfxNegateAttack = "assets/images/card_negate_attack.png";
const gfxNegateMoveGerman = "assets/images/card_negate_move_ger.png";
const gfxNegateAttackAmerican = "assets/images/card_negate_attack_usa.png";

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

const constStackedUnitPickerOrdersMessage = "Units in this map hex:";
const constStackedUnitPickerMoveMessage = "Select an eligible unit to move, or Cancel to return.";
const constStackedUnitPickerAttackMessage = "Select a unit to attack with, or Cancel to return.";
const constOrdersPhaseMessage =
    "Review your cards. If you have more than 3, you must discard some.";
const constMovePhaseMessage =
    "Choose a Move card, select an eligible unit, and then pick a destination hex.";
const constAttackPhaseMessage =
    "Choose an Attack card, select an eligible unit, and then a target.";
const constYourHandMessage = "Your\r\nCards:";
const constVictoryMessage =
    "Congratulations, you killed both German officers. Their attack has been stopped!";
const constDefeatMessage =
    "The German forces have killed your officers and overrun your postion. You lost!";

// card notes 
const constCardBayonet = "Bayonet attack card.";
const constCardPistol = "Pistol attack card. Only Officer units can use.";
const constCardFlamethrower =
    "Flamethrower attack card. Only German Heavy Weapons units can use.";
const constCardGrenade = "Grenade attack card.";
const constCardRifle = "Rifle attack card.";
const constCardMachineGun =
    "Machine Gun attack card. Only American Heavy Weapons can use.";
const constCardSniper = "Sniper attack card. Only Sniper units can use. ";
const constCardCrawl = "Crawl move card.";
const constCardMarch = "March move card.";
const constCardDoubletime = "Double time move card.";
const constCardZigzag = "Combat rush move card.";
const constCardRun = "Run move card.";
const constCardCharge = "Charge move card.";
const constCardAdvance = "Advance move card. Only German unit can use.";
const constCardCounterattack =
    "Counter Attack move card. Only American units can use.";
const constCardSmoke = "Negate an attack with smoke.";
const constCardArtillery =
    "Negate an attack with artillery. Only American units can use.";
const constCardWire = "Negate a move with wire.";
const constCardLandmine =
    "Negate a move with land mines. Only German units can use.";

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