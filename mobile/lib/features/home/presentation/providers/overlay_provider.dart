import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OverlayState {
  final bool isEnabled;
  final Offset position;
  final double size;
  final double transparency;
  final bool isLocked;

  OverlayState({
    this.isEnabled = false,
    this.position = const Offset(100, 100),
    this.size = 80,
    this.transparency = 0.9,
    this.isLocked = false,
  });

  OverlayState copyWith({
    bool? isEnabled,
    Offset? position,
    double? size,
    double? transparency,
    bool? isLocked,
  }) {
    return OverlayState(
      isEnabled: isEnabled ?? this.isEnabled,
      position: position ?? this.position,
      size: size ?? this.size,
      transparency: transparency ?? this.transparency,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

class OverlayNotifier extends StateNotifier<OverlayState> {
  OverlayNotifier() : super(OverlayState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox('maxie_settings');
    final isEnabled = box.get('overlayEnabled', defaultValue: false);
    final size = box.get('overlaySize', defaultValue: 80.0);
    final transparency = box.get('overlayTransparency', defaultValue: 0.9);
    
    state = state.copyWith(
      isEnabled: isEnabled,
      size: size,
      transparency: transparency,
    );
  }

  Future<void> _saveSettings() async {
    final box = await Hive.openBox('maxie_settings');
    await box.put('overlayEnabled', state.isEnabled);
    await box.put('overlaySize', state.size);
    await box.put('overlayTransparency', state.transparency);
  }

  void toggleOverlay() {
    state = state.copyWith(isEnabled: !state.isEnabled);
    _saveSettings();
  }

  void updatePosition(Offset newPosition) {
    if (!state.isLocked) {
      state = state.copyWith(position: newPosition);
    }
  }

  void updateSize(double newSize) {
    state = state.copyWith(size: newSize);
    _saveSettings();
  }

  void updateTransparency(double newTransparency) {
    state = state.copyWith(transparency: newTransparency);
    _saveSettings();
  }

  void toggleLock() {
    state = state.copyWith(isLocked: !state.isLocked);
  }
}

final overlayProvider =
    StateNotifierProvider<OverlayNotifier, OverlayState>((ref) {
  return OverlayNotifier();
});
