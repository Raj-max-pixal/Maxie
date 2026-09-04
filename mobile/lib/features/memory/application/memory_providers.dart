import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/memory/data/hive_memory_repository.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_entry.dart';
import 'package:maxie_mobile/features/memory/domain/repositories/memory_repository.dart';
import 'package:maxie_mobile/services/storage/storage_providers.dart';

final memoryRepositoryProvider = Provider<MemoryRepository>(
  (ref) => HiveMemoryRepository(ref.watch(storageServiceProvider)),
);

final memoryListProvider = FutureProvider<List<MemoryEntry>>((ref) {
  return ref.watch(memoryRepositoryProvider).readMemories();
});
