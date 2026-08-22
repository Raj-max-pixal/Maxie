import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/ai_chat/application/ai_settings_providers.dart';
import 'package:maxie_mobile/features/ai_chat/application/conversation_repository_provider.dart';
import 'package:maxie_mobile/features/ai_chat/data/ai_repository_impl.dart';
import 'package:maxie_mobile/features/ai_chat/domain/models/chat_message.dart';
import 'package:maxie_mobile/features/ai_chat/domain/models/chat_state.dart';
import 'package:maxie_mobile/features/ai_chat/domain/models/conversation.dart';
import 'package:maxie_mobile/features/ai_chat/domain/repositories/ai_repository.dart';
import 'package:maxie_mobile/features/ai_chat/domain/repositories/conversation_repository.dart';
import 'package:maxie_mobile/features/ai_companion/application/companion_state_engine.dart';
import 'package:maxie_mobile/features/memory/application/memory_providers.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_service.dart';

final aiRepositoryProvider = Provider<AiRepository>(
  (ref) => AiRepositoryImpl(),
);

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>(
  (ref) {
    final controller = ChatController(
      ref: ref,
      aiRepository: ref.watch(aiRepositoryProvider),
      conversationRepository: ref.watch(conversationRepositoryProvider),
      memoryService: ref.watch(memoryBrainServiceProvider),
    );
    unawaited(controller.load());
    return controller;
  },
);

class ChatController extends StateNotifier<ChatState> {
  ChatController({
    required Ref ref,
    required this.aiRepository,
    required this.conversationRepository,
    required MemoryService memoryService,
  }) : _ref = ref,
       _memoryService = memoryService,
       super(ChatState.initial());

  final Ref _ref;
  final AiRepository aiRepository;
  final ConversationRepository conversationRepository;
  final MemoryService _memoryService;
  StreamSubscription<String>? _streamSubscription;

  Future<void> load() async {
    final conversations = await conversationRepository.readConversations();
    final lastOpened = await conversationRepository
        .readLastOpenedConversationId();
    state = state.copyWith(
      conversations: conversations,
      activeConversationId: lastOpened ?? conversations.first.id,
      clearError: true,
    );
  }

  Future<void> sendMessage(String text) async {
    final prompt = text.trim();
    if (prompt.isEmpty || state.isGenerating) {
      return;
    }

    final now = DateTime.now();
    final conversation = state.activeConversation;
    final userMessage = ChatMessage(
      id: _id('user'),
      conversationId: conversation.id,
      role: ChatRole.user,
      content: prompt,
      createdAt: now,
    );
    final assistantMessage = ChatMessage(
      id: _id('assistant'),
      conversationId: conversation.id,
      role: ChatRole.assistant,
      content: '',
      createdAt: now,
      status: ChatMessageStatus.streaming,
    );

    _replaceActiveConversation(
      conversation.copyWith(
        title: conversation.messages.isEmpty ? _titleFromPrompt(prompt) : null,
        updatedAt: now,
        messages: [...conversation.messages, userMessage, assistantMessage],
      ),
      isGenerating: true,
      clearError: true,
    );

    await _persist();
    unawaited(_ref.read(companionStateEngineProvider.notifier).reactToChat());

    final memoryEnabled = _ref.read(aiSettingsProvider).memoryEnabled;
    if (memoryEnabled) {
      unawaited(_captureMemory(prompt, conversation.id, userMessage.id));
    } else {
      state = state.copyWith(clearMemorySuggestion: true);
    }

    final recalled = memoryEnabled
        ? await _memoryService.recallMemory(prompt)
        : const <MemoryRecord>[];
    final systemPrompt = _buildMemoryPrompt(recalled);

    var accumulated = '';
    await _streamSubscription?.cancel();
    _streamSubscription = aiRepository
        .streamResponse(
          state.activeConversation.messages,
          systemPrompt: systemPrompt,
        )
        .listen(
          (chunk) {
            accumulated += chunk;
            _updateAssistantMessage(
              assistantMessage.id,
              accumulated,
              ChatMessageStatus.streaming,
            );
          },
          onError: (Object error) {
            _updateAssistantMessage(
              assistantMessage.id,
              accumulated.isEmpty ? 'I hit a connection issue.' : accumulated,
              ChatMessageStatus.failed,
              errorMessage: error.toString(),
            );
            state = state.copyWith(
              isGenerating: false,
              errorMessage: error.toString(),
            );
            unawaited(_persist());
          },
          onDone: () {
            _updateAssistantMessage(
              assistantMessage.id,
              accumulated,
              ChatMessageStatus.complete,
            );
            state = state.copyWith(isGenerating: false, clearError: true);
            unawaited(_persist());
          },
        );
  }

