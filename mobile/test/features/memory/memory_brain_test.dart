import 'package:flutter_test/flutter_test.dart';
import 'package:maxie_mobile/features/memory/data/memory_brain_service_impl.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';

void main() {
  const extractor = PatternMemoryExtractor();

  test('ignores trivial conversation', () {
    expect(extractor.extractCandidates(text: 'Hi MAXie'), isEmpty);
    expect(extractor.extractCandidates(text: 'Thanks!'), isEmpty);
  });

  test('extracts classified project, event, and preference memories', () {
    final project = extractor.extractCandidates(
      text: "I'm building MAXie for a hackathon.",
    );
    final event = extractor.extractCandidates(
      text: 'I have a hackathon tomorrow.',
    );
    final preference = extractor.extractCandidates(
      text: "I don't like coffee.",
    );

    expect(project.single.category, MemoryCategory.projects);
    expect(project.single.priority, MemoryPriority.high);
    expect(event.single.category, MemoryCategory.importantDates);
    expect(event.single.priority, MemoryPriority.high);
    expect(preference.single.category, MemoryCategory.preferences);
    expect(preference.single.value, contains('coffee'));
  });

  test('memory model preserves active, user, and usage fields', () {
    final memory = MemoryModel(
      id: 'memory-1',
      userId: 'user-1',
      category: MemoryCategory.projects,
      title: 'Project',
      value: 'Raj is building MAXie.',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      usageCount: 2,
    );

    final restored = MemoryModel.fromJson(memory.toJson());
    expect(restored.userId, 'user-1');
    expect(restored.isActive, isTrue);
    expect(restored.usageCount, 2);
  });
}
