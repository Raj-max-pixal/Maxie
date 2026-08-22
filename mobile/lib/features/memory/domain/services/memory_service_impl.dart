import 'package:maxie_mobile/features/ai_chat/domain/models/conversation.dart';
import 'package:maxie_mobile/features/ai_chat/domain/repositories/conversation_repository.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/repositories/memory_repository.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_extractor.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_ranker.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_search.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_service.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_summarizer.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_timeline.dart';

class DefaultMemoryService implements MemoryService {
  DefaultMemoryService({
    required MemoryRepository memoryRepository,
    required ConversationRepository conversationRepository,
  }) : _memoryRepository = memoryRepository,
       _conversationRepository = conversationRepository;

  final MemoryRepository _memoryRepository;
  final ConversationRepository _conversationRepository;
  final MemoryExtractor _extractor = const MemoryExtractor();
  final MemoryRanker _ranker = const MemoryRanker();
  late final MemorySearch _search = MemorySearch(_ranker);
  final MemorySummarizer _summarizer = const MemorySummarizer();
  final MemoryTimelineBuilder _timelineBuilder = const MemoryTimelineBuilder();

  @override
  Future<MemorySuggestion?> extractSuggestion(
    String text, {
    String? conversationId,
    String? messageId,
  }) async {
    final suggestion = _extractor.extract(text, conversationId: conversationId);
    if (suggestion == null) {
      return null;
    }
    return MemorySuggestion(
      memory: suggestion.memory.copyWith(
        conversationId: conversationId,
        messageId: messageId,
      ),
      reason: suggestion.reason,
      confidence: suggestion.confidence,
      capturedAt: suggestion.capturedAt,
    );
  }

  @override
  Future<void> saveMemory(MemoryRecord memory) async {
    await _memoryRepository.saveMemory(
      memory.copyWith(updatedAt: DateTime.now(), lastUsedAt: DateTime.now()),
    );
  }

  @override
  Future<void> deleteMemory(String id) => _memoryRepository.deleteMemory(id);

  @override
  Future<void> clearMemories() => _memoryRepository.clearMemories();

  @override
  Future<List<MemoryRecord>> recallMemory(String query) async {
    final memories = await _memoryRepository.readMemories();
    if (query.trim().isEmpty) {
      return _ranker.rank(memories);
    }
    return _search.search(memories, MemorySearchQuery(query: query));
  }

  @override
  Future<List<MemoryRecord>> searchMemories(MemorySearchQuery query) async {
    final memories = await _memoryRepository.readMemories();
    return _search.search(memories, query);
  }

  @override
  Future<MemorySummary> summarize() async {
    final memories = await _memoryRepository.readMemories();
    return _summarizer.summarize(
      memories,
      relationship: await relationshipSnapshot(),
    );
  }

  @override
  Future<MemoryTimeline> buildTimeline() async {
    return _timelineBuilder.build(await _memoryRepository.readMemories());
  }

  @override
  Future<MemoryRelationshipState> relationshipSnapshot() async {
    final conversations = await _conversationRepository.readConversations();
    final memories = await _memoryRepository.readMemories();

    final conversationCount = conversations.length;
    final messagesExchanged = conversations.fold<int>(
      0,
      (sum, conversation) => sum + conversation.messages.length,
    );
    final earliestConversation = conversations.isEmpty
        ? DateTime.now()
        : conversations
              .map((conversation) => conversation.createdAt)
              .reduce((left, right) => left.isBefore(right) ? left : right);
    final daysTogether = DateTime.now().difference(earliestConversation).inDays;
    final xpEarnedTogether =
        (messagesExchanged * 8) +
        (memories.length * 25) +
        memories.where((memory) => memory.isPinned).length * 12;
    final friendshipLevel = (12 + (xpEarnedTogether / 120)).round().clamp(
      1,
      99,
    );
    final trustLevel = (10 + (conversationCount / 3) + (memories.length / 4))
        .round()
        .clamp(1, 99);

    final milestones = <String>[];
    if (conversationCount >= 100) {
      milestones.add('100 conversations');
    }
    if (daysTogether >= 30) {
      milestones.add('1 month together');
    }
    if (memories.any((memory) => memory.category == MemoryCategory.projects)) {
      milestones.add('First Project');
    }
    if (memories.where((memory) => memory.isPinned).isNotEmpty) {
      milestones.add('Pinned Memories');
    }

    return MemoryRelationshipState(
      friendshipLevel: friendshipLevel,
      trustLevel: trustLevel,
      conversationCount: conversationCount,
      daysTogether: daysTogether,
      messagesExchanged: messagesExchanged,
      xpEarnedTogether: xpEarnedTogether,
      milestones: milestones,
    );
  }

  @override
  Future<MemoryRecord?> updateMemory(MemoryRecord memory) async {
    final current = await _memoryRepository.readMemories();
    final next = memory.copyWith(updatedAt: DateTime.now());
    await _memoryRepository.saveMemory(next);
    if (current.any((item) => item.id == memory.id)) {
      return next;
    }
    return null;
  }

  @override
  Future<MemoryRecord?> pinMemory(String id, {bool pinned = true}) async {
    final current = await _memoryRepository.readMemories();
    final target = current.where((memory) => memory.id == id).firstOrNull;
    if (target == null) {
      return null;
    }
    final updated = target.copyWith(
      isPinned: pinned,
      updatedAt: DateTime.now(),
    );
    await _memoryRepository.saveMemory(updated);
    return updated;
  }

  @override
  Future<List<Conversation>> readConversations() {
    return _conversationRepository.readConversations();
  }
}

extension _FirstOrNullX<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
