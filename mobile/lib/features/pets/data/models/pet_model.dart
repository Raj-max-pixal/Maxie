import 'package:flutter/material.dart';

enum PetType {
  maxie,
  cat,
  dog,
  panda,
  fox,
  rabbit,
  penguin,
  dragon,
  slime,
  robot,
  capybara,
  axolotl,
}

enum PetPersonality {
  intelligent,
  helpful,
  motivational,
  lazy,
  funny,
  loyal,
  energetic,
  brave,
  protective,
  logical,
  curious,
  playful,
  calm,
  sassy,
  sleepy,
}

enum PetEmotion {
  happy,
  sad,
  excited,
  hungry,
  sleepy,
  curious,
  thinking,
  laughing,
  celebrating,
  angry,
  surprised,
  playful,
  loving,
  dizzy,
  shy,
}

enum PetActivity {
  idle,
  walking,
  running,
  jumping,
  sitting,
  sleeping,
  dancing,
  waving,
  looking,
  blinking,
  eating,
  stretching,
  falling,
  climbing,
  hiding,
  dragged,
  chasing,
  following,
  thinking,
  celebrating,
  yawning,
  scratching,
  playing,
  listening,
  talking,
}

class PetCustomization {
  final String? hat;
  final String? shirt;
  final String? glasses;
  final String? wings;
  final String? aura;
  final String? trail;
  final Color color;
  final double size;
  final double animationSpeed;
  final String name;

  const PetCustomization({
    this.hat,
    this.shirt,
    this.glasses,
    this.wings,
    this.aura,
    this.trail,
    this.color = const Color(0xFF6C63FF),
    this.size = 1.0,
    this.animationSpeed = 1.0,
    this.name = 'MAXie',
  });

