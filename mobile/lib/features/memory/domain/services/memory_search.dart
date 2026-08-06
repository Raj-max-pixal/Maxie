import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_tags.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_ranker.dart';

class MemorySearch {
  const MemorySearch(this._ranker);

  final MemoryRanker _ranker;

  List<MemoryRecord> search(
    Iterable<MemoryRecord> memories,
    MemorySearchQuery query,
  ) {
    final normalized = query.query.trim().toLowerCase();
    final results = memories.where((memory) {
      if (query.categories.isNotEmpty &&
          !query.categories.contains(memory.category)) {
        return false;
      }
      if (query.pinnedOnly && !memory.isPinned) {
        return false;
      }
      if (query.favoriteOnly && !memory.isFavorite) {
        return false;
      }
      if (query.archivedOnly && !memory.isArchived) {
        return false;
      }
      if (query.minPriority != null &&
          memory.priority.weight < query.minPriority!.weight) {
        return false;
      }
      if (query.minImportance != null &&
          memory.importance.weight < query.minImportance!.weight) {
        return false;
      }
      if (query.createdAfter != null &&
          memory.createdAt.isBefore(query.createdAfter!)) {
        return false;
      }
      if (query.createdBefore != null &&
          memory.createdAt.isAfter(query.createdBefore!)) {
        return false;
      }
      if (query.tags.isNotEmpty &&
          !MemoryTags.containsAny(memory.tags, query.tags)) {
        return false;
      }
      if (normalized.isEmpty) {
        return true;
      }
      final searchable = memory.searchableText;
      return searchable.contains(normalized) ||
          query.semanticHint?.toLowerCase().split(' ').any(searchable.contains) ==
              true;
    }).toList();

    return _ranker.rank(results);
  }
}
