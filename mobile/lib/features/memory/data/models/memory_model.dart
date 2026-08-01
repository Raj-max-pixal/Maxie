import 'package:flutter/foundation.dart';

enum MemoryType {
  conversation,
  userPreference,
  userGoal,
  habit,
  task,
  productivity,
  emotion,
  fact,
  reminder,
  custom,
}

class MemoryModel {
  final String id;
  final MemoryType type;
  final String content;
  final DateTime timestamp;
  final List<String> tags;
  final double importance;
  final int accessCount;
  final DateTime? lastAccessed;
  final Map<String, dynamic>? metadata;
  final bool isFavorite;

  const MemoryModel({
    required this.id,
    required this.type,
    required this.content,
    required this.timestamp,
    this.tags = const [],
    this.importance = 0.5,
    this.accessCount = 0,
    this.lastAccessed,
    this.metadata,
    this.isFavorite = false,
  });

  MemoryModel copyWith({
    String? id,
    MemoryType? type,
    String? content,
    DateTime? timestamp,
    List<String>? tags,
    double? importance,
    int? accessCount,
    DateTime? lastAccessed,
    Map<String, dynamic>? metadata,
    bool? isFavorite,
  }) {
    return MemoryModel(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      tags: tags ?? this.tags,
      importance: importance ?? this.importance,
      accessCount: accessCount ?? this.accessCount,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      metadata: metadata ?? this.metadata,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'content': content,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'tags': tags,
        'importance': importance,
        'accessCount': accessCount,
        'lastAccessed': lastAccessed?.millisecondsSinceEpoch,
        'metadata': metadata,
        'isFavorite': isFavorite,
      };

  factory MemoryModel.fromJson(Map<String, dynamic> json) {
    return MemoryModel(
      id: json['id'] as String? ?? '',
      type: MemoryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MemoryType.custom,
      ),
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
          : DateTime.now(),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      importance: (json['importance'] as num?)?.toDouble() ?? 0.5,
      accessCount: json['accessCount'] as int? ?? 0,
      lastAccessed: json['lastAccessed'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastAccessed'] as int)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'MemoryModel(type: ${type.name}, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content})';
  }
}