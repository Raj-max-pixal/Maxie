import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/services/ai_chat_service.dart';
import '../../../memory/data/models/memory_model.dart';
import '../../../memory/data/services/memory_service.dart';
import '../../../gamification/data/services/gamification_service.dart';
import '../../../pets/presentation/providers/pet_provider.dart';

final uuid = const Uuid();

final chatServiceProvider = Provider<AIChatService>((ref) {
  return AIChatService(useOfflineMode: true);
});

final conversationsProvider =
    StateNotifierProvider<ConversationsNotifier, List<ConversationModel>>((ref) {
  return ConversationsNotifier(ref);
});

final currentConversationIdProvider = StateProvider<String?>((ref) => null);

class ConversationsNotifier extends StateNotifier<List<ConversationModel>> {
  final Ref _ref;

  ConversationsNotifier(this._ref) : super([]);

  ConversationModel? get currentConversation {
    final id = _ref.read(currentConversationIdProvider);
    if (id == null) return null;
    return state.where((c) => c.id == id).firstOrNull;
  }

  ConversationModel createNewConversation({String? petId}) {
    final conversation = ConversationModel(
      id: uuid.v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      petId: petId,
    );
    state = [conversation, ...state];
    _ref.read(currentConversationIdProvider.notifier).state = conversation.id;
    return conversation;
  }

  void selectConversation(String id) {
    _ref.read(currentConversationIdProvider.notifier).state = id;
  }

  Future<void> sendMessage(String content, {bool isVoice = false}) async {
    final convId = _ref.read(currentConversationIdProvider);
    ConversationModel conversation;

    if (convId == null || !state.any((c) => c.id == convId)) {
      conversation = createNewConversation();
    } else {
      conversation = state.firstWhere((c) => c.id == convId);
    }

    // Add user message
    final userMessage = ChatMessageModel(
      id: uuid.v4(),
      content: content,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      isVoiceMessage: isVoice,
    );

    final updatedMessages = [...conversation.messages, userMessage];

    // Generate AI response
    final aiService = _ref.read(chatServiceProvider);
    final memoryService = _ref.read(memoryServiceProvider);
    final memories = memoryService.getMemoriesAsMap();
    final petsState = _ref.read(petEngineProvider);
    final petName = petsState.pets.isNotEmpty ? petsState.pets.first.name : 'MAXie';

    final response = await aiService.generateResponse(
      content,
      memory: memories,
      petName: petName,
    );

    // Add AI response
    final aiMessage = ChatMessageModel(
      id: uuid.v4(),
      content: response,
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
    );

    final finalMessages = [...updatedMessages, aiMessage];

    // Update conversation
    final updatedConversation = conversation.copyWith(
      messages: finalMessages,
      updatedAt: DateTime.now(),
      title: conversation.title == 'New Chat' && finalMessages.isNotEmpty
          ? content.length > 50
              ? '${content.substring(0, 50)}...'
              : content
          : conversation.title,
    );

    state = state.map((c) => c.id == conversation.id ? updatedConversation : c).toList();

    // Save to memory
    memoryService.addMemory(
      type: MemoryType.conversation,
      content: response,
      tags: ['chat', aiService.summarizeConversation(finalMessages)],
    );

    // Award XP for chatting
    final gamificationService = _ref.read(gamificationServiceProvider.notifier);
    gamificationService.addXP(5, source: 'Chat');
  }

  void deleteConversation(String id) {
    state = state.where((c) => c.id != id).toList();
  }

  void togglePinConversation(String id) {
    state = state.map((c) {
      if (c.id == id) {
        return c.copyWith(isPinned: !c.isPinned);
      }
      return c;
    }).toList();
  }

  void clearAllConversations() {
    state = [];
  }

  List<ConversationModel> get pinnedConversations =>
      state.where((c) => c.isPinned).toList();

  List<ConversationModel> get recentConversations {
    final sorted = [...state]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.take(20).toList();
  }
}