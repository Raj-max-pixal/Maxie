enum MemoryCategory {
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

enum MemoryImportance { low, medium, high, vital }

enum MemorySource { user, assistant, system, manual, import }

class MemoryRecord {
  const MemoryRecord({
    required this.id,
    required this.category,
    required this.title,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
    required this.priority,
    required this.importance,
    required this.confidence,
    this.tags = const [],
    this.source = MemorySource.user,
    this.lastUsedAt,
    this.usageCount = 0,
    this.conversationId,
    this.messageId,
    this.isPinned = false,
    this.isFavorite = false,
    this.isArchived = false,
    this.notes,
    this.metadata = const {},
  });

  final String id;
  final MemoryCategory category;
  final String title;
  final String value;
  final List<String> tags;
  final MemoryPriority priority;
  final MemoryImportance importance;
  final double confidence;
  final MemorySource source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastUsedAt;
  final int usageCount;
  final String? conversationId;
  final String? messageId;
  final bool isPinned;
  final bool isFavorite;
  final bool isArchived;
  final String? notes;
  final Map<String, Object?> metadata;

  String get searchableText =>
      [title, value, notes, ...tags].whereType<String>().join(' ').toLowerCase();

  MemoryRecord copyWith({
    String? title,
    String? value,
    List<String>? tags,
    MemoryCategory? category,
    MemoryPriority? priority,
    MemoryImportance? importance,
    double? confidence,
    MemorySource? source,
    DateTime? updatedAt,
    DateTime? lastUsedAt,
    int? usageCount,
    String? conversationId,
    String? messageId,
    bool? isPinned,
    bool? isFavorite,
    bool? isArchived,
    String? notes,
    Map<String, Object?>? metadata,
  }) {
    return MemoryRecord(
      id: id,
      category: category ?? this.category,
      title: title ?? this.title,
      value: value ?? this.value,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      importance: importance ?? this.importance,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      usageCount: usageCount ?? this.usageCount,
      conversationId: conversationId ?? this.conversationId,
      messageId: messageId ?? this.messageId,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'category': category.name,
      'title': title,
      'value': value,
      'tags': tags,
      'priority': priority.name,
      'importance': importance.name,
      'confidence': confidence,
      'source': source.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
      'usageCount': usageCount,
      'conversationId': conversationId,
      'messageId': messageId,
      'isPinned': isPinned,
      'isFavorite': isFavorite,
      'isArchived': isArchived,
      'notes': notes,
      'metadata': metadata,
    };
  }

  factory MemoryRecord.fromJson(Map<dynamic, dynamic> json) {
    return MemoryRecord(
      id: json['id'] as String,
      category: MemoryCategory.values.byName(json['category'] as String),
      title: json['title'] as String,
      value: json['value'] as String,
      tags: [
        for (final tag in (json['tags'] as List<dynamic>? ?? const []))
          tag.toString(),
      ],
      priority: MemoryPriority.values.byName(
        (json['priority'] as String?) ?? MemoryPriority.normal.name,
      ),
      importance: MemoryImportance.values.byName(
        (json['importance'] as String?) ?? MemoryImportance.medium.name,
      ),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      source: MemorySource.values.byName(
        (json['source'] as String?) ?? MemorySource.user.name,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastUsedAt: json['lastUsedAt'] == null
          ? null
          : DateTime.parse(json['lastUsedAt'] as String),
      usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
      conversationId: json['conversationId'] as String?,
      messageId: json['messageId'] as String?,
      isPinned: (json['isPinned'] as bool?) ?? false,
      isFavorite: (json['isFavorite'] as bool?) ?? false,
      isArchived: (json['isArchived'] as bool?) ?? false,
      notes: json['notes'] as String?,
      metadata: Map<String, Object?>.from(
        (json['metadata'] as Map<dynamic, dynamic>? ?? const {}),
      ),
    );
  }
}

class MemoryCandidate {
  const MemoryCandidate({
    required this.memory,
    required this.reason,
    required this.detectedAt,
  });

  final MemoryRecord memory;
  final String reason;
  final DateTime detectedAt;
}

class MemorySummary {
  const MemorySummary({
    required this.totalMemories,
    required this.pinnedMemories,
    required this.relationshipLevel,
    required this.topCategories,
    required this.recentCount,
    required this.mostImportantCount,
  });

  final int totalMemories;
  final int pinnedMemories;
  final int relationshipLevel;
  final Map<MemoryCategory, int> topCategories;
  final int recentCount;
  final int mostImportantCount;
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

class MemoryTimeline {
  const MemoryTimeline({required this.entries});

  final List<MemoryTimelineEntry> entries;
}

class MemoryRelationshipState {
  const MemoryRelationshipState({
    required this.friendshipLevel,
    required this.trustLevel,
    required this.conversationCount,
    required this.daysTogether,
    required this.messagesExchanged,
    required this.xpEarnedTogether,
    required this.milestones,
  });

  final int friendshipLevel;
  final int trustLevel;
  final int conversationCount;
  final int daysTogether;
  final int messagesExchanged;
  final int xpEarnedTogether;
  final List<String> milestones;
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
    this.minPriority,
    this.minImportance,
    this.createdAfter,
    this.createdBefore,
    this.pinnedOnly = false,
    this.favoriteOnly = false,
    this.archivedOnly = false,
    this.semanticHint,
  });

  final String query;
  final List<MemoryCategory> categories;
  final List<String> tags;
  final MemoryPriority? minPriority;
  final MemoryImportance? minImportance;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final bool pinnedOnly;
  final bool favoriteOnly;
  final bool archivedOnly;
  final String? semanticHint;
}

extension MemoryPriorityX on MemoryPriority {
  int get weight => switch (this) {
        MemoryPriority.low => 1,
        MemoryPriority.normal => 2,
        MemoryPriority.high => 3,
        MemoryPriority.critical => 4,
      };

  String get label => switch (this) {
        MemoryPriority.low => 'Low',
        MemoryPriority.normal => 'Normal',
        MemoryPriority.high => 'High',
        MemoryPriority.critical => 'Critical',
      };
}

extension MemoryImportanceX on MemoryImportance {
  int get weight => switch (this) {
        MemoryImportance.low => 1,
        MemoryImportance.medium => 2,
        MemoryImportance.high => 3,
        MemoryImportance.vital => 4,
      };

  String get label => switch (this) {
        MemoryImportance.low => 'Low',
        MemoryImportance.medium => 'Medium',
        MemoryImportance.high => 'High',
        MemoryImportance.vital => 'Vital',
      };
}

