import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';

abstract interface class MemoryRepository {
  Future<List<MemoryRecord>> readMemories();

  Future<void> saveMemory(MemoryRecord entry);

  Future<void> deleteMemory(String id);

  Future<void> clearMemories();
}
