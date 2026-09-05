import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/pet/application/pet_providers.dart';
import 'package:maxie_mobile/features/pet/domain/models/pet_state.dart';
import 'package:maxie_mobile/features/pet/domain/repositories/pet_repository.dart';
import 'package:maxie_mobile/features/shimeji/data/hive_shimeji_repository.dart';
import 'package:maxie_mobile/features/shimeji/domain/models/shimeji_models.dart';
import 'package:maxie_mobile/features/shimeji/domain/repositories/shimeji_repository.dart';
import 'package:maxie_mobile/services/storage/storage_providers.dart';

final shimejiRepositoryProvider = Provider<ShimejiRepository>(
  (ref) => HiveShimejiRepository(ref.watch(storageServiceProvider)),
);

final shimejiControllerProvider =
    StateNotifierProvider<ShimejiController, ShimejiState>((ref) {
      final controller = ShimejiController(
        repository: ref.watch(shimejiRepositoryProvider),
        petRepository: ref.watch(petRepositoryProvider),
      );
      controller.load();
      return controller;
    });

class ShimejiController extends StateNotifier<ShimejiState> {
  ShimejiController({
    required this._repository,
    required this._petRepository,
  }) : super(ShimejiState.initial());

  final ShimejiRepository _repository;
  final PetRepository _petRepository;
  final Random _random = Random();
  Offset _lastDragDelta = Offset.zero;
  int _saveThrottle = 0;

  Future<void> load() async {
    final saved = await _repository.readState();
    final maxie = await _petRepository.readPet();
    state = _syncFromMaxie(saved, maxie);
  }

  Future<void> save() async {
    await _repository.saveState(state);
  }

  void tick(Size bounds, double seconds) {
    if (state.settings.paused || state.settings.hidden) {
      return;
    }

    final fpsStep = state.settings.batterySaver ? 2 : 1;
    final nextTick = state.tick + 1;
    if (state.settings.reducedMotion && nextTick % 3 != 0) {
      state = state.copyWith(tick: nextTick);
      return;
    }
    if (nextTick % fpsStep != 0) {
      state = state.copyWith(tick: nextTick);
      return;
    }

    final updatedPets = state.pets
        .map((pet) => _stepPet(pet, bounds, seconds, nextTick))
        .toList();
    state = state.copyWith(pets: updatedPets, tick: nextTick);

    _saveThrottle++;
    if (_saveThrottle > 24) {
      _saveThrottle = 0;
      unawaitedSave();
    }
  }

  void selectPet(String id) {
    state = state.copyWith(selectedPetId: id);
    unawaitedSave();
  }

  void spawnPet(String id) {
    state = _updatePet(
      id,
      (pet) => pet.copyWith(
        visible: true,
        unlocked: true,
        currentAnimation: ShimejiAnimation.wake,
        mood: ShimejiMood.excited,
        xp: pet.xp + 10,
      ),
      selectedPetId: id,
    );
    unawaitedSave();
  }

  void despawnPet(String id) {
    state = _updatePet(
      id,
      (pet) =>
          pet.copyWith(visible: false, currentAnimation: ShimejiAnimation.idle),
    );
    unawaitedSave();
  }

  void interact(String id, ShimejiAnimation animation) {
    final mood = switch (animation) {
      ShimejiAnimation.dance => ShimejiMood.excited,
      ShimejiAnimation.sleep => ShimejiMood.sleepy,
      ShimejiAnimation.eat => ShimejiMood.happy,
      ShimejiAnimation.love => ShimejiMood.love,
      ShimejiAnimation.listen => ShimejiMood.happy,
      ShimejiAnimation.think => ShimejiMood.neutral,
      ShimejiAnimation.jump => ShimejiMood.surprised,
      ShimejiAnimation.wave => ShimejiMood.happy,
      _ => ShimejiMood.happy,
    };
    state = _updatePet(
      id,
      (pet) => pet.copyWith(
        currentAnimation: animation,
        mood: mood,
        vy: animation == ShimejiAnimation.jump ? -520 : pet.vy,
        vx: animation == ShimejiAnimation.dance ? 60 : pet.vx,
        friendship: pet.friendship + 4,
        xp: pet.xp + 6,
        nextBehaviorTick: state.tick + 36,
      ),
    );
    if (id == 'maxie') {
      unawaitedMaxieSync(mood, animation);
    }
    unawaitedSave();
  }

