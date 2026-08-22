import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppItem {
  final String id;
  final String name;
  final IconData icon;
  final Offset position;
  final String route;

  AppItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.position,
    required this.route,
  });

  AppItem copyWith({
    Offset? position,
  }) {
    return AppItem(
      id: id,
      name: name,
      icon: icon,
      position: position ?? this.position,
      route: route,
    );
  }
}

class AppsState {
  final List<AppItem> apps;
  final bool hasLoaded;

  AppsState({
    required this.apps,
    this.hasLoaded = false,
  });

  AppsState copyWith({
    List<AppItem>? apps,
    bool? hasLoaded,
  }) {
    return AppsState(
      apps: apps ?? this.apps,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

class AppsNotifier extends StateNotifier<AppsState> {
  AppsNotifier() : super(AppsState(apps: _getDefaultApps())) {
    _loadPositions();
  }

  static List<AppItem> _getDefaultApps() {
    return [
      AppItem(
        id: 'chat',
        name: 'Chat AI',
        icon: Icons.chat_bubble_rounded,
        position: const Offset(40, 120),
        route: '/chat',
      ),
      AppItem(
        id: 'games',
        name: 'Games',
        icon: Icons.sports_esports_rounded,
        position: const Offset(160, 120),
        route: '/games_tab', // handled in Home Page navigation
      ),
      AppItem(
        id: 'care',
        name: 'Care & Play',
        icon: Icons.favorite_rounded,
        position: const Offset(280, 120),
        route: '/care_tab',
      ),
      AppItem(
        id: 'music',
        name: 'Music Player',
        icon: Icons.music_note_rounded,
        position: const Offset(40, 240),
        route: '/music',
      ),
      AppItem(
        id: 'pomodoro',
        name: 'Focus',
        icon: Icons.timer_rounded,
        position: const Offset(160, 240),
        route: '/pomodoro',
      ),
      AppItem(
        id: 'settings',
        name: 'Settings',
        icon: Icons.settings_rounded,
        position: const Offset(280, 240),
        route: '/settings',
      ),
    ];
  }

  Future<void> _loadPositions() async {
    try {
      final box = await Hive.openBox('maxie_settings');
      final updatedApps = state.apps.map((app) {
        final x = box.get('app_${app.id}_x', defaultValue: app.position.dx) as double;
        final y = box.get('app_${app.id}_y', defaultValue: app.position.dy) as double;
        return app.copyWith(position: Offset(x, y));
      }).toList();
      state = AppsState(apps: updatedApps, hasLoaded: true);
    } catch (e) {
      // Fallback
      state = state.copyWith(hasLoaded: true);
    }
  }

  Future<void> updateAppPosition(String id, Offset newPosition) async {
    final updatedApps = state.apps.map((app) {
      if (app.id == id) {
        return app.copyWith(position: newPosition);
      }
      return app;
    }).toList();
    state = state.copyWith(apps: updatedApps);

    try {
      final box = await Hive.openBox('maxie_settings');
      await box.put('app_${id}_x', newPosition.dx);
      await box.put('app_${id}_y', newPosition.dy);
    } catch (_) {}
  }
}

final appsProvider = StateNotifierProvider<AppsNotifier, AppsState>((ref) {
  return AppsNotifier();
});
