import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:maxie_mobile/core/config/firebase_options.dart';
import 'package:maxie_mobile/services/storage/hive_storage_service.dart';

class AppBootstrap {
  const AppBootstrap._();

  static bool firebaseReady = false;
  static Object? firebaseError;

  static Future<void> initialize() async {
    await HiveStorageService.initialize();
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseReady = true;
    } catch (error) {
      firebaseError = error;
      debugPrint('Firebase initialization failed: $error');
    }
  }
}
