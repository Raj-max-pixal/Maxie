import 'package:maxie_mobile/features/ai_chat/domain/models/conversation.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';

class ChatState {
  const ChatState({
    required this.conversations,
    required this.activeConversationId,
    this.isGenerating = false,
    this.pendingMemoryCandidates = const [],
    this.errorMessage,
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
  final List<MemoryCandidate> pendingMemoryCandidates;
  final String? errorMessage;

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
    List<MemoryCandidate>? pendingMemoryCandidates,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      activeConversationId: activeConversationId ?? this.activeConversationId,
      isGenerating: isGenerating ?? this.isGenerating,
      pendingMemoryCandidates:
          pendingMemoryCandidates ?? this.pendingMemoryCandidates,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
