import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:maxie_mobile/core/app_bootstrap.dart';

class AuthService extends ChangeNotifier {
  AuthService() {
    if (!AppBootstrap.firebaseReady) {
      _ready = true;
      return;
    }
    _auth = FirebaseAuth.instance;
    _subscription = _auth!.authStateChanges().listen((user) {
      _user = user;
      _ready = true;
      notifyListeners();
    });
  }

  FirebaseAuth? _auth;
  StreamSubscription<User?>? _subscription;
  User? _user;
  bool _ready = false;

  bool get isReady => _ready;
  bool get isConfigured => _auth != null;
  User? get user => _user ?? _auth?.currentUser;
  Object? get configurationError => AppBootstrap.firebaseError;

  Future<UserCredential> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _requireAuth().createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (displayName != null && displayName.trim().isNotEmpty) {
      await credential.user?.updateDisplayName(displayName.trim());
      await credential.user?.reload();
      _user = _auth?.currentUser;
      notifyListeners();
    }
    return credential;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _requireAuth().signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordReset(String email) {
    return _requireAuth().sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await _requireAuth().signOut();
  }

  FirebaseAuth _requireAuth() {
    final auth = _auth;
    if (auth == null) {
      throw StateError(
        'Firebase is not configured. Add valid FlutterFire configuration before using authentication.',
      );
    }
    return auth;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
