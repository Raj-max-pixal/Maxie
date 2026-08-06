import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';

class MemoryTimelineBuilder {
  const MemoryTimelineBuilder();

  MemoryTimeline build(Iterable<MemoryRecord> memories) {
    final entries = memories.map((memory) {
      return MemoryTimelineEntry(
        date: memory.createdAt,
        title: memory.title,
        subtitle: memory.value,
        category: memory.category,
        priority: memory.priority,
        importance: memory.importance,
        tags: memory.tags,
        memoryId: memory.id,
      );
    }).toList()
      ..sort((left, right) => right.date.compareTo(left.date));

    return MemoryTimeline(entries: entries);
  }
}
