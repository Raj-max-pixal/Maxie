import 'package:maxie_mobile/features/memory/domain/models/memory_entry.dart';
import 'package:maxie_mobile/features/memory/domain/repositories/memory_repository.dart';

class PlaceholderMemoryRepository implements MemoryRepository {
  const PlaceholderMemoryRepository();

  @override
  Future<void> deleteMemory(String id) async {}

  @override
  Future<List<MemoryEntry>> readMemories() async {
    return const [];
  }

  @override
  Future<void> saveMemory(MemoryEntry entry) async {}
}
