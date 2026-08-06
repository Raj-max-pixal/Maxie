import 'package:maxie_mobile/features/ai_chat/domain/models/conversation.dart';

abstract interface class ConversationRepository {
  Future<List<Conversation>> readConversations();

  Future<void> saveConversations(List<Conversation> conversations);

  Future<String?> readLastOpenedConversationId();

  Future<void> saveLastOpenedConversationId(String conversationId);
}
