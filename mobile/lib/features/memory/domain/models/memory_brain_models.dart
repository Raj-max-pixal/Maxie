enum MemoryCategory {
  user,
  userProfile,
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

extension MemoryPriorityScore on MemoryPriority {
  int get weight {
    switch (this) {
      case MemoryPriority.low:
        return 1;
      case MemoryPriority.normal:
        return 2;
      case MemoryPriority.high:
        return 3;
      case MemoryPriority.critical:
        return 4;
    }
  }
}

enum MemoryImportance { low, medium, high, vital }

extension MemoryImportanceScore on MemoryImportance {
  int get weight {
    switch (this) {
      case MemoryImportance.low:
        return 1;
      case MemoryImportance.medium:
        return 2;
      case MemoryImportance.high:
        return 3;
      case MemoryImportance.vital:
        return 4;
    }
  }
}

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

class MemoryRecord {
  const MemoryRecord({
    required this.id,
    required this.category,
    required this.title,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
    this.priority = MemoryPriority.normal,
    this.importance = MemoryImportance.medium,
    this.confidence = 0.8,
    this.source = MemorySource.chat,
    this.tags = const [],
    this.conversationId,
    this.messageId,
    this.metadata = const {},
    this.lastUsedAt,
    this.isPinned = false,
    this.isFavorite = false,
    this.isArchived = false,
  });

  final String id;
  final MemoryCategory category;
  final String title;
  final String value;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MemoryPriority priority;
  final MemoryImportance importance;
  final double confidence;
  final MemorySource source;
  final List<String> tags;
  final String? conversationId;
  final String? messageId;
  final Map<String, Object?> metadata;
  final DateTime? lastUsedAt;
  final bool isPinned;
  final bool isFavorite;
  final bool isArchived;

  String get searchableText =>
      [title, value, category.name, ...tags].join(' ').toLowerCase();

  MemoryRecord copyWith({
    String? title,
    String? value,
    DateTime? updatedAt,
    DateTime? lastUsedAt,
    String? conversationId,
    String? messageId,
    bool? isPinned,
    bool? isFavorite,
    bool? isArchived,
  }) {
    return MemoryRecord(
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
      conversationId: conversationId ?? this.conversationId,
      messageId: messageId ?? this.messageId,
      metadata: metadata,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

class MemorySuggestion {
  const MemorySuggestion({
    required this.memory,
    required this.reason,
    required this.confidence,
    required this.capturedAt,
  });

  final MemoryRecord memory;
  final String reason;
  final double confidence;
  final DateTime capturedAt;
}

class MemorySearchQuery {
  const MemorySearchQuery({
    this.query = '',
    this.categories = const [],
    this.tags = const [],
    this.pinnedOnly = false,
    this.favoriteOnly = false,
    this.archivedOnly = false,
    this.minPriority,
    this.minImportance,
    this.createdAfter,
    this.createdBefore,
    this.semanticHint,
  });

  final String query;
  final List<MemoryCategory> categories;
  final List<String> tags;
  final bool pinnedOnly;
  final bool favoriteOnly;
  final bool archivedOnly;
  final MemoryPriority? minPriority;
  final MemoryImportance? minImportance;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final String? semanticHint;
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
    this.topCategories = const {},
    this.recentCount = 0,
    this.mostImportantCount = 0,
  });

  final int totalMemories;
  final int pinnedMemories;
  final int relationshipLevel;
  final List<MemoryModel> mostImportant;
  final List<MemoryModel> recent;
  final Map<MemoryCategory, int> topCategories;
  final int recentCount;
  final int mostImportantCount;
}

class MemoryTimeline {
  const MemoryTimeline({
    this.groups = const [],
    this.entries = const [],
  });

  final List<MemoryTimelineGroup> groups;
  final List<MemoryTimelineEntry> entries;
}

class MemoryTimelineEntry {
  const MemoryTimelineEntry({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.priority,
    required this.importance,
    required this.tags,
    required this.memoryId,
  });

  final DateTime date;
  final String title;
  final String subtitle;
  final MemoryCategory category;
  final MemoryPriority priority;
  final MemoryImportance importance;
  final List<String> tags;
  final String memoryId;
}

class MemoryTimelineGroup {
  const MemoryTimelineGroup({required this.label, required this.memories});

  final String label;
  final List<MemoryModel> memories;
}

class MemoryRelationshipState {
  const MemoryRelationshipState({
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
