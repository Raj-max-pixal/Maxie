enum PetMood {
  neutral,
  happy,
  excited,
  hungry,
  tired,
  sleepy,
  sad,
  focused,
  listening,
  dancing,
  loving,
}

enum PetActivity { idle, eating, playing, sleeping, dancing, listening }

enum PetPersonality { curious, kind, playful, calm }

class DailyMission {
  const DailyMission({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.progress,
    required this.xpReward,
    required this.date,
  });

  final String id;
  final String title;
  final String description;
  final int target;
  final int progress;
  final int xpReward;
  final DateTime date;

  bool get completed => progress >= target;

  DailyMission copyWith({int? progress}) => DailyMission(
        id: id,
        title: title,
        description: description,
        target: target,
        progress: progress ?? this.progress,
        xpReward: xpReward,
        date: date,
      );

  factory DailyMission.fromJson(Map<dynamic, dynamic> json) => DailyMission(
        id: json['id'] as String? ?? 'feed',
        title: json['title'] as String? ?? 'Feed MAXie once',
        description: json['description'] as String? ?? 'Give MAXie a little care.',
        target: (json['target'] as num?)?.toInt() ?? 1,
        progress: (json['progress'] as num?)?.toInt() ?? 0,
        xpReward: (json['xpReward'] as num?)?.toInt() ?? 25,
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'target': target,
        'progress': progress,
        'xpReward': xpReward,
        'date': date.toIso8601String(),
      };
}

class PetState {
  const PetState({
    this.id = 'maxie-primary',
    this.name = 'MAXie',
    this.level = 1,
    this.xp = 0,
    this.friendship = 0,
    this.hunger = 72,
    this.energy = 82,
    this.happiness = 70,
    this.mood = PetMood.neutral,
    this.currentActivity = PetActivity.idle,
    this.personality = PetPersonality.kind,
    this.createdAt,
    this.updatedAt,
    this.gifts = 0,
    this.lastAction = 'Ready to hang out',
    this.recentInteraction = 'MAXie is waiting for you.',
    this.missions = const [],
    this.inventory = const [],
    this.equippedItemIds = const [],
  });

  final String id;
  final String name;
  final int level;
  final int xp;
  final int friendship;
  final double hunger;
  final double happiness;
  final PetMood mood;
  final double energy;
  final PetActivity currentActivity;
  final PetPersonality personality;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int gifts;
  final String lastAction;
  final String recentInteraction;
  final List<DailyMission> missions;
  final List<String> inventory;
  final List<String> equippedItemIds;

  int get affinity => friendship;
  double get xpProgress => (xp % 100) / 100;
  int get friendshipLevel => (friendship ~/ 100) + 1;

  PetState copyWith({
    String? id,
    String? name,
    int? level,
    int? xp,
    int? friendship,
    int? affinity,
    double? hunger,
    double? happiness,
    PetMood? mood,
    double? energy,
    PetActivity? currentActivity,
    PetPersonality? personality,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? gifts,
    String? lastAction,
    String? recentInteraction,
    List<DailyMission>? missions,
    List<String>? inventory,
    List<String>? equippedItemIds,
  }) {
    return PetState(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      friendship: friendship ?? affinity ?? this.friendship,
      hunger: hunger ?? this.hunger,
      happiness: happiness ?? this.happiness,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      currentActivity: currentActivity ?? this.currentActivity,
      personality: personality ?? this.personality,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      gifts: gifts ?? this.gifts,
      lastAction: lastAction ?? this.lastAction,
      recentInteraction: recentInteraction ?? this.recentInteraction,
      missions: missions ?? this.missions,
      inventory: inventory ?? this.inventory,
      equippedItemIds: equippedItemIds ?? this.equippedItemIds,
    );
  }

  factory PetState.fromJson(Map<dynamic, dynamic> json) {
    PetMood readMood() => PetMood.values.firstWhere(
          (value) => value.name == json['mood'],
          orElse: () => PetMood.neutral,
        );
    PetActivity readActivity() => PetActivity.values.firstWhere(
          (value) => value.name == json['currentActivity'],
          orElse: () => PetActivity.idle,
        );
    PetPersonality readPersonality() => PetPersonality.values.firstWhere(
          (value) => value.name == json['personality'],
          orElse: () => PetPersonality.kind,
        );

    return PetState(
      id: json['id'] as String? ?? 'maxie-primary',
      name: json['name'] as String? ?? 'MAXie',
      level: (json['level'] as num?)?.toInt() ?? 1,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      friendship: (json['friendship'] as num?)?.toInt() ??
          (json['affinity'] as num?)?.toInt() ?? 0,
      hunger: (json['hunger'] as num?)?.toDouble() ?? 72,
      happiness: (json['happiness'] as num?)?.toDouble() ?? 70,
      mood: readMood(),
      energy: (json['energy'] as num?)?.toDouble() ?? 82,
      currentActivity: readActivity(),
      personality: readPersonality(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      gifts: (json['gifts'] as num?)?.toInt() ?? 0,
      lastAction: json['lastAction'] as String? ?? 'Ready to hang out',
      recentInteraction: json['recentInteraction'] as String? ??
          'MAXie is waiting for you.',
      missions: (json['missions'] as List<dynamic>? ?? const [])
          .whereType<Map<dynamic, dynamic>>()
          .map(DailyMission.fromJson)
          .toList(),
      inventory: (json['inventory'] as List<dynamic>? ?? const []).cast<String>(),
      equippedItemIds:
          (json['equippedItemIds'] as List<dynamic>? ?? const []).cast<String>(),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'xp': xp,
      'friendship': friendship,
      'hunger': hunger,
      'happiness': happiness,
      'mood': mood.name,
      'energy': energy,
      'currentActivity': currentActivity.name,
      'personality': personality.name,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'gifts': gifts,
      'lastAction': lastAction,
      'recentInteraction': recentInteraction,
      'missions': missions.map((mission) => mission.toJson()).toList(),
      'inventory': inventory,
      'equippedItemIds': equippedItemIds,
    };
  }
}
