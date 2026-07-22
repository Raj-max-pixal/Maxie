import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:battery_plus/battery_plus.dart';

class HealthService {
  final Battery _battery = Battery();
  Timer? _reminderTimer;
  Timer? _batteryCheckTimer;
  
  // Health reminders
  DateTime? _lastWaterReminder;
  DateTime? _lastStretchReminder;
  DateTime? _lastEyeRestReminder;
  DateTime? _lastWalkReminder;
  DateTime? _lastWorkoutReminder;
  
  // Battery state
  int _currentBatteryLevel = 100;
  BatteryState _batteryState = BatteryState.full;

  int get currentBatteryLevel => _currentBatteryLevel;
  BatteryState get batteryState => _batteryState;

  Future<void> initialize() async {
    _currentBatteryLevel = await _battery.batteryLevel;
    _batteryState = await _battery.batteryState;
    
    _battery.onBatteryStateChanged.listen((state) {
      _batteryState = state;
      _handleBatteryStateChange();
    });
    
    _startHealthReminders();
    _startBatteryMonitoring();
  }

  void _startHealthReminders() {
    _reminderTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _checkAndSendReminders();
    });
  }

  void _startBatteryMonitoring() {
    _batteryCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      _currentBatteryLevel = await _battery.batteryLevel;
      _handleBatteryLevelChange();
    });
  }

  void _checkAndSendReminders() {
    final now = DateTime.now();
    
    // Water reminder (every 2 hours)
    if (_lastWaterReminder == null || 
        now.difference(_lastWaterReminder!).inHours >= 2) {
      _sendWaterReminder();
      _lastWaterReminder = now;
    }
    
    // Stretch reminder (every hour)
    if (_lastStretchReminder == null || 
        now.difference(_lastStretchReminder!).inHours >= 1) {
      _sendStretchReminder();
      _lastStretchReminder = now;
    }
    
    // Eye rest reminder (every 20 minutes of screen time)
    if (_lastEyeRestReminder == null || 
        now.difference(_lastEyeRestReminder!).inMinutes >= 20) {
      _sendEyeRestReminder();
      _lastEyeRestReminder = now;
    }
    
    // Walk reminder (every 3 hours)
    if (_lastWalkReminder == null || 
        now.difference(_lastWalkReminder!).inHours >= 3) {
      _sendWalkReminder();
      _lastWalkReminder = now;
    }
  }

  void _handleBatteryStateChange() {
    switch (_batteryState) {
      case BatteryState.charging:
        _sendChargingReaction();
        break;
      case BatteryState.discharging:
        // Handle discharging
        break;
      case BatteryState.full:
        _sendFullBatteryReaction();
        break;
      case BatteryState.unknown:
        break;
    }
  }

  void _handleBatteryLevelChange() {
    if (_currentBatteryLevel <= 20 && _batteryState == BatteryState.discharging) {
      _sendLowBatteryWarning();
    } else if (_currentBatteryLevel == 100 && _batteryState == BatteryState.charging) {
      _sendFullBatteryReaction();
    }
  }

  String _sendWaterReminder() {
    final reminders = [
      'Time to drink water! Stay hydrated! 💧',
      'Hydration break! Your body needs water! 🚰',
      'Water time! Don\'t forget to hydrate! 💙',
      'Quick water break! You\'ll feel better! 🥤',
    ];
    return reminders[(DateTime.now().millisecond) % reminders.length];
  }

  String _sendStretchReminder() {
    final reminders = [
      'Stretch break! Your body will thank you! 🧘',
      'Time to stretch! Loosen up those muscles! 🙆',
      'Stretch break! Keep your body flexible! 🤸',
      'Quick stretch! You\'ve been sitting too long! 🧘‍♂️',
    ];
    return reminders[(DateTime.now().millisecond) % reminders.length];
  }

  String _sendEyeRestReminder() {
    final reminders = [
      'Rest your eyes! Look away from the screen! 👀',
      '20-20-20 rule! Look at something 20 feet away! 🌳',
      'Eye break! Give your eyes some rest! 😌',
      'Time to rest your eyes! Blink blink blink! 👁️',
    ];
    return reminders[(DateTime.now().millisecond) % reminders.length];
  }

  String _sendWalkReminder() {
    final reminders = [
      'Time for a walk! Get those legs moving! 🚶',
      'Walking break! A short walk will refresh you! 🏃',
      'Get up and walk around! Your body needs it! 🚶‍♂️',
      'Walk time! Even 5 minutes helps! 🚶‍♀️',
    ];
    return reminders[(DateTime.now().millisecond) % reminders.length];
  }

  String _sendWorkoutReminder() {
    final reminders = [
      'Workout time! Let\'s get active! 💪',
      'Time to exercise! Your body will thank you! 🏋️',
      'Workout reminder! Stay fit and healthy! 🏃',
      'Exercise time! Get your heart pumping! ❤️',
    ];
    return reminders[(DateTime.now().millisecond) % reminders.length];
  }

  String _sendChargingReaction() {
    final reactions = [
      'Nom nom nom... charging up! 🔋',
      'Energy incoming! ⚡',
      'Recharging my cuteness! ✨',
      'Charging... *happy noises* 🔌',
    ];
    return reactions[(DateTime.now().millisecond) % reactions.length];
  }

  String _sendLowBatteryWarning() {
    final warnings = [
      'I\'m getting hungry... ⚡',
      'Low battery! Time to charge! 🔋',
      'My energy is draining... ⚡',
      'Battery low! Need more power!",
    ];
    return warnings[(DateTime.now().millisecond) % warnings.length];
  }

  String _sendFullBatteryReaction() {
    final reactions = [
      'Full energy! Let\'s go! ⚡',
      'I\'m fully charged and ready! 🔋',
      'Maximum power achieved! ⚡',
      '100% charged! Ready for anything! 🔋',
    ];
    return reactions[(DateTime.now().millisecond) % reactions.length];
  }

  Future<void> setReminderSchedule({
    int? waterIntervalMinutes,
    int? stretchIntervalMinutes,
    int? eyeRestIntervalMinutes,
    int? walkIntervalMinutes,
  }) async {
    final box = await Hive.openBox('maxie_settings');
    
    if (waterIntervalMinutes != null) {
      await box.put('waterReminderInterval', waterIntervalMinutes);
    }
    if (stretchIntervalMinutes != null) {
      await box.put('stretchReminderInterval', stretchIntervalMinutes);
    }
    if (eyeRestIntervalMinutes != null) {
      await box.put('eyeRestReminderInterval', eyeRestIntervalMinutes);
    }
    if (walkIntervalMinutes != null) {
      await box.put('walkReminderInterval', walkIntervalMinutes);
    }
  }

  Future<Map<String, int>> getReminderSchedule() async {
    final box = await Hive.openBox('maxie_settings');
    
    return {
      'water': box.get('waterReminderInterval', defaultValue: 120),
      'stretch': box.get('stretchReminderInterval', defaultValue: 60),
      'eyeRest': box.get('eyeRestReminderInterval', defaultValue: 20),
      'walk': box.get('walkReminderInterval', defaultValue: 180),
    };
  }

  void dispose() {
    _reminderTimer?.cancel();
    _batteryCheckTimer?.cancel();
  }
}

final healthServiceProvider = Provider<HealthService>((ref) {
  final healthService = HealthService();
  ref.onDispose(() => healthService.dispose());
  return healthService;
});
