import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/core/constants/app_constants.dart';
import 'package:maxie_mobile/features/gamification/data/services/gamification_service.dart';
import 'package:maxie_mobile/features/shared/widgets/glass_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationServiceProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
                  ]
                : [
                    const Color(0xFF667eea),
                    const Color(0xFF764ba2),
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Your Profile',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // XP & Level Card
                GlassCard(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Level Badge
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppConstants.primaryPurple,
                                AppConstants.primaryPink,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: AppConstants.primaryPurple.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${gamification.level}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'LEVEL',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // XP Bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'XP Progress',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${gamification.xp.toInt()} / ${gamification.xpToNextLevel.toInt()} XP',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: gamification.levelProgress.clamp(0.0, 1.0),
                                backgroundColor: Colors.white.withValues(alpha: 0.1),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppConstants.primaryPurple,
                                ),
                                minHeight: 12,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStat(
                              context,
                              icon: Icons.monetization_on,
                              value: '${gamification.coins}',
                              label: 'Coins',
                              color: AppConstants.primaryYellow,
                            ),
                            _buildStat(
                              context,
                              icon: Icons.local_fire_department,
                              value: '${gamification.dailyStreak}',
                              label: 'Day Streak',
                              color: AppConstants.primaryOrange,
                            ),
                            _buildStat(
                              context,
                              icon: Icons.favorite,
                              value: '${gamification.friendshipLevel}',
                              label: 'Friendship',
                              color: AppConstants.primaryPink,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Achievement Progress
                GlassCard(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.emoji_events, color: AppConstants.primaryYellow),
                            const SizedBox(width: 8),
                            Text(
                              'Achievements',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${gamification.unlockedAchievementCount} / ${gamification.totalAchievements}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: gamification.achievementProgress.clamp(0.0, 1.0),
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppConstants.primaryYellow,
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...gamification.achievementDescriptions.entries
                            .where((e) => gamification.achievements[e.key] == true)
                            .take(5)
                            .map((entry) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: AppConstants.primaryGreen,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          entry.value,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.8),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Statistics
                GlassCard(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statistics',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStatRow('Tasks Completed', '${gamification.totalTasksCompleted}'),
                        _buildStatRow('Chat Messages', '${gamification.totalChats}'),
                        _buildStatRow('Habit Completions', '${gamification.totalHabitCompletions}'),
                        _buildStatRow('Pomodoro Sessions', '${gamification.totalPomodoroSessions}'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}