import 'package:maxie_mobile/features/ai_chat/domain/models/ai_response.dart';
import 'package:maxie_mobile/features/ai_chat/domain/models/chat_message.dart';

abstract interface class AiProvider {
  String get id;

  bool get isConfigured;

  Future<AiResponse> complete(
    List<ChatMessage> messages, {
    String? systemPrompt,
  });
}
