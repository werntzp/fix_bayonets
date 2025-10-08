const appTitle = "Fix Bayonets!";
const appSplashGraphic = "images/fix_bayonets_splash.jpg";
const appVersion = "Version 1.2, October 2025";
const sdsLogo = "images/sds_logo.png";

const constSpecialMove = 99;
const constSpecialAttack = 100;
const constInvalidUnit = -99;
const constMapSize = 63;
const constAmericanMaxCardsInHand = 3;
const constGermanMaxCardsInHand = 3;
const constNoCardSelected = -1;
const constZigZag = -1;
const constValidSpace = 1;
const constInvalidSpace = -1;
const gfxMoveGreen = "images/green43x43.png";
const gfxMoveRed = "images/red43x43.png";
const gfxStartSquare = "images/grey43x43.png";
const gfxAmericanFlag = "images/american_flag.png";
const gfxGermanFlag = "images/german_flag.png";
const gfxForest = "images/forest42x42.png"; // 0xff6b8e23
const gfxOpen = "images/open42x42.png"; // 0xff7c9c3b
const gfxThick = "images/thick42x42.png"; // 0xff536e1c
const gfxUsStacked = "images/us_multiple.png";
const gfxGermanStacked = "images/german_multiple.png";
const gfxGermanSingle = "images/german_single.png";
const gfxGermanOfficer = "images/german_officer";
const gfxGermanRifle = "images/german_rifle";
const gfxGermanHeavy = "images/german_machinegun";
const gfxGermanRunner = "images/german_runner";
const gfxGermanSniper = "images/german_sniper";
const gfxUsOfficer = "images/us_officer";
const gfxUsRifle = "images/us_rifle";
const gfxUsHeavy = "images/us_machinegun";
const gfxUsRunner = "images/us_runner";
const gfxUsSniper = "images/us_sniper";
const gfxImageType = ".png";
const gfxAttack1 = "images/attack_1.png";
const gfxAttack2Officer = "images/attack_2_officer.png";
const gfxAttack23German = "images/attack_2-3_german.png";
const gfxAttack3 = "images/attack_3.png";
const gfxAttack4 = "images/attack_4.png";
const gfxAttack5 = "images/attack_5.png";
const gfxAttackZ = "images/attack_z.png";
const gfxAttack45American = "images/attack_4-5_american.png";
const gfxAttack56Sniper = "images/attack_5-6_sniper.png";
const gfxMove1 = "images/move_1.png";
const gfxMove2 = "images/move_2.png";
const gfxMove3 = "images/move_3.png";
const gfxMove4 = "images/move_4.png";
const gfxMove5 = "images/move_5.png";
const gfxMoveZ = "images/move_z.png";
const gfxMove2German = "images/move_2_german.png";
const gfxMove3American = "images/move_3_american.png";
const gfxNegateMove = "images/negate_move.png";
const gfxNegateAttack = "images/negate_attack.png";
const gfxNegateMoveGerman = "images/negate_move_german.png";
const gfxNegateAttackAmerican = "images/negate_attack_american.png";

const constVictoryMessage =
    "Congratulations, you killed both German officers. Their attack has been stopped!";
const constDefeatMessage =
    "The German forces have killed your officers and overrun your postion. You lost!";
const constYourHand = "Your Cards:";
const constGermanPanelHeader = "German Turn Actions:";
const ordersNotice =
    'Orders Phase: Review the cards in your hand. If you have more than 3, you must discard some.';
const moveNotice =
    'Move Phase: Choose a Move (green) card, then a unit, and a valid square.';
const attackNotice =
    'Attack Phase: Choose an Attack (red) card, then a unit to attack with, and a target.';

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

enum EnumUnitType { officer, rifleman, heavyweapon, runner, sniper, all }

enum EnumUnitOwner { american, german, neither }

enum EnumUnitMoveAllowed { one, two }

enum EnumCardType { attack, move, negate }

enum EnumCardLocation { american, german, draw, discard }

enum EnumPlayerUse { american, german, both }

enum EnumCardNegate { move, attack, neither }

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

enum EnumNegateAction { yes, no }

enum EnumSpecialCard { yes, no }
