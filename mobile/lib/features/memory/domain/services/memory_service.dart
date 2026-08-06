import 'package:maxie_mobile/features/ai_chat/domain/models/conversation.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';

abstract interface class MemoryService {
  Future<MemorySuggestion?> extractSuggestion(
    String text, {
    String? conversationId,
    String? messageId,
  });

  Future<List<MemoryRecord>> recallMemory(String query);

  Future<void> saveMemory(MemoryRecord memory);

  Future<void> deleteMemory(String id);

  Future<void> clearMemories();

  Future<List<MemoryRecord>> searchMemories(MemorySearchQuery query);

  Future<MemorySummary> summarize();

  Future<MemoryTimeline> buildTimeline();

  Future<MemoryRelationshipState> relationshipSnapshot();

  Future<MemoryRecord?> updateMemory(MemoryRecord memory);

  Future<MemoryRecord?> pinMemory(String id, {bool pinned = true});

  Future<List<Conversation>> readConversations();
}
