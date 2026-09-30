import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maxie_mobile/core/app_bootstrap.dart';
import 'package:maxie_mobile/features/pet/data/hive_pet_repository.dart';
import 'package:maxie_mobile/features/pet/domain/models/pet_state.dart';
import 'package:maxie_mobile/features/pet/domain/repositories/pet_repository.dart';

class ScopedPetRepository implements PetRepository {
  ScopedPetRepository(this._local, {FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final HivePetRepository _local;
  final FirebaseFirestore _firestore;

  String? get _uid => AppBootstrap.firebaseReady
      ? FirebaseAuth.instance.currentUser?.uid
      : null;

  DocumentReference<Map<String, dynamic>>? get _remote {
    final uid = _uid;
    return uid == null
        ? null
        : _firestore
              .collection('users')
              .doc(uid)
              .collection('petState')
              .doc('main');
  }

  @override
  Future<PetState> readPet() async {
    final remote = _remote;
    if (remote == null) return _local.readPet();
    try {
      final snapshot = await remote.get();
      if (snapshot.exists && snapshot.data() != null) {
        final state = PetState.fromJson(snapshot.data()!);
        await _local.savePet(state);
        return state;
      }
    } catch (_) {}
    return _local.readPet();
  }

  @override
  Future<void> savePet(PetState state) async {
    await _local.savePet(state);
    final remote = _remote;
    if (remote == null) return;
    try {
      await remote.set(state.toJson(), SetOptions(merge: true));
    } catch (_) {}
  }
}
