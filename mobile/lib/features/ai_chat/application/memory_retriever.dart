import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_service.dart';

class MemoryRetriever {
  const MemoryRetriever(this._memoryService);

  final MemoryService _memoryService;

  Future<List<MemoryModel>> retrieve(String query, {int limit = 8}) async {
    final memories = await _memoryService.recallMemory(query);
    return memories.take(limit).toList(growable: false);
  }
}
