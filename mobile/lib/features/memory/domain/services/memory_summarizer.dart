import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';

class MemorySummarizer {
  const MemorySummarizer();

  MemorySummary summarize(
    Iterable<MemoryRecord> memories, {
    required MemoryRelationshipState relationship,
  }) {
    final items = memories.toList();
    final counts = <MemoryCategory, int>{};
    for (final memory in items) {
      counts[memory.category] = (counts[memory.category] ?? 0) + 1;
    }
    final recentCount = items.where((memory) {
      return DateTime.now().difference(memory.updatedAt).inDays <= 7;
    }).length;
    final mostImportantCount = items.where((memory) {
      return memory.priority == MemoryPriority.high ||
          memory.priority == MemoryPriority.critical ||
          memory.importance == MemoryImportance.high ||
          memory.importance == MemoryImportance.vital;
    }).length;

    return MemorySummary(
      totalMemories: items.length,
      pinnedMemories: items.where((memory) => memory.isPinned).length,
      relationshipLevel: relationship.friendshipLevel,
      topCategories: counts,
      recentCount: recentCount,
      mostImportantCount: mostImportantCount,
    );
  }
}
