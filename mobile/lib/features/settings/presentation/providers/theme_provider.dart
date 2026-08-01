import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeState {
  final ThemeMode themeMode;
  final bool useMaterial3;
  final Color seedColor;
  final double borderRadius;
  final bool useAnimations;

  const ThemeState({
    this.themeMode = ThemeMode.system,
    this.useMaterial3 = true,
    this.seedColor = const Color(0xFF6C63FF),
    this.borderRadius = 20.0,
    this.useAnimations = true,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? useMaterial3,
    Color? seedColor,
    double? borderRadius,
    bool? useAnimations,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      seedColor: seedColor ?? this.seedColor,
      borderRadius: borderRadius ?? this.borderRadius,
      useAnimations: useAnimations ?? this.useAnimations,
    );
  }

  bool get isDark => themeMode == ThemeMode.dark;
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final box = await Hive.openBox('maxie_settings');
      final themeModeStr = box.get('themeMode', defaultValue: 'system');
      final useMaterial3 = box.get('useMaterial3', defaultValue: true) as bool;
      final seedColorInt = box.get('seedColor', defaultValue: 0xFF6C63FF) as int;
      final borderRadius = box.get('borderRadius', defaultValue: 20.0) as double;
      final useAnimations = box.get('useAnimations', defaultValue: true) as bool;

      ThemeMode themeMode;
      switch (themeModeStr) {
        case 'light':
          themeMode = ThemeMode.light;
          break;
        case 'dark':
          themeMode = ThemeMode.dark;
          break;
        default:
          themeMode = ThemeMode.system;
      }

      state = ThemeState(
        themeMode: themeMode,
        useMaterial3: useMaterial3,
        seedColor: Color(seedColorInt),
        borderRadius: borderRadius,
        useAnimations: useAnimations,
      );
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    try {
      final box = await Hive.openBox('maxie_settings');
      await box.put('themeMode', mode.name);
    } catch (_) {}
  }

  Future<void> toggleDarkMode() async {
    final newMode = state.isDark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  Future<void> setSeedColor(Color color) async {
    state = state.copyWith(seedColor: color);
    try {
      final box = await Hive.openBox('maxie_settings');
      await box.put('seedColor', color.value);
    } catch (_) {}
  }
}

final themeStateProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeStateProvider).themeMode;
});

final appThemeProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(themeStateProvider);
  return _buildTheme(themeState);
});

final darkThemeProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(themeStateProvider);
  return _buildDarkTheme(themeState);
});

ThemeData _buildTheme(ThemeState state) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: state.seedColor,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: state.useMaterial3,
    colorScheme: colorScheme,
    brightness: Brightness.light,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(state.borderRadius),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      backgroundColor: colorScheme.surface.withOpacity(0.8),
    ),
  );
}

ThemeData _buildDarkTheme(ThemeState state) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: state.seedColor,
    brightness: Brightness.dark,
  );

  return ThemeData(
    useMaterial3: state.useMaterial3,
    colorScheme: colorScheme,
    brightness: Brightness.dark,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(state.borderRadius),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      backgroundColor: colorScheme.surface.withOpacity(0.8),
    ),
  );
}