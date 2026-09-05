import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:maxie_mobile/features/pets/data/models/pet_model.dart';
import 'package:uuid/uuid.dart';

// ---- Pet State ----
class PetsState {
  final List<PetModel> pets;
  final bool isInitialized;
  final int coins;
  final int totalXp;
  final int streak;
  final int totalLevel;

  const PetsState({
    this.pets = const [],
    this.isInitialized = false,
    this.coins = 0,
    this.totalXp = 0,
    this.streak = 0,
    this.totalLevel = 0,
  });

  PetsState copyWith({
    List<PetModel>? pets,
    bool? isInitialized,
    int? coins,
    int? totalXp,
    int? streak,
    int? totalLevel,
  }) {
    return PetsState(
      pets: pets ?? this.pets,
      isInitialized: isInitialized ?? this.isInitialized,
      coins: coins ?? this.coins,
      totalXp: totalXp ?? this.totalXp,
      streak: streak ?? this.streak,
      totalLevel: totalLevel ?? this.totalLevel,
    );
  }

  PetModel? get activePet => pets.isNotEmpty ? pets.first : null;
}

// ---- Pet Notifier / Animation Engine ----
class PetEngineNotifier extends StateNotifier<PetsState> {
  Timer? _loopTimer;
  Timer? _statsDecayTimer;
  Timer? _speechClearTimer;
  final _random = Random();
  final _uuid = const Uuid();

  // Screen bounds
  double _screenWidth = 400;
  double _screenHeight = 800;
  double get _safeMinX => 20;
  double get _safeMaxX => _screenWidth - 140;
  double get _safeMinY => 80;
  double get _safeMaxY => _screenHeight - 200;

  // Personality-based behavior weights
  static const Map<PetPersonality, Map<String, double>> _behaviorWeights = {
    PetPersonality.intelligent: {
      'wander_chance': 0.04,
      'speed': 5.0,
      'curiosity': 0.8,
      'energy_decay': 0.008,
    },
    PetPersonality.lazy: {
      'wander_chance': 0.015,
      'speed': 2.5,
      'curiosity': 0.3,
      'energy_decay': 0.004,
    },
    PetPersonality.playful: {
      'wander_chance': 0.06,
      'speed': 7.0,
      'curiosity': 0.9,
      'energy_decay': 0.015,
    },
    PetPersonality.loyal: {
      'wander_chance': 0.03,
      'speed': 4.0,
      'curiosity': 0.6,
      'energy_decay': 0.007,
    },
    PetPersonality.sleepy: {
      'wander_chance': 0.01,
      'speed': 2.0,
      'curiosity': 0.2,
      'energy_decay': 0.003,
    },
    PetPersonality.energetic: {
      'wander_chance': 0.07,
      'speed': 8.0,
      'curiosity': 0.95,
      'energy_decay': 0.02,
    },
    PetPersonality.brave: {
      'wander_chance': 0.05,
      'speed': 6.0,
      'curiosity': 0.85,
      'energy_decay': 0.01,
    },
    PetPersonality.curious: {
      'wander_chance': 0.06,
      'speed': 5.5,
      'curiosity': 0.9,
      'energy_decay': 0.012,
    },
    PetPersonality.funny: {
      'wander_chance': 0.04,
      'speed': 5.0,
      'curiosity': 0.7,
      'energy_decay': 0.01,
    },
    PetPersonality.logical: {
      'wander_chance': 0.035,
      'speed': 4.5,
      'curiosity': 0.5,
      'energy_decay': 0.006,
    },
    PetPersonality.calm: {
      'wander_chance': 0.02,
      'speed': 3.0,
      'curiosity': 0.4,
      'energy_decay': 0.005,
    },
    PetPersonality.sassy: {
      'wander_chance': 0.045,
      'speed': 5.5,
      'curiosity': 0.75,
      'energy_decay': 0.009,
    },
    PetPersonality.helpful: {
      'wander_chance': 0.03,
      'speed': 4.0,
      'curiosity': 0.6,
      'energy_decay': 0.007,
    },
    PetPersonality.motivational: {
      'wander_chance': 0.03,
      'speed': 4.5,
      'curiosity': 0.7,
      'energy_decay': 0.008,
    },
    PetPersonality.protective: {
      'wander_chance': 0.025,
      'speed': 4.0,
      'curiosity': 0.5,
      'energy_decay': 0.006,
    },
  };

