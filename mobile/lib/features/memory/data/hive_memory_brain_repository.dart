import 'package:maxie_mobile/config/app_constants.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_service.dart';
import 'package:maxie_mobile/services/storage/storage_service.dart';

class HiveMemoryBrainRepository implements MemoryRepository {
  const HiveMemoryBrainRepository(this._storage, {this.scope = 'anonymous'});

  static const String _memoriesKey = 'memory_brain_items';

  final StorageService _storage;
  final String scope;

  String get _scopedKey => '$_memoriesKey-$scope';

  @override
  Future<void> clearMemories() {
    return _storage.delete(AppConstants.hiveMemoryBox, _scopedKey);
  }

  @override
  Future<void> deleteMemory(String id) async {
    final memories = await readMemories();
    await _write(memories.where((memory) => memory.id != id).toList());
  }

  @override
  Future<List<MemoryModel>> readMemories() async {
    final data = await _storage.read<List<dynamic>>(
      AppConstants.hiveMemoryBox,
      _scopedKey,
    );
    if (data == null) return const [];
    return [
      for (final item in data)
        MemoryModel.fromJson(item as Map<dynamic, dynamic>),
    ];
  }

  @override
  Future<MemoryModel?> getMemory(String id) async {
    final memories = await readMemories();
    for (final memory in memories) {
      if (memory.id == id && memory.isActive) return memory;
    }
    return null;
  }

  @override
  Future<List<MemoryModel>> searchMemories(String query) async {
    final normalized = query.trim().toLowerCase();
    return (await readMemories()).where((memory) {
      return memory.isActive &&
          (normalized.isEmpty ||
              memory.value.toLowerCase().contains(normalized) ||
              memory.title.toLowerCase().contains(normalized) ||
              memory.tags.any((tag) => tag.toLowerCase().contains(normalized)));
    }).toList();
  }

  @override
  Future<List<MemoryModel>> retrieveRelevantMemories(String query) {
    return searchMemories(query);
  }

  @override
  Future<void> saveMemory(MemoryModel memory) async {
    final memories = await readMemories();
    final existingIndex = memories.indexWhere((item) => item.id == memory.id);
    if (existingIndex >= 0) {
      memories[existingIndex] = memory;
    } else {
      memories.insert(0, memory);
    }
    await _write(memories);
  }

  Future<void> replaceMemories(List<MemoryModel> memories) => _write(memories);

  Future<void> _write(List<MemoryModel> memories) {
    return _storage.write<List<Map<String, Object?>>>(
      AppConstants.hiveMemoryBox,
      _scopedKey,
      memories.map((memory) => memory.toJson()).toList(),
    );
  }
}
