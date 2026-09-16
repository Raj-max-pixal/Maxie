import 'package:flutter_test/flutter_test.dart';
import 'package:maxie_mobile/features/pet/application/pet_controller.dart';
import 'package:maxie_mobile/features/pet/domain/models/pet_state.dart';

void main() {
  test('feed improves care, XP, friendship, and mission progress', () {
    final mission = DailyMission(
      id: 'feed',
      title: 'Feed MAXie once',
      description: 'Care',
      target: 1,
      progress: 0,
      xpReward: 25,
      date: DateTime(2026, 9, 16),
    );
    final pet = PetState(hunger: 40, happiness: 50, missions: [mission]);

    final updated = PetEngine.apply(
      pet,
      PetAction.feed,
      now: DateTime(2026, 9, 16, 12),
    );

    expect(updated.hunger, 62);
    expect(updated.happiness, 55);
    expect(updated.xp, 5);
    expect(updated.friendship, 1);
    expect(updated.missions.single.completed, isTrue);
    expect(updated.currentActivity, PetActivity.eating);
  });

  test('play validates energy and changes happiness and energy', () {
    final pet = PetState(energy: 50);
    final updated = PetEngine.apply(pet, PetAction.play);

    expect(updated.energy, 38);
    expect(updated.happiness, 84);
    expect(updated.xp, 10);
    expect(updated.friendship, 2);
  });

  test('low energy blocks dance without awarding rewards', () {
    final pet = PetState(energy: 10);
    final updated = PetEngine.apply(pet, PetAction.dance);

    expect(updated.xp, 0);
    expect(updated.friendship, 0);
    expect(updated.energy, 10);
    expect(updated.recentInteraction, contains('tired'));
  });

  test('level and mood are deterministic', () {
    final pet = PetState(xp: 95, happiness: 60);
    final updated = PetEngine.apply(pet, PetAction.feed);

    expect(updated.level, 2);
    expect(updated.xp, 100);
    expect(updated.mood, PetMood.happy);
  });

  test('time decay updates energy and hunger on resume', () {
    final savedAt = DateTime(2026, 9, 16, 8);
    final pet = PetState(
      energy: 80,
      hunger: 70,
      updatedAt: savedAt,
    );

    final updated = PetEngine.applyTime(pet, DateTime(2026, 9, 16, 12));

    expect(updated.energy, 72);
    expect(updated.hunger, 64);
    expect(updated.updatedAt, DateTime(2026, 9, 16, 12));
  });

  test('state round trips through local storage JSON', () {
    final pet = PetState(
      xp: 12,
      friendship: 4,
      hunger: 55,
      energy: 44,
      happiness: 77,
      updatedAt: DateTime(2026, 9, 16),
    );

    final restored = PetState.fromJson(pet.toJson());

    expect(restored.xp, pet.xp);
    expect(restored.friendship, pet.friendship);
    expect(restored.hunger, pet.hunger);
    expect(restored.updatedAt, pet.updatedAt);
  });
}