  // Pet type display info
  static const Map<PetType, Map<String, dynamic>> petTypeInfo = {
    PetType.maxie: {
      'name': 'MAXie',
      'emoji': '🤖',
      'color': 0xFF6C63FF,
      'description': 'Your intelligent AI companion',
    },
    PetType.cat: {
      'name': 'Cat',
      'emoji': '🐱',
      'color': 0xFFFF9800,
      'description': 'A lazy but lovable feline friend',
    },
    PetType.dog: {
      'name': 'Dog',
      'emoji': '🐶',
      'color': 0xFF795548,
      'description': 'A loyal and energetic pup',
    },
    PetType.panda: {
      'name': 'Panda',
      'emoji': '🐼',
      'color': 0xFF212121,
      'description': 'A sleepy cuddly bear',
    },
    PetType.fox: {
      'name': 'Fox',
      'emoji': '🦊',
      'color': 0xFFFF5722,
      'description': 'A curious clever trickster',
    },
    PetType.rabbit: {
      'name': 'Rabbit',
      'emoji': '🐰',
      'color': 0xFFE91E63,
      'description': 'A playful hoppy friend',
    },
    PetType.penguin: {
      'name': 'Penguin',
      'emoji': '🐧',
      'color': 0xFF3F51B5,
      'description': 'A funny waddling pal',
    },
    PetType.dragon: {
      'name': 'Dragon',
      'emoji': '🐉',
      'color': 0xFF4CAF50,
      'description': 'A brave fiery protector',
    },
    PetType.slime: {
      'name': 'Slime',
      'emoji': '🫧',
      'color': 0xFF00BCD4,
      'description': 'A bouncy calm blob',
    },
    PetType.robot: {
      'name': 'Robot',
      'emoji': '🤖',
      'color': 0xFF607D8B,
      'description': 'A logical mechanical friend',
    },
    PetType.capybara: {
      'name': 'Capybara',
      'emoji': '🐹',
      'color': 0xFF8D6E63,
      'description': 'A chill relaxed buddy',
    },
    PetType.axolotl: {
      'name': 'Axolotl',
      'emoji': '🦎',
      'color': 0xFFE1BEE7,
      'description': 'A cute sassy water friend',
    },
  };

  PetEngineNotifier() : super(const PetsState()) {
    _initPets();
    _startAnimations();
    _startStatsDecay();
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    _statsDecayTimer?.cancel();
    _speechClearTimer?.cancel();
    super.dispose();
  }

  void updateScreenBounds(double width, double height) {
    _screenWidth = width;
    _screenHeight = height;
  }

  Future<void> _initPets() async {
    try {
      final box = await Hive.openBox('maxie_pets');
      final savedPets = box.get('pets', defaultValue: <Map<String, dynamic>>[]) as List;
      if (savedPets.isNotEmpty) {
        final pets = savedPets.map((e) => PetModel.fromJson(Map<String, dynamic>.from(e))).toList();
        state = PetsState(pets: pets, isInitialized: true);
        return;
      }
    } catch (_) {}

    // Default: create MAXie
    await addPet(PetType.maxie);
    state = state.copyWith(isInitialized: true);
  }

  Future<void> _savePets() async {
    try {
      final box = await Hive.openBox('maxie_pets');
      await box.put('pets', state.pets.map((p) => p.toJson()).toList());
    } catch (_) {}
  }

  Future<PetModel> addPet(PetType type, {String? name}) async {
    final personality = PetModel.defaultPersonalities[type] ?? PetPersonality.playful;
    final info = petTypeInfo[type]!;

    final pet = PetModel(
      id: _uuid.v4(),
      type: type,
      name: name ?? info['name'] as String,
      primaryPersonality: personality,
      customization: PetCustomization(
        color: Color(info['color'] as int),
        name: name ?? info['name'] as String,
      ),
      position: Offset(
        _safeMinX + _random.nextDouble() * (_safeMaxX - _safeMinX),
        _safeMinY + _random.nextDouble() * (_safeMaxY - _safeMinY),
      ),
    );

    state = state.copyWith(pets: [...state.pets, pet]);
    await _savePets();
    return pet;
  }