  void startDrag(String id) {
    _lastDragDelta = Offset.zero;
    state = _updatePet(
      id,
      (pet) => pet.copyWith(
        dragging: true,
        vx: 0,
        vy: 0,
        currentAnimation: ShimejiAnimation.drag,
        mood: ShimejiMood.surprised,
      ),
    );
  }

  void dragPet(String id, Offset delta, Size bounds) {
    _lastDragDelta = delta;
    state = _updatePet(
      id,
      (pet) => pet.copyWith(
        x: (pet.x + delta.dx).clamp(0, max(0, bounds.width - _petPixels(pet))),
        y: (pet.y + delta.dy).clamp(0, max(0, bounds.height - _petPixels(pet))),
      ),
    );
  }

  void throwPet(String id) {
    state = _updatePet(
      id,
      (pet) => pet.copyWith(
        dragging: false,
        vx: _lastDragDelta.dx * 24,
        vy: _lastDragDelta.dy * 24,
        currentAnimation: ShimejiAnimation.throwing,
        friendship: pet.friendship + 2,
        xp: pet.xp + 3,
      ),
    );
    unawaitedSave();
  }

  void resetPositions() {
    var index = 0;
    state = state.copyWith(
      pets: [
        for (final pet in state.pets)
          pet.copyWith(
            x: 34 + (index++ * 62),
            y: 0,
            vx: 0,
            vy: 0,
            currentAnimation: ShimejiAnimation.idle,
          ),
      ],
    );
    unawaitedSave();
  }

  void updateSettings(ShimejiSettings settings) {
    state = state.copyWith(settings: settings);
    unawaitedSave();
  }

  void toggleOverlay(bool enabled) {
    state = state.copyWith(
      settings: state.settings.copyWith(
        overlayEnabled: enabled,
        inAppFallback: true,
      ),
      overlayStatus: enabled
          ? 'Demo stage active; Android overlay permission is the next release step'
          : 'Demo stage active',
    );
    unawaitedSave();
  }

  void unlockWithXp(String id) {
    final maxieXp = state.pets
        .where((pet) => pet.id == 'maxie')
        .fold<int>(0, (total, pet) => total + pet.xp + pet.friendship);
    if (maxieXp < 20) {
      state = state.copyWith(lastError: 'Earn 20 MAXie XP to unlock pets.');
      return;
    }
    spawnPet(id);
  }

  void unawaitedSave() {
    _repository.saveState(state);
  }

  void unawaitedMaxieSync(ShimejiMood mood, ShimejiAnimation animation) async {
    final pet = await _petRepository.readPet();
    final petMood = switch (mood) {
      ShimejiMood.happy => PetMood.happy,
      ShimejiMood.sleepy => PetMood.sleepy,
      ShimejiMood.excited => PetMood.dancing,
      ShimejiMood.love => PetMood.loving,
      ShimejiMood.surprised => PetMood.happy,
      ShimejiMood.hungry => PetMood.neutral,
      ShimejiMood.bored => PetMood.neutral,
      ShimejiMood.sad => PetMood.neutral,
      ShimejiMood.angry => PetMood.focused,
      ShimejiMood.neutral => PetMood.neutral,
    };
    await _petRepository.savePet(
      pet.copyWith(
        mood: petMood,
        affinity: pet.affinity + 3,
        lastAction: 'Shimeji ${animation.name}',
      ),
    );
  }

  ShimejiState _updatePet(
    String id,
    ShimejiPet Function(ShimejiPet pet) update, {
    String? selectedPetId,
  }) {
    return state.copyWith(
      pets: [for (final pet in state.pets) pet.id == id ? update(pet) : pet],
      selectedPetId: selectedPetId,
    );
  }

