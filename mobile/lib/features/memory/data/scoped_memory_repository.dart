import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maxie_mobile/core/app_bootstrap.dart';
import 'package:maxie_mobile/features/memory/data/hive_memory_brain_repository.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/memory/domain/services/memory_service.dart';

class ScopedMemoryRepository implements MemoryRepository {
  ScopedMemoryRepository(
    this._local, {
    this.requireAuthentication = false,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final HiveMemoryBrainRepository _local;
  final bool requireAuthentication;
  final FirebaseFirestore _firestore;

  String? get _uid => AppBootstrap.firebaseReady
      ? FirebaseAuth.instance.currentUser?.uid
      : null;

  CollectionReference<Map<String, dynamic>>? get _remote {
    final uid = _uid;
    return uid == null
        ? null
        : _firestore.collection('users').doc(uid).collection('memories');
  }

  @override
  Future<List<MemoryModel>> readMemories() async {
    if (requireAuthentication && _uid == null) return const [];
    final remote = _remote;
    if (remote == null) return _local.readMemories();
    try {
      final snapshot = await remote
          .orderBy('updatedAt', descending: true)
          .get();
      final memories = snapshot.docs.map(_fromDocument).toList();
      await _local.replaceMemories(memories);
      return memories;
    } catch (_) {
      return _local.readMemories();
    }
  }

  @override
  Future<void> saveMemory(MemoryModel memory) async {
    if (requireAuthentication && _uid == null) return;
    final scoped = memory.copyWith(userId: _uid);
    await _local.saveMemory(scoped);
    final remote = _remote;
    if (remote != null) {
      try {
        await remote
            .doc(scoped.id)
            .set(_toDocument(scoped), SetOptions(merge: true));
      } catch (_) {}
    }
  }

  @override
  Future<void> deleteMemory(String id) => forgetMemory(id);

  @override
  Future<void> clearMemories() async {
    if (requireAuthentication && _uid == null) return;
    final memories = await readMemories();
    for (final memory in memories) {
      await forgetMemory(memory.id);
    }
  }

  @override
  Future<MemoryModel?> getMemory(String id) async {
    if (requireAuthentication && _uid == null) return null;
    final memories = await readMemories();
    for (final memory in memories) {
      if (memory.id == id && memory.isActive) return memory;
    }
    return null;
  }

  @override
  Future<List<MemoryModel>> searchMemories(String query) async {
    final memories = await readMemories();
    final normalized = query.trim().toLowerCase();
    return memories.where((memory) {
      return memory.isActive &&
          (normalized.isEmpty ||
              memory.title.toLowerCase().contains(normalized) ||
              memory.value.toLowerCase().contains(normalized) ||
              memory.tags.any((tag) => tag.toLowerCase().contains(normalized)));
    }).toList();
  }

  @override
  Future<List<MemoryModel>> retrieveRelevantMemories(String query) async {
    final results = await searchMemories(query);
    results.sort((left, right) {
      final pinned = (right.isPinned ? 1 : 0).compareTo(left.isPinned ? 1 : 0);
      if (pinned != 0) return pinned;
      final importance = right.importance.compareTo(left.importance);
      if (importance != 0) return importance;
      return right.updatedAt.compareTo(left.updatedAt);
    });
    return results.take(8).toList();
  }

  Future<void> forgetMemory(String id) async {
    final memory = await getMemory(id);
    if (memory == null) return;
    final forgotten = memory.copyWith(
      isActive: false,
      isArchived: true,
      updatedAt: DateTime.now(),
    );
    await _local.saveMemory(forgotten);
    final remote = _remote;
    if (remote != null) {
      try {
        await remote
            .doc(id)
            .set(_toDocument(forgotten), SetOptions(merge: true));
      } catch (_) {}
    }
  }

  MemoryModel _fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    return MemoryModel.fromJson({...data, 'id': document.id});
  }

  Map<String, Object?> _toDocument(MemoryModel memory) => memory.toJson();
}
