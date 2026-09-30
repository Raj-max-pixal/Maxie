 import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamificationState {
  final int xp;
  final int level;
  final int coins;
  final int dailyStreak;
  final int friendshipLevel;
  final DateTime lastLoginDate;
  final Map<String, bool> achievements;
  final int totalTasksCompleted;
  final int totalChats;
  final int totalHabitCompletions;
  final int totalPomodoroSessions;

  const GamificationState({
    this.xp = 0,
    this.level = 1,
    this.coins = 0,
    this.dailyStreak = 0,
    this.friendshipLevel = 1,
    required this.lastLoginDate,
    this.achievements = const {},
    this.totalTasksCompleted = 0,
    this.totalChats = 0,
    this.totalHabitCompletions = 0,
    this.totalPomodoroSessions = 0,
  });

  GamificationState copyWith({
    int? xp,
    int? level,
    int? coins,
    int? dailyStreak,
    int? friendshipLevel,
    DateTime? lastLoginDate,
    Map<String, bool>? achievements,
    int? totalTasksCompleted,
    int? totalChats,
    int? totalHabitCompletions,
    int? totalPomodoroSessions,
  }) {
    return GamificationState(
      xp: xp ?? this.xp,
      level: level ?? this.level,
      coins: coins ?? this.coins,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      friendshipLevel: friendshipLevel ?? this.friendshipLevel,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      achievements: achievements ?? this.achievements,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      totalChats: totalChats ?? this.totalChats,
      totalHabitCompletions: totalHabitCompletions ?? this.totalHabitCompletions,
      totalPomodoroSessions: totalPomodoroSessions ?? this.totalPomodoroSessions,
    );
  }

  double get xpToNextLevel {
    return AppConstants.xpForLevelUp *
        (1 + (level - 1) * (AppConstants.xpMultiplierPerLevel - 1));
  }

  double get levelProgress => xp / xpToNextLevel;

  int get unlockedAchievementCount =>
      achievements.values.where((v) => v).length;

  int get totalAchievements => 30;

  double get achievementProgress => unlockedAchievementCount / totalAchievements;

  Map<String, String> get achievementDescriptions {
    return {
      'first_chat': 'Send your first message',
      'chat_50': 'Send 50 messages',
      'chat_100': 'Send 100 messages',
      'first_task': 'Complete your first task',
      'task_10': 'Complete 10 tasks',
      'task_50': 'Complete 50 tasks',
      'task_100': 'Complete 100 tasks',
      'first_habit': 'Start your first habit',
      'habit_7': 'Maintain a habit for 7 days',
      'habit_30': 'Maintain a habit for 30 days',
      'first_pomodoro': 'Complete your first Pomodoro',
      'pomodoro_10': 'Complete 10 Pomodoros',
      'pomodoro_50': 'Complete 50 Pomodoros',
      'level_5': 'Reach level 5',
      'level_10': 'Reach level 10',
      'level_25': 'Reach level 25',
      'level_50': 'Reach level 50',
      'streak_3': '3 day streak',
      'streak_7': '7 day streak',
      'streak_30': '30 day streak',
      'streak_100': '100 day streak',
      'coins_100': 'Collect 100 coins',
      'coins_1000': 'Collect 1000 coins',
      'coins_10000': 'Collect 10000 coins',
      'friend_5': 'Reach friendship level 5',
      'friend_10': 'Reach friendship level 10',
      'friend_25': 'Reach friendship level 25',
      'friend_50': 'Reach max friendship',
    };
  }

  Map<String, dynamic> toJson() => {
        'xp': xp,
        'level': level,
        'coins': coins,
        'dailyStreak': dailyStreak,
        'friendshipLevel': friendshipLevel,
        'lastLoginDate': lastLoginDate.toIso8601String(),
        'achievements': achievements,
        'totalTasksCompleted': totalTasksCompleted,
        'totalChats': totalChats,
        'totalHabitCompletions': totalHabitCompletions,
        'totalPomodoroSessions': totalPomodoroSessions,
      };

  factory GamificationState.fromJson(Map<String, dynamic> json) {
    return GamificationState(
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      coins: json['coins'] as int? ?? 0,
      dailyStreak: json['dailyStreak'] as int? ?? 0,
      friendshipLevel: json['friendshipLevel'] as int? ?? 1,
      lastLoginDate: json['lastLoginDate'] != null
          ? DateTime.parse(json['lastLoginDate'] as String)
          : DateTime.now(),
      achievements: (json['achievements'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as bool)) ??
          {},
      totalTasksCompleted: json['totalTasksCompleted'] as int? ?? 0,
      totalChats: json['totalChats'] as int? ?? 0,
      totalHabitCompletions: json['totalHabitCompletions'] as int? ?? 0,
      totalPomodoroSessions: json['totalPomodoroSessions'] as int? ?? 0,
    );
  }
}

