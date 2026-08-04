enum PetMood { neutral, happy, focused, sleepy }

class PetState {
  const PetState({
    this.name = 'MAXie',
    this.mood = PetMood.neutral,
    this.energy = 1,
    this.affinity = 0,
  });

  final String name;
  final PetMood mood;
  final double energy;
  final int affinity;
}
