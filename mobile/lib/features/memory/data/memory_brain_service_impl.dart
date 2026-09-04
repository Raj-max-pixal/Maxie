import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_service.dart';

class MemoryBrainServiceImpl implements MemoryService {
  const MemoryBrainServiceImpl({
    required MemoryRepository repository,
    required MemoryExtractor extractor,
    required MemorySearch search,
    required MemoryRanker ranker,
    required MemorySummarizer summarizer,
  }) : _repository = repository,
       _extractor = extractor,
       _search = search,
       _ranker = ranker,
       _summarizer = summarizer;

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
    final memories = await _repository.readMemories();
    return _ranker.rank(_search.search(memories, query: query));
  }

  @override
  Future<void> saveMemory(MemoryModel memory) => _repository.saveMemory(memory);

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

    final candidates = <MemoryCandidate>[];
    void add(
      MemoryCategory category,
      String title,
      String value,
      double confidence,
    ) {
      candidates.add(
        MemoryCandidate(
          id: 'memory-${DateTime.now().microsecondsSinceEpoch}-${candidates.length}',
          category: category,
          title: title,
          value: value,
          confidence: confidence,
          tags: [category.name],
          sourceConversationId: conversationId,
        ),
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
      );
    }

    final love = RegExp(
      r'\b(?:i love|i like|favorite|favourite)\s+([^.!?]+)',
      caseSensitive: false,
    ).firstMatch(normalized);
    if (love != null) {
      add(MemoryCategory.interests, 'Interest', love.group(1)!.trim(), 0.82);
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
      );
    }

    final project = RegExp(
      r'\b(?:building|working on|current project is)\s+([^.!?]+)',
      caseSensitive: false,
    ).firstMatch(normalized);
    if (project != null) {
      add(MemoryCategory.projects, 'Project', project.group(1)!.trim(), 0.86);
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
