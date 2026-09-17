import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maxie_mobile/features/auth/domain/models/user_profile.dart';

class UserProfileRepository {
  UserProfileRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _document(String uid) =>
      _firestore.collection('users').doc(uid);

  Future<UserProfile> ensureProfile(User user) async {
    final ref = _document(user.uid);
    final snapshot = await ref.get();
    if (!snapshot.exists) {
      final now = DateTime.now();
      final profile = UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        createdAt: now,
        updatedAt: now,
      );
      await ref.set(profile.toFirestore());
      return profile;
    }

    await ref.set({
      'email': user.email ?? '',
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return UserProfile.fromDocument(await ref.get());
  }

  Stream<UserProfile?> watchProfile(String uid) {
    return _document(uid).snapshots().map(
      (snapshot) => snapshot.exists ? UserProfile.fromDocument(snapshot) : null,
    );
  }

  Future<void> updateProfile(
    String uid, {
    String? displayName,
    String? maxieName,
    String? maxiePersonality,
  }) {
    return _document(uid).set({
      if (displayName != null) 'displayName': displayName.trim(),
      if (maxieName != null) 'maxieName': maxieName.trim(),
      if (maxiePersonality != null) 'maxiePersonality': maxiePersonality,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
