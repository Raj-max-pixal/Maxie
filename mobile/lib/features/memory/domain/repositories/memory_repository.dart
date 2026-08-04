import 'package:maxie_mobile/features/memory/domain/models/memory_entry.dart';

abstract interface class MemoryRepository {
  Future<List<MemoryEntry>> readMemories();

  Future<void> saveMemory(MemoryEntry entry);

  Future<void> deleteMemory(String id);
}
