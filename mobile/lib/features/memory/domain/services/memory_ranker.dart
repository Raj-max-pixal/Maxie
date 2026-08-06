import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_importance.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_priority.dart';

class MemoryRanker {
  const MemoryRanker();

  List<MemoryRecord> rank(Iterable<MemoryRecord> memories) {
    final sorted = memories.toList();
    sorted.sort((left, right) => score(right).compareTo(score(left)));
    return sorted;
  }

  double score(MemoryRecord memory) {
    var total = 0.0;
    total += MemoryPriorityWeights.score(memory.priority) * 10;
    total += MemoryImportanceWeights.score(memory.importance) * 12;
    total += memory.confidence * 20;
    if (memory.isPinned) {
      total += 18;
    }
    if (memory.isFavorite) {
      total += 8;
    }
    if (memory.lastUsedAt != null) {
      final hoursAgo = DateTime.now().difference(memory.lastUsedAt!).inHours;
      total += hoursAgo < 24 ? 8 : hoursAgo < 168 ? 4 : 1;
    }
    return total;
  }
}
