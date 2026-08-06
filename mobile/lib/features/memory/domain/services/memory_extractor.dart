import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_tags.dart';

class MemoryExtractor {
  const MemoryExtractor();

  MemorySuggestion? extract(String text, {String? conversationId}) {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final lower = normalized.toLowerCase();
    final pattern = _matchPattern(lower);
    if (pattern == null) {
      return null;
    }

    final memory = MemoryRecord(
      id: 'memory-${DateTime.now().microsecondsSinceEpoch}',
      category: pattern.category,
      title: pattern.title,
      value: pattern.value,
      tags: MemoryTags.merge([
        ...pattern.tags,
        ...MemoryTags.fromText(pattern.value),
      ]),
      priority: pattern.priority,
      importance: pattern.importance,
      confidence: pattern.confidence,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      conversationId: conversationId,
      metadata: const {'origin': 'auto-suggestion'},
    );

    return MemorySuggestion(
      memory: memory,
      reason: pattern.reason,
      confidence: pattern.confidence,
      capturedAt: DateTime.now(),
    );
  }

  _MemoryPattern? _matchPattern(String text) {
    final patterns = <_MemoryPattern>[
      _MemoryPattern(
        regex: RegExp(r'\bmy birthday is\s+([^.!,?]+)'),
        category: MemoryCategory.birthdays,
        titleBuilder: (match) => 'Birthday',
        valueBuilder: (match) => match.group(1)!.trim(),
        reason: 'This looks like a birthday.',
        priority: MemoryPriority.critical,
        importance: MemoryImportance.vital,
        confidence: 0.98,
        tags: const ['birthday', 'personal'],
      ),
      _MemoryPattern(
        regex: RegExp(r'\b(i love|i like|i enjoy)\s+([^.!,?]+)'),
        category: MemoryCategory.interests,
        titleBuilder: (match) => match.group(2)!.trim(),
        valueBuilder: (match) => match.group(2)!.trim(),
        reason: 'This sounds like a personal interest.',
        priority: MemoryPriority.high,
        importance: MemoryImportance.high,
        confidence: 0.92,
        tags: const ['interest', 'preference'],
      ),
      _MemoryPattern(
        regex: RegExp(
          r'\b(i want to work at|my dream company is|i want to join)\s+([^.!,?]+)',
        ),
        category: MemoryCategory.dreamCompanies,
        titleBuilder: (match) => 'Dream Company',
        valueBuilder: (match) => match.group(2)!.trim(),
        reason: 'This is a career goal worth remembering.',
        priority: MemoryPriority.critical,
        importance: MemoryImportance.vital,
        confidence: 0.95,
        tags: const ['career', 'goal'],
      ),
      _MemoryPattern(
        regex: RegExp(
          r"\b(i am building|i'm building|we are building)\s+([^.!,?]+)",
        ),
        category: MemoryCategory.projects,
        titleBuilder: (match) => match.group(2)!.trim(),
        valueBuilder: (match) => match.group(2)!.trim(),
        reason: 'This sounds like an active project.',
        priority: MemoryPriority.critical,
        importance: MemoryImportance.vital,
        confidence: 0.96,
        tags: const ['project', 'building'],
      ),
      _MemoryPattern(
        regex: RegExp(r'\b(my favorite (app|song|movie|game) is)\s+([^.!,?]+)'),
        category: MemoryCategory.preferences,
        titleBuilder: (match) => match.group(2)!.toLowerCase(),
        valueBuilder: (match) => match.group(3)!.trim(),
        reason: 'This is a favorite worth remembering.',
        priority: MemoryPriority.high,
        importance: MemoryImportance.high,
        confidence: 0.9,
        tags: const ['favorite', 'preference'],
      ),
      _MemoryPattern(
        regex: RegExp(r'\b(i study at|i go to|i attend)\s+([^.!,?]+)'),
        category: MemoryCategory.college,
        titleBuilder: (match) => 'College',
        valueBuilder: (match) => match.group(2)!.trim(),
        reason: 'This is educational context.',
        priority: MemoryPriority.high,
        importance: MemoryImportance.high,
        confidence: 0.89,
        tags: const ['college', 'education'],
      ),
      _MemoryPattern(
        regex: RegExp(
          r'\b(my friend|my brother|my sister|my mom|my dad|my family)\s+([^.!,?]+)',
        ),
        category: MemoryCategory.family,
        titleBuilder: (match) => match.group(1)!.replaceFirst('my ', '').trim(),
        valueBuilder: (match) => match.group(2)!.trim(),
        reason: 'This is a relationship detail.',
        priority: MemoryPriority.normal,
        importance: MemoryImportance.medium,
        confidence: 0.8,
        tags: const ['family', 'relationship'],
      ),
      _MemoryPattern(
        regex: RegExp(
          r'\b(i usually|my daily routine|every day i)\s+([^.!,?]+)',
        ),
        category: MemoryCategory.dailyRoutine,
        titleBuilder: (match) => 'Daily routine',
        valueBuilder: (match) => match.group(2)!.trim(),
        reason: 'This describes a routine.',
        priority: MemoryPriority.high,
        importance: MemoryImportance.high,
        confidence: 0.84,
        tags: const ['routine', 'habit'],
      ),
      _MemoryPattern(
        regex: RegExp(r'\b(i achieved|i finished|i completed)\s+([^.!,?]+)'),
        category: MemoryCategory.achievements,
        titleBuilder: (match) => 'Achievement',
        valueBuilder: (match) => match.group(2)!.trim(),
        reason: 'This is an accomplishment.',
        priority: MemoryPriority.high,
        importance: MemoryImportance.high,
        confidence: 0.86,
        tags: const ['achievement', 'milestone'],
      ),
      _MemoryPattern(
        regex: RegExp(r'\b(i want to|i will)\s+([^.!,?]+)'),
        category: MemoryCategory.goals,
        titleBuilder: (match) => 'Goal',
        valueBuilder: (match) => match.group(2)!.trim(),
        reason: 'This sounds like a goal.',
        priority: MemoryPriority.high,
        importance: MemoryImportance.high,
        confidence: 0.78,
        tags: const ['goal', 'future'],
      ),
    ];

    for (final candidate in patterns) {
      final match = candidate.regex.firstMatch(text);
      if (match != null) {
        return candidate.copyWith(
          title: candidate.titleBuilder(match),
          value: candidate.valueBuilder(match),
        );
      }
    }

    return null;
  }
}

class _MemoryPattern {
  const _MemoryPattern({
    required this.regex,
    required this.category,
    required this.titleBuilder,
    required this.valueBuilder,
    required this.reason,
    required this.priority,
    required this.importance,
    required this.confidence,
    required this.tags,
    this.title = '',
    this.value = '',
  });

  final RegExp regex;
  final MemoryCategory category;
  final String Function(RegExpMatch match) titleBuilder;
  final String Function(RegExpMatch match) valueBuilder;
  final String reason;
  final MemoryPriority priority;
  final MemoryImportance importance;
  final double confidence;
  final List<String> tags;
  final String title;
  final String value;

  _MemoryPattern copyWith({String? title, String? value}) {
    return _MemoryPattern(
      regex: regex,
      category: category,
      titleBuilder: titleBuilder,
      valueBuilder: valueBuilder,
      reason: reason,
      priority: priority,
      importance: importance,
      confidence: confidence,
      tags: tags,
      title: title ?? this.title,
      value: value ?? this.value,
    );
  }
}