  Future<void> removePet(String petId) async {
    state = state.copyWith(
      pets: state.pets.where((p) => p.id != petId).toList(),
    );
    await _savePets();
  }

  Future<void> updatePet(String petId, PetModel Function(PetModel) updater) async {
    state = state.copyWith(
      pets: state.pets.map((p) => p.id == petId ? updater(p) : p).toList(),
    );
  }

  Future<void> setAllPets(List<PetModel> pets) async {
    state = state.copyWith(pets: pets);
    await _savePets();
  }

  // ---- Animation Loop ----
  void _startAnimations() {
    _loopTimer?.cancel();
    _loopTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      _tick();
    });
  }

  void _tick() {
    if (state.pets.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    final updatedPets = state.pets.map((pet) {
      if (!pet.isVisible || pet.isDragging) return pet;

      final weights = _behaviorWeights[pet.primaryPersonality] ?? _behaviorWeights[PetPersonality.playful]!;
      final speed = weights['speed']! * pet.customization.animationSpeed;
      final wanderChance = weights['wander_chance']!;
      final curiosity = weights['curiosity']!;

      // Time based animation frame
      final animSpeed = pet.customization.animationSpeed * 5.0;
      double newFrame = pet.animationFrame + animSpeed * 0.033;

      // Handle idle timer for random actions
      final double newIdleTimer = pet.idleTimer + 0.033;

      PetActivity activity = pet.currentActivity;
      Offset? newTarget = pet.targetPosition;
      Offset newPos = pet.position;
      PetEmotion emotion = pet.currentEmotion;
      String? speech = pet.speechBubble;

      // === BEHAVIOR STATE MACHINE ===
      switch (pet.currentActivity) {
        case PetActivity.idle:
          // Random idle animations
          if (_random.nextDouble() < wanderChance * pet.customization.animationSpeed) {
            // Decide to wander
            final targetX = _safeMinX + _random.nextDouble() * (_safeMaxX - _safeMinX);
            final targetY = _safeMinY + _random.nextDouble() * (_safeMaxY - _safeMinY);
            newTarget = Offset(targetX, targetY);

            // Randomly choose walking or running based on energy & personality
            if (pet.energy > 0.5 && _random.nextDouble() < curiosity * 0.3) {
              activity = PetActivity.running;
            } else {
              activity = PetActivity.walking;
            }
          } else if (_random.nextDouble() < 0.008 * pet.customization.animationSpeed) {
            // Random idle action
            final actions = [
              PetActivity.looking,
              PetActivity.blinking,
              PetActivity.stretching,
              PetActivity.yawning,
              PetActivity.scratching,
              PetActivity.waving,
            ];
            activity = actions[_random.nextInt(actions.length)];

            // Sometimes speak
            if (_random.nextDouble() < 0.3) {
              speech = _getRandomSpeech(pet);
            }
          } else if (_random.nextDouble() < 0.003 * pet.customization.animationSpeed && pet.energy > 0.6) {
            // Random dance!
            activity = PetActivity.dancing;
            emotion = PetEmotion.excited;
            speech = 'Dancing time! 💃🎶';
          } else if (_random.nextDouble() < 0.002 * pet.customization.animationSpeed) {
            // Jump!
            activity = PetActivity.jumping;
          } else if (pet.energy < 0.2 || (pet.isSleeping && _random.nextDouble() < 0.01)) {
            activity = PetActivity.sleeping;
            emotion = PetEmotion.sleepy;
          } else if (pet.hunger < 0.3 && _random.nextDouble() < 0.005) {
            emotion = PetEmotion.hungry;
            speech = _random.nextBool() ? 'I\'m hungry! 🍽️' : 'Got any snacks? 🥺';
          }
          break;

        case PetActivity.walking:
        case PetActivity.running:
          if (newTarget != null) {
            final dist = (newTarget - newPos).distance;
            if (dist > 5) {
              final direction = (newTarget - newPos) / dist;
              final stepSize = activity == PetActivity.running ? speed * 1.5 : speed;
              newPos += direction * stepSize;
            } else {
              activity = PetActivity.idle;
              newTarget = null;
              if (_random.nextDouble() < 0.2) {
                speech = _getRandomArrivalSpeech(pet);
              }
            }
          } else {
            activity = PetActivity.idle;
          }
          break;

        case PetActivity.jumping:
          // Jump lasts a short time then returns to idle
          if (newFrame % 1.0 < 0.3) {
            newPos = Offset(newPos.dx, newPos.dy - 8 * pet.customization.animationSpeed);
          } else {
            activity = PetActivity.idle;
          }
          break;

        case PetActivity.dancing:
          if (_random.nextDouble() < 0.03) {
            activity = PetActivity.idle;
            emotion = PetEmotion.happy;
          }
          break;

        case PetActivity.sleeping:
          if (!pet.isSleeping && _random.nextDouble() < 0.01) {
            activity = PetActivity.idle;
            emotion = PetEmotion.happy;
            speech = '*wakes up* Good morning! ☀️';
          }
          break;

        case PetActivity.following:
          // Follow behavior - handled via interaction
          activity = PetActivity.idle;
          break;

        default:
          // After a brief moment, return to idle
          if (_random.nextDouble() < 0.05) {
            activity = PetActivity.idle;
          }
          break;
      }

      // Clamp position
      newPos = Offset(
        newPos.dx.clamp(10.0, _screenWidth - 100),
        newPos.dy.clamp(40.0, _screenHeight - 140),
      );

      // Frame reset
      if (newFrame > 1000) newFrame = 0;

      return pet.copyWith(
        position: newPos,
        targetPosition: newTarget,
        currentActivity: activity,
        currentEmotion: emotion,
        animationFrame: newFrame,
        idleTimer: newIdleTimer,
        speechBubble: speech,
        clearSpeechBubble: speech == null,
      );
    }).toList();

    state = state.copyWith(pets: updatedPets);
  }

  // ---- Interaction Methods ----
  void handleTap(String petId) {
    _handleInteraction(petId, () {
      final pet = state.pets.firstWhere((p) => p.id == petId);
      final emotions = [
        PetEmotion.happy,
        PetEmotion.excited,
        PetEmotion.playful,
        PetEmotion.loving,
        PetEmotion.surprised,
      ];
      final speeches = {
        PetEmotion.happy: [
          'Hey! 👋',
          'Yay! 🥰',
          'You\'re the best!',
          'I love you! ❤️',
        ],
        PetEmotion.excited: [
          'Tee-hee! 🤭',
          'Again! Again! 🎉',
          'Wheee!',
        ],
        PetEmotion.playful: [
          'Let\'s play! 🎮',
          'Catch me! 🏃',
          'I\'m gonna get you! 😜',
        ],
        PetEmotion.loving: [
          'You make me so happy! 💕',
          'My favorite human! ✨',
          'Stawwwp, you\'re making me blush! 😊',
        ],
        PetEmotion.surprised: [
          'Oh! Hi! 😮',
          'You scared me! 😄',
        ],
      };

      final emo = emotions[_random.nextInt(emotions.length)];
      final msgList = speeches[emo]!;
      final msg = msgList[_random.nextInt(msgList.length)];

      return pet.copyWith(
        currentEmotion: emo,
        speechBubble: msg,
        mood: (pet.mood + 0.1).clamp(0.0, 1.0),
        social: (pet.social + 0.08).clamp(0.0, 1.0),
        energy: (pet.energy + 0.03).clamp(0.0, 1.0),
      );
    });
  }

  void handleDoubleTap(String petId) {
    _handleInteraction(petId, () {
      final pet = state.pets.firstWhere((p) => p.id == petId);
      return pet.copyWith(
        currentEmotion: PetEmotion.excited,
        currentActivity: PetActivity.jumping,
        speechBubble: 'High five! 🙌🎉',
        mood: (pet.mood + 0.15).clamp(0.0, 1.0),
        social: (pet.social + 0.12).clamp(0.0, 1.0),
        energy: (pet.energy + 0.05).clamp(0.0, 1.0),
      );
    });
  }

  void handleLongPress(String petId) {
    _handleInteraction(petId, () {
      final pet = state.pets.firstWhere((p) => p.id == petId);
      final newSleep = !pet.isSleeping;
      return pet.copyWith(
        isSleeping: newSleep,
        currentEmotion: newSleep ? PetEmotion.sleepy : PetEmotion.happy,
        currentActivity: newSleep ? PetActivity.sleeping : PetActivity.idle,
        speechBubble: newSleep
            ? '*yawns* Good night... 😴💫'
            : '*wakes up* What time is it?! ☀️',
        energy: newSleep ? pet.energy : (pet.energy * 0.6),
      );
    });
  }

  void handleDragStart(String petId) {
    _handleInteraction(petId, () {
      final pet = state.pets.firstWhere((p) => p.id == petId);
      return pet.copyWith(
        isDragging: true,
        currentActivity: PetActivity.dragged,
        currentEmotion: PetEmotion.surprised,
        speechBubble: 'Wheee! Flying! 🚀',
      );
    });
  }

  void handleDragUpdate(String petId, Offset newPos) {
    final pet = state.pets.firstWhere((p) => p.id == petId);
    final boundedPos = Offset(
      newPos.dx.clamp(10.0, _screenWidth - 100),
      newPos.dy.clamp(40.0, _screenHeight - 140),
    );
    state = state.copyWith(
      pets: state.pets.map((p) {
        if (p.id != petId) return p;
        return p.copyWith(
          position: boundedPos,
          currentEmotion: PetEmotion.excited,
        );
      }).toList(),
    );
  }

  void handleDragEnd(String petId) {
    _handleInteraction(petId, () {
      final pet = state.pets.firstWhere((p) => p.id == petId);
      return pet.copyWith(
        isDragging: false,
        currentActivity: PetActivity.idle,
        currentEmotion: PetEmotion.happy,
        speechBubble: 'That was fun! Let\'s do it again! 🎈',
      );
    });
  }

  void startFollowing(String petId, Offset fingerPos) {
    final pet = state.pets.firstWhere((p) => p.id == petId);
    final boundedTarget = Offset(
      fingerPos.dx.clamp(10.0, _screenWidth - 100),
      fingerPos.dy.clamp(40.0, _screenHeight - 140),
    );
    state = state.copyWith(
      pets: state.pets.map((p) {
        if (p.id != petId) return p;
        return p.copyWith(
          targetPosition: boundedTarget,
          currentActivity: PetActivity.following,
          currentEmotion: PetEmotion.curious,
        );
      }).toList(),
    );
  }

  void updateFollowTarget(String petId, Offset fingerPos) {
    final pet = state.pets.firstWhere((p) => p.id == petId);
    final boundedTarget = Offset(
      fingerPos.dx.clamp(10.0, _screenWidth - 100),
      fingerPos.dy.clamp(40.0, _screenHeight - 140),
    );
    final dist = (boundedTarget - pet.position).distance;

    // Move toward target
    if (dist > 10) {
      final direction = (boundedTarget - pet.position) / dist;
      final speed = 6.0 * pet.customization.animationSpeed;
      Offset newPos = pet.position + direction * speed;
      newPos = Offset(
        newPos.dx.clamp(10.0, _screenWidth - 100),
        newPos.dy.clamp(40.0, _screenHeight - 140),
      );

      state = state.copyWith(
        pets: state.pets.map((p) {
          if (p.id != petId) return p;
          return p.copyWith(
            position: newPos,
            currentActivity: PetActivity.following,
            currentEmotion: PetEmotion.curious,
          );
        }).toList(),
      );
    }
  }

  void stopFollowing(String petId) {
    _handleInteraction(petId, () {
      final pet = state.pets.firstWhere((p) => p.id == petId);
      return pet.copyWith(
        currentActivity: PetActivity.idle,
        currentEmotion: PetEmotion.happy,
      );
    });
  }

  void celebrate(String petId) {
    _handleInteraction(petId, () {
      final pet = state.pets.firstWhere((p) => p.id == petId);
      return pet.copyWith(
        currentEmotion: PetEmotion.celebrating,
        currentActivity: PetActivity.celebrating,
        speechBubble: 'Congratulations! 🎉🥳✨',
        mood: (pet.mood + 0.2).clamp(0.0, 1.0),
        fun: (pet.fun + 0.2).clamp(0.0, 1.0),
      );
    });
  }

  // ---- Stats Management ----
  void _startStatsDecay() {
    _statsDecayTimer?.cancel();
    _statsDecayTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _decayStats();
    });
  }

  void _decayStats() {
    state = state.copyWith(
      pets: state.pets.map((pet) {
        final weights = _behaviorWeights[pet.primaryPersonality] ?? _behaviorWeights[PetPersonality.playful]!;
        final energyDecay = weights['energy_decay']!;

        final double newHunger = (pet.hunger - 0.02).clamp(0.0, 1.0);
        final double newEnergy = (pet.energy - energyDecay).clamp(0.0, 1.0);
        final double newMood = (pet.mood - 0.005).clamp(0.0, 1.0);
        final double newFun = (pet.fun - 0.008).clamp(0.0, 1.0);
        final double newSocial = (pet.social - 0.005).clamp(0.0, 1.0);
        final double newHygiene = (pet.hygiene - 0.003).clamp(0.0, 1.0);

        PetEmotion newEmotion = pet.currentEmotion;
        if (newHunger < 0.25) {
          newEmotion = PetEmotion.hungry;
        } else if (newEnergy < 0.2) newEmotion = PetEmotion.sleepy;
        else if (newMood < 0.25) newEmotion = PetEmotion.sad;

        return pet.copyWith(
          hunger: newHunger,
          energy: newEnergy,
          mood: newMood,
          fun: newFun,
          social: newSocial,
          hygiene: newHygiene,
          currentEmotion: newEmotion,
        );
      }).toList(),
    );
    _savePets();
  }

  void feedPet(String petId, double amount) {
    _handleInteraction(petId, () {
      final pet = state.pets.firstWhere((p) => p.id == petId);
      return pet.copyWith(
        hunger: (pet.hunger + amount).clamp(0.0, 1.0),
        currentEmotion: PetEmotion.happy,
        speechBubble: 'Yummy! Thank you! 😋🍕',
        mood: (pet.mood + 0.1).clamp(0.0, 1.0),
      );
    });
  }

  void playWithPet(String petId) {
    _handleInteraction(petId, () {
      final pet = state.pets.firstWhere((p) => p.id == petId);
      return pet.copyWith(
        fun: (pet.fun + 0.3).clamp(0.0, 1.0),
        energy: (pet.energy - 0.1).clamp(0.0, 1.0),
        currentEmotion: PetEmotion.excited,
        currentActivity: PetActivity.playing,
        speechBubble: 'That was so fun! Let\'s play again! 🎾🎮',
      );
    });
  }

  void cleanPet(String petId) {
    _handleInteraction(petId, () {
      final pet = state.pets.firstWhere((p) => p.id == petId);
      return pet.copyWith(
        hygiene: 1.0,
        currentEmotion: PetEmotion.happy,
        speechBubble: 'I feel so fresh and clean! ✨🧼',
        mood: (pet.mood + 0.1).clamp(0.0, 1.0),
      );
    });
  }

  void addFriendshipXP(String petId, int amount) {
    final pet = state.pets.firstWhere((p) => p.id == petId);
    final newXP = pet.friendshipXP + amount;
    final xpNeeded = pet.friendshipLevel * 100;
    int newLevel = pet.friendshipLevel;
    int remainingXP = newXP;

    if (newXP >= xpNeeded) {
      newLevel++;
      remainingXP = newXP - xpNeeded;
    }

    state = state.copyWith(
      pets: state.pets.map((p) {
        if (p.id != petId) return p;
        final leveledUp = newLevel > p.friendshipLevel;
        return p.copyWith(
          friendshipLevel: newLevel,
          friendshipXP: remainingXP,
          speechBubble: leveledUp
              ? 'Level $newLevel! We\'re closer than ever! 🎉✨'
              : (p.speechBubble),
          currentEmotion: leveledUp ? PetEmotion.celebrating : p.currentEmotion,
        );
      }).toList(),
    );
    _savePets();
  }

  // ---- Customization ----
  Future<void> updatePetCustomization(String petId, PetCustomization customization) async {
    await updatePet(petId, (pet) => pet.copyWith(customization: customization));
    await _savePets();
  }

  // ---- Helper Methods ----
  void _handleInteraction(String petId, PetModel Function() update) {
    try {
      final updated = update();
      state = state.copyWith(
        pets: state.pets.map((p) => p.id == petId ? updated : p).toList(),
      );

      // Auto-clear speech bubble
      _speechClearTimer?.cancel();
      _speechClearTimer = Timer(const Duration(seconds: 4), () {
        state = state.copyWith(
          pets: state.pets.map((p) {
            if (p.id != petId) return p;
            return p.copyWith(clearSpeechBubble: true);
          }).toList(),
        );
      });
    } catch (_) {}
  }

  String _getRandomSpeech(PetModel pet) {
    final speeches = {
      PetType.maxie: [
        'I\'m thinking about life... 🤔',
        'You\'re doing great! 🌟',
        'Let\'s learn something new! 📚',
        'I believe in you! 💪',
      ],
      PetType.cat: [
        'Meow~ 🐱',
        'Purrr... 😌',
        'I fits, I sits.',
        'Feed me... 👀',
        'Naptime! 😴',
      ],
      PetType.dog: [
        'Woof! 🐶',
        'BALL! BALL! BALL! 🎾',
        'I love walks! 🚶',
        'Pet me! Pet me! 🥹',
        'Who\'s a good human? You are!',
      ],
      PetType.fox: [
        'What does the fox say? 🦊',
        'Ring-ding-ding! 🎵',
        'Sneaky sneaky... 🤫',
        'I found something interesting!',
      ],
      PetType.rabbit: [
        'Boing boing! 🐰',
        'Carrots please! 🥕',
        'Fluffy butt! 🐇',
        'Hop hop!',
      ],
      PetType.panda: [
        'Bamboo time! 🎋',
        'So sleepy... 🐼',
        'Roll roll roll...',
        'I\'m not fat, I\'m fluffy!',
      ],
      PetType.dragon: [
        'Rawr! 🐉🔥',
        'I\'ll protect you! 🛡️',
        'Feel my fire! ...okay maybe not.',
        'Flying is the best!',
      ],
      PetType.slime: [
        'Blop blop~ 🫧',
        'Boing!',
        'Squish squish...',
        'I\'m a happy blob!',
      ],
      PetType.robot: [
        'BEEP BOOP. I LIKE YOU. 🤖',
        'CALCULATING FRIENDSHIP... DONE.',
        'SYSTEM: HAPPY.',
        '01101000 01101001 👋',
      ],
      PetType.penguin: [
        'Waddle waddle! 🐧',
        'It\'s cold in here!',
        'Fish? 🐟',
        'I\'m a happy penguin!',
      ],
      PetType.capybara: [
        'Okay. 😌',
        'Just vibing... 🐹',
        'Life is good.',
        'Chillin\' like a capybara.',
      ],
      PetType.axolotl: [
        'Glub glub! 🦎',
        'I smile because I must! 😊',
        'Water is life.',
        'Look at my little arms!',
      ],
    };

    final list = speeches[pet.type] ?? speeches[PetType.maxie]!;
    return list[_random.nextInt(list.length)];
  }

  String _getRandomArrivalSpeech(PetModel pet) {
    final speeches = [
      'Nice spot! 🌸',
      'Right here is nice ✨',
      'Perfect! 🎯',
      'I like this place! 🏠',
      'Cozy corner! 🧸',
      'Made it! 🏁',
    ];
    return speeches[_random.nextInt(speeches.length)];
  }
}

// ---- Providers ----
final petEngineProvider =
    StateNotifierProvider<PetEngineNotifier, PetsState>((ref) {
  return PetEngineNotifier();
});