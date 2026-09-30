import 'package:maxie_mobile/features/ai_chat/domain/models/ai_response.dart';
import 'package:maxie_mobile/features/ai_chat/domain/models/chat_message.dart';

abstract interface class AiRepository {
  Stream<String> streamResponse(List<ChatMessage> messages);

  Future<AiResponse> complete(List<ChatMessage> messages);

  void cancel();
}
