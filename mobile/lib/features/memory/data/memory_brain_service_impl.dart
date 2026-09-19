import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_service.dart';

class MemoryBrainServiceImpl implements MemoryService {
  const MemoryBrainServiceImpl({
    required this._repository,
    required this._extractor,
    required this._search,
    required this._ranker,
    required this._summarizer,
  });

  final MemoryRepository _repository;
  final MemoryExtractor _extractor;
  final MemorySearch _search;
  final MemoryRanker _ranker;
  final MemorySummarizer _summarizer;

  @override
  Future<void> clearMemories() => _repository.clearMemories();

  @override
  Future<void> deleteMemory(String id) => _repository.deleteMemory(id);

  @override
  Future<List<MemoryCandidate>> extractMemoryCandidates({
    required String text,
    String? conversationId,
  }) async {
    return _extractor.extractCandidates(
      text: text,
      conversationId: conversationId,
    );
  }

  @override
  Future<List<MemoryModel>> readMemories() => _repository.readMemories();

  @override
  Future<List<MemoryModel>> recallMemory(String query) async {
    try {
      final memories = await _repository.readMemories();
      return _ranker.rank(_search.search(memories, query: query));
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveMemory(MemoryModel memory) async {
    final existing = await _repository.readMemories();
    final normalized = _normalize(memory.value);
    final duplicate = existing.where((item) {
      if (!item.isActive || item.category != memory.category) return false;
      final other = _normalize(item.value);
      return other == normalized ||
          other.contains(normalized) ||
          normalized.contains(other);
    }).firstOrNull;

    if (duplicate == null) {
      await _repository.saveMemory(memory);
      return;
    }

    await _repository.saveMemory(
      duplicate.copyWith(
        title: memory.title,
        value: memory.value,
        updatedAt: DateTime.now(),
        confidence: memory.confidence > duplicate.confidence
            ? memory.confidence
            : duplicate.confidence,
        importance: memory.importance > duplicate.importance
            ? memory.importance
            : duplicate.importance,
        priority: memory.priority.weight > duplicate.priority.weight
            ? memory.priority
            : duplicate.priority,
        lastUsedAt: DateTime.now(),
        usageCount: duplicate.usageCount + 1,
      ),
    );
  }

  String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  @override
  Future<void> updateMemory(MemoryModel memory) =>
      _repository.saveMemory(memory.copyWith(updatedAt: DateTime.now()));

  @override
  Future<void> pinMemory(String id, {required bool pinned}) async {
    final memory = await _repository.getMemory(id);
    if (memory != null) {
      await _repository.saveMemory(
        memory.copyWith(isPinned: pinned, updatedAt: DateTime.now()),
      );
    }
  }

  @override
  Future<void> forgetMemory(String id) async {
    final memory = await _repository.getMemory(id);
    if (memory != null) {
      await _repository.saveMemory(
        memory.copyWith(
          isActive: false,
          isArchived: true,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<MemorySummary> summarize() async {
    return _summarizer.summarize(await _repository.readMemories());
  }

  @override
  Future<MemoryTimeline> timeline() async {
    final memories = _ranker.rank(await _repository.readMemories());
    final today = DateTime.now();
    final recent = memories.where((memory) {
      return today.difference(memory.createdAt).inDays == 0;
    }).toList();
    final earlier = memories.where((memory) {
      return today.difference(memory.createdAt).inDays > 0;
    }).toList();
    return MemoryTimeline(
      groups: [
        MemoryTimelineGroup(label: 'Today', memories: recent),
        MemoryTimelineGroup(label: 'Earlier', memories: earlier),
      ],
    );
  }
}

class PatternMemoryExtractor implements MemoryExtractor {
  const PatternMemoryExtractor();

  @override
  List<MemoryCandidate> extractCandidates({
    required String text,
    String? conversationId,
  }) {
    final normalized = text.trim();
    if (normalized.length < 6) {
      return const [];
    }
    if (RegExp(
      r'^(hi|hello|hey|thanks|thank you|okay|cool|i understand)[.! ]*$',
      caseSensitive: false,
    ).hasMatch(normalized)) {
      return const [];
    }

    final candidates = <MemoryCandidate>[];
    void add(
      MemoryCategory category,
      String title,
      String value,
      double confidence,
      MemoryPriority priority,
      double importance,
    ) {
      candidates.add(
        MemoryCandidate(
          id: 'memory-${DateTime.now().microsecondsSinceEpoch}-${candidates.length}',
          category: category,
          title: title,
          value: value,
          confidence: confidence,
          priority: priority,
          importance: importance,
          tags: [category.name],
          sourceConversationId: conversationId,
        ),
      );
    }

    final name = RegExp(
      r'\bmy name is\s+([A-Za-z][A-Za-z -]+)',
      caseSensitive: false,
    ).firstMatch(normalized);
    if (name != null) {
      add(
        MemoryCategory.userProfile,
        'Name',
        name.group(1)!.trim(),
        1,
        MemoryPriority.critical,
        1,
      );
    }

    final event = RegExp(
      r'\b(?:i have|my)\s+(a\s+)?(hackathon|exam|interview|deadline)\s+([^.!?]+)',
      caseSensitive: false,
    ).firstMatch(normalized);
    if (event != null) {
      add(
        MemoryCategory.importantDates,
        'Important event',
        'Upcoming ${event.group(2)} ${event.group(3)!.trim()}',
        0.94,
        MemoryPriority.high,
        0.9,
      );
    }

    final dislike = RegExp(
      r"\b(?:i don't like|i do not like|i dislike)\s+([^.!?]+)",
      caseSensitive: false,
    ).firstMatch(normalized);
    if (dislike != null) {
      add(
        MemoryCategory.preferences,
        'Preference',
        'Does not like ${dislike.group(1)!.trim()}',
        0.92,
        MemoryPriority.normal,
        0.6,
      );
    }

    final birthday = RegExp(
      r'\b(?:my birthday is|birthday is)\s+([^.!?]+)',
      caseSensitive: false,
    ).firstMatch(normalized);
    if (birthday != null) {
      add(
        MemoryCategory.birthdays,
        'Birthday',
        birthday.group(1)!.trim(),
        0.94,
        MemoryPriority.critical,
        1,
      );
    }

    final love = RegExp(
      r'\b(?:i love|i like|favorite|favourite)\s+([^.!?]+)',
      caseSensitive: false,
    ).firstMatch(normalized);
    if (love != null) {
      add(
        MemoryCategory.interests,
        'Interest',
        love.group(1)!.trim(),
        0.82,
        MemoryPriority.normal,
        0.55,
      );
    }

    final dreamCompany = RegExp(
      r'\b(?:work at|join|dream company is)\s+([A-Z][A-Za-z0-9 ]+)',
    ).firstMatch(normalized);
    if (dreamCompany != null) {
      add(
        MemoryCategory.dreamCompanies,
        'Dream Company',
        dreamCompany.group(1)!.trim(),
        0.88,
        MemoryPriority.high,
        0.85,
      );
    }

    final project = RegExp(
      r'\b(?:building|working on|current project is)\s+([^.!?]+)',
      caseSensitive: false,
    ).firstMatch(normalized);
    if (project != null) {
      add(
        MemoryCategory.projects,
        'Project',
        project.group(1)!.trim(),
        0.86,
        MemoryPriority.high,
        0.85,
      );
    }

    return candidates;
  }
}

class KeywordMemorySearch implements MemorySearch {
  const KeywordMemorySearch();

  @override
  List<MemoryModel> search(
    List<MemoryModel> memories, {
    required String query,
    MemoryCategory? category,
  }) {
    final normalized = query.toLowerCase().trim();
    return memories.where((memory) {
      final categoryMatches = category == null || memory.category == category;
      final queryMatches =
          normalized.isEmpty ||
          memory.title.toLowerCase().contains(normalized) ||
          memory.value.toLowerCase().contains(normalized) ||
          memory.tags.any((tag) => tag.toLowerCase().contains(normalized));
      return categoryMatches && queryMatches && !memory.isArchived;
    }).toList();
  }
}

class ImportanceMemoryRanker implements MemoryRanker {
  const ImportanceMemoryRanker();

  @override
  List<MemoryModel> rank(List<MemoryModel> memories) {
    return [...memories]..sort((a, b) {
      final pinned = (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0);
      if (pinned != 0) {
        return pinned;
      }
      return b.importance.compareTo(a.importance);
    });
  }
}

class LocalMemorySummarizer implements MemorySummarizer {
  const LocalMemorySummarizer();

  @override
  MemorySummary summarize(List<MemoryModel> memories) {
    final active = memories.where((memory) => !memory.isArchived).toList();
    final important = const ImportanceMemoryRanker()
        .rank(active)
        .take(5)
        .toList();
    final recent = [...active]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return MemorySummary(
      totalMemories: active.length,
      pinnedMemories: active.where((memory) => memory.isPinned).length,
      relationshipLevel: 12,
      mostImportant: important,
      recent: recent.take(5).toList(),
    );
  }
}
