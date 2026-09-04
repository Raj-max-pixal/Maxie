import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/ai_chat/data/ai_repository_impl.dart';
import 'package:maxie_mobile/features/ai_chat/data/hive_conversation_repository.dart';
import 'package:maxie_mobile/features/ai_chat/domain/models/chat_message.dart';
import 'package:maxie_mobile/features/ai_chat/domain/models/chat_state.dart';
import 'package:maxie_mobile/features/ai_chat/domain/models/conversation.dart';
import 'package:maxie_mobile/features/ai_chat/domain/repositories/ai_repository.dart';
import 'package:maxie_mobile/features/ai_chat/domain/repositories/conversation_repository.dart';
import 'package:maxie_mobile/features/memory/application/memory_manager.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_service.dart';
import 'package:maxie_mobile/features/pet/application/pet_providers.dart';
import 'package:maxie_mobile/features/pet/domain/models/pet_state.dart';
import 'package:maxie_mobile/features/pet/domain/repositories/pet_repository.dart';
import 'package:maxie_mobile/services/storage/storage_providers.dart';

final aiRepositoryProvider = Provider<AiRepository>(
  (ref) => AiRepositoryImpl(),
);

final conversationRepositoryProvider = Provider<ConversationRepository>(
  (ref) => HiveConversationRepository(ref.watch(storageServiceProvider)),
);

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>(
  (ref) {
    final controller = ChatController(
      aiRepository: ref.watch(aiRepositoryProvider),
      conversationRepository: ref.watch(conversationRepositoryProvider),
      memoryService: ref.watch(memoryBrainServiceProvider),
      petRepository: ref.watch(petRepositoryProvider),
      onPetChanged: () => ref.invalidate(petStateProvider),
    );
    unawaited(controller.load());
    return controller;
  },
);

class ChatController extends StateNotifier<ChatState> {
  ChatController({
    required this.aiRepository,
    required this.conversationRepository,
    required this.memoryService,
    required this.petRepository,
    required this.onPetChanged,
  }) : super(ChatState.initial());

  final AiRepository aiRepository;
  final ConversationRepository conversationRepository;
  final MemoryService memoryService;
  final PetRepository petRepository;
  final VoidCallback onPetChanged;
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
    final candidates = await memoryService.extractMemoryCandidates(
      text: prompt,
      conversationId: conversation.id,
    );
    if (candidates.isNotEmpty) {
      state = state.copyWith(pendingMemoryCandidates: candidates);
    }

    var accumulated = '';
    await _streamSubscription?.cancel();
    _streamSubscription = aiRepository
        .streamResponse(state.activeConversation.messages)
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
            unawaited(_rewardCompanionForChat(prompt, candidates.length));
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

  Future<void> saveMemoryCandidate(MemoryCandidate candidate) async {
    await memoryService.saveMemory(MemoryModel.fromCandidate(candidate));
    await _rewardCompanionForMemory(candidate);
    state = state.copyWith(
      pendingMemoryCandidates: [
        for (final item in state.pendingMemoryCandidates)
          if (item.id != candidate.id) item,
      ],
    );
  }

  Future<void> saveMessageAsMemory(ChatMessage message) async {
    final content = message.content.trim();
    if (content.isEmpty) {
      return;
    }
    final now = DateTime.now();
    final memory = MemoryModel(
      id: _id('memory'),
      category: MemoryCategory.conversation,
      title: 'Saved Chat Insight',
      value: content.length <= 220
          ? content
          : '${content.substring(0, 220)}...',
      createdAt: now,
      updatedAt: now,
      importance: 0.72,
      confidence: 0.9,
      tags: const ['chat', 'saved'],
      sourceConversationId: message.conversationId,
      isFavorite: true,
    );
    await memoryService.saveMemory(memory);
    await _rewardCompanionForMemory(
      MemoryCandidate(
        id: memory.id,
        category: memory.category,
        title: memory.title,
        value: memory.value,
        confidence: memory.confidence,
        tags: memory.tags,
        sourceConversationId: memory.sourceConversationId,
      ),
    );
  }

  Future<void> _rewardCompanionForChat(
    String prompt,
    int memoryCandidateCount,
  ) async {
    final current = await petRepository.readPet();
    final lower = prompt.toLowerCase();
    final mood =
        lower.contains('study') ||
            lower.contains('learn') ||
            lower.contains('debug') ||
            lower.contains('plan')
        ? PetMood.focused
        : memoryCandidateCount > 0
        ? PetMood.listening
        : PetMood.happy;
    await petRepository.savePet(
      current.copyWith(
        mood: mood,
        affinity: current.affinity + 6 + (memoryCandidateCount * 3),
        energy: (current.energy - 0.02).clamp(0, 1).toDouble(),
        lastAction: memoryCandidateCount > 0
            ? 'Found a memory in chat'
            : 'Chatted with you',
      ),
    );
    onPetChanged();
  }

  Future<void> _rewardCompanionForMemory(MemoryCandidate candidate) async {
    final current = await petRepository.readPet();
    await petRepository.savePet(
      current.copyWith(
        mood: PetMood.loving,
        affinity: current.affinity + 12,
        energy: (current.energy + 0.04).clamp(0, 1).toDouble(),
        lastAction: 'Remembered ${candidate.title.toLowerCase()}',
      ),
    );
    onPetChanged();
  }

  void ignoreMemoryCandidate(String candidateId) {
    state = state.copyWith(
      pendingMemoryCandidates: [
        for (final item in state.pendingMemoryCandidates)
          if (item.id != candidateId) item,
      ],
    );
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

  @override
  void dispose() {
    unawaited(_streamSubscription?.cancel());
    super.dispose();
  }
}
