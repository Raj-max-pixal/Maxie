import 'package:flutter_test/flutter_test.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_extractor.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_ranker.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_search.dart';

void main() {
  group('MemoryExtractor', () {
    test('extracts birthday memories', () {
      const extractor = MemoryExtractor();
      final suggestion = extractor.extract('My birthday is January 20.');

      expect(suggestion, isNotNull);
      expect(suggestion!.memory.category, MemoryCategory.birthdays);
      expect(suggestion.memory.title, 'Birthday');
      expect(suggestion.memory.value, 'january 20');
    });

    test('extracts project memories', () {
      const extractor = MemoryExtractor();
      final suggestion = extractor.extract("I'm building MAXie.");

      expect(suggestion, isNotNull);
      expect(suggestion!.memory.category, MemoryCategory.projects);
      expect(suggestion.memory.value, 'maxie');
    });
  });

  group('MemoryRanker', () {
    test('prefers pinned and important memories', () {
      const ranker = MemoryRanker();
      final now = DateTime.now();
      final memories = [
        MemoryRecord(
          id: 'low',
          category: MemoryCategory.interests,
          title: 'Music',
          value: 'Jazz',
          createdAt: now,
          updatedAt: now,
          priority: MemoryPriority.normal,
          importance: MemoryImportance.medium,
          confidence: 0.4,
        ),
        MemoryRecord(
          id: 'high',
          category: MemoryCategory.projects,
          title: 'MAXie',
          value: 'Building MAXie',
          createdAt: now,
          updatedAt: now,
          priority: MemoryPriority.critical,
          importance: MemoryImportance.vital,
          confidence: 0.99,
          isPinned: true,
        ),
      ];

      final ranked = ranker.rank(memories);

      expect(ranked.first.id, 'high');
    });
  });

  group('MemorySearch', () {
    test('filters by keywords and tags', () {
      const ranker = MemoryRanker();
      const search = MemorySearch(ranker);
      final now = DateTime.now();
      final memories = [
        MemoryRecord(
          id: 'flutter',
          category: MemoryCategory.interests,
          title: 'Flutter',
          value: 'I love Flutter',
          tags: const ['flutter', 'mobile'],
          createdAt: now,
          updatedAt: now,
          priority: MemoryPriority.high,
          importance: MemoryImportance.high,
          confidence: 0.95,
        ),
        MemoryRecord(
          id: 'music',
          category: MemoryCategory.favoriteSongs,
          title: 'Song',
          value: 'Ambient',
          tags: const ['music'],
          createdAt: now,
          updatedAt: now,
          priority: MemoryPriority.normal,
          importance: MemoryImportance.medium,
          confidence: 0.5,
        ),
      ];

      final results = search.search(
        memories,
        const MemorySearchQuery(query: 'flutter'),
      );

      expect(results.map((memory) => memory.id), contains('flutter'));
      expect(results.map((memory) => memory.id), isNot(contains('music')));
    });
  });
}