class GamificationService extends StateNotifier<GamificationState> {
  GamificationService() : super(GamificationState(lastLoginDate: DateTime.now())) {
    _loadState();
    _checkDailyLogin();
  }

  void _checkDailyLogin() {
    final now = DateTime.now();
    final lastLogin = state.lastLoginDate;
    final difference = now.difference(lastLogin);

    if (difference.inDays >= 1) {
      final isConsecutive = difference.inDays == 1;
      final newStreak = isConsecutive ? state.dailyStreak + 1 : 1;

      final int bonus = isConsecutive
          ? AppConstants.dailyLoginBonus + (newStreak * AppConstants.streakBonus)
          : AppConstants.dailyLoginBonus;

      state = state.copyWith(
        dailyStreak: newStreak,
        coins: state.coins + AppConstants.dailyLoginBonus + bonus,
        xp: state.xp + AppConstants.baseXPPerTask,
        lastLoginDate: now,
      );
      _checkLevelUp();
      _saveState();
    }
  }

  void addXP(int amount, {String? source}) {
    state = state.copyWith(
      xp: state.xp + amount,
      totalChats: source == 'Chat' ? state.totalChats + 1 : state.totalChats,
      totalTasksCompleted: source == 'Task' ? state.totalTasksCompleted + 1 : state.totalTasksCompleted,
      totalHabitCompletions: source == 'Habit' ? state.totalHabitCompletions + 1 : state.totalHabitCompletions,
      totalPomodoroSessions: source == 'Pomodoro' ? state.totalPomodoroSessions + 1 : state.totalPomodoroSessions,
    );
    _checkLevelUp();
    _checkAchievements();
    _saveState();
  }

  void addCoins(int amount, {String? source}) {
    state = state.copyWith(coins: state.coins + amount);
    _saveState();
  }

  bool spendCoins(int amount) {
    if (state.coins >= amount) {
      state = state.copyWith(coins: state.coins - amount);
      _saveState();
      return true;
    }
    return false;
  }

  void addFriendshipXP(int amount) {
    final currentXP = state.friendshipLevel;
    final newXP = currentXP + (amount ~/ AppConstants.xpPerFriendshipLevel);
    if (newXP <= AppConstants.maxFriendshipLevel) {
      state = state.copyWith(friendshipLevel: newXP);
      _saveState();
    }
  }

  void _checkLevelUp() {
    while (state.xp >= state.xpToNextLevel) {
      state = state.copyWith(
        level: state.level + 1,
        xp: state.xp - state.xpToNextLevel.toInt(),
        coins: state.coins + (state.level * 10),
      );
    }
  }