  PetCustomization copyWith({
    String? hat,
    String? shirt,
    String? glasses,
    String? wings,
    String? aura,
    String? trail,
    Color? color,
    double? size,
    double? animationSpeed,
    String? name,
  }) {
    return PetCustomization(
      hat: hat ?? this.hat,
      shirt: shirt ?? this.shirt,
      glasses: glasses ?? this.glasses,
      wings: wings ?? this.wings,
      aura: aura ?? this.aura,
      trail: trail ?? this.trail,
      color: color ?? this.color,
      size: size ?? this.size,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toJson() => {
        'hat': hat,
        'shirt': shirt,
        'glasses': glasses,
        'wings': wings,
        'aura': aura,
        'trail': trail,
        'color': color.value,
        'size': size,
        'animationSpeed': animationSpeed,
        'name': name,
      };

  factory PetCustomization.fromJson(Map<String, dynamic> json) {
    return PetCustomization(
      hat: json['hat'] as String?,
      shirt: json['shirt'] as String?,
      glasses: json['glasses'] as String?,
      wings: json['wings'] as String?,
      aura: json['aura'] as String?,
      trail: json['trail'] as String?,
      color: Color(json['color'] as int? ?? 0xFF6C63FF),
      size: (json['size'] as num?)?.toDouble() ?? 1.0,
      animationSpeed: (json['animationSpeed'] as num?)?.toDouble() ?? 1.0,
      name: json['name'] as String? ?? 'MAXie',
    );
  }
}

class PetModel {
  final String id;
  final PetType type;
  final String name;
  final PetPersonality primaryPersonality;
  final List<PetPersonality> secondaryPersonalities;
  final PetCustomization customization;
  final PetEmotion currentEmotion;
  final PetActivity currentActivity;
  final Offset position;
  final Offset? targetPosition;
  final double hunger;
  final double energy;
  final double mood;
  final double fun;
  final double social;
  final double hygiene;
  final int friendshipLevel;
  final int friendshipXP;
  final bool isSleeping;
  final bool isVisible;
  final double animationFrame;
  final String? speechBubble;
  final bool isDragging;
  final bool isChasing;
  final bool isFollowing;
  final double idleTimer;

  PetModel({
    required this.id,
    required this.type,
    this.name = 'MAXie',
    this.primaryPersonality = PetPersonality.intelligent,
    this.secondaryPersonalities = const [],
    this.customization = const PetCustomization(),
    this.currentEmotion = PetEmotion.happy,
    this.currentActivity = PetActivity.idle,
    this.position = const Offset(150, 400),
    this.targetPosition,
    this.hunger = 0.8,
    this.energy = 0.8,
    this.mood = 0.8,
    this.fun = 0.7,
    this.social = 0.7,
    this.hygiene = 0.9,
    this.friendshipLevel = 1,
    this.friendshipXP = 0,
    this.isSleeping = false,
    this.isVisible = true,
    this.animationFrame = 0.0,
    this.speechBubble,
    this.isDragging = false,
    this.isChasing = false,
    this.isFollowing = false,
    this.idleTimer = 0.0,
  });

  static const Map<PetType, PetPersonality> defaultPersonalities = {
    PetType.maxie: PetPersonality.intelligent,
    PetType.cat: PetPersonality.lazy,
    PetType.dog: PetPersonality.loyal,
    PetType.panda: PetPersonality.sleepy,
    PetType.fox: PetPersonality.curious,
    PetType.rabbit: PetPersonality.playful,
    PetType.penguin: PetPersonality.funny,
    PetType.dragon: PetPersonality.brave,
    PetType.slime: PetPersonality.calm,
    PetType.robot: PetPersonality.logical,
    PetType.capybara: PetPersonality.calm,
    PetType.axolotl: PetPersonality.sassy,
  };

  PetModel copyWith({
    String? id,
    PetType? type,
    String? name,
    PetPersonality? primaryPersonality,
    List<PetPersonality>? secondaryPersonalities,
    PetCustomization? customization,
    PetEmotion? currentEmotion,
    PetActivity? currentActivity,
    Offset? position,
    Offset? targetPosition,
    double? hunger,
    double? energy,
    double? mood,
    double? fun,
    double? social,
    double? hygiene,
    int? friendshipLevel,
    int? friendshipXP,
    bool? isSleeping,
    bool? isVisible,
    double? animationFrame,
    String? speechBubble,
    bool? isDragging,
    bool? isChasing,
    bool? isFollowing,
    double? idleTimer,
    bool clearSpeechBubble = false,
  }) {
    return PetModel(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      primaryPersonality: primaryPersonality ?? this.primaryPersonality,
      secondaryPersonalities:
          secondaryPersonalities ?? this.secondaryPersonalities,
      customization: customization ?? this.customization,
      currentEmotion: currentEmotion ?? this.currentEmotion,
      currentActivity: currentActivity ?? this.currentActivity,
      position: position ?? this.position,
      targetPosition: targetPosition ?? this.targetPosition,
      hunger: hunger ?? this.hunger,
      energy: energy ?? this.energy,
      mood: mood ?? this.mood,
      fun: fun ?? this.fun,
      social: social ?? this.social,
      hygiene: hygiene ?? this.hygiene,
      friendshipLevel: friendshipLevel ?? this.friendshipLevel,
      friendshipXP: friendshipXP ?? this.friendshipXP,
      isSleeping: isSleeping ?? this.isSleeping,
      isVisible: isVisible ?? this.isVisible,
      animationFrame: animationFrame ?? this.animationFrame,
      speechBubble: clearSpeechBubble ? null : (speechBubble ?? this.speechBubble),
      isDragging: isDragging ?? this.isDragging,
      isChasing: isChasing ?? this.isChasing,
      isFollowing: isFollowing ?? this.isFollowing,
      idleTimer: idleTimer ?? this.idleTimer,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'name': name,
        'primaryPersonality': primaryPersonality.name,
        'secondaryPersonalities':
            secondaryPersonalities.map((p) => p.name).toList(),
        'customization': customization.toJson(),
        'currentEmotion': currentEmotion.name,
        'currentActivity': currentActivity.name,
        'positionX': position.dx,
        'positionY': position.dy,
        'hunger': hunger,
        'energy': energy,
        'mood': mood,
        'fun': fun,
        'social': social,
        'hygiene': hygiene,
        'friendshipLevel': friendshipLevel,
        'friendshipXP': friendshipXP,
        'isSleeping': isSleeping,
        'isVisible': isVisible,
      };

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'] ?? '',
      type: PetType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PetType.maxie,
      ),
      name: json['name'] ?? 'MAXie',
      primaryPersonality: PetPersonality.values.firstWhere(
        (e) => e.name == json['primaryPersonality'],
        orElse: () => PetPersonality.intelligent,
      ),
      secondaryPersonalities:
          (json['secondaryPersonalities'] as List<dynamic>?)
                  ?.map((e) => PetPersonality.values.firstWhere(
                        (p) => p.name == e,
                        orElse: () => PetPersonality.playful,
                      ))
                  .toList() ??
              [],
      customization: json['customization'] != null
          ? PetCustomization.fromJson(json['customization'])
          : const PetCustomization(),
      currentEmotion: PetEmotion.values.firstWhere(
        (e) => e.name == json['currentEmotion'],
        orElse: () => PetEmotion.happy,
      ),
      currentActivity: PetActivity.values.firstWhere(
        (a) => a.name == json['currentActivity'],
        orElse: () => PetActivity.idle,
      ),
      position: Offset(
        (json['positionX'] as num?)?.toDouble() ?? 150,
        (json['positionY'] as num?)?.toDouble() ?? 400,
      ),
      hunger: (json['hunger'] as num?)?.toDouble() ?? 0.8,
      energy: (json['energy'] as num?)?.toDouble() ?? 0.8,
      mood: (json['mood'] as num?)?.toDouble() ?? 0.8,
      fun: (json['fun'] as num?)?.toDouble() ?? 0.7,
      social: (json['social'] as num?)?.toDouble() ?? 0.7,
      hygiene: (json['hygiene'] as num?)?.toDouble() ?? 0.9,
      friendshipLevel: json['friendshipLevel'] ?? 1,
      friendshipXP: json['friendshipXP'] ?? 0,
      isSleeping: json['isSleeping'] ?? false,
      isVisible: json['isVisible'] ?? true,
    );
  }
}
