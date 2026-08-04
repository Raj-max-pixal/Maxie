import 'package:flutter/material.dart';

class AppConstants {
  const AppConstants._();

  static const String appName = 'MAXie';
  static const String appTagline = 'Your AI Companion';
  static const String appTitle = '$appName - $appTagline';
  static const String appVersion = '1.0.0';

  static const String hiveSettingsBox = 'maxie_settings';
  static const String hiveMemoryBox = 'maxie_memory';
  static const String hiveCompanionBox = 'maxie_companion';
  static const String hivePetBox = 'maxie_pet';

  static const Duration shortAnimation = Duration(milliseconds: 180);
  static const Duration mediumAnimation = Duration(milliseconds: 280);
  static const Duration longAnimation = Duration(milliseconds: 450);

  static const Curve defaultCurve = Curves.easeOutCubic;
}
