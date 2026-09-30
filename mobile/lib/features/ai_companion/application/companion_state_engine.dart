import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/ai_companion/application/ai_companion_providers.dart';
import 'package:maxie_mobile/features/ai_companion/data/hive_companion_emotion_repository.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/companion_emotion.dart';
import 'package:maxie_mobile/features/ai_companion/domain/repositories/ai_companion_repository.dart';
import 'package:maxie_mobile/features/ai_companion/domain/repositories/companion_emotion_repository.dart';
import 'package:maxie_mobile/features/memory/application/memory_providers.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_entry.dart';
import 'package:maxie_mobile/features/memory/domain/repositories/memory_repository.dart';
import 'package:maxie_mobile/features/pet/application/pet_providers.dart';
import 'package:maxie_mobile/features/pet/domain/models/pet_state.dart';
import 'package:maxie_mobile/features/pet/domain/repositories/pet_repository.dart';
import 'package:maxie_mobile/services/storage/storage_providers.dart';

final companionEmotionRepositoryProvider = Provider<CompanionEmotionRepository>(
  (ref) => HiveCompanionEmotionRepository(ref.watch(storageServiceProvider)),
);

final companionStateEngineProvider =
    StateNotifierProvider<CompanionStateEngine, AsyncValue<CompanionEmotion>>(
      (ref) {
        final engine = CompanionStateEngine(
          emotionRepository: ref.watch(companionEmotionRepositoryProvider),
          petRepository: ref.watch(petRepositoryProvider),
          companionRepository: ref.watch(aiCompanionRepositoryProvider),
          memoryRepository: ref.watch(memoryRepositoryProvider),
        );
        unawaited(engine.restoreState());
        return engine;
      },
    );

final companionEmotionProvider = companionStateEngineProvider;

class CompanionStateEngine extends StateNotifier<AsyncValue<CompanionEmotion>> {
  CompanionStateEngine({
    required CompanionEmotionRepository emotionRepository,
    required PetRepository petRepository,
    required AiCompanionRepository companionRepository,
    MemoryRepository? memoryRepository,
    DateTime Function()? now,
  })  : _emotionRepository = emotionRepository,
        _petRepository = petRepository,
        _companionRepository = companionRepository,
        _memoryRepository = memoryRepository,
        _now = now ?? DateTime.now,
        super(const AsyncValue.loading());

  final CompanionEmotionRepository _emotionRepository;
  final PetRepository _petRepository;
  final AiCompanionRepository _companionRepository;
  final MemoryRepository? _memoryRepository;
  final DateTime Function() _now;

  Future<CompanionEmotion> restoreState() async {
    try {
      final restored = await _emotionRepository.readEmotion();
      final next = _applyInactivity(restored, _now());
      await _persistEmotion(next);
      state = AsyncValue.data(next);
      return next;
    } catch (error, stackTrace) {
      final fallback = CompanionEmotion.initial(now: _now());
      state = AsyncValue.error(error, stackTrace);
      await _persistEmotion(fallback);
      state = AsyncValue.data(fallback);
      return fallback;
    }
  }

  Future<CompanionEmotion> reactToFeed() async {
    final current = await _currentEmotion();
    final type = switch (current.type) {
      CompanionEmotionType.hungry => CompanionEmotionType.satisfied,
      _ => CompanionEmotionType.happy,
    };
    await _updatePet(
      mood: PetMood.happy,
      energyDelta: 0.16,
      affinityDelta: 4,
    );
    return setEmotion(
      type,
      intensity: 0.78,
      reason: 'fed',
      duration: const Duration(minutes: 35),
      meaningfulMemory: 'User fed MAXie',
    );
  }

  Future<CompanionEmotion> reactToPlay() async {
    final current = await _currentEmotion();
    final type = switch (current.type) {
      CompanionEmotionType.bored => CompanionEmotionType.playful,
      CompanionEmotionType.sad => CompanionEmotionType.happy,
      _ => CompanionEmotionType.excited,
    };
    await _updatePet(
      mood: PetMood.focused,
      energyDelta: -0.08,
      affinityDelta: 6,
    );
    return setEmotion(
      type,
      intensity: 0.82,
      reason: 'played',
      duration: const Duration(minutes: 25),
      meaningfulMemory: 'User played with MAXie',
    );
  }

