import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FloatingWidget {
  final String id;
  final String type;
  final Offset position;
  final double size;
  final bool isVisible;
  final bool isLocked;

  FloatingWidget({
    required this.id,
    required this.type,
    required this.position,
    this.size = 80,
    this.isVisible = true,
    this.isLocked = false,
  });

  FloatingWidget copyWith({
    Offset? position,
    double? size,
    bool? isVisible,
    bool? isLocked,
  }) {
    return FloatingWidget(
      id: id,
      type: type,
      position: position ?? this.position,
      size: size ?? this.size,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

class OverlayState {
  final bool isEnabled;
  final double transparency;
  final List<FloatingWidget> widgets;

  OverlayState({
    this.isEnabled = false,
    this.transparency = 0.9,
    List<FloatingWidget>? widgets,
  }) : widgets = widgets ?? _getDefaultWidgets();

  static List<FloatingWidget> _getDefaultWidgets() {
    return [
      FloatingWidget(
        id: 'maxie_character',
        type: 'character',
        position: const Offset(100, 100),
        size: 100,
      ),
      FloatingWidget(
        id: 'quick_actions',
        type: 'quick_actions',
        position: const Offset(100, 220),
        size: 60,
      ),
      FloatingWidget(
        id: 'status_bar',
        type: 'status_bar',
        position: const Offset(0, 0),
        size: 40,
      ),
      FloatingWidget(
        id: 'music_player',
        type: 'music_player',
        position: const Offset(100, 320),
        size: 60,
        isVisible: true,
      ),
      FloatingWidget(
        id: 'pomodoro_timer',
        type: 'pomodoro_timer',
        position: const Offset(100, 400),
        size: 60,
        isVisible: true,
      ),
    ];
  }

  OverlayState copyWith({
    bool? isEnabled,
    double? transparency,
    List<FloatingWidget>? widgets,
  }) {
    return OverlayState(
      isEnabled: isEnabled ?? this.isEnabled,
      transparency: transparency ?? this.transparency,
      widgets: widgets ?? this.widgets,
    );
  }

  FloatingWidget? getWidget(String id) {
    try {
      return widgets.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }
}

class OverlayNotifier extends StateNotifier<OverlayState> {
  OverlayNotifier() : super(OverlayState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox('maxie_settings');
    final isEnabled = box.get('overlayEnabled', defaultValue: false);
    final transparency = box.get('overlayTransparency', defaultValue: 0.9);
    
    state = state.copyWith(
      isEnabled: isEnabled,
      transparency: transparency,
    );
  }

  Future<void> _saveSettings() async {
    final box = await Hive.openBox('maxie_settings');
    await box.put('overlayEnabled', state.isEnabled);
    await box.put('overlayTransparency', state.transparency);
    
    // Save widget positions
    for (final widget in state.widgets) {
      await box.put('widget_${widget.id}_x', widget.position.dx);
      await box.put('widget_${widget.id}_y', widget.position.dy);
      await box.put('widget_${widget.id}_visible', widget.isVisible);
    }
  }

  void toggleOverlay() {
    state = state.copyWith(isEnabled: !state.isEnabled);
    _saveSettings();
  }

  void updateWidgetPosition(String widgetId, Offset newPosition) {
    final widget = state.getWidget(widgetId);
    if (widget != null && !widget.isLocked) {
      final updatedWidgets = state.widgets.map((w) {
        if (w.id == widgetId) {
          return w.copyWith(position: newPosition);
        }
        return w;
      }).toList();
      state = state.copyWith(widgets: updatedWidgets);
      _saveSettings();
    }
  }

  void updateWidgetSize(String widgetId, double newSize) {
    final updatedWidgets = state.widgets.map((w) {
      if (w.id == widgetId) {
        return w.copyWith(size: newSize);
      }
      return w;
    }).toList();
    state = state.copyWith(widgets: updatedWidgets);
    _saveSettings();
  }

  void toggleWidgetVisibility(String widgetId) {
    final updatedWidgets = state.widgets.map((w) {
      if (w.id == widgetId) {
        return w.copyWith(isVisible: !w.isVisible);
      }
      return w;
    }).toList();
    state = state.copyWith(widgets: updatedWidgets);
    _saveSettings();
  }

  void toggleWidgetLock(String widgetId) {
    final updatedWidgets = state.widgets.map((w) {
      if (w.id == widgetId) {
        return w.copyWith(isLocked: !w.isLocked);
      }
      return w;
    }).toList();
    state = state.copyWith(widgets: updatedWidgets);
    _saveSettings();
  }

  void updateTransparency(double newTransparency) {
    state = state.copyWith(transparency: newTransparency);
    _saveSettings();
  }

  void addWidget(FloatingWidget widget) {
    final updatedWidgets = [...state.widgets, widget];
    state = state.copyWith(widgets: updatedWidgets);
    _saveSettings();
  }

  void removeWidget(String widgetId) {
    final updatedWidgets = state.widgets.where((w) => w.id != widgetId).toList();
    state = state.copyWith(widgets: updatedWidgets);
    _saveSettings();
  }
}

final overlayProvider =
    StateNotifierProvider<OverlayNotifier, OverlayState>((ref) {
  return OverlayNotifier();
});
