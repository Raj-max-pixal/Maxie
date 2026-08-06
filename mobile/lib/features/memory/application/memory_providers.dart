import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/ai_chat/application/conversation_repository_provider.dart';
import 'package:maxie_mobile/features/memory/application/memory_manager.dart';
import 'package:maxie_mobile/features/memory/data/placeholder_memory_repository.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/repositories/memory_repository.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_service.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_service_impl.dart';
import 'package:maxie_mobile/services/storage/storage_providers.dart';

final memoryRepositoryProvider = Provider<MemoryRepository>(
  (ref) => HiveMemoryRepository(ref.watch(storageServiceProvider)),
);

final memoryBrainServiceProvider = Provider<MemoryService>((ref) {
  return DefaultMemoryService(
    memoryRepository: ref.watch(memoryRepositoryProvider),
    conversationRepository: ref.watch(conversationRepositoryProvider),
  );
});

final memoryManagerProvider =
    StateNotifierProvider<MemoryManager, MemoryBrainState>((ref) {
      final manager = MemoryManager(
        service: ref.watch(memoryBrainServiceProvider),
      );
      Future<void>.microtask(manager.load);
      return manager;
    });

final memoryListProvider = FutureProvider<List<MemoryRecord>>((ref) {
  return ref.watch(memoryRepositoryProvider).readMemories();
});
