import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'MAXie';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'India\'s First AI Mobile Companion';

  // Brand Colors
  static const Color primaryPurple = Color(0xFF6C63FF);
  static const Color primaryPink = Color(0xFFFF6B9D);
  static const Color primaryBlue = Color(0xFF4FC3F7);
  static const Color primaryGreen = Color(0xFF69F0AE);
  static const Color primaryYellow = Color(0xFFFFD54F);
  static const Color primaryOrange = Color(0xFFFFAB40);
  static const Color primaryRed = Color(0xFFFF5252);
  static const Color primaryTeal = Color(0xFF1DE9B6);

  // Pet Colors
  static const Map<String, Color> petColors = {
    'maxie': Color(0xFF6C63FF),
    'cat': Color(0xFFFF9800),
    'dog': Color(0xFF795548),
    'panda': Color(0xFF424242),
    'fox': Color(0xFFFF5722),
    'rabbit': Color(0xFFE91E63),
    'penguin': Color(0xFF2196F3),
    'dragon': Color(0xFF4CAF50),
    'slime': Color(0xFF00BCD4),
    'robot': Color(0xFF607D8B),
    'capybara': Color(0xFF8D6E63),
    'axolotl': Color(0xFFFF80AB),
  };

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration slowAnimation = Duration(milliseconds: 800);
  static const Duration verySlowAnimation = Duration(milliseconds: 1200);

  // Pet Defaults
  static const double defaultPetSize = 140.0;
  static const double minPetSize = 60.0;
  static const double maxPetSize = 300.0;
  static const double petSpeedMultiplier = 1.0;
  static const int maxPetsOnScreen = 6;
  static const double petWalkSpeed = 1.5;
  static const double petRunSpeed = 3.0;
  static const double petJumpVelocity = -8.0;
  static const double petGravity = 0.5;

  // Gamification
  static const int baseXPPerTask = 10;
  static const int baseXPPerChat = 5;
  static const int xpForLevelUp = 100;
  static const double xpMultiplierPerLevel = 1.5;
  static const int coinsPerTask = 5;
  static const int dailyLoginBonus = 20;
  static const int streakBonus = 50;

  // Friendship
  static const int maxFriendshipLevel = 50;
  static const int xpPerFriendshipLevel = 200;
  static const double friendshipDecayRate = 0.01;
  static const double needsDecayRate = 0.02;

  // Productivity
  static const int pomodoroDefaultMinutes = 25;
  static const int pomodoroShortBreak = 5;
  static const int pomodoroLongBreak = 15;
  static const int pomodoroSessionsBeforeLongBreak = 4;

  // Storage Keys
  static const String userPrefsKey = 'user_prefs';
  static const String petsKey = 'pets_data';
  static const String tasksKey = 'tasks_data';
  static const String habitsKey = 'habits_data';
  static const String notesKey = 'notes_data';
  static const String goalsKey = 'goals_data';
  static const String achievementsKey = 'achievements_data';
  static const String chatHistoryKey = 'chat_history';
  static const String memoryKey = 'ai_memory';
  static const String settingsKey = 'app_settings';
  static const String gamificationKey = 'gamification_data';
  static const String lastBackupKey = 'cloud_last_backup';

  // Cloud Keys
  static const String cloudLoginKey = 'cloud_is_logged_in';
  static const String userEmailKey = 'cloud_user_email';
  static const String userIdKey = 'cloud_user_id';
  static const String lastSyncTimeKey = 'cloud_last_sync_time';

  // PC Companion Keys
  static const String pcBatteryKey = 'pc_battery';
  static const String pcCpuKey = 'pc_cpu';
  static const String pcRamKey = 'pc_ram';
  static const String pcClipboardKey = 'pc_clipboard';
  static const String pcConnectionKey = 'pc_connection';

  // API Keys (Free/Open Source)
  static const String geminiApiKey = ''; // User provides their own key
  static const String openWeatherApiKey = ''; // User provides their own key

  // URLs
  static const String githubRepo = 'https://github.com/Raj-max-pixal/Maxie';
  static const String privacyPolicy = 'https://maxie.app/privacy';
  static const String termsOfService = 'https://maxie.app/terms';

  // AI Service
  static const String aiApiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static const Duration aiTimeout = Duration(seconds: 30);

  // Motivational Quotes
  static const List<String> dailyQuotes = [
    'The only way to do great work is to love what you do.',
    'Believe you can and you\'re halfway there.',
    'Your limitation—it\'s only your imagination.',
    'Push yourself because no one else is going to do it for you.',
    'Great things never come from comfort zones.',
    'Dream it. Wish it. Do it.',
    'Success doesn\'t just find you. You have to go out and get it.',
    'The harder you work for something, the greater you\'ll feel when you achieve it.',
    'Dream bigger. Do bigger.',
    'Don\'t stop when you\'re tired. Stop when you\'re done.',
    'Wake up with determination. Go to bed with satisfaction.',
    'Do something today that your future self will thank you for.',
    'Little things make big days.',
    'It\'s going to be hard, but hard does not mean impossible.',
    'Don\'t wait for opportunity. Create it.',
    'Sometimes we\'re tested not to show our weaknesses, but to discover our strengths.',
    'The key to success is to focus on goals, not obstacles.',
    'Your only limit is your mind.',
    'Make each day your masterpiece.',
    'You are stronger than you think.',
  ];

  // Emotions
  static const Map<String, String> emotionEmojis = {
    'happy': '😊',
    'sad': '😢',
    'excited': '🎉',
    'hungry': '🍕',
    'sleepy': '😴',
    'curious': '🤔',
    'thinking': '💭',
    'laughing': '😂',
    'celebrating': '🥳',
    'angry': '😠',
    'surprised': '😮',
    'playful': '😜',
    'loving': '🥰',
    'dizzy': '😵',
    'shy': '😊',
  };

  // Sizes
  static const double cardRadius = 24.0;
  static const double buttonRadius = 20.0;
  static const double inputRadius = 20.0;
  static const double dialogRadius = 28.0;
  static const double chipRadius = 20.0;
  static const double avatarRadius = 40.0;

  // Padding
  static const double paddingXs = 4.0;
  static const double paddingSm = 8.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 24.0;
  static const double paddingXl = 32.0;
}