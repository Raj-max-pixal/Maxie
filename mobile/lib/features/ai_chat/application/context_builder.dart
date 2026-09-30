import 'package:maxie_mobile/features/ai_chat/application/memory_retriever.dart';
import 'package:maxie_mobile/features/ai_chat/application/personality_engine.dart';
import 'package:maxie_mobile/features/ai_chat/domain/models/chat_message.dart';
import 'package:maxie_mobile/features/ai_chat/domain/models/conversation.dart';
import 'package:maxie_mobile/features/auth/domain/models/user_profile.dart';
import 'package:maxie_mobile/features/pet/domain/models/pet_state.dart';

class ContextBuilder {
  const ContextBuilder({
    required this._memoryRetriever,
    required this._personalityEngine,
    this.maxRecentMessages = 20,
  });

  final MemoryRetriever _memoryRetriever;
  final PersonalityEngine _personalityEngine;
  final int maxRecentMessages;

  Future<List<ChatMessage>> build({
    required Conversation conversation,
    required String prompt,
    required UserProfile? profile,
    required PetState pet,
  }) async {
    final memories = await _memoryRetriever.retrieve(prompt);
    final recent = conversation.messages
        .where((message) => message.role != ChatRole.system)
        .where((message) => message.content.trim().isNotEmpty)
        .toList();
    final start = recent.length > maxRecentMessages
        ? recent.length - maxRecentMessages
        : 0;

    return [
      _personalityEngine.systemMessage(
        conversationId: conversation.id,
        profile: profile,
        pet: pet,
        memories: memories,
      ),
      ...recent.sublist(start),
    ];
  }
}