  Future<void> regenerateLastResponse() async {
    if (state.isGenerating) {
      return;
    }
    final messages = state.activeConversation.messages;
    final lastUserIndex = messages.lastIndexWhere((message) => message.isUser);
    if (lastUserIndex >= 0) {
      final lastUser = messages[lastUserIndex];
      final beforeLastTurn = messages.take(lastUserIndex).toList();
      _replaceActiveConversation(
        state.activeConversation.copyWith(messages: beforeLastTurn),
      );
      await sendMessage(lastUser.content);
    }
  }

  Future<void> stopGeneration() async {
    aiRepository.cancel();
    await _streamSubscription?.cancel();
    final conversation = state.activeConversation;
    final messages = conversation.messages.map((message) {
      if (message.status == ChatMessageStatus.streaming) {
        return message.copyWith(status: ChatMessageStatus.cancelled);
      }
      return message;
    }).toList();
    _replaceActiveConversation(
      conversation.copyWith(messages: messages, updatedAt: DateTime.now()),
      isGenerating: false,
    );
    await _persist();
  }

  Future<void> createConversation() async {
    final now = DateTime.now();
    final conversation = Conversation(
      id: _id('conversation'),
      title: 'New chat',
      createdAt: now,
      updatedAt: now,
    );
    state = state.copyWith(
      conversations: [conversation, ...state.conversations],
      activeConversationId: conversation.id,
      clearError: true,
    );
    await _persist();
  }

  Future<void> selectConversation(String conversationId) async {
    state = state.copyWith(activeConversationId: conversationId);
    await conversationRepository.saveLastOpenedConversationId(conversationId);
  }

  Future<void> saveDraft(String draft) async {
    _replaceActiveConversation(state.activeConversation.copyWith(draft: draft));
    await _persist();
  }

  Future<void> acceptPendingMemory() async {
    final suggestion = state.pendingMemorySuggestion;
    if (suggestion == null) {
      return;
    }
    await _memoryService.saveMemory(suggestion.memory);
    state = state.copyWith(clearMemorySuggestion: true);
  }

  void ignorePendingMemory() {
    state = state.copyWith(clearMemorySuggestion: true);
  }

  void _updateAssistantMessage(
    String messageId,
    String content,
    ChatMessageStatus status, {
    String? errorMessage,
  }) {
    final conversation = state.activeConversation;
    final messages = conversation.messages.map((message) {
      if (message.id == messageId) {
        return message.copyWith(
          content: content,
          status: status,
          errorMessage: errorMessage,
        );
      }
      return message;
    }).toList();
    _replaceActiveConversation(
      conversation.copyWith(messages: messages, updatedAt: DateTime.now()),
    );
  }

  void _replaceActiveConversation(
    Conversation conversation, {
    bool? isGenerating,
    bool clearError = false,
  }) {
    state = state.copyWith(
      conversations: [
        for (final item in state.conversations)
          if (item.id == conversation.id) conversation else item,
      ],
      isGenerating: isGenerating,
      clearError: clearError,
    );
  }

  Future<void> _persist() async {
    await conversationRepository.saveConversations(state.conversations);
    await conversationRepository.saveLastOpenedConversationId(
      state.activeConversationId,
    );
  }

  String _titleFromPrompt(String prompt) {
    return prompt.length <= 28 ? prompt : '${prompt.substring(0, 28)}...';
  }

  String _id(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<void> _captureMemory(
    String prompt,
    String conversationId,
    String messageId,
  ) async {
    final suggestion = await _memoryService.extractSuggestion(
      prompt,
      conversationId: conversationId,
      messageId: messageId,
    );
    if (suggestion == null) {
      state = state.copyWith(clearMemorySuggestion: true);
      return;
    }
    state = state.copyWith(pendingMemorySuggestion: suggestion);
  }

  String _buildMemoryPrompt(List<MemoryRecord> memories) {
    if (memories.isEmpty) {
      return '';
    }
    final lines = memories
        .take(4)
        .map((memory) {
          return '- ${memory.category.name}: ${memory.title} = ${memory.value}';
        })
        .join('\n');
    return 'Use these memories when answering:\n$lines';
  }

  @override
  void dispose() {
    unawaited(_streamSubscription?.cancel());
    super.dispose();
  }
}
