import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/settings/presentation/providers/theme_provider.dart';
import 'package:maxie_mobile/features/shared/widgets/glass_card.dart';
import 'package:maxie_mobile/core/constants/app_constants.dart';
import 'package:maxie_mobile/core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

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
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Settings',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Settings Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Theme Section
                      _buildSection(
                        context,
                        title: 'Appearance',
                        icon: Icons.palette,
                        children: [
                          _SettingsTile(
                            icon: Icons.dark_mode,
                            title: 'Dark Mode',
                            subtitle: isDark ? 'Dark theme active' : 'Light theme active',
                            trailing: Switch.adaptive(
                              value: isDark,
                              activeColor: AppConstants.primaryPurple,
                              onChanged: (v) {
                                ref.read(themeStateProvider.notifier).toggleDarkMode();
                              },
                            ),
                          ),
                          _SettingsTile(
                            icon: Icons.color_lens,
                            title: 'Theme Color',
                            subtitle: 'Customize accent color',
                            onTap: () {},
                          ),
                          _SettingsTile(
                            icon: Icons.animation,
                            title: 'Animations',
                            subtitle: 'Reduce motion',
                            trailing: Switch.adaptive(
                              value: true,
                              activeColor: AppConstants.primaryPurple,
                              onChanged: (v) {},
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // AI & Voice Section
                      _buildSection(
                        context,
                        title: 'AI & Voice',
                        icon: Icons.psychology,
                        children: [
                          _SettingsTile(
                            icon: Icons.record_voice_over,
                            title: 'Voice Input',
                            subtitle: 'Speech to text',
                            trailing: Switch.adaptive(
                              value: true,
                              activeColor: AppConstants.primaryPurple,
                              onChanged: (v) {},
                            ),
                          ),
                          _SettingsTile(
                            icon: Icons.volume_up,
                            title: 'Text to Speech',
                            subtitle: 'Voice responses',
                            trailing: Switch.adaptive(
                              value: true,
                              activeColor: AppConstants.primaryPurple,
                              onChanged: (v) {},
                            ),
                          ),
                          _SettingsTile(
                            icon: Icons.cloud,
                            title: 'Offline Mode',
                            subtitle: 'Use on-device AI',
                            trailing: Switch.adaptive(
                              value: true,
                              activeColor: AppConstants.primaryPurple,
                              onChanged: (v) {},
                            ),
                          ),
                          _SettingsTile(
                            icon: Icons.language,
                            title: 'AI Model',
                            subtitle: 'Gemini 2.0 Flash',
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Notification Section
                      _buildSection(
                        context,
                        title: 'Notifications',
                        icon: Icons.notifications,
                        children: [
                          _SettingsTile(
                            icon: Icons.notifications_active,
                            title: 'Push Notifications',
                            trailing: Switch.adaptive(
                              value: true,
                              activeColor: AppConstants.primaryPurple,
                              onChanged: (v) {},
                            ),
                          ),
                          _SettingsTile(
                            icon: Icons.pets,
                            title: 'Pet Notifications',
                            subtitle: 'When pet needs attention',
                            trailing: Switch.adaptive(
                              value: true,
                              activeColor: AppConstants.primaryPurple,
                              onChanged: (v) {},
                            ),
                          ),
                          _SettingsTile(
                            icon: Icons.tips_and_updates,
                            title: 'Daily Reminders',
                            subtitle: 'Motivational quotes & tips',
                            trailing: Switch.adaptive(
                              value: true,
                              activeColor: AppConstants.primaryPurple,
                              onChanged: (v) {},
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Data & Sync Section
                      _buildSection(
                        context,
                        title: 'Data & Backup',
                        icon: Icons.cloud_sync,
                        children: [
                          _SettingsTile(
                            icon: Icons.cloud_download,
                            title: 'Cloud Backup',
                            subtitle: 'Sync across devices',
                            onTap: () {},
                          ),
                          _SettingsTile(
                            icon: Icons.restore,
                            title: 'Restore Data',
                            subtitle: 'Recover from backup',
                            onTap: () {},
                          ),
                          _SettingsTile(
                            icon: Icons.delete_sweep,
                            title: 'Clear Cache',
                            subtitle: 'Free up storage space',
                            onTap: () {},
                          ),
                          _SettingsTile(
                            icon: Icons.download,
                            title: 'Export Data',
                            subtitle: 'Download your data',
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Accessibility Section
                      _buildSection(
                        context,
                        title: 'Accessibility',
                        icon: Icons.accessibility_new,
                        children: [
                          _SettingsTile(
                            icon: Icons.text_fields,
                            title: 'Font Size',
                            subtitle: 'Adjust text size',
                            onTap: () {},
                          ),
                          _SettingsTile(
                            icon: Icons.hearing,
                            title: 'Sound Effects',
                            trailing: Switch.adaptive(
                              value: true,
                              activeColor: AppConstants.primaryPurple,
                              onChanged: (v) {},
                            ),
                          ),
                          _SettingsTile(
                            icon: Icons.touch_app,
                            title: 'Haptic Feedback',
                            trailing: Switch.adaptive(
                              value: true,
                              activeColor: AppConstants.primaryPurple,
                              onChanged: (v) {},
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // About Section
                      _buildSection(
                        context,
                        title: 'About',
                        icon: Icons.info,
                        children: [
                          _SettingsTile(
                            icon: Icons.info_outline,
                            title: 'Version',
                            subtitle: AppConstants.appVersion,
                          ),
                          _SettingsTile(
                            icon: Icons.code,
                            title: 'Open Source',
                            subtitle: 'View on GitHub',
                            onTap: () {},
                          ),
                          _SettingsTile(
                            icon: Icons.policy,
                            title: 'Privacy Policy',
                            subtitle: 'How we protect your data',
                            onTap: () {},
                          ),
                          _SettingsTile(
                            icon: Icons.description,
                            title: 'Terms of Service',
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Premium Banner
                      GlassCard(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppConstants.primaryPurple,
                                      AppConstants.primaryPink,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'MAXie is Free Forever',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'No subscriptions. No locked features.\n100% free for everyone.',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        GlassCard(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.primaryPurple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppConstants.primaryPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.5),
                          ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
            if (onTap != null && trailing == null)
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.5),
              ),
          ],
        ),
      ),
    );
  }
}