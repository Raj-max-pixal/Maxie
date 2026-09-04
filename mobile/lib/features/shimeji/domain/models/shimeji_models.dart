enum ShimejiAnimation {
  idle,
  walk,
  run,
  jump,
  fall,
  climb,
  sit,
  sleep,
  wake,
  dance,
  happy,
  sad,
  angry,
  surprised,
  love,
  eat,
  listen,
  think,
  wave,
  drag,
  throwing,
  land,
}

enum ShimejiMood {
  happy,
  neutral,
  sad,
  angry,
  sleepy,
  excited,
  love,
  surprised,
  hungry,
  bored,
}

enum ShimejiPersonality { friendly, playful, lazy, curious, calm }

class ShimejiPersonalityTraits {
  const ShimejiPersonalityTraits({
    required this.friendly,
    required this.energy,
    required this.curiosity,
    required this.playfulness,
    required this.calmness,
  });

  final int friendly;
  final int energy;
  final int curiosity;
  final int playfulness;
  final int calmness;

  factory ShimejiPersonalityTraits.forPersonality(
    ShimejiPersonality personality,
  ) {
    return switch (personality) {
      ShimejiPersonality.friendly => const ShimejiPersonalityTraits(
        friendly: 90,
        energy: 75,
        curiosity: 80,
        playfulness: 85,
        calmness: 60,
      ),
      ShimejiPersonality.playful => const ShimejiPersonalityTraits(
        friendly: 78,
        energy: 95,
        curiosity: 76,
        playfulness: 98,
        calmness: 35,
      ),
      ShimejiPersonality.lazy => const ShimejiPersonalityTraits(
        friendly: 72,
        energy: 35,
        curiosity: 45,
        playfulness: 42,
        calmness: 92,
      ),
      ShimejiPersonality.curious => const ShimejiPersonalityTraits(
        friendly: 80,
        energy: 72,
        curiosity: 98,
        playfulness: 70,
        calmness: 52,
      ),
      ShimejiPersonality.calm => const ShimejiPersonalityTraits(
        friendly: 84,
        energy: 50,
        curiosity: 62,
        playfulness: 48,
        calmness: 96,
      ),
    };
  }

  factory ShimejiPersonalityTraits.fromJson(Map<dynamic, dynamic> json) {
    return ShimejiPersonalityTraits(
      friendly: (json['friendly'] as num?)?.toInt() ?? 80,
      energy: (json['energy'] as num?)?.toInt() ?? 70,
      curiosity: (json['curiosity'] as num?)?.toInt() ?? 70,
      playfulness: (json['playfulness'] as num?)?.toInt() ?? 70,
      calmness: (json['calmness'] as num?)?.toInt() ?? 60,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'friendly': friendly,
      'energy': energy,
      'curiosity': curiosity,
      'playfulness': playfulness,
      'calmness': calmness,
    };
  }
}

class ShimejiPet {
  const ShimejiPet({
    required this.id,
    required this.name,
    required this.displayName,
    required this.personality,
    required this.traits,
    required this.color,
    required this.accentColor,
    this.currentAnimation = ShimejiAnimation.idle,
    this.mood = ShimejiMood.neutral,
    this.x = 40,
    this.y = 0,
    this.vx = 0,
    this.vy = 0,
    this.scale = 1,
    this.friendship = 0,
    this.xp = 0,
    this.unlocked = false,
    this.visible = true,
    this.dragging = false,
    this.nextBehaviorTick = 0,
  });

  final String id;
  final String name;
  final String displayName;
  final ShimejiPersonality personality;
  final ShimejiPersonalityTraits traits;
  final int color;
  final int accentColor;
  final ShimejiAnimation currentAnimation;
  final ShimejiMood mood;
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double scale;
  final int friendship;
  final int xp;
  final bool unlocked;
  final bool visible;
  final bool dragging;
  final int nextBehaviorTick;

