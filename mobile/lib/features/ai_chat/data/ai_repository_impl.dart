import 'dart:async';
import 'dart:math';

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
  final Random _random = Random();

  @override
  Future<AiResponse> complete(List<ChatMessage> messages) async {
    try {
      return await _provider.complete(messages);
    } catch (error) {
      final userMessage = messages.lastWhere(
        (m) => m.role == ChatRole.user,
        orElse: () => ChatMessage(
          id: 'user',
          conversationId: 'default',
          role: ChatRole.user,
          content: '',
          createdAt: DateTime.now(),
        ),
      );
      final text = _generateSmartFallback(userMessage.content);
      return AiResponse(text: text, model: 'maxie-local-brain');
    }
  }

  @override
  Stream<String> streamResponse(List<ChatMessage> messages) async* {
    _cancelled = false;
    final response = await complete(messages);
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

  String _generateSmartFallback(String prompt) {
    final lower = prompt.toLowerCase().trim();
    if (lower.contains('hello') || lower.contains('hi') || lower.contains('hey')) {
      return 'Hey there! I am MAXie, your AI companion. How can I help you today? ✨';
    }
    if (lower.contains('who are you') || lower.contains('your name')) {
      return 'I am MAXie — your local-first AI companion! I remember what matters to you, track your goals, and keep you company. 💕';
    }
    if (lower.contains('remember') || lower.contains('memory')) {
      return 'I got it! I have saved that into your Memory Brain so we never forget. 🧠✨';
    }
    if (lower.contains('focus') || lower.contains('study') || lower.contains('work')) {
      return 'That sounds like a great plan! Let\'s stay focused together. You\'ve got this! 🚀';
    }
    if (lower.contains('pet') || lower.contains('shimeji') || lower.contains('overlay')) {
      return 'You can interact with me anytime! Check out Companion Studio to spawn me on your screen! 🐾';
    }

    final genericReplies = [
      'That\'s really interesting! Tell me more about it. 😊',
      'I hear you! MAXie is right here with you every step of the way. ✨',
      'Got it! I\'ve noted that down for us. What\'s next on your mind? 🚀',
      'That sounds awesome! I\'m always here to support your goals. 💕',
    ];
    return genericReplies[_random.nextInt(genericReplies.length)];
  }
}