  Future<CompanionEmotion> reactToCustomize() async {
    final current = await _currentEmotion();
    final type = current.type == CompanionEmotionType.happy
        ? CompanionEmotionType.curious
        : CompanionEmotionType.excited;
    return setEmotion(
      type,
      intensity: 0.68,
      reason: 'customized',
      duration: const Duration(minutes: 20),
      meaningfulMemory: 'User customized MAXie',
    );
  }

  Future<CompanionEmotion> reactToChat() async {
    final current = await _currentEmotion();
    final type = switch (current.type) {
      CompanionEmotionType.sad => CompanionEmotionType.comforted,
      CompanionEmotionType.happy => CompanionEmotionType.excited,
      _ => CompanionEmotionType.curious,
    };
    return setEmotion(
      type,
      intensity: 0.64,
      reason: 'chat',
      duration: const Duration(minutes: 18),
    );
  }

  Future<CompanionEmotion> reactToWake() {
    return setEmotion(
      CompanionEmotionType.happy,
      intensity: 0.58,
      reason: 'wake',
      duration: const Duration(minutes: 15),
    );
  }

  Future<CompanionEmotion> reactToSleep() {
    return setEmotion(
      CompanionEmotionType.sleepy,
      intensity: 0.56,
      reason: 'sleep',
      duration: const Duration(hours: 1),
    );
  }

  Future<CompanionEmotion> updateFromInactivity() async {
    final current = await _currentEmotion();
    final next = _applyInactivity(current, _now());
    await _persistEmotion(next);
    state = AsyncValue.data(next);
    return next;
  }

  Future<CompanionEmotion> setEmotion(
    CompanionEmotionType type, {
    required double intensity,
    required String reason,
    Duration? duration,
    String? meaningfulMemory,
  }) async {
    final current = await _currentEmotion();
    final now = _now();
    final next = CompanionEmotion(
      type: type,
      intensity: intensity.clamp(0, 1),
      reason: reason,
      changedAt: now,
      expiresAt: duration == null ? null : now.add(duration),
      lastInteractionAt: now,
      reactionMessage: _reactionMessage(type, reason, current.reactionMessage),
    );
    await _persistEmotion(next);
    if (meaningfulMemory != null) {
      unawaited(_recordMeaningfulMemory(meaningfulMemory, next));
    }
    state = AsyncValue.data(next);
    return next;
  }

  Future<CompanionEmotion> _currentEmotion() async {
    return state.valueOrNull ?? await restoreState();
  }

  CompanionEmotion _applyInactivity(CompanionEmotion emotion, DateTime now) {
    if (!emotion.isExpired(now) &&
        now.difference(emotion.changedAt) < const Duration(minutes: 20)) {
      return emotion;
    }

    final elapsed = now.difference(emotion.lastInteractionAt);
    if (elapsed >= const Duration(hours: 24)) {
      return _inactiveEmotion(
        emotion,
        now,
        CompanionEmotionType.sleepy,
        0.62,
        'long_absence',
      );
    }
    if (elapsed >= const Duration(hours: 6)) {
      final morning = now.hour >= 5 && now.hour < 12;
      return _inactiveEmotion(
        emotion,
        now,
        morning ? CompanionEmotionType.curious : CompanionEmotionType.sleepy,
        morning ? 0.55 : 0.52,
        morning ? 'morning_return' : 'resting',
      );
    }
    if (elapsed >= const Duration(minutes: 90)) {
      return _inactiveEmotion(
        emotion,
        now,
        CompanionEmotionType.bored,
        0.42,
        'quiet_time',
      );
    }
    if (emotion.isExpired(now)) {
      return _inactiveEmotion(
        emotion,
        now,
        CompanionEmotionType.neutral,
        0.45,
        'settled',
      );
    }
    return emotion;
  }

  CompanionEmotion _inactiveEmotion(
    CompanionEmotion previous,
    DateTime now,
    CompanionEmotionType type,
    double intensity,
    String reason,
  ) {
    return previous.copyWith(
      type: type,
      intensity: intensity,
      reason: reason,
      changedAt: now,
      expiresAt: null,
      reactionMessage: _reactionMessage(type, reason, previous.reactionMessage),
    );
  }

