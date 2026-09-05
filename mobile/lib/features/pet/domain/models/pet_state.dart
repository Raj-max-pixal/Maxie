enum PetMood { neutral, happy, focused, sleepy, listening, dancing, loving }

class PetState {
  const PetState({
    this.name = 'MAXie',
    this.mood = PetMood.neutral,
    this.energy = 1,
    this.affinity = 0,
    this.gifts = 0,
    this.lastAction = 'Idle',
  });

  final String name;
  final PetMood mood;
  final double energy;
  final int affinity;
  final int gifts;
  final String lastAction;

  PetState copyWith({
    String? name,
    PetMood? mood,
    double? energy,
    int? affinity,
    int? gifts,
    String? lastAction,
  }) {
    return PetState(
      name: name ?? this.name,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      affinity: affinity ?? this.affinity,
      gifts: gifts ?? this.gifts,
      lastAction: lastAction ?? this.lastAction,
    );
  }

  factory PetState.fromJson(Map<dynamic, dynamic> json) {
    return PetState(
      name: json['name'] as String? ?? 'MAXie',
      mood: PetMood.values.byName(json['mood'] as String? ?? 'neutral'),
      energy: (json['energy'] as num?)?.toDouble() ?? 1,
      affinity: (json['affinity'] as num?)?.toInt() ?? 0,
      gifts: (json['gifts'] as num?)?.toInt() ?? 0,
      lastAction: json['lastAction'] as String? ?? 'Idle',
    );
  }

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'mood': mood.name,
      'energy': energy,
      'affinity': affinity,
      'gifts': gifts,
      'lastAction': lastAction,
    };
  }
}
