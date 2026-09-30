import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
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

  // New features
  final Offset petPosition;
  final Offset? targetPosition;
  final double hunger; // 0.0 to 1.0
  final double energy; // 0.0 to 1.0
  final double mood;   // 0.0 to 1.0
  final int points;
  final List<String> equippedAccessories;
  final Offset? spawnedToyPosition;
  final String? spawnedToyType;
  final bool isChasing;
  final bool isWandering;

  MaxieState({
    this.currentEmotion = 'happy',
    this.currentActivity = 'idle',
    this.currentMessage = 'Hey! I\'m MAXie! Let\'s be friends! 🐾',
    this.friendshipLevel = 1,
    this.friendshipXP = 0,
    this.isSleeping = false,
    this.isDancing = false,
    this.petPosition = const Offset(150, 400),
    this.targetPosition,
    this.hunger = 0.8,
    this.energy = 0.7,
    this.mood = 0.9,
    this.points = 150, // Start with some pocket money
    this.equippedAccessories = const [],
    this.spawnedToyPosition,
    this.spawnedToyType,
    this.isChasing = false,
    this.isWandering = true,
  });

  MaxieState copyWith({
    String? currentEmotion,
    String? currentActivity,
    String? currentMessage,
    int? friendshipLevel,
    int? friendshipXP,
    bool? isSleeping,
    bool? isDancing,
    Offset? petPosition,
    Offset? targetPosition,
    double? hunger,
    double? energy,
    double? mood,
    int? points,
    List<String>? equippedAccessories,
    Offset? spawnedToyPosition,
    String? spawnedToyType,
    bool? isChasing,
    bool? isWandering,
  }) {
    return MaxieState(
      currentEmotion: currentEmotion ?? this.currentEmotion,
      currentActivity: currentActivity ?? this.currentActivity,
      currentMessage: currentMessage ?? this.currentMessage,
      friendshipLevel: friendshipLevel ?? this.friendshipLevel,
      friendshipXP: friendshipXP ?? this.friendshipXP,
      isSleeping: isSleeping ?? this.isSleeping,
      isDancing: isDancing ?? this.isDancing,
      petPosition: petPosition ?? this.petPosition,
      targetPosition: targetPosition ?? this.targetPosition,
      hunger: hunger ?? this.hunger,
      energy: energy ?? this.energy,
      mood: mood ?? this.mood,
      points: points ?? this.points,
      equippedAccessories: equippedAccessories ?? this.equippedAccessories,
      spawnedToyPosition: spawnedToyPosition ?? this.spawnedToyPosition,
      spawnedToyType: spawnedToyType ?? this.spawnedToyType,
      isChasing: isChasing ?? this.isChasing,
      isWandering: isWandering ?? this.isWandering,
    );
  }
}

class MaxieStateNotifier extends StateNotifier<MaxieState> {
  Timer? _wanderTimer;
  final _random = Random();
  double _screenWidth = 360;
  double _screenHeight = 640;

  MaxieStateNotifier() : super(MaxieState()) {
    _loadState();
    _startLoop();
  }

  @override
  void dispose() {
    _wanderTimer?.cancel();
    super.dispose();
  }

  void updateScreenBounds(double width, double height) {
    _screenWidth = width;
    _screenHeight = height;
  }

  Future<void> _loadState() async {
    try {
      final box = await Hive.openBox('maxie_friendship');
      final level = box.get('friendshipLevel', defaultValue: 1);
      final xp = box.get('friendshipXP', defaultValue: 0);
      final points = box.get('points', defaultValue: 150);

      final settingsBox = await Hive.openBox('maxie_settings');
      final acc = settingsBox.get('equippedAccessories', defaultValue: <String>[]);
      final hunger = settingsBox.get('hunger', defaultValue: 0.8) as double;
      final energy = settingsBox.get('energy', defaultValue: 0.7) as double;
      final mood = settingsBox.get('mood', defaultValue: 0.9) as double;

      // Make sure equippedAccessories is List<String>
      final List<String> accessoryList = List<String>.from(acc);

      state = state.copyWith(
        friendshipLevel: level,
        friendshipXP: xp,
        points: points,
        equippedAccessories: accessoryList,
        hunger: hunger,
        energy: energy,
        mood: mood,
      );
    } catch (e) {
      // Fallback
    }
  }

