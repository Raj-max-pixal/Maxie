import 'package:flutter/material.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';

class MemoryCategoryInfo {
  const MemoryCategoryInfo({
    required this.category,
    required this.label,
    required this.icon,
    required this.group,
  });

  final MemoryCategory category;
  final String label;
  final IconData icon;
  final String group;
}

class MemoryCategories {
  const MemoryCategories._();

  static const List<MemoryCategoryInfo> all = [
    MemoryCategoryInfo(
      category: MemoryCategory.userProfile,
      label: 'Profile',
      icon: Icons.badge_rounded,
      group: 'Identity',
    ),
    MemoryCategoryInfo(
      category: MemoryCategory.goals,
      label: 'Goals',
      icon: Icons.flag_rounded,
      group: 'Identity',
    ),
    MemoryCategoryInfo(
      category: MemoryCategory.dreamCompanies,
      label: 'Dream Companies',
      icon: Icons.apartment_rounded,
      group: 'Identity',
    ),
    MemoryCategoryInfo(
      category: MemoryCategory.projects,
      label: 'Projects',
      icon: Icons.workspaces_rounded,
      group: 'Work',
    ),
    MemoryCategoryInfo(
      category: MemoryCategory.skills,
      label: 'Skills',
      icon: Icons.psychology_rounded,
      group: 'Work',
    ),
    MemoryCategoryInfo(
      category: MemoryCategory.interests,
      label: 'Interests',
      icon: Icons.auto_awesome_rounded,
      group: 'Personal',
    ),
    MemoryCategoryInfo(
      category: MemoryCategory.favoriteApps,
      label: 'Favorite Apps',
      icon: Icons.apps_rounded,
      group: 'Personal',
    ),
    MemoryCategoryInfo(
      category: MemoryCategory.favoriteSongs,
      label: 'Favorite Songs',
      icon: Icons.music_note_rounded,
      group: 'Personal',
    ),
    MemoryCategoryInfo(
      category: MemoryCategory.favoriteMovies,
      label: 'Favorite Movies',
      icon: Icons.movie_rounded,
      group: 'Personal',
    ),
    MemoryCategoryInfo(
      category: MemoryCategory.favoriteGames,
      label: 'Favorite Games',
      icon: Icons.sports_esports_rounded,
      group: 'Personal',
    ),
    MemoryCategoryInfo(
      category: MemoryCategory.college,
      label: 'College',
      icon: Icons.school_rounded,
      group: 'People',
    ),
    MemoryCategoryInfo(
      category: MemoryCategory.friends,
      label: 'Friends',
      icon: Icons.people_alt_rounded,
      group: 'People',
    ),
    MemoryCategoryInfo(
      category: MemoryCategory.family,
      label: 'Family',
      icon: Icons.family_restroom_rounded,
      group: 'People',
    ),
    MemoryCategoryInfo(
      category: MemoryCategory.birthdays,
      label: 'Birthdays',
      icon: Icons.cake_rounded,
      group: 'People',
    ),
    MemoryCategoryInfo(
      category: MemoryCategory.importantDates,
      label: 'Important Dates',
      icon: Icons.event_rounded,
      group: 'People',
    ),
    MemoryCategoryInfo(
      category: MemoryCategory.achievements,
      label: 'Achievements',
      icon: Icons.emoji_events_rounded,
      group: 'Growth',
    ),
    MemoryCategoryInfo(
      category: MemoryCategory.habits,
      label: 'Habits',
      icon: Icons.repeat_rounded,
      group: 'Growth',
    ),
    MemoryCategoryInfo(
      category: MemoryCategory.dailyRoutine,
      label: 'Daily Routine',
      icon: Icons.wb_sunny_rounded,
      group: 'Growth',
    ),
    MemoryCategoryInfo(
      category: MemoryCategory.preferences,
      label: 'Preferences',
      icon: Icons.tune_rounded,
      group: 'Personal',
    ),
    MemoryCategoryInfo(
      category: MemoryCategory.pinned,
      label: 'Pinned',
      icon: Icons.push_pin_rounded,
      group: 'Highlights',
    ),
    MemoryCategoryInfo(
      category: MemoryCategory.conversation,
      label: 'Conversation',
      icon: Icons.chat_bubble_rounded,
      group: 'Conversation',
    ),
  ];

  static MemoryCategoryInfo info(MemoryCategory category) {
    return all.firstWhere((item) => item.category == category);
  }

  static List<MemoryCategoryInfo> grouped(String group) {
    return all.where((item) => item.group == group).toList();
  }
}
