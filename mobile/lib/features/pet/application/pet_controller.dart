import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/pet/application/pet_providers.dart';
import 'package:maxie_mobile/features/pet/domain/models/pet_state.dart';
import 'package:maxie_mobile/features/pet/domain/repositories/pet_repository.dart';

enum PetAction { feed, play, sleep, dance, listen }

class PetEngine {
  const PetEngine._();

  static const xpRewards = {
    PetAction.feed: 5,
    PetAction.play: 10,
    PetAction.sleep: 4,
    PetAction.dance: 7,
    PetAction.listen: 3,
  };

  static PetState apply(PetState pet, PetAction action, {DateTime? now}) {
    final timestamp = now ?? DateTime.now();
    final reward = xpRewards[action]!;
    late PetState next;
    switch (action) {
      case PetAction.feed:
        next = pet.copyWith(
          hunger: (pet.hunger + 22).clamp(0, 100).toDouble(),
          happiness: (pet.happiness + 5).clamp(0, 100).toDouble(),
          currentActivity: PetActivity.eating,
          lastFedAt: timestamp,
          lastInteractionAt: timestamp,
          lastAction: 'Fed MAXie',
          recentInteraction: 'That hit the spot. Thank you!',
        );
      case PetAction.play:
        if (pet.energy < 12) {
          return pet.copyWith(recentInteraction: 'MAXie needs a rest first.');
        }
        next = pet.copyWith(
          happiness: (pet.happiness + 14).clamp(0, 100).toDouble(),
          energy: (pet.energy - 12).clamp(0, 100).toDouble(),
          currentActivity: PetActivity.playing,
          lastPlayedAt: timestamp,
          lastInteractionAt: timestamp,
          lastAction: 'Played together',
          recentInteraction: 'That was fun! Again soon?',
        );
      case PetAction.sleep:
        next = pet.copyWith(
          currentActivity: PetActivity.sleeping,
          mood: PetMood.sleepy,
          lastSleptAt: timestamp,
          lastInteractionAt: timestamp,
          lastAction: 'Took a nap',
          recentInteraction: 'A quiet recharge sounds perfect.',
        );
      case PetAction.dance:
        if (pet.energy < 18) {
          return pet.copyWith(
            recentInteraction: 'MAXie is too tired to dance.',
          );
        }
        next = pet.copyWith(
          happiness: (pet.happiness + 10).clamp(0, 100).toDouble(),
          energy: (pet.energy - 18).clamp(0, 100).toDouble(),
          currentActivity: PetActivity.dancing,
          lastPlayedAt: timestamp,
          lastInteractionAt: timestamp,
          lastAction: 'Danced together',
          recentInteraction: 'MAXie is showing off a new move!',
        );
      case PetAction.listen:
        next = pet.copyWith(
          happiness: (pet.happiness + 3).clamp(0, 100).toDouble(),
          currentActivity: PetActivity.listening,
          lastInteractionAt: timestamp,
          lastAction: 'Listened to you',
          recentInteraction: 'MAXie is listening closely.',
        );
    }

    final xp = pet.xp + reward;
    final missions = next.missions.map((mission) {
      if (mission.id != action.name || mission.completed) return mission;
      return mission.copyWith(progress: mission.progress + 1);
    }).toList();
    return next.copyWith(
      xp: xp,
      level: (xp ~/ 100) + 1,
      friendship: pet.friendship + (action == PetAction.play ? 2 : 1),
      mood: _moodFor(next.hunger, next.energy, next.happiness, next.sleepiness),
      updatedAt: timestamp,
      missions: missions,
    );
  }

  static PetMood _moodFor(
    double hunger,
    double energy,
    double happiness,
    double sleepiness,
  ) {
    if (sleepiness >= 80) return PetMood.sleepy;
    if (energy < 20) return PetMood.tired;
    if (hunger < 20) return PetMood.hungry;
    if (happiness >= 85) return PetMood.excited;
    if (happiness >= 60) return PetMood.happy;
    if (happiness < 25) return PetMood.sad;
    return PetMood.neutral;
  }

  static PetState applyTime(PetState pet, DateTime now) {
    final updatedAt = pet.updatedAt;
    if (updatedAt == null || !now.isAfter(updatedAt)) return pet;
    final hours = now.difference(updatedAt).inMinutes / 60;
    final sleeping = pet.currentActivity == PetActivity.sleeping;
    final energy = sleeping
        ? (pet.energy + hours * 12).clamp(0, 100).toDouble()
        : (pet.energy - hours * 2).clamp(0, 100).toDouble();
    final hunger = (pet.hunger - hours * 1.5).clamp(0, 100).toDouble();
    final sleepiness = sleeping
        ? (pet.sleepiness - hours * 15).clamp(0, 100).toDouble()
        : (pet.sleepiness + hours * 2).clamp(0, 100).toDouble();
    return pet.copyWith(
      energy: energy,
      hunger: hunger,
      sleepiness: sleepiness,
      mood: _moodFor(hunger, energy, pet.happiness, sleepiness),
      currentActivity: PetActivity.idle,
      updatedAt: now,
    );
  }
}

class PetController extends AsyncNotifier<PetState> {
  late final PetRepository _repository;

  @override
  Future<PetState> build() async {
    _repository = ref.watch(petRepositoryProvider);
    final loaded = await _repository.readPet();
    final now = DateTime.now();
    final initial = loaded.createdAt == null
        ? loaded.copyWith(createdAt: now, updatedAt: now)
        : PetEngine.applyTime(loaded, now);
    final withMissions = initial.missions.isEmpty
        ? initial.copyWith(missions: _todayMissions(now))
        : initial;
    await _repository.savePet(withMissions);
    return withMissions;
  }

  Future<void> perform(PetAction action) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final next = PetEngine.apply(current, action);
    if (next == current) return;
    state = AsyncData(next);
    try {
      await _repository.savePet(next);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  List<DailyMission> _todayMissions(DateTime now) => [
    DailyMission(
      id: 'feed',
      title: 'Feed MAXie once',
      description: 'Give MAXie a little care today.',
      target: 1,
      progress: 0,
      xpReward: 25,
      date: now,
    ),
    DailyMission(
      id: 'play',
      title: 'Play together',
      description: 'Make time for one playful moment.',
      target: 1,
      progress: 0,
      xpReward: 25,
      date: now,
    ),
  ];
}

final petControllerProvider = AsyncNotifierProvider<PetController, PetState>(
  PetController.new,
);
