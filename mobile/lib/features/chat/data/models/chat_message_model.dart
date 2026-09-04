import 'package:flutter/foundation.dart';

enum MessageSender { user, assistant, system }

class ChatMessageModel {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? metadata;
  final bool isVoiceMessage;
  final String? voiceUrl;

  String get text => content;
  bool get isUser => sender == MessageSender.user;

  const ChatMessageModel({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.isRead = true,
    this.metadata,
    this.isVoiceMessage = false,
    this.voiceUrl,
  });

  ChatMessageModel copyWith({
    String? id,
    String? content,
    MessageSender? sender,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? metadata,
    bool? isVoiceMessage,
    String? voiceUrl,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
      isVoiceMessage: isVoiceMessage ?? this.isVoiceMessage,
      voiceUrl: voiceUrl ?? this.voiceUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'sender': sender.name,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'isRead': isRead,
        'metadata': metadata,
        'isVoiceMessage': isVoiceMessage,
        'voiceUrl': voiceUrl,
      };

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      sender: MessageSender.values.firstWhere(
        (e) => e.name == json['sender'],
        orElse: () => MessageSender.assistant,
      ),
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isVoiceMessage: json['isVoiceMessage'] as bool? ?? false,
      voiceUrl: json['voiceUrl'] as String?,
    );
  }

  @override
  String toString() {
    return 'ChatMessageModel(id: $id, sender: ${sender.name}, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content})';
  }
}

class ConversationModel {
  final String id;
  final String title;
  final List<ChatMessageModel> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final String? petId;

  const ConversationModel({
    required this.id,
    this.title = 'New Chat',
    this.messages = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.petId,
  });

  ConversationModel copyWith({
    String? id,
    String? title,
    List<ChatMessageModel>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    String? petId,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      petId: petId ?? this.petId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'messages': messages.map((m) => m.toJson()).toList(),
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
        'isPinned': isPinned,
        'petId': petId,
      };

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'New Chat',
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) =>
                  ChatMessageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : DateTime.now(),
      isPinned: json['isPinned'] as bool? ?? false,
      petId: json['petId'] as String?,
    );
  }
}