  Future<void> _updatePet({
    required PetMood mood,
    required double energyDelta,
    required int affinityDelta,
  }) async {
    final pet = await _petRepository.readPet();
    await _petRepository.savePet(
      pet.copyWith(
        mood: mood,
        energy: (pet.energy + energyDelta).clamp(0, 1).toDouble(),
        affinity: pet.affinity + affinityDelta,
      ),
    );
  }

  Future<void> _persistEmotion(CompanionEmotion emotion) async {
    await _emotionRepository.saveEmotion(emotion);
    await _companionRepository.saveState(
      AiCompanionState(
        presence: _presenceForEmotion(emotion.type),
        statusMessage: emotion.reactionMessage ?? _labelForEmotion(emotion.type),
      ),
    );
  }

  Future<void> _recordMeaningfulMemory(
    String value,
    CompanionEmotion emotion,
  ) async {
    final repository = _memoryRepository;
    if (repository == null) {
      return;
    }
    final now = _now();
    await repository.saveMemory(
      MemoryEntry(
        id: 'companion-${now.microsecondsSinceEpoch}',
        title:
            'Companion interaction: $value. MAXie became ${_labelForEmotion(emotion.type)}.',
        createdAt: now,
        tags: const ['companion', 'emotion'],
      ),
    );
  }

  CompanionPresence _presenceForEmotion(CompanionEmotionType type) {
    return switch (type) {
      CompanionEmotionType.happy ||
      CompanionEmotionType.satisfied ||
      CompanionEmotionType.comforted =>
        CompanionPresence.happy,
      CompanionEmotionType.excited || CompanionEmotionType.playful =>
        CompanionPresence.excited,
      CompanionEmotionType.sleepy => CompanionPresence.sleeping,
      CompanionEmotionType.curious => CompanionPresence.thinking,
      CompanionEmotionType.bored => CompanionPresence.idle,
      CompanionEmotionType.sad => CompanionPresence.idle,
      CompanionEmotionType.hungry => CompanionPresence.listening,
      CompanionEmotionType.angry => CompanionPresence.typing,
      CompanionEmotionType.neutral => CompanionPresence.idle,
    };
  }

  String _reactionMessage(
    CompanionEmotionType type,
    String reason,
    String? previous,
  ) {
    final messages = switch (reason) {
      'fed' => const ['Yummy! Thanks!', 'That was good!', 'Feeling happy!'],
      'played' => const ["Let's play!", 'That was fun!', 'Again soon!'],
      'customized' => const ['New look saved!', 'I feel fresh!', 'Nice style!'],
      'chat' => const ['Tell me more.', "I'm listening.", 'That is interesting.'],
      'quiet_time' => const ['Still here with you.', 'A quiet moment.', 'Ready when you are.'],
      'long_absence' => const ["You're back!", 'I missed you!', 'Good to see you.'],
      'sleep' => const ['Getting sleepy...', 'Time for a little rest.'],
      'wake' => const ['Good to see you!', "I'm awake.", 'Ready again.'],
      _ => const ['Ready when you are.', 'I am here.', 'All set.'],
    };
    for (final message in messages) {
      if (message != previous) {
        return message;
      }
    }
    return '${_labelForEmotion(type)} mode';
  }

  String _labelForEmotion(CompanionEmotionType type) {
    return switch (type) {
      CompanionEmotionType.happy => 'happy',
      CompanionEmotionType.excited => 'excited',
      CompanionEmotionType.playful => 'playful',
      CompanionEmotionType.sleepy => 'sleepy',
      CompanionEmotionType.hungry => 'hungry',
      CompanionEmotionType.sad => 'sad',
      CompanionEmotionType.bored => 'bored',
      CompanionEmotionType.curious => 'curious',
      CompanionEmotionType.angry => 'focused',
      CompanionEmotionType.neutral => 'calm',
      CompanionEmotionType.satisfied => 'satisfied',
      CompanionEmotionType.comforted => 'comforted',
    };
  }
}
