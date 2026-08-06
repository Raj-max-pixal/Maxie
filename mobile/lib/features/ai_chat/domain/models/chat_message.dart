enum ChatRole { user, assistant, system }

enum ChatMessageStatus { sending, streaming, complete, failed, cancelled }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.status = ChatMessageStatus.complete,
    this.attachments = const [],
    this.errorMessage,
  });

  final String id;
  final String conversationId;
  final ChatRole role;
  final String content;
  final DateTime createdAt;
  final ChatMessageStatus status;
  final List<ChatAttachment> attachments;
  final String? errorMessage;

  bool get isUser => role == ChatRole.user;

  ChatMessage copyWith({
    String? content,
    ChatMessageStatus? status,
    String? errorMessage,
  }) {
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      role: role,
      content: content ?? this.content,
      createdAt: createdAt,
      status: status ?? this.status,
      attachments: attachments,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'role': role.name,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'attachments': attachments.map((attachment) => attachment.toJson()).toList(),
      'errorMessage': errorMessage,
    };
  }

  factory ChatMessage.fromJson(Map<dynamic, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      role: ChatRole.values.byName(json['role'] as String),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: ChatMessageStatus.values.byName(
        (json['status'] as String?) ?? ChatMessageStatus.complete.name,
      ),
      attachments: [
        for (final attachment in (json['attachments'] as List<dynamic>? ?? []))
          ChatAttachment.fromJson(attachment as Map<dynamic, dynamic>),
      ],
      errorMessage: json['errorMessage'] as String?,
    );
  }
}

class ChatAttachment {
  const ChatAttachment({
    required this.id,
    required this.name,
    required this.mimeType,
    this.localPath,
  });

  final String id;
  final String name;
  final String mimeType;
  final String? localPath;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'mimeType': mimeType,
      'localPath': localPath,
    };
  }

  factory ChatAttachment.fromJson(Map<dynamic, dynamic> json) {
    return ChatAttachment(
      id: json['id'] as String,
      name: json['name'] as String,
      mimeType: json['mimeType'] as String,
      localPath: json['localPath'] as String?,
    );
  }
}
