import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';

abstract interface class MemoryRepository {
  Future<List<MemoryModel>> readMemories();

  Future<void> saveMemory(MemoryModel memory);

  Future<void> deleteMemory(String id);

  Future<void> clearMemories();
}

abstract interface class MemoryExtractor {
  List<MemoryCandidate> extractCandidates({
    required String text,
    String? conversationId,
  });
}

abstract interface class MemorySearch {
  List<MemoryModel> search(
    List<MemoryModel> memories, {
    required String query,
    MemoryCategory? category,
  });
}

abstract interface class MemoryRanker {
  List<MemoryModel> rank(List<MemoryModel> memories);
}

abstract interface class MemorySummarizer {
  MemorySummary summarize(List<MemoryModel> memories);
}

abstract interface class MemoryService {
  Future<List<MemoryModel>> readMemories();

  Future<void> saveMemory(MemoryModel memory);

  Future<void> deleteMemory(String id);

  Future<void> clearMemories();

  Future<List<MemoryModel>> recallMemory(String query);

  Future<List<MemoryCandidate>> extractMemoryCandidates({
    required String text,
    String? conversationId,
  });

  Future<MemorySummary> summarize();

  Future<MemoryTimeline> timeline();
}
