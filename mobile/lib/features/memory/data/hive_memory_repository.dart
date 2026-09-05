import 'package:maxie_mobile/config/app_constants.dart';
import 'package:maxie_mobile/config/storage_keys.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_entry.dart';
import 'package:maxie_mobile/features/memory/domain/repositories/memory_repository.dart';
import 'package:maxie_mobile/services/storage/storage_service.dart';

class HiveMemoryRepository implements MemoryRepository {
  const HiveMemoryRepository(this._storage);

  final StorageService _storage;

  @override
  Future<void> deleteMemory(String id) async {
    final memories = await readMemories();
    await _write(memories.where((memory) => memory.id != id).toList());
  }

  @override
  Future<List<MemoryEntry>> readMemories() async {
    final data = await _storage.read<List<dynamic>>(
      AppConstants.hiveMemoryBox,
      StorageKeys.memoryIndex,
    );
    if (data == null) {
      return _seedMemories();
    }
    return [
      for (final item in data)
        MemoryEntry.fromJson(item as Map<dynamic, dynamic>),
    ];
  }

  @override
  Future<void> saveMemory(MemoryEntry entry) async {
    final memories = await readMemories();
    final existingIndex = memories.indexWhere((item) => item.id == entry.id);
    if (existingIndex >= 0) {
      memories[existingIndex] = entry;
    } else {
      memories.insert(0, entry);
    }
    await _write(memories);
  }

  Future<void> _write(List<MemoryEntry> memories) {
    return _storage.write<List<Map<String, Object?>>>(
      AppConstants.hiveMemoryBox,
      StorageKeys.memoryIndex,
      memories.map((memory) => memory.toJson()).toList(),
    );
  }

  List<MemoryEntry> _seedMemories() {
    final now = DateTime.now();
    return [
      MemoryEntry(
        id: 'memory-preference-planning',
        title: 'You prefer morning planning',
        createdAt: now,
        tags: const ['preference', 'planning'],
      ),
      MemoryEntry(
        id: 'memory-project-maxie',
        title: 'MAXie Mobile is the current priority',
        createdAt: now,
        tags: const ['project', 'maxie'],
      ),
    ];
  }
}
