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

  PetState copyWith({
    String? name,
    PetMood? mood,
    double? energy,
    int? affinity,
  }) {
    return PetState(
      name: name ?? this.name,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      affinity: affinity ?? this.affinity,
    );
  }

  factory PetState.fromJson(Map<dynamic, dynamic> json) {
    return PetState(
      name: json['name'] as String? ?? 'MAXie',
      mood: _petMoodFromName(json['mood'] as String?),
      energy: (json['energy'] as num?)?.toDouble() ?? 1,
      affinity: (json['affinity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'mood': mood.name,
      'energy': energy,
      'affinity': affinity,
    };
  }
}

PetMood _petMoodFromName(String? name) {
  for (final mood in PetMood.values) {
    if (mood.name == name) {
      return mood;
    }
  }
  return PetMood.neutral;
}
