import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameDetector {
  static final Map<String, String> gamePackages = {
    'com.pubg.imobile': 'BGMI',
    'com.dts.freefireth': 'Free Fire',
    'com.activision.callofduty.shooter': 'COD Mobile',
    'com.mojang.minecraftpe': 'Minecraft',
    'com.chess': 'Chess',
    'com.supercell.clashroyale': 'Clash Royale',
    'com.pokemonunite': 'Pokemon Unite',
    'com.garena.game.garena': 'Garena Games',
    'com.ea.gp.fifamobile': 'FIFA Mobile',
    'com.king.candycrushsaga': 'Candy Crush',
    'com.zeptolab.cats': 'Cut the Rope',
    'com.kiloo.subwaysurfers': 'Subway Surfers',
    'com.fingersoft.hillclimb': 'Hill Climb Racing',
    'com.gameloft.android.ANMP.GloftA8HM': 'Asphalt 8',
    'com.ea.game.fifa14_row': 'FIFA 14',
    'com.nianticlabs.pokemongo': 'Pokemon GO',
    'com.ubisoft.mightyquest': 'Mighty Quest',
    'com.scopely.headball': 'Head Ball 2',
    'com.miniclip.8ballpool': '8 Ball Pool',
  };

  String? detectGame(String packageName) {
    return gamePackages[packageName];
  }

  bool isGame(String packageName) {
    return gamePackages.containsKey(packageName);
  }

  String getGameReaction(String gameName, String gameState) {
    switch (gameState) {
      case 'playing':
        return _getPlayingReaction(gameName);
      case 'victory':
        return _getVictoryReaction();
      case 'defeat':
        return _getDefeatReaction();
      case 'loading':
        return _getLoadingReaction();
      default:
        return _getDefaultReaction(gameName);
    }
  }

  String _getPlayingReaction(String gameName) {
    final reactions = [
      'Enemy ahead! Watch out! 👀',
      'Push! You got this! 💪',
      'Heal up before it\'s too late!',
      'Clutch this! I believe in you! 🔥',
      'Reload! Reload! 🔫',
      'Focus! You\'re doing great! 🎯',
      'Nice play! Keep it up! ⭐',
      'Don\'t give up! Fight! ⚔️',
    ];

    return reactions[(DateTime.now().millisecond) % reactions.length];
  }

  String _getVictoryReaction() {
    return [
      'VICTORY! You\'re amazing! 🏆',
      'WE WON! Celebration time! 🎉',
      'You crushed it! Legend! 👑',
      '*confetti explosion* You\'re the best!',
      'GG! That was incredible! 🌟',
    ][(DateTime.now().millisecond) % 5];
  }

  String _getDefeatReaction() {
    return [
      'No worries, we\'ll get \'em next round! 💪',
      'Close one! You\'ll win next time!',
      'Don\'t give up! Practice makes perfect!',
      'It\'s okay! Even pros lose sometimes.',
      'Shake it off! Come back stronger! 🔥',
    ][(DateTime.now().millisecond) % 5];
  }

  String _getLoadingReaction() {
    return [
      'Loading... Get ready! 🎮',
      'Game starting! Good luck! 🍀',
      'Time to show your skills! 💪',
      'Let\'s go! You got this! ⚡',
    ][(DateTime.now().millisecond) % 4];
  }

  String _getDefaultReaction(String gameName) {
    return [
      'Playing $gameName? Nice choice! 🎮',
      '$gameName time! Let\'s win!',
      'I\'ll be your coach for $gameName!',
      'Show them how it\'s done in $gameName!',
    ][(DateTime.now().millisecond) % 4];
  }
}

final gameDetectorProvider = Provider<GameDetector>((ref) {
  return GameDetector();
});
