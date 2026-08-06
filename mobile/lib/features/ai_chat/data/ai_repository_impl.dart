import 'dart:async';

import 'package:maxie_mobile/features/ai_chat/data/ai_provider.dart';
import 'package:maxie_mobile/features/ai_chat/data/gemini_provider.dart';
import 'package:maxie_mobile/features/ai_chat/domain/models/ai_response.dart';
import 'package:maxie_mobile/features/ai_chat/domain/models/chat_message.dart';
import 'package:maxie_mobile/features/ai_chat/domain/repositories/ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  AiRepositoryImpl({AiProvider? provider})
      : _provider = provider ?? GeminiProvider();

  final AiProvider _provider;
  bool _cancelled = false;

  @override
  Future<AiResponse> complete(
    List<ChatMessage> messages, {
    String? systemPrompt,
  }) {
    return _provider.complete(messages, systemPrompt: systemPrompt);
  }

  @override
  Stream<String> streamResponse(
    List<ChatMessage> messages, {
    String? systemPrompt,
  }) async* {
    _cancelled = false;
    final response = await complete(messages, systemPrompt: systemPrompt);
    final chunks = _chunkText(response.text);

    for (final chunk in chunks) {
      if (_cancelled) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 28));
      yield chunk;
    }
  }

  @override
  void cancel() {
    _cancelled = true;
  }

  List<String> _chunkText(String text) {
    final chunks = <String>[];
    final words = text.split(RegExp(r'(\s+)'));
    for (final word in words) {
      if (word.isNotEmpty) {
        chunks.add(word);
      }
    }
    return chunks;
  }
}
