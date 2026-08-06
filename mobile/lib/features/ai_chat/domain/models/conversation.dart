import 'package:maxie_mobile/features/ai_chat/domain/models/chat_message.dart';

class Conversation {
  const Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
    this.isPinned = false,
    this.draft = '',
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;
  final bool isPinned;
  final String draft;

  Conversation copyWith({
    String? title,
    DateTime? updatedAt,
    List<ChatMessage>? messages,
    bool? isPinned,
    String? draft,
  }) {
    return Conversation(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      isPinned: isPinned ?? this.isPinned,
      draft: draft ?? this.draft,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((message) => message.toJson()).toList(),
      'isPinned': isPinned,
      'draft': draft,
    };
  }

  factory Conversation.fromJson(Map<dynamic, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messages: [
        for (final message in (json['messages'] as List<dynamic>? ?? []))
          ChatMessage.fromJson(message as Map<dynamic, dynamic>),
      ],
      isPinned: (json['isPinned'] as bool?) ?? false,
      draft: (json['draft'] as String?) ?? '',
    );
  }
}

class ConversationFactory {
  const ConversationFactory._();

  static const String defaultId = 'default-conversation';

  static Conversation empty() {
    final now = DateTime.now();
    return Conversation(
      id: defaultId,
      title: 'New chat',
      createdAt: now,
      updatedAt: now,
    );
  }
}
