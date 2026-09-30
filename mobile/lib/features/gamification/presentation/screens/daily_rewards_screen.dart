import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/core/constants/app_constants.dart';
import 'package:maxie_mobile/features/shared/widgets/glass_card.dart';

class DailyRewardsScreen extends ConsumerWidget {
  const DailyRewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final days = 7;
    final currentDay = 3; // Example: user claimed days 1-3

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)]
                : [const Color(0xFF667eea), const Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
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
                      'Daily Rewards',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Streak & Info
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Icon(Icons.emoji_events, color: Colors.white, size: 40),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '3-Day Streak!',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: const Color(0xFFFFD700),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Come back tomorrow for more rewards!\nKeep your streak going!',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Streak indicator
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(7, (i) {
                                  final isActive = i < currentDay;
                                  final isToday = i == currentDay - 1;
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    width: isToday ? 36 : 28,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      gradient: isActive
                                          ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)])
                                          : null,
                                      color: isActive ? null : Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Reward Days Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: days,
                        itemBuilder: (context, index) {
                          final day = index + 1;
                          final isClaimed = day <= currentDay;
                          final isAvailable = day == currentDay + 1;
                          final isLocked = day > currentDay + 1;

                          return _buildDayReward(
                            context,
                            day: day,
                            reward: ['50 Coins', '100 Coins', 'Pet Egg', '200 Coins', 'Rare Item', '500 Coins', 'Legendary Pet'][index],
                            icon: [Icons.monetization_on, Icons.monetization_on, Icons.egg, Icons.monetization_on, Icons.card_giftcard, Icons.monetization_on, Icons.auto_awesome][index],
                            isClaimed: isClaimed,
                            isAvailable: isAvailable,
                            isLocked: isLocked,
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Claim Button
                      SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: currentDay < days ? () {} : null,
                            icon: Icon(
                              currentDay < days ? Icons.card_giftcard : Icons.check_circle,
                              color: currentDay < days ? Colors.white : Colors.white54,
                            ),
                            label: Text(
                              currentDay >= days ? 'All Rewards Claimed!' : 'Claim Day ${currentDay + 1} Reward',
                              style: TextStyle(
                                color: currentDay < days ? Colors.white : Colors.white54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayReward(
    BuildContext context, {
    required int day,
    required String reward,
    required IconData icon,
    required bool isClaimed,
    required bool isAvailable,
    required bool isLocked,
  }) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day number
            Text(
              'Day $day',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: isLocked ? 0.3 : 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: isClaimed
                    ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)])
                    : isAvailable
                        ? const LinearGradient(colors: [AppConstants.primaryPurple, AppConstants.primaryPink])
                        : null,
                color: isLocked ? Colors.white.withValues(alpha: 0.05) : null,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isClaimed ? Icons.check_circle : icon,
                color: isLocked
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            // Reward text
            Text(
              reward,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isLocked
                    ? Colors.white.withValues(alpha: 0.2)
                    : isClaimed
                        ? const Color(0xFFFFD700)
                        : Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}