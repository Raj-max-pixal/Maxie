import 'package:maxie_mobile/config/app_constants.dart';
import 'package:maxie_mobile/features/ai_chat/domain/models/conversation.dart';
import 'package:maxie_mobile/features/ai_chat/domain/repositories/conversation_repository.dart';
import 'package:maxie_mobile/services/storage/storage_service.dart';

class HiveConversationRepository implements ConversationRepository {
  const HiveConversationRepository(this._storage);

  static const String _conversationsKey = 'conversations';
  static const String _lastOpenedKey = 'last_opened_conversation';

  final StorageService _storage;

  @override
  Future<List<Conversation>> readConversations() async {
    final data = await _storage.read<List<dynamic>>(
      AppConstants.hiveCompanionBox,
      _conversationsKey,
    );
    if (data == null || data.isEmpty) {
      return [ConversationFactory.empty()];
    }
    return [
      for (final item in data)
        Conversation.fromJson(item as Map<dynamic, dynamic>),
    ];
  }

  @override
  Future<void> saveConversations(List<Conversation> conversations) {
    return _storage.write<List<Map<String, Object?>>>(
      AppConstants.hiveCompanionBox,
      _conversationsKey,
      conversations.map((conversation) => conversation.toJson()).toList(),
    );
  }

  @override
  Future<String?> readLastOpenedConversationId() {
    return _storage.read<String>(
      AppConstants.hiveCompanionBox,
      _lastOpenedKey,
    );
  }

  @override
  Future<void> saveLastOpenedConversationId(String conversationId) {
    return _storage.write<String>(
      AppConstants.hiveCompanionBox,
      _lastOpenedKey,
      conversationId,
    );
  }
}
