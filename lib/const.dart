const appTitle = "Fix Bayonets!";
const appSplashGraphic = "images/fix_bayonets_splash.jpg";
const appVersion = "Version 1.0, May 2022";
const sdsLogo = "images/sds_logo.png";

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
const gfxGermanOfficer = "images/german_officer.png";
const gfxGermanRifle = "images/german_rifle.png";
const gfxGermanHeavy = "images/german_machinegun.png";
const gfxGermanRunner = "images/german_runner.png";
const gfxGermanSniper = "images/german_sniper.png";
const gfxUsOfficer = "images/us_officer.png";
const gfxUsRifle = "images/us_rifle.png";
const gfxUsHeavy = "images/us_machinegun.png";
const gfxUsRunner = "images/us_runner.png";
const gfxUsSniper = "images/us_sniper.png";
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
const ordersNotice =
    'Orders Phase: Review the cards in your hand. If you have more than 3, you must discard some.';
const moveNotice =
    'Move Phase: Choose a Move (green) card, then a unit, and a valid square.';
const attackNotice =
    'Attack Phase: Choose an Attack (red) card, then a unit to attack with, and a target.';

enum enumCurrentPlayer { american, german }
enum enumUnitType { officer, rifleman, heavyweapon, runner, sniper, all }
enum enumUnitOwner { american, german, neither }
enum enumUnitMoveAllowed { one, two }
enum enumCardType { attack, move, terrain }
enum enumCardLocation { americanhand, germanhand, draw, discard }
enum enumPlayerUse { american, german, both }
enum enumCardNegate { move, attack, neither }
enum enumCardName {
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
