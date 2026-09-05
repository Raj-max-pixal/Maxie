import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceSyncState {
  final String activeDevice;
  final String status;
  final String petType;
  final String petName;

  const DeviceSyncState({
    this.activeDevice = 'desktop',
    this.status = 'idle',
    this.petType = 'maxie',
    this.petName = 'MAXie',
  });

  DeviceSyncState copyWith({
    String? activeDevice,
    String? status,
    String? petType,
    String? petName,
  }) {
    return DeviceSyncState(
      activeDevice: activeDevice ?? this.activeDevice,
      status: status ?? this.status,
      petType: petType ?? this.petType,
      petName: petName ?? this.petName,
    );
  }
}

class DeviceSyncService extends StateNotifier<DeviceSyncState> {
  DeviceSyncService() : super(const DeviceSyncState()) {
    _listenToSyncDoc();
  }

  StreamSubscription? _subscription;

  void _listenToSyncDoc() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ?? 'offline_dev_user_123';

      _subscription = FirebaseFirestore.instance
          .collection('device_sync')
          .doc(uid)
          .snapshots()
          .listen((doc) {
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          state = DeviceSyncState(
            activeDevice: data['activeDevice'] ?? 'desktop',
            status: data['status'] ?? 'idle',
            petType: data['petType'] ?? 'maxie',
            petName: data['petName'] ?? 'MAXie',
          );
        }
      }, onError: (e) {
        debugPrint('DeviceSync: Listen error: $e');
      });
    } catch (e) {
      debugPrint('DeviceSync: Listen initialization error: $e');
    }
  }

  Future<void> summonPetFromPC() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'offline_dev_user_123';
    
    try {
      await FirebaseFirestore.instance.collection('device_sync').doc(uid).set({
        'activeDevice': 'mobile',
        'status': 'traveling',
        'petType': 'maxie',
        'petName': 'MAXie',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('DeviceSync: Failed to summon: $e');
      // Offline fallback: simulate traveling state locally
      state = state.copyWith(
        activeDevice: 'mobile',
        status: 'traveling',
      );
    }
  }

  Future<void> sendPetToPC() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'offline_dev_user_123';

    try {
      await FirebaseFirestore.instance.collection('device_sync').doc(uid).set({
        'activeDevice': 'desktop',
        'status': 'traveling',
        'petType': 'maxie',
        'petName': 'MAXie',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('DeviceSync: Failed to send to PC: $e');
      // Offline fallback: simulate traveling to desktop locally
      state = state.copyWith(
        activeDevice: 'desktop',
        status: 'traveling',
      );
    }
  }

  Future<void> markArrived() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'offline_dev_user_123';

    try {
      await FirebaseFirestore.instance.collection('device_sync').doc(uid).update({
        'status': 'arrived',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('DeviceSync: Failed to mark arrived: $e');
      state = state.copyWith(status: 'arrived');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final deviceSyncServiceProvider =
    StateNotifierProvider<DeviceSyncService, DeviceSyncState>((ref) {
  return DeviceSyncService();
});
