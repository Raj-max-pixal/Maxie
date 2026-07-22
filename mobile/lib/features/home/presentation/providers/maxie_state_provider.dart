import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MaxieState {
  final String currentEmotion;
  final String currentActivity;
  final String currentMessage;
  final int friendshipLevel;
  final int friendshipXP;
  final bool isSleeping;
  final bool isDancing;

  MaxieState({
    this.currentEmotion = 'happy',
    this.currentActivity = 'idle',
    this.currentMessage = 'Hey! I\'m MAXie! Let\'s be friends! 🐾',
    this.friendshipLevel = 1,
    this.friendshipXP = 0,
    this.isSleeping = false,
    this.isDancing = false,
  });

  MaxieState copyWith({
    String? currentEmotion,
    String? currentActivity,
    String? currentMessage,
    int? friendshipLevel,
    int? friendshipXP,
    bool? isSleeping,
    bool? isDancing,
  }) {
    return MaxieState(
      currentEmotion: currentEmotion ?? this.currentEmotion,
      currentActivity: currentActivity ?? this.currentActivity,
      currentMessage: currentMessage ?? this.currentMessage,
      friendshipLevel: friendshipLevel ?? this.friendshipLevel,
      friendshipXP: friendshipXP ?? this.friendshipXP,
      isSleeping: isSleeping ?? this.isSleeping,
      isDancing: isDancing ?? this.isDancing,
    );
  }
}

class MaxieStateNotifier extends StateNotifier<MaxieState> {
  MaxieStateNotifier() : super(MaxieState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final box = await Hive.openBox('maxie_friendship');
    final level = box.get('friendshipLevel', defaultValue: 1);
    final xp = box.get('friendshipXP', defaultValue: 0);
    
    state = state.copyWith(
      friendshipLevel: level,
      friendshipXP: xp,
    );
  }

  Future<void> _saveState() async {
    final box = await Hive.openBox('maxie_friendship');
    await box.put('friendshipLevel', state.friendshipLevel);
    await box.put('friendshipXP', state.friendshipXP);
  }

  void handleTap() {
    final messages = [
      'Hey! What\'s up? 👋',
      'I love when you pet me!',
      'You\'re the best!',
      'MAXie loves you! ❤️',
      'Let\'s play together!',
    ];
    
    state = state.copyWith(
      currentEmotion: 'happy',
      currentMessage: messages[(state.friendshipXP + 1) % messages.length],
      friendshipXP: state.friendshipXP + 1,
    );
    
    _checkLevelUp();
    _saveState();
  }

  void handleDoubleTap() {
    state = state.copyWith(
      currentEmotion: 'excited',
      currentMessage: 'Wooo! That was fun! 🎉',
      friendshipXP: state.friendshipXP + 5,
    );
    
    _checkLevelUp();
    _saveState();
  }

  void handleLongPress() {
    state = state.copyWith(
      currentEmotion: 'sleepy',
      currentMessage: '*yawns* I\'m a bit sleepy... 😴',
      isSleeping: true,
    );
  }

  void setEmotion(String emotion) {
    state = state.copyWith(currentEmotion: emotion);
  }

  void setActivity(String activity, {String? message}) {
    state = state.copyWith(
      currentActivity: activity,
      currentMessage: message ?? _getDefaultMessageForActivity(activity),
    );
  }

  void addFriendshipXP(int amount) {
    state = state.copyWith(
      friendshipXP: state.friendshipXP + amount,
    );
    _checkLevelUp();
    _saveState();
  }

  void _checkLevelUp() {
    final xpNeeded = state.friendshipLevel * 100;
    if (state.friendshipXP >= xpNeeded) {
      state = state.copyWith(
        friendshipLevel: state.friendshipLevel + 1,
        friendshipXP: state.friendshipXP - xpNeeded,
        currentMessage: 'Level up! We\'re now best friends! 🎉',
        currentEmotion: 'excited',
      );
    }
  }

  String _getDefaultMessageForActivity(String activity) {
    switch (activity) {
      case 'whatsapp':
        return 'Someone texted you 👀';
      case 'instagram':
        return 'Only 5 minutes... promise?';
      case 'spotify':
        return 'Damn this song is fire 🔥';
      case 'youtube':
        return 'What are we watching today?';
      case 'gaming':
        return 'Enemy ahead! Push! 🎮';
      case 'coding':
        return 'Bug detected... or is it a feature? 😂';
      case 'studying':
        return 'Focus! You\'ll thank yourself later 📚';
      default:
        return 'I\'m here with you! 🐾';
    }
  }
}

final maxieStateProvider =
    StateNotifierProvider<MaxieStateNotifier, MaxieState>((ref) {
  return MaxieStateNotifier();
});