  ShimejiPet copyWith({
    String? displayName,
    ShimejiPersonality? personality,
    ShimejiPersonalityTraits? traits,
    int? color,
    int? accentColor,
    ShimejiAnimation? currentAnimation,
    ShimejiMood? mood,
    double? x,
    double? y,
    double? vx,
    double? vy,
    double? scale,
    int? friendship,
    int? xp,
    bool? unlocked,
    bool? visible,
    bool? dragging,
    int? nextBehaviorTick,
  }) {
    return ShimejiPet(
      id: id,
      name: name,
      displayName: displayName ?? this.displayName,
      personality: personality ?? this.personality,
      traits: traits ?? this.traits,
      color: color ?? this.color,
      accentColor: accentColor ?? this.accentColor,
      currentAnimation: currentAnimation ?? this.currentAnimation,
      mood: mood ?? this.mood,
      x: x ?? this.x,
      y: y ?? this.y,
      vx: vx ?? this.vx,
      vy: vy ?? this.vy,
      scale: scale ?? this.scale,
      friendship: friendship ?? this.friendship,
      xp: xp ?? this.xp,
      unlocked: unlocked ?? this.unlocked,
      visible: visible ?? this.visible,
      dragging: dragging ?? this.dragging,
      nextBehaviorTick: nextBehaviorTick ?? this.nextBehaviorTick,
    );
  }

