import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]) {
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final box = await Hive.openBox('maxie_memory');
    final chatHistory = box.get('chatHistory', defaultValue: <dynamic>[]);
    
    state = chatHistory
        .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveChatHistory() async {
    final box = await Hive.openBox('maxie_memory');
    await box.put('chatHistory', state.map((msg) => msg.toJson()).toList());
  }

  Future<void> sendMessage(String text) async {
    // Add user message
    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    state = [...state, userMessage];
    await _saveChatHistory();

    // Simulate AI response (replace with actual AI call)
    await Future.delayed(const Duration(seconds: 1));
    
    final aiResponse = _generateResponse(text);
    final aiMessage = ChatMessage(
      text: aiResponse,
      isUser: false,
      timestamp: DateTime.now(),
    );
    
    state = [...state, aiMessage];
    await _saveChatHistory();
  }

  String _generateResponse(String userMessage) {
    // This is a placeholder - replace with actual AI integration
    final responses = [
      'That\'s so interesting! Tell me more! 🐾',
      'I love talking to you! You\'re the best!',
      'OMG really? That\'s amazing! ✨',
      'I totally get what you mean!',
      'You always have the best ideas! 💡',
      '*excited tail wags* This is fun!',
      'I\'m so happy we\'re chatting! ❤️',
    ];
    
    return responses[(userMessage.hashCode + DateTime.now().millisecond) % responses.length];
  }

  Future<void> clearChat() async {
    state = [];
    final box = await Hive.openBox('maxie_memory');
    await box.delete('chatHistory');
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier();
});
