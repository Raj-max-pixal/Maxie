import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_service.dart';

class ConversationMemoryExtractor {
  const ConversationMemoryExtractor(this._memoryService);

  final MemoryService _memoryService;

  Future<List<MemoryCandidate>> extract({
    required String text,
    required String conversationId,
  }) {
    return _memoryService.extractMemoryCandidates(
      text: text,
      conversationId: conversationId,
    );
  }
}