  factory ShimejiPet.fromJson(Map<dynamic, dynamic> json) {
    final personality = ShimejiPersonality.values.byName(
      json['personality'] as String? ?? ShimejiPersonality.friendly.name,
    );

    return ShimejiPet(
      id: json['id'] as String? ?? 'maxie',
      name: json['name'] as String? ?? 'MAXie',
      displayName: json['displayName'] as String? ?? 'MAXie',
      personality: personality,
      traits: json['traits'] is Map
          ? ShimejiPersonalityTraits.fromJson(json['traits'] as Map)
          : ShimejiPersonalityTraits.forPersonality(personality),
      color: (json['color'] as num?)?.toInt() ?? 0xFF7C3AED,
      accentColor: (json['accentColor'] as num?)?.toInt() ?? 0xFF06B6D4,
      currentAnimation: ShimejiAnimation.values.byName(
        json['currentAnimation'] as String? ?? ShimejiAnimation.idle.name,
      ),
      mood: ShimejiMood.values.byName(
        json['mood'] as String? ?? ShimejiMood.neutral.name,
      ),
      x: (json['x'] as num?)?.toDouble() ?? 40,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      vx: (json['vx'] as num?)?.toDouble() ?? 0,
      vy: (json['vy'] as num?)?.toDouble() ?? 0,
      scale: (json['scale'] as num?)?.toDouble() ?? 1,
      friendship: (json['friendship'] as num?)?.toInt() ?? 0,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      unlocked: json['unlocked'] as bool? ?? false,
      visible: json['visible'] as bool? ?? true,
      dragging: json['dragging'] as bool? ?? false,
      nextBehaviorTick: (json['nextBehaviorTick'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'personality': personality.name,
      'traits': traits.toJson(),
      'color': color,
      'accentColor': accentColor,
      'currentAnimation': currentAnimation.name,
      'mood': mood.name,
      'x': x,
      'y': y,
      'vx': vx,
      'vy': vy,
      'scale': scale,
      'friendship': friendship,
      'xp': xp,
      'unlocked': unlocked,
      'visible': visible,
      'dragging': dragging,
      'nextBehaviorTick': nextBehaviorTick,
    };
  }
}

class ShimejiSettings {
  const ShimejiSettings({
    this.overlayEnabled = false,
    this.inAppFallback = true,
    this.petSize = 1,
    this.movementSpeed = 1,
    this.opacity = 1,
    this.soundEnabled = false,
    this.volume = 0.7,
    this.autoMovement = true,
    this.interactionEnabled = true,
    this.batterySaver = true,
    this.notificationsEnabled = false,
    this.reducedMotion = false,
    this.paused = false,
    this.hidden = false,
    this.debugEnabled = false,
  });

  final bool overlayEnabled;
  final bool inAppFallback;
  final double petSize;
  final double movementSpeed;
  final double opacity;
  final bool soundEnabled;
  final double volume;
  final bool autoMovement;
  final bool interactionEnabled;
  final bool batterySaver;
  final bool notificationsEnabled;
  final bool reducedMotion;
  final bool paused;
  final bool hidden;
  final bool debugEnabled;

  ShimejiSettings copyWith({
    bool? overlayEnabled,
    bool? inAppFallback,
    double? petSize,
    double? movementSpeed,
    double? opacity,
    bool? soundEnabled,
    double? volume,
    bool? autoMovement,
    bool? interactionEnabled,
    bool? batterySaver,
    bool? notificationsEnabled,
    bool? reducedMotion,
    bool? paused,
    bool? hidden,
    bool? debugEnabled,
  }) {
    return ShimejiSettings(
      overlayEnabled: overlayEnabled ?? this.overlayEnabled,
      inAppFallback: inAppFallback ?? this.inAppFallback,
      petSize: petSize ?? this.petSize,
      movementSpeed: movementSpeed ?? this.movementSpeed,
      opacity: opacity ?? this.opacity,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      volume: volume ?? this.volume,
      autoMovement: autoMovement ?? this.autoMovement,
      interactionEnabled: interactionEnabled ?? this.interactionEnabled,
      batterySaver: batterySaver ?? this.batterySaver,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      paused: paused ?? this.paused,
      hidden: hidden ?? this.hidden,
      debugEnabled: debugEnabled ?? this.debugEnabled,
    );
  }

  factory ShimejiSettings.fromJson(Map<dynamic, dynamic> json) {
    return ShimejiSettings(
      overlayEnabled: json['overlayEnabled'] as bool? ?? false,
      inAppFallback: json['inAppFallback'] as bool? ?? true,
      petSize: (json['petSize'] as num?)?.toDouble() ?? 1,
      movementSpeed: (json['movementSpeed'] as num?)?.toDouble() ?? 1,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
      soundEnabled: json['soundEnabled'] as bool? ?? false,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.7,
      autoMovement: json['autoMovement'] as bool? ?? true,
      interactionEnabled: json['interactionEnabled'] as bool? ?? true,
      batterySaver: json['batterySaver'] as bool? ?? true,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      paused: json['paused'] as bool? ?? false,
      hidden: json['hidden'] as bool? ?? false,
      debugEnabled: json['debugEnabled'] as bool? ?? false,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'overlayEnabled': overlayEnabled,
      'inAppFallback': inAppFallback,
      'petSize': petSize,
      'movementSpeed': movementSpeed,
      'opacity': opacity,
      'soundEnabled': soundEnabled,
      'volume': volume,
      'autoMovement': autoMovement,
      'interactionEnabled': interactionEnabled,
      'batterySaver': batterySaver,
      'notificationsEnabled': notificationsEnabled,
      'reducedMotion': reducedMotion,
      'paused': paused,
      'hidden': hidden,
      'debugEnabled': debugEnabled,
    };
  }
}

class ShimejiState {
  const ShimejiState({
    required this.pets,
    this.settings = const ShimejiSettings(),
    this.selectedPetId = 'maxie',
    this.tick = 0,
    this.overlayStatus = 'Demo stage active',
    this.lastError,
  });

  final List<ShimejiPet> pets;
  final ShimejiSettings settings;
  final String selectedPetId;
  final int tick;
  final String overlayStatus;
  final String? lastError;

  ShimejiPet? get selectedPet {
    for (final pet in pets) {
      if (pet.id == selectedPetId) {
        return pet;
      }
    }
    return pets.isEmpty ? null : pets.first;
  }

  int get visiblePetCount => pets.where((pet) => pet.visible).length;

  ShimejiState copyWith({
    List<ShimejiPet>? pets,
    ShimejiSettings? settings,
    String? selectedPetId,
    int? tick,
    String? overlayStatus,
    String? lastError,
  }) {
    return ShimejiState(
      pets: pets ?? this.pets,
      settings: settings ?? this.settings,
      selectedPetId: selectedPetId ?? this.selectedPetId,
      tick: tick ?? this.tick,
      overlayStatus: overlayStatus ?? this.overlayStatus,
      lastError: lastError,
    );
  }

  factory ShimejiState.initial() {
    return ShimejiState(pets: defaultShimejiPets);
  }

  factory ShimejiState.fromJson(Map<dynamic, dynamic> json) {
    final savedPets =
        (json['pets'] as List?)
            ?.whereType<Map>()
            .map(ShimejiPet.fromJson)
            .toList() ??
        const <ShimejiPet>[];
    final mergedPets = _mergeDefaultPets(savedPets);

    return ShimejiState(
      pets: mergedPets,
      settings: json['settings'] is Map
          ? ShimejiSettings.fromJson(json['settings'] as Map)
          : const ShimejiSettings(),
      selectedPetId: json['selectedPetId'] as String? ?? 'maxie',
      tick: (json['tick'] as num?)?.toInt() ?? 0,
      overlayStatus: json['overlayStatus'] as String? ?? 'Demo stage active',
      lastError: json['lastError'] as String?,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'pets': pets.map((pet) => pet.toJson()).toList(),
      'settings': settings.toJson(),
      'selectedPetId': selectedPetId,
      'tick': tick,
      'overlayStatus': overlayStatus,
      'lastError': lastError,
    };
  }

  static List<ShimejiPet> _mergeDefaultPets(List<ShimejiPet> savedPets) {
    return [
      for (final defaultPet in defaultShimejiPets)
        _savedOrDefault(savedPets, defaultPet),
    ];
  }

  static ShimejiPet _savedOrDefault(
    List<ShimejiPet> savedPets,
    ShimejiPet defaultPet,
  ) {
    for (final pet in savedPets) {
      if (pet.id == defaultPet.id) {
        return pet;
      }
    }
    return defaultPet;
  }
}

final defaultShimejiPets = <ShimejiPet>[
  ShimejiPet(
    id: 'maxie',
    name: 'maxie',
    displayName: 'MAXie',
    personality: ShimejiPersonality.friendly,
    traits: ShimejiPersonalityTraits.forPersonality(
      ShimejiPersonality.friendly,
    ),
    color: 0xFF7C3AED,
    accentColor: 0xFF06B6D4,
    unlocked: true,
  ),
  ShimejiPet(
    id: 'mimi',
    name: 'mimi',
    displayName: 'Mimi',
    personality: ShimejiPersonality.playful,
    traits: ShimejiPersonalityTraits.forPersonality(ShimejiPersonality.playful),
    color: 0xFFEC4899,
    accentColor: 0xFFFDE68A,
    x: 160,
  ),
  ShimejiPet(
    id: 'kuro',
    name: 'kuro',
    displayName: 'Kuro',
    personality: ShimejiPersonality.calm,
    traits: ShimejiPersonalityTraits.forPersonality(ShimejiPersonality.calm),
    color: 0xFF111827,
    accentColor: 0xFFA78BFA,
    x: 260,
  ),
  ShimejiPet(
    id: 'luna',
    name: 'luna',
    displayName: 'Luna',
    personality: ShimejiPersonality.curious,
    traits: ShimejiPersonalityTraits.forPersonality(ShimejiPersonality.curious),
    color: 0xFF2563EB,
    accentColor: 0xFF93C5FD,
    x: 100,
  ),
  ShimejiPet(
    id: 'nova',
    name: 'nova',
    displayName: 'Nova',
    personality: ShimejiPersonality.lazy,
    traits: ShimejiPersonalityTraits.forPersonality(ShimejiPersonality.lazy),
    color: 0xFFF59E0B,
    accentColor: 0xFF22C55E,
    x: 210,
  ),
];
