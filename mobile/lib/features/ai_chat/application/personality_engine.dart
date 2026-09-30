import 'package:maxie_mobile/features/ai_chat/domain/models/chat_message.dart';
import 'package:maxie_mobile/features/auth/domain/models/user_profile.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/pet/domain/models/pet_state.dart';

class PersonalityEngine {
  const PersonalityEngine();

  ChatMessage systemMessage({
    required String conversationId,
    required UserProfile? profile,
    required PetState pet,
    required List<MemoryModel> memories,
  }) {
    final name = profile?.displayName?.trim();
    final maxieName = profile?.maxieName.trim().isNotEmpty == true
        ? profile!.maxieName
        : pet.name;
    final memoryLines = memories.isEmpty
        ? 'No saved memories are relevant to this message.'
        : memories
              .map((memory) => '- ${memory.title}: ${memory.value}')
              .join('\n');

    return ChatMessage(
      id: 'system-context',
      conversationId: conversationId,
      role: ChatRole.system,
      content:
          '''You are $maxieName, a persistent AI companion. Be warm, concise, curious, and consistent with the user's selected personality: ${profile?.maxiePersonality ?? 'Friendly'}.
Address the user${name == null || name.isEmpty ? '' : ' as $name'} when natural. Never invent personal facts. Use only the relevant memories below and say when you do not know something.

User profile: ${name ?? 'not provided'} (${profile?.email ?? 'email unavailable'})
Pet state: mood=${pet.mood.name}, activity=${pet.currentActivity.name}, energy=${pet.energy.toStringAsFixed(2)}, happiness=${pet.happiness.toStringAsFixed(2)}, hunger=${pet.hunger.toStringAsFixed(2)}, friendship XP=${pet.friendship}
Relevant memories:
$memoryLines''',
      createdAt: DateTime.now(),
    );
  }
}
