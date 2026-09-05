import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/memory/data/hive_memory_brain_repository.dart';
import 'package:maxie_mobile/features/memory/data/memory_brain_service_impl.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_service.dart';
import 'package:maxie_mobile/services/storage/storage_providers.dart';

class MemoryManagerState {
  const MemoryManagerState({required this.memories, required this.summary});

  final List<MemoryModel> memories;
  final MemorySummary summary;
}

final memoryBrainRepositoryProvider = Provider<MemoryRepository>(
  (ref) => HiveMemoryBrainRepository(ref.watch(storageServiceProvider)),
);

final memoryExtractorProvider = Provider<MemoryExtractor>(
  (ref) => const PatternMemoryExtractor(),
);

final memorySearchProvider = Provider<MemorySearch>(
  (ref) => const KeywordMemorySearch(),
);

final memoryRankerProvider = Provider<MemoryRanker>(
  (ref) => const ImportanceMemoryRanker(),
);

final memorySummarizerProvider = Provider<MemorySummarizer>(
  (ref) => const LocalMemorySummarizer(),
);

final memoryBrainServiceProvider = Provider<MemoryService>(
  (ref) => MemoryBrainServiceImpl(
    repository: ref.watch(memoryBrainRepositoryProvider),
    extractor: ref.watch(memoryExtractorProvider),
    search: ref.watch(memorySearchProvider),
    ranker: ref.watch(memoryRankerProvider),
    summarizer: ref.watch(memorySummarizerProvider),
  ),
);

final memoryBrainListProvider = FutureProvider<List<MemoryModel>>(
  (ref) => ref.watch(memoryBrainServiceProvider).readMemories(),
);

final memoryBrainSummaryProvider = FutureProvider<MemorySummary>(
  (ref) => ref.watch(memoryBrainServiceProvider).summarize(),
);

final memoryBrainTimelineProvider = FutureProvider<MemoryTimeline>(
  (ref) => ref.watch(memoryBrainServiceProvider).timeline(),
);

final memoryManagerProvider = Provider<MemoryManagerState>((ref) {
  final memories =
      ref.watch(memoryBrainListProvider).valueOrNull ?? const <MemoryModel>[];
  final summary = ref.watch(memoryBrainSummaryProvider).valueOrNull ??
      MemorySummary(
        totalMemories: memories.length,
        pinnedMemories: memories.where((memory) => memory.isPinned).length,
        relationshipLevel: 12,
      );
  return MemoryManagerState(memories: memories, summary: summary);
});

final relationshipStatsProvider = Provider<RelationshipStats>(
  (ref) => const RelationshipStats(
    friendshipLevel: 12,
    trustLevel: 84,
    conversationCount: 42,
    daysTogether: 18,
    messagesExchanged: 318,
    xpEarnedTogether: 2840,
    milestones: ['First Project', 'AI Chat Built', 'Memory Brain Started'],
  ),
);
