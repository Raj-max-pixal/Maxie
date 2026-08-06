import 'package:maxie_mobile/config/app_constants.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/repositories/memory_repository.dart';
import 'package:maxie_mobile/services/storage/storage_service.dart';

class HiveMemoryRepository implements MemoryRepository {
  const HiveMemoryRepository(this._storage);

  static const String _memoryRecordsKey = 'memory_records';

  final StorageService _storage;

  @override
  Future<void> clearMemories() {
    return _storage.clear(AppConstants.hiveMemoryBox);
  }

  @override
  Future<void> deleteMemory(String id) async {
    final memories = await readMemories();
    final remaining = memories.where((memory) => memory.id != id).toList();
    await _storage.write<List<Map<String, Object?>>>(
      AppConstants.hiveMemoryBox,
      _memoryRecordsKey,
      remaining.map((memory) => memory.toJson()).toList(),
    );
  }

  @override
  Future<List<MemoryRecord>> readMemories() async {
    final data = await _storage.read<List<dynamic>>(
      AppConstants.hiveMemoryBox,
      _memoryRecordsKey,
    );
    if (data == null || data.isEmpty) {
      return const [];
    }
    return [
      for (final item in data)
        MemoryRecord.fromJson(item as Map<dynamic, dynamic>),
    ];
  }

  @override
  Future<void> saveMemory(MemoryRecord entry) async {
    final memories = await readMemories();
    final next = [
      for (final memory in memories)
        if (memory.id != entry.id) memory,
      entry,
    ]..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));

    await _storage.write<List<Map<String, Object?>>>(
      AppConstants.hiveMemoryBox,
      _memoryRecordsKey,
      next.map((memory) => memory.toJson()).toList(),
    );
  }
}
