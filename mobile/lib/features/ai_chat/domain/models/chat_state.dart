import 'package:maxie_mobile/features/ai_chat/domain/models/conversation.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';

class ChatState {
  const ChatState({
    required this.conversations,
    required this.activeConversationId,
    this.isGenerating = false,
    this.errorMessage,
    this.pendingMemorySuggestion,
  });

  factory ChatState.initial() {
    return ChatState(
      conversations: [ConversationFactory.empty()],
      activeConversationId: ConversationFactory.defaultId,
    );
  }

  final List<Conversation> conversations;
  final String activeConversationId;
  final bool isGenerating;
  final String? errorMessage;
  final MemorySuggestion? pendingMemorySuggestion;

  Conversation get activeConversation {
    return conversations.firstWhere(
      (conversation) => conversation.id == activeConversationId,
      orElse: () => conversations.first,
    );
  }

  ChatState copyWith({
    List<Conversation>? conversations,
    String? activeConversationId,
    bool? isGenerating,
    String? errorMessage,
    MemorySuggestion? pendingMemorySuggestion,
    bool clearError = false,
    bool clearMemorySuggestion = false,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      activeConversationId: activeConversationId ?? this.activeConversationId,
      isGenerating: isGenerating ?? this.isGenerating,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      pendingMemorySuggestion: clearMemorySuggestion
          ? null
          : pendingMemorySuggestion ?? this.pendingMemorySuggestion,
    );
  }
}
