import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsState {
  final double maxieSize;
  final double overlayTransparency;
  final String animationSpeed;
  final bool overlayEnabled;
  final bool overlayLocked;
  final bool voiceEnabled;
  final bool speechToTextEnabled;
  final bool soundEffectsEnabled;
  final String aiProvider;
  final String apiKey;
  final bool offlineMode;
  final bool notificationReactionsEnabled;
  final bool callReactionsEnabled;
  final String theme;
  final String maxieTheme;

  SettingsState({
    this.maxieSize = 1.0,
    this.overlayTransparency = 0.9,
    this.animationSpeed = 'normal',
    this.overlayEnabled = false,
    this.overlayLocked = false,
    this.voiceEnabled = false,
    this.speechToTextEnabled = false,
    this.soundEffectsEnabled = true,
    this.aiProvider = 'Gemini',
    this.apiKey = '',
    this.offlineMode = true,
    this.notificationReactionsEnabled = true,
    this.callReactionsEnabled = true,
    this.theme = 'system',
    this.maxieTheme = 'default',
  });

  SettingsState copyWith({
    double? maxieSize,
    double? overlayTransparency,
    String? animationSpeed,
    bool? overlayEnabled,
    bool? overlayLocked,
    bool? voiceEnabled,
    bool? speechToTextEnabled,
    bool? soundEffectsEnabled,
    String? aiProvider,
    String? apiKey,
    bool? offlineMode,
    bool? notificationReactionsEnabled,
    bool? callReactionsEnabled,
    String? theme,
    String? maxieTheme,
  }) {
    return SettingsState(
      maxieSize: maxieSize ?? this.maxieSize,
      overlayTransparency: overlayTransparency ?? this.overlayTransparency,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      overlayEnabled: overlayEnabled ?? this.overlayEnabled,
      overlayLocked: overlayLocked ?? this.overlayLocked,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      speechToTextEnabled: speechToTextEnabled ?? this.speechToTextEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      aiProvider: aiProvider ?? this.aiProvider,
      apiKey: apiKey ?? this.apiKey,
      offlineMode: offlineMode ?? this.offlineMode,
      notificationReactionsEnabled: notificationReactionsEnabled ?? this.notificationReactionsEnabled,
      callReactionsEnabled: callReactionsEnabled ?? this.callReactionsEnabled,
      theme: theme ?? this.theme,
      maxieTheme: maxieTheme ?? this.maxieTheme,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox('maxie_settings');
    
    state = SettingsState(
      maxieSize: box.get('maxieSize', defaultValue: 1.0),
      overlayTransparency: box.get('overlayTransparency', defaultValue: 0.9),
      animationSpeed: box.get('animationSpeed', defaultValue: 'normal'),
      overlayEnabled: box.get('overlayEnabled', defaultValue: false),
      overlayLocked: box.get('overlayLocked', defaultValue: false),
      voiceEnabled: box.get('voiceEnabled', defaultValue: false),
      speechToTextEnabled: box.get('speechToTextEnabled', defaultValue: false),
      soundEffectsEnabled: box.get('soundEffectsEnabled', defaultValue: true),
      aiProvider: box.get('aiProvider', defaultValue: 'Gemini'),
      apiKey: box.get('apiKey', defaultValue: ''),
      offlineMode: box.get('offlineMode', defaultValue: true),
      notificationReactionsEnabled: box.get('notificationReactionsEnabled', defaultValue: true),
      callReactionsEnabled: box.get('callReactionsEnabled', defaultValue: true),
      theme: box.get('theme', defaultValue: 'system'),
      maxieTheme: box.get('maxieTheme', defaultValue: 'default'),
    );
  }

  Future<void> _saveSettings() async {
    final box = await Hive.openBox('maxie_settings');
    
    await box.put('maxieSize', state.maxieSize);
    await box.put('overlayTransparency', state.overlayTransparency);
    await box.put('animationSpeed', state.animationSpeed);
    await box.put('overlayEnabled', state.overlayEnabled);
    await box.put('overlayLocked', state.overlayLocked);
    await box.put('voiceEnabled', state.voiceEnabled);
    await box.put('speechToTextEnabled', state.speechToTextEnabled);
    await box.put('soundEffectsEnabled', state.soundEffectsEnabled);
    await box.put('aiProvider', state.aiProvider);
    await box.put('apiKey', state.apiKey);
    await box.put('offlineMode', state.offlineMode);
    await box.put('notificationReactionsEnabled', state.notificationReactionsEnabled);
    await box.put('callReactionsEnabled', state.callReactionsEnabled);
    await box.put('theme', state.theme);
    await box.put('maxieTheme', state.maxieTheme);
  }

  void updateMaxieSize(double size) {
    state = state.copyWith(maxieSize: size);
    _saveSettings();
  }

  void updateOverlayTransparency(double transparency) {
    state = state.copyWith(overlayTransparency: transparency);
    _saveSettings();
  }

  void updateAnimationSpeed(String speed) {
    state = state.copyWith(animationSpeed: speed);
    _saveSettings();
  }

  void toggleOverlay(bool enabled) {
    state = state.copyWith(overlayEnabled: enabled);
    _saveSettings();
  }

  void toggleOverlayLock(bool locked) {
    state = state.copyWith(overlayLocked: locked);
    _saveSettings();
  }

  void toggleVoice(bool enabled) {
    state = state.copyWith(voiceEnabled: enabled);
    _saveSettings();
  }

  void toggleSpeechToText(bool enabled) {
    state = state.copyWith(speechToTextEnabled: enabled);
    _saveSettings();
  }

  void toggleSoundEffects(bool enabled) {
    state = state.copyWith(soundEffectsEnabled: enabled);
    _saveSettings();
  }

  void updateApiKey(String key) {
    state = state.copyWith(apiKey: key);
    _saveSettings();
  }

  void toggleOfflineMode(bool enabled) {
    state = state.copyWith(offlineMode: enabled);
    _saveSettings();
  }

  void toggleNotificationReactions(bool enabled) {
    state = state.copyWith(notificationReactionsEnabled: enabled);
    _saveSettings();
  }

  void toggleCallReactions(bool enabled) {
    state = state.copyWith(callReactionsEnabled: enabled);
    _saveSettings();
  }

  void updateTheme(String theme) {
    state = state.copyWith(theme: theme);
    _saveSettings();
  }

  Future<void> clearChatHistory() async {
    final box = await Hive.openBox('maxie_memory');
    await box.delete('chatHistory');
  }

  Future<void> resetMaxie() async {
    // Clear all data
    final settingsBox = await Hive.openBox('maxie_settings');
    final memoryBox = await Hive.openBox('maxie_memory');
    final friendshipBox = await Hive.openBox('maxie_friendship');
    final emotionsBox = await Hive.openBox('maxie_emotions');

    await settingsBox.clear();
    await memoryBox.clear();
    await friendshipBox.clear();
    await emotionsBox.clear();

    // Reset to default state
    state = SettingsState();
    await _saveSettings();
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
