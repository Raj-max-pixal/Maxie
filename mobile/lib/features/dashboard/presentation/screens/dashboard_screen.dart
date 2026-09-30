import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/pets/presentation/providers/pet_provider.dart'
    as legacy_pet;
import '../../../pets/presentation/widgets/pet_animation_widget.dart';
import '../../../pets/presentation/providers/pet_provider.dart';
import '../../../settings/presentation/providers/theme_provider.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/animated_greeting.dart';
import '../../../../core/theme/app_theme_enhanced.dart';
import '../../../cloud/presentation/widgets/portal_summon_widget.dart';


class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsState = ref.watch(petEngineProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    // Get primary pet
    final mainPet = petsState.pets.isNotEmpty ? petsState.pets.first : null;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFF5F0FF),
                    const Color(0xFFE8F0FF),
                    const Color(0xFFF0FFF0),
                  ],
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with greeting and settings
                _buildHeader(context, ref, isDark, mainPet?.name ?? 'MAXie'),

                const SizedBox(height: 16),

                // Main pet display area
                if (mainPet != null)
                  Container(
                    height: size.height * 0.3,
                    width: double.infinity,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Center(
                          child: PetAnimationWidget(
                            petId: mainPet.id,
                            size: 140,
                          ),
                        ),
                        // Quick action buttons around the pet
                        Positioned(
                          left: 10,
                          top: size.height * 0.05,
                          child: _QuickActionButton(
                            icon: Icons.chat_bubble_rounded,
                            color: theme.colorScheme.primary,
                            onTap: () {},
                            label: 'Chat',
                          ),
                        ),
                        Positioned(
                          right: 10,
                          top: size.height * 0.05,
                          child: _QuickActionButton(
                            icon: Icons.brush_rounded,
                            color: Colors.pink,
                            onTap: () {},
                            label: 'Style',
                          ),
                        ),
                        Positioned(
                          left: 10,
                          bottom: 10,
                          child: _QuickActionButton(
                            icon: Icons.favorite_rounded,
                            color: Colors.red,
                            onTap: () {},
                            label: 'Love',
                          ),
                        ),
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: _QuickActionButton(
                            icon: Icons.play_circle_rounded,
                            color: Colors.orange,
                            onTap: () {},
                            label: 'Play',
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pets, size: 80, color: theme.colorScheme.primary.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'Adopt a pet to get started!',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.shopping_bag_rounded),
                            label: const Text('Visit Shop'),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Stats row
                _buildStatsRow(context, petsState, isDark),

                const SizedBox(height: 20),

                // Cross-device portal travel control card
                const PortalSummonWidget(),

                const SizedBox(height: 20),


                // Today's overview
                _buildSection(
                  context,
                  'Today\'s Overview',
                  Icons.today_rounded,
                  [
                    _buildOverviewCard(
                      context,
                      'Tasks',
                      '5 remaining',
                      Icons.checklist_rounded,
                      Colors.blue,
                      isDark,
                    ),
                    _buildOverviewCard(
                      context,
                      'Habits',
                      '3 of 4 done',
                      Icons.repeat_rounded,
                      Colors.green,
                      isDark,
                    ),
                    _buildOverviewCard(
                      context,
                      'Focus',
                      '25 min',
                      Icons.timer_rounded,
                      Colors.orange,
                      isDark,
                    ),
                    _buildOverviewCard(
                      context,
                      'XP Today',
                      '+150 XP',
                      Icons.stars_rounded,
                      Colors.purple,
                      isDark,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Productivity score
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppGradients.sunset,
                          ),
                          child: Center(
                            child: Text(
                              '78',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Productivity Score',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'You\'re doing great! Keep it up! 🎉',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: 0.78,
                                  minHeight: 8,
                                  backgroundColor: theme.colorScheme.surfaceVariant,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Friendship level
                if (mainPet != null)
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite_rounded,
                            color: Colors.red.shade300,
                            size: 40,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Friendship Level',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Level ${mainPet.friendshipLevel} with ${mainPet.name}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: (mainPet.friendshipLevel % 10) / 10.0,
                                    minHeight: 8,
                                    backgroundColor: theme.colorScheme.surfaceVariant,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.red.shade300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Daily Motivation
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.amber.shade400,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Daily Motivation',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '"The only way to do great work is to love what you do." - Steve Jobs',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Weather and pet status row
                Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 32),
                              const SizedBox(height: 8),
                              Text('28°C', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                              Text('Sunny', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(Icons.pets_rounded, color: theme.colorScheme.primary, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                petsState.pets.length.toString(),
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Pets Active',
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(Icons.stars_rounded, color: Colors.amber.shade600, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                'Lv.${petsState.totalLevel}',
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Total Level',
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, bool isDark, String petName) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedGreeting(name: petName),
            const SizedBox(height: 4),
            Text(
              'Your best friend is waiting 💜',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              ),
              child: IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    legacy_pet.PetsState state,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _buildStatChip(context, Icons.monetization_on_rounded, '${state.coins}', Colors.amber, isDark),
        const SizedBox(width: 8),
        _buildStatChip(context, Icons.stars_rounded, '${state.totalXp} XP', Colors.purple, isDark),
        const SizedBox(width: 8),
        _buildStatChip(context, Icons.local_fire_department_rounded, '${state.streak} day streak', Colors.orange, isDark),
      ],
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String label, Color color, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.15) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, List<Widget> cards) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.6,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) => cards[index],
        ),
      ],
    );
  }

  Widget _buildOverviewCard(BuildContext context, String title, String subtitle, IconData icon, Color color, bool isDark) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5), size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String label;

  const _QuickActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
