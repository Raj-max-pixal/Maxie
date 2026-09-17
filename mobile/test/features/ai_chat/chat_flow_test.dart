import 'package:flutter_test/flutter_test.dart';
import 'package:maxie_mobile/features/ai_chat/application/chat_controller.dart';
import 'package:maxie_mobile/features/ai_chat/application/context_builder.dart';
import 'package:maxie_mobile/features/ai_chat/application/conversation_service.dart';
import 'package:maxie_mobile/features/ai_chat/application/memory_extractor.dart';
import 'package:maxie_mobile/features/ai_chat/application/memory_retriever.dart';
import 'package:maxie_mobile/features/ai_chat/application/personality_engine.dart';
import 'package:maxie_mobile/features/ai_chat/domain/models/ai_response.dart';
import 'package:maxie_mobile/features/ai_chat/domain/models/chat_message.dart';
import 'package:maxie_mobile/features/ai_chat/domain/models/conversation.dart';
import 'package:maxie_mobile/features/ai_chat/domain/repositories/ai_repository.dart';
import 'package:maxie_mobile/features/ai_chat/domain/repositories/conversation_repository.dart';
import 'package:maxie_mobile/features/auth/domain/models/user_profile.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_service.dart';
import 'package:maxie_mobile/features/pet/domain/models/pet_state.dart';
import 'package:maxie_mobile/features/pet/domain/repositories/pet_repository.dart';

void main() {
  test(
    'chat flow builds context, streams response, and persists conversation',
    () async {
      final ai = _FakeAiRepository();
      final conversations = _FakeConversationRepository();
      final memory = _FakeMemoryService();
      final pet = _FakePetRepository();
      final controller = ChatController(
        aiRepository: ai,
        conversationRepository: conversations,
        conversationService: ConversationService(conversations),
        contextBuilder: ContextBuilder(
          memoryRetriever: MemoryRetriever(memory),
          personalityEngine: const PersonalityEngine(),
        ),
        memoryExtractor: ConversationMemoryExtractor(memory),
        memoryService: memory,
        petRepository: pet,
        userProfile: UserProfile(
          uid: 'user-1',
          email: 'raj@example.com',
          displayName: 'Raj',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
        onPetChanged: () {},
      );

      await controller.load();
      await controller.sendMessage('What am I building?');
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final messages = controller.state.activeConversation.messages;
      expect(messages.last.content, 'You are building MAXie.');
      expect(messages.last.status.name, 'complete');
      expect(ai.lastMessages.first.role, ChatRole.system);
      expect(ai.lastMessages.first.content, contains('Raj'));
      expect(ai.lastMessages.first.content, contains('MAXie project'));
      expect(ai.lastMessages.first.content, contains('mood=happy'));
      expect(conversations.saved.isNotEmpty, isTrue);

      controller.dispose();
    },
  );
}

class _FakeAiRepository implements AiRepository {
  List<ChatMessage> lastMessages = const [];

  @override
  Future<AiResponse> complete(List<ChatMessage> messages) async =>
      const AiResponse(text: 'You are building MAXie.');

  @override
  void cancel() {}

  @override
  Stream<String> streamResponse(List<ChatMessage> messages) async* {
    lastMessages = messages;
    yield 'You are ';
    yield 'building MAXie.';
  }
}

class _FakeConversationRepository implements ConversationRepository {
  List<Conversation> saved = const [];
  String? lastId;

  @override
  Future<List<Conversation>> readConversations() async => [
    ConversationFactory.empty(),
  ];

  @override
  Future<String?> readLastOpenedConversationId() async => lastId;

  @override
  Future<void> saveConversations(List<Conversation> conversations) async {
    saved = conversations;
  }

  @override
  Future<void> saveLastOpenedConversationId(String conversationId) async {
    lastId = conversationId;
  }
}

class _FakeMemoryService implements MemoryService {
  final memories = [
    MemoryModel(
      id: 'memory-1',
      category: MemoryCategory.projects,
      title: 'Current project',
      value: 'Raj is building the MAXie project.',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
  ];

  @override
  Future<List<MemoryCandidate>> extractMemoryCandidates({
    required String text,
    String? conversationId,
  }) async => const [];

  @override
  Future<List<MemoryModel>> readMemories() async => memories;

  @override
  Future<List<MemoryModel>> recallMemory(String query) async => memories;

  @override
  Future<void> saveMemory(MemoryModel memory) async {}

  @override
  Future<void> deleteMemory(String id) async {}

  @override
  Future<void> clearMemories() async {}

  @override
  Future<MemorySummary> summarize() async => const MemorySummary(
    totalMemories: 1,
    pinnedMemories: 0,
    relationshipLevel: 1,
  );

  @override
  Future<MemoryTimeline> timeline() async => const MemoryTimeline();
}

class _FakePetRepository implements PetRepository {
  PetState state = const PetState(mood: PetMood.happy);

  @override
  Future<PetState> readPet() async => state;

  @override
  Future<void> savePet(PetState value) async => state = value;
}
