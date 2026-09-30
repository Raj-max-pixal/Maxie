import 'package:maxie_mobile/features/ai_chat/domain/models/conversation.dart';
import 'package:maxie_mobile/features/ai_chat/domain/repositories/conversation_repository.dart';

class ConversationService {
  const ConversationService(this._repository);

  final ConversationRepository _repository;

  Future<List<Conversation>> load() => _repository.readConversations();

  Future<void> persist(
    List<Conversation> conversations,
    String activeId,
  ) async {
    await _repository.saveConversations(conversations);
    await _repository.saveLastOpenedConversationId(activeId);
  }

  Future<String?> lastOpenedId() => _repository.readLastOpenedConversationId();

  List<Conversation> withUpdatedConversation(
    List<Conversation> conversations,
    Conversation updated,
  ) {
    return [
      for (final conversation in conversations)
        if (conversation.id == updated.id) updated else conversation,
    ];
  }
}