  Future<void> _saveState() async {
    try {
      final box = await Hive.openBox('maxie_friendship');
      await box.put('friendshipLevel', state.friendshipLevel);
      await box.put('friendshipXP', state.friendshipXP);
      await box.put('points', state.points);

      final settingsBox = await Hive.openBox('maxie_settings');
      await settingsBox.put('equippedAccessories', state.equippedAccessories);
      await settingsBox.put('hunger', state.hunger);
      await settingsBox.put('energy', state.energy);
      await settingsBox.put('mood', state.mood);
    } catch (_) {}
  }

  void _startLoop() {
    _wanderTimer?.cancel();
    // Run ticker loop every 150ms for smooth autonomous wandering and chasing
    _wanderTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      _tick();
    });
  }

  void _tick() {
    // 1. Slow decay of stats over time
    if (_random.nextDouble() < 0.005) {
      final double newHunger = max(0.0, state.hunger - 0.02);
      final double newEnergy = max(0.0, state.energy - 0.01);
      final double newMood = max(0.0, state.mood - 0.015);
      
      // If stats are low, pet changes emotion
      String emotion = state.currentEmotion;
      if (newHunger < 0.3) {
        emotion = 'sad';
      } else if (newEnergy < 0.2) {
        emotion = 'sleepy';
      }

      state = state.copyWith(
        hunger: newHunger,
        energy: newEnergy,
        mood: newMood,
        currentEmotion: emotion,
      );
      _saveState();
    }

    // 2. Chasing spawned food or toy takes priority
    if (state.spawnedToyPosition != null) {
      final toyPos = state.spawnedToyPosition!;
      final distance = (toyPos - state.petPosition).distance;

      if (distance > 15) {
        // Walk towards toy
        final direction = (toyPos - state.petPosition) / distance;
        final step = direction * 12.0; // Faster speed when chasing food/toy
        state = state.copyWith(
          petPosition: state.petPosition + step,
          currentActivity: 'walking',
          currentEmotion: 'excited',
        );
      } else {
        // Arrived at toy! Eat or play
        final isFood = state.spawnedToyType == 'cookie' || state.spawnedToyType == 'apple';
        final bonusPoints = isFood ? 15 : 20;
        final xpGained = isFood ? 25 : 30;

        final String msg = isFood ? 'Yum! Thank you for the treat! 😋❤️' : 'Wheee! That was so much fun! ⚽🎉';
        
        state = state.copyWith(
          currentEmotion: 'happy',
          currentActivity: 'idle',
          currentMessage: msg,
          hunger: isFood ? min(1.0, state.hunger + 0.35) : state.hunger,
          mood: !isFood ? min(1.0, state.mood + 0.40) : state.mood,
          energy: isFood ? min(1.0, state.energy + 0.15) : min(1.0, state.energy + 0.25),
          points: state.points + bonusPoints,
          isChasing: false,
        );
        addFriendshipXP(xpGained);
        _saveState();
      }
      return;
    }

    // 3. Autonomous Wandering
    if (state.isWandering && !state.isSleeping && !state.isDancing) {
      if (state.targetPosition == null) {
        // Occasionally pick a random coordinate to wander to
        if (_random.nextDouble() < 0.04) {
          // Wandering bounds
          final double minX = 40;
          final double maxX = max(minX + 40, _screenWidth - 120);
          final double minY = 120;
          final double maxY = max(minY + 40, _screenHeight - 240);

          final double targetX = minX + _random.nextDouble() * (maxX - minX);
          final double targetY = minY + _random.nextDouble() * (maxY - minY);

          state = state.copyWith(
            targetPosition: Offset(targetX, targetY),
            currentActivity: 'walking',
          );
        }
      } else {
        final dist = (state.targetPosition! - state.petPosition).distance;
        if (dist > 8) {
          final direction = (state.targetPosition! - state.petPosition) / dist;
          final step = direction * 5.0; // Moderate walking speed
          state = state.copyWith(
            petPosition: state.petPosition + step,
          );
        } else {
          // Arrived at wander destination
          state = state.copyWith(
            currentActivity: 'idle',
          );

          // Occasionally say something cute upon arriving
          if (_random.nextDouble() < 0.15) {
            final dialogues = [
              'What a nice spot! 🌸',
              'You can drag me anywhere, you know! 🐾',
              'I\'m wandering around, looking for toys! 🧶',
              'Maxie is happy to be here with you! ✨',
              'Did you try dragging the apps around?',
              'Double-tap me for a high five! 🙌',
            ];
            state = state.copyWith(
              currentMessage: dialogues[_random.nextInt(dialogues.length)],
              currentEmotion: 'happy',
            );
          }
        }
      }
    }
  }

  // Spawning toy or food
  void spawnToy(String type, Offset globalPosition) {
    // Convert click coordinates to stack position bounds if needed
    state = state.copyWith(
      spawnedToyPosition: globalPosition,
      spawnedToyType: type,
      isChasing: true,
      currentActivity: 'walking',
      currentEmotion: 'excited',
    );
  }

  // Update pet position when dragged by the user
  void updatePetDragPosition(Offset newPos) {
    // Keep pet within screen boundaries
    final double boundedX = newPos.dx.clamp(10.0, max(10.0, _screenWidth - 110));
    final double boundedY = newPos.dy.clamp(60.0, max(60.0, _screenHeight - 180));

    state = state.copyWith(
      petPosition: Offset(boundedX, boundedY),
      currentActivity: 'dragged',
      currentEmotion: 'excited',
      currentMessage: 'Wheee! I\'m flying! 🚀☁️',
    );
  }

  void releaseDrag() {
    state = state.copyWith(
      currentActivity: 'idle',
      currentEmotion: 'happy',
    );
  }

  // Accessory Shop Methods
  bool buyAccessory(String id, int cost) {
    if (state.points >= cost && !state.equippedAccessories.contains(id)) {
      final List<String> list = [...state.equippedAccessories, id];
      state = state.copyWith(
        points: state.points - cost,
        equippedAccessories: list,
        currentMessage: 'Wow! I look so stylish! 😎🎩',
        currentEmotion: 'excited',
      );
      _saveState();
      return true;
    }
    return false;
  }

  void toggleAccessory(String id) {
    final List<String> list = List<String>.from(state.equippedAccessories);
    if (list.contains(id)) {
      list.remove(id);
      state = state.copyWith(
        equippedAccessories: list,
        currentMessage: 'A refreshed look! 🐾',
      );
    } else {
      list.add(id);
      state = state.copyWith(
        equippedAccessories: list,
        currentMessage: 'Ready to show off this style! ✨',
      );
    }
    _saveState();
  }

  void earnPoints(int amount) {
    state = state.copyWith(points: state.points + amount);
    _saveState();
  }

  // Actions
  void handleTap() {
    final messages = [
      'Hey! What\'s up? 👋',
      'I love when you pet me! 🥰',
      'You\'re the best!',
      'MAXie loves you! ❤️',
      'Let\'s play together!',
      'Tee-hee! That tickles! 🤭',
    ];
    
    state = state.copyWith(
      currentEmotion: 'happy',
      currentMessage: messages[_random.nextInt(messages.length)],
      mood: min(1.0, state.mood + 0.15),
      energy: min(1.0, state.energy + 0.05),
    );
    
    addFriendshipXP(5);
    _saveState();
  }

  void handleDoubleTap() {
    state = state.copyWith(
      currentEmotion: 'excited',
      currentMessage: 'Woohoo! That was super fun! 🎉',
      energy: min(1.0, state.energy + 0.10),
      mood: min(1.0, state.mood + 0.20),
    );
    
    addFriendshipXP(15);
    _saveState();
  }

  void handleLongPress() {
    final sleepMsg = state.isSleeping 
        ? '*yawns* Good morning! I\'m awake! ☀️' 
        : '*yawns* I\'m a bit sleepy... Good night! 😴💤';
    
    state = state.copyWith(
      currentEmotion: state.isSleeping ? 'happy' : 'sleepy',
      currentMessage: sleepMsg,
      isSleeping: !state.isSleeping,
      energy: state.isSleeping ? min(1.0, state.energy + 0.50) : state.energy,
    );
    _saveState();
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
        currentMessage: 'Level up! We\'re now best friends! 🎉✨',
        currentEmotion: 'excited',
        points: state.points + 50, // Bonus points on level up!
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
