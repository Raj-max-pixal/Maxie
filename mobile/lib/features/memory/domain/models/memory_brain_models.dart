enum MemoryCategory {
  user,
  goals,
  dreamCompanies,
  projects,
  skills,
  interests,
  favoriteApps,
  favoriteSongs,
  favoriteMovies,
  favoriteGames,
  college,
  friends,
  family,
  birthdays,
  importantDates,
  achievements,
  habits,
  dailyRoutine,
  preferences,
  pinned,
  conversation,
}

enum MemoryPriority { low, normal, high, critical }

enum MemorySource { chat, manual, system }

class MemoryCandidate {
  const MemoryCandidate({
    required this.id,
    required this.category,
    required this.title,
    required this.value,
    required this.confidence,
    this.tags = const [],
    this.sourceConversationId,
  });

  final String id;
  final MemoryCategory category;
  final String title;
  final String value;
  final double confidence;
  final List<String> tags;
  final String? sourceConversationId;
}

class MemoryModel {
  const MemoryModel({
    required this.id,
    required this.category,
    required this.title,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
    this.priority = MemoryPriority.normal,
    this.importance = 0.5,
    this.confidence = 0.8,
    this.source = MemorySource.chat,
    this.tags = const [],
    this.sourceConversationId,
    this.lastUsedAt,
    this.isPinned = false,
    this.isFavorite = false,
    this.isArchived = false,
  });

  factory MemoryModel.fromCandidate(MemoryCandidate candidate) {
    final now = DateTime.now();
    return MemoryModel(
      id: candidate.id,
      category: candidate.category,
      title: candidate.title,
      value: candidate.value,
      createdAt: now,
      updatedAt: now,
      confidence: candidate.confidence,
      tags: candidate.tags,
      sourceConversationId: candidate.sourceConversationId,
      priority: candidate.confidence > 0.85
          ? MemoryPriority.high
          : MemoryPriority.normal,
      importance: candidate.confidence,
    );
  }

  final String id;
  final MemoryCategory category;
  final String title;
  final String value;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MemoryPriority priority;
  final double importance;
  final double confidence;
  final MemorySource source;
  final List<String> tags;
  final String? sourceConversationId;
  final DateTime? lastUsedAt;
  final bool isPinned;
  final bool isFavorite;
  final bool isArchived;

  MemoryModel copyWith({
    String? title,
    String? value,
    DateTime? updatedAt,
    DateTime? lastUsedAt,
    bool? isPinned,
    bool? isFavorite,
    bool? isArchived,
  }) {
    return MemoryModel(
      id: id,
      category: category,
      title: title ?? this.title,
      value: value ?? this.value,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      priority: priority,
      importance: importance,
      confidence: confidence,
      source: source,
      tags: tags,
      sourceConversationId: sourceConversationId,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'category': category.name,
      'title': title,
      'value': value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'priority': priority.name,
      'importance': importance,
      'confidence': confidence,
      'source': source.name,
      'tags': tags,
      'sourceConversationId': sourceConversationId,
      'lastUsedAt': lastUsedAt?.toIso8601String(),
      'isPinned': isPinned,
      'isFavorite': isFavorite,
      'isArchived': isArchived,
    };
  }

  factory MemoryModel.fromJson(Map<dynamic, dynamic> json) {
    return MemoryModel(
      id: json['id'] as String,
      category: MemoryCategory.values.byName(json['category'] as String),
      title: json['title'] as String,
      value: json['value'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      priority: MemoryPriority.values.byName(
        (json['priority'] as String?) ?? MemoryPriority.normal.name,
      ),
      importance: (json['importance'] as num?)?.toDouble() ?? 0.5,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.8,
      source: MemorySource.values.byName(
        (json['source'] as String?) ?? MemorySource.chat.name,
      ),
      tags: List<String>.from(json['tags'] as List<dynamic>? ?? []),
      sourceConversationId: json['sourceConversationId'] as String?,
      lastUsedAt: json['lastUsedAt'] == null
          ? null
          : DateTime.parse(json['lastUsedAt'] as String),
      isPinned: (json['isPinned'] as bool?) ?? false,
      isFavorite: (json['isFavorite'] as bool?) ?? false,
      isArchived: (json['isArchived'] as bool?) ?? false,
    );
  }
}

class RelationshipStats {
  const RelationshipStats({
    required this.friendshipLevel,
    required this.trustLevel,
    required this.conversationCount,
    required this.daysTogether,
    required this.messagesExchanged,
    required this.xpEarnedTogether,
    this.milestones = const [],
  });

  final int friendshipLevel;
  final int trustLevel;
  final int conversationCount;
  final int daysTogether;
  final int messagesExchanged;
  final int xpEarnedTogether;
  final List<String> milestones;
}

class MemorySummary {
  const MemorySummary({
    required this.totalMemories,
    required this.pinnedMemories,
    required this.relationshipLevel,
    this.mostImportant = const [],
    this.recent = const [],
  });

  final int totalMemories;
  final int pinnedMemories;
  final int relationshipLevel;
  final List<MemoryModel> mostImportant;
  final List<MemoryModel> recent;
}

class MemoryTimeline {
  const MemoryTimeline({required this.groups});

  final List<MemoryTimelineGroup> groups;
}

class MemoryTimelineGroup {
  const MemoryTimelineGroup({
    required this.label,
    required this.memories,
  });

  final String label;
  final List<MemoryModel> memories;
}
