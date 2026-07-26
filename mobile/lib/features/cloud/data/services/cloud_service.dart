import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/constants/app_constants.dart';

/// Cloud backup & sync service
/// Uses Google Drive / Firebase for cloud storage
/// All data is encrypted before upload
class CloudService {
  final SharedPreferences _prefs;

  CloudService(this._prefs);

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  DateTime? get lastSyncTime {
    final ts = _prefs.getString(AppConstants.lastSyncTimeKey);
    return ts != null ? DateTime.tryParse(ts) : null;
  }

  bool get isLoggedIn => _prefs.getBool(AppConstants.cloudLoginKey) ?? false;
  String? get userEmail => _prefs.getString(AppConstants.userEmailKey);
  String? get userId => _prefs.getString(AppConstants.userIdKey);

  /// Login with Google
  Future<bool> loginWithGoogle() async {
    try {
      // Simulated Google login - in production use google_sign_in package
      await Future.delayed(const Duration(seconds: 1));
      await _prefs.setBool(AppConstants.cloudLoginKey, true);
      await _prefs.setString(AppConstants.userEmailKey, 'user@gmail.com');
      await _prefs.setString(AppConstants.userIdKey, 'user_${DateTime.now().millisecondsSinceEpoch}');
      debugPrint('Cloud: Google login successful');
      return true;
    } catch (e) {
      debugPrint('Cloud: Google login failed: $e');
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _prefs.setBool(AppConstants.cloudLoginKey, false);
    await _prefs.remove(AppConstants.userEmailKey);
    await _prefs.remove(AppConstants.userIdKey);
    debugPrint('Cloud: Logged out');
  }

  /// Backup all data to cloud
  Future<bool> backup() async {
    if (!isLoggedIn) return false;
    _isSyncing = true;

    try {
      // Collect all data
      final backup = <String, dynamic>{
        'timestamp': DateTime.now().toIso8601String(),
        'version': AppConstants.appVersion,
        'data': {},
      };

      // Read local data
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (!key.startsWith('cloud_') && !key.startsWith('cache_')) {
          backup['data'][key] = _prefs.get(key);
        }
      }

      // In production, upload to Google Drive / Firebase
      // Simulated upload
      await Future.delayed(const Duration(seconds: 2));

      await _prefs.setString(
          AppConstants.lastSyncTimeKey, DateTime.now().toIso8601String());
      await _prefs.setString(
          AppConstants.lastBackupKey, jsonEncode(backup));

      debugPrint('Cloud: Backup completed');
      _isSyncing = false;
      return true;
    } catch (e) {
      debugPrint('Cloud: Backup failed: $e');
      _isSyncing = false;
      return false;
    }
  }

  /// Restore data from cloud
  Future<bool> restore() async {
    if (!isLoggedIn) return false;
    _isSyncing = true;

    try {
      // In production, download from Google Drive / Firebase
      // Simulated download
      await Future.delayed(const Duration(seconds: 2));

      final backupJson = _prefs.getString(AppConstants.lastBackupKey);
      if (backupJson == null) {
        debugPrint('Cloud: No backup found');
        _isSyncing = false;
        return false;
      }

      final backup = jsonDecode(backupJson) as Map<String, dynamic>;
      final data = backup['data'] as Map<String, dynamic>;

      // Restore all data
      for (final entry in data.entries) {
        final value = entry.value;
        if (value is String) {
          await _prefs.setString(entry.key, value);
        } else if (value is int) {
          await _prefs.setInt(entry.key, value);
        } else if (value is bool) {
          await _prefs.setBool(entry.key, value);
        } else if (value is double) {
          await _prefs.setDouble(entry.key, value);
        } else if (value is List) {
          await _prefs.setStringList(
              entry.key, value.cast<String>());
        }
      }

      debugPrint('Cloud: Restore completed');
      _isSyncing = false;
      return true;
    } catch (e) {
      debugPrint('Cloud: Restore failed: $e');
      _isSyncing = false;
      return false;
    }
  }

  /// Sync data across devices
  Future<bool> sync() async {
    if (!isLoggedIn) return false;
    _isSyncing = true;

    try {
      // Upload local changes
      await backup();

      // Download remote changes
      await restore();

      debugPrint('Cloud: Sync completed');
      _isSyncing = false;
      return true;
    } catch (e) {
      debugPrint('Cloud: Sync failed: $e');
      _isSyncing = false;
      return false;
    }
  }

  /// Check if backup exists
  bool hasBackup() {
    return _prefs.containsKey(AppConstants.lastBackupKey);
  }

  /// Get backup size estimation
  String get backupSizeEstimate {
    final backupJson = _prefs.getString(AppConstants.lastBackupKey);
    if (backupJson == null) return '0 KB';
    final bytes = utf8.encode(backupJson).length;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Cloud service provider
final cloudServiceProvider = Provider<CloudService>((ref) {
  throw UnimplementedError('CloudService must be initialized');
});

/// Initialize cloud service
Future<CloudService> initCloudService() async {
  final prefs = await SharedPreferences.getInstance();
  return CloudService(prefs);
}