  void _checkAchievements() {
    final newAchievements = Map<String, bool>.from(state.achievements);
    bool changed = false;

    // Check and unlock achievements
    if (state.totalChats >= 1 && !newAchievements.containsKey('first_chat')) { newAchievements['first_chat'] = true; changed = true; }
    if (state.totalChats >= 50 && !newAchievements.containsKey('chat_50')) { newAchievements['chat_50'] = true; changed = true; }
    if (state.totalChats >= 100 && !newAchievements.containsKey('chat_100')) { newAchievements['chat_100'] = true; changed = true; }
    if (state.totalTasksCompleted >= 1 && !newAchievements.containsKey('first_task')) { newAchievements['first_task'] = true; changed = true; }
    if (state.totalTasksCompleted >= 10 && !newAchievements.containsKey('task_10')) { newAchievements['task_10'] = true; changed = true; }
    if (state.totalTasksCompleted >= 50 && !newAchievements.containsKey('task_50')) { newAchievements['task_50'] = true; changed = true; }
    if (state.totalTasksCompleted >= 100 && !newAchievements.containsKey('task_100')) { newAchievements['task_100'] = true; changed = true; }
    if (state.totalHabitCompletions >= 1 && !newAchievements.containsKey('first_habit')) { newAchievements['first_habit'] = true; changed = true; }
    if (state.totalHabitCompletions >= 7 && !newAchievements.containsKey('habit_7')) { newAchievements['habit_7'] = true; changed = true; }
    if (state.totalHabitCompletions >= 30 && !newAchievements.containsKey('habit_30')) { newAchievements['habit_30'] = true; changed = true; }
    if (state.totalPomodoroSessions >= 1 && !newAchievements.containsKey('first_pomodoro')) { newAchievements['first_pomodoro'] = true; changed = true; }
    if (state.totalPomodoroSessions >= 10 && !newAchievements.containsKey('pomodoro_10')) { newAchievements['pomodoro_10'] = true; changed = true; }
    if (state.totalPomodoroSessions >= 50 && !newAchievements.containsKey('pomodoro_50')) { newAchievements['pomodoro_50'] = true; changed = true; }
    if (state.level >= 5 && !newAchievements.containsKey('level_5')) { newAchievements['level_5'] = true; changed = true; }
    if (state.level >= 10 && !newAchievements.containsKey('level_10')) { newAchievements['level_10'] = true; changed = true; }
    if (state.level >= 25 && !newAchievements.containsKey('level_25')) { newAchievements['level_25'] = true; changed = true; }
    if (state.level >= 50 && !newAchievements.containsKey('level_50')) { newAchievements['level_50'] = true; changed = true; }
    if (state.dailyStreak >= 3 && !newAchievements.containsKey('streak_3')) { newAchievements['streak_3'] = true; changed = true; }
    if (state.dailyStreak >= 7 && !newAchievements.containsKey('streak_7')) { newAchievements['streak_7'] = true; changed = true; }
    if (state.dailyStreak >= 30 && !newAchievements.containsKey('streak_30')) { newAchievements['streak_30'] = true; changed = true; }
    if (state.dailyStreak >= 100 && !newAchievements.containsKey('streak_100')) { newAchievements['streak_100'] = true; changed = true; }
    if (state.coins >= 100 && !newAchievements.containsKey('coins_100')) { newAchievements['coins_100'] = true; changed = true; }
    if (state.coins >= 1000 && !newAchievements.containsKey('coins_1000')) { newAchievements['coins_1000'] = true; changed = true; }
    if (state.coins >= 10000 && !newAchievements.containsKey('coins_10000')) { newAchievements['coins_10000'] = true; changed = true; }
    if (state.friendshipLevel >= 5 && !newAchievements.containsKey('friend_5')) { newAchievements['friend_5'] = true; changed = true; }
    if (state.friendshipLevel >= 10 && !newAchievements.containsKey('friend_10')) { newAchievements['friend_10'] = true; changed = true; }
    if (state.friendshipLevel >= 25 && !newAchievements.containsKey('friend_25')) { newAchievements['friend_25'] = true; changed = true; }
    if (state.friendshipLevel >= 50 && !newAchievements.containsKey('friend_50')) { newAchievements['friend_50'] = true; changed = true; }

    if (changed) {
      state = state.copyWith(achievements: newAchievements);
      _saveState();
    }
  }

  void _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(AppConstants.gamificationKey);
      if (data != null) {
        state = GamificationState.fromJson(
            jsonDecode(data) as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error loading gamification state: $e');
    }
  }

  void _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          AppConstants.gamificationKey, jsonEncode(state.toJson()));
    } catch (e) {
      debugPrint('Error saving gamification state: $e');
    }
  }
}

final gamificationServiceProvider =
    StateNotifierProvider<GamificationService, GamificationState>((ref) {
  return GamificationService();
});