import 'package:maxie_mobile/config/app_constants.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_service.dart';
import 'package:maxie_mobile/services/storage/storage_service.dart';

class HiveMemoryBrainRepository implements MemoryRepository {
  const HiveMemoryBrainRepository(this._storage);

  static const String _memoriesKey = 'memory_brain_items';

  final StorageService _storage;

  @override
  Future<void> clearMemories() {
    return _storage.delete(AppConstants.hiveMemoryBox, _memoriesKey);
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
      _memoriesKey,
    );
    if (data == null) {
      return _seedMemories();
    }
    return [
      for (final item in data)
        MemoryModel.fromJson(item as Map<dynamic, dynamic>),
    ];
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

  Future<void> _write(List<MemoryModel> memories) {
    return _storage.write<List<Map<String, Object?>>>(
      AppConstants.hiveMemoryBox,
      _memoriesKey,
      memories.map((memory) => memory.toJson()).toList(),
    );
  }

  List<MemoryModel> _seedMemories() {
    final now = DateTime.now();
    return [
      MemoryModel(
        id: 'seed-project-maxie',
        category: MemoryCategory.projects,
        title: 'Current Project',
        value: 'You are building MAXie Mobile for the Shipathon demo.',
        createdAt: now,
        updatedAt: now,
        priority: MemoryPriority.high,
        importance: 0.95,
        tags: const ['maxie', 'shipathon', 'flutter'],
        isPinned: true,
      ),
      MemoryModel(
        id: 'seed-skill-flutter',
        category: MemoryCategory.skills,
        title: 'Flutter',
        value: 'You are building with Flutter and a clean feature structure.',
        createdAt: now,
        updatedAt: now,
        priority: MemoryPriority.high,
        importance: 0.9,
        tags: const ['flutter', 'clean-architecture'],
      ),
      MemoryModel(
        id: 'seed-goal-shipaton',
        category: MemoryCategory.goals,
        title: 'Current Goal',
        value: 'Win Shipathon with a focused AI companion demo.',
        createdAt: now,
        updatedAt: now,
        priority: MemoryPriority.critical,
        importance: 1,
        tags: const ['goal', 'shipathon'],
        isPinned: true,
      ),
    ];
  }
}