  ShimejiPet _stepPet(ShimejiPet pet, Size bounds, double seconds, int tick) {
    if (!pet.visible || pet.dragging) {
      return pet;
    }

    final size = _petPixels(pet);
    final ground = max(0.0, bounds.height - size);
    final maxX = max(0.0, bounds.width - size);
    final gravity = 980.0;
    final friction = 0.86;
    var next = pet;

    if (state.settings.autoMovement && tick >= pet.nextBehaviorTick) {
      next = _chooseBehavior(pet, tick);
    }

    var x = next.x + next.vx * seconds * state.settings.movementSpeed;
    var y = next.y + next.vy * seconds;
    var vx = next.vx * friction;
    var vy = next.vy + gravity * seconds;
    var animation = next.currentAnimation;
    var mood = next.mood;

    if (x <= 0) {
      x = 0;
      vx = vx.abs();
    } else if (x >= maxX) {
      x = maxX;
      vx = -vx.abs();
    }

    if (y >= ground) {
      y = ground;
      if (vy > 160) {
        animation = ShimejiAnimation.land;
        mood = ShimejiMood.surprised;
      }
      vy = 0;
    } else if (vy > 120) {
      animation = ShimejiAnimation.fall;
    } else if (vy < -80) {
      animation = ShimejiAnimation.jump;
    }

    if (y == ground && animation != ShimejiAnimation.sleep) {
      if (vx.abs() > 170) {
        animation = ShimejiAnimation.run;
      } else if (vx.abs() > 26) {
        animation = ShimejiAnimation.walk;
      } else if (animation == ShimejiAnimation.land) {
        animation = ShimejiAnimation.land;
      } else if (tick > next.nextBehaviorTick - 8) {
        animation = next.currentAnimation;
      } else {
        animation = ShimejiAnimation.idle;
      }
    }

    return next.copyWith(
      x: x,
      y: y,
      vx: vx.abs() < 8 ? 0 : vx,
      vy: vy,
      currentAnimation: animation,
      mood: mood,
    );
  }

  ShimejiPet _chooseBehavior(ShimejiPet pet, int tick) {
    final play = pet.traits.playfulness / 100;
    final calm = pet.traits.calmness / 100;
    final energy = pet.traits.energy / 100;
    final roll = _random.nextDouble();
    final direction = _random.nextBool() ? 1.0 : -1.0;
    final nextDelay = tick + 18 + _random.nextInt(48);

    if (roll < calm * 0.18) {
      return pet.copyWith(
        currentAnimation: ShimejiAnimation.sleep,
        mood: ShimejiMood.sleepy,
        vx: 0,
        nextBehaviorTick: nextDelay + 30,
      );
    }
    if (roll < calm * 0.30) {
      return pet.copyWith(
        currentAnimation: ShimejiAnimation.sit,
        mood: ShimejiMood.neutral,
        vx: 0,
        nextBehaviorTick: nextDelay,
      );
    }
    if (roll < play * 0.52) {
      return pet.copyWith(
        currentAnimation: ShimejiAnimation.jump,
        mood: ShimejiMood.excited,
        vx: direction * (70 + _random.nextDouble() * 95),
        vy: -360 - (_random.nextDouble() * 170 * energy),
        nextBehaviorTick: nextDelay,
      );
    }
    if (roll < play * 0.70) {
      return pet.copyWith(
        currentAnimation: ShimejiAnimation.dance,
        mood: ShimejiMood.happy,
        vx: direction * 55,
        nextBehaviorTick: nextDelay,
      );
    }
    if (roll < energy * 0.85) {
      return pet.copyWith(
        currentAnimation: ShimejiAnimation.run,
        mood: ShimejiMood.excited,
        vx: direction * (150 + _random.nextDouble() * 120),
        nextBehaviorTick: nextDelay,
      );
    }
    return pet.copyWith(
      currentAnimation: ShimejiAnimation.walk,
      mood: ShimejiMood.bored,
      vx: direction * (45 + _random.nextDouble() * 80),
      nextBehaviorTick: nextDelay,
    );
  }

  double _petPixels(ShimejiPet pet) {
    return 78 * pet.scale * state.settings.petSize;
  }

  ShimejiState _syncFromMaxie(ShimejiState saved, PetState maxie) {
    return saved.copyWith(
      pets: [
        for (final pet in saved.pets)
          pet.id == 'maxie'
              ? pet.copyWith(
                  friendship: max(pet.friendship, maxie.affinity),
                  xp: max(pet.xp, maxie.affinity),
                  mood: switch (maxie.mood) {
                    PetMood.happy => ShimejiMood.happy,
                    PetMood.focused => ShimejiMood.neutral,
                    PetMood.sleepy => ShimejiMood.sleepy,
                    PetMood.listening => ShimejiMood.happy,
                    PetMood.dancing => ShimejiMood.excited,
                    PetMood.loving => ShimejiMood.love,
                    PetMood.neutral => ShimejiMood.neutral,
                  },
                )
              : pet,
      ],
    );
  }
}
