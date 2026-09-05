import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/shared/widgets/glass_card.dart';
import 'package:maxie_mobile/core/constants/app_constants.dart';

class AccessibilityScreen extends ConsumerWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Accessibility',
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
                      // Display
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildTile(
                                context,
                                icon: Icons.text_fields,
                                title: 'Font Size',
                                subtitle: 'Small (Default)',
                                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                              ),
                              const Divider(color: Colors.white12),
                              _buildTile(
                                context,
                                icon: Icons.format_size,
                                title: 'Bold Text',
                                subtitle: 'Use bold font throughout',
                                trailing: Switch.adaptive(
                                  value: false,
                                  activeColor: AppConstants.primaryPurple,
                                  onChanged: (v) {},
                                ),
                              ),
                              const Divider(color: Colors.white12),
                              _buildTile(
                                context,
                                icon: Icons.contrast,
                                title: 'High Contrast',
                                subtitle: 'Increase color contrast',
                                trailing: Switch.adaptive(
                                  value: false,
                                  activeColor: AppConstants.primaryPurple,
                                  onChanged: (v) {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Hearing
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.hearing, color: Colors.white.withOpacity(0.8), size: 20),
                                  const SizedBox(width: 8),
                                  Text('Hearing',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildTile(
                                context,
                                icon: Icons.volume_up,
                                title: 'Sound Effects',
                                subtitle: 'Play sounds for interactions',
                                trailing: Switch.adaptive(
                                  value: true,
                                  activeColor: AppConstants.primaryPurple,
                                  onChanged: (v) {},
                                ),
                              ),
                              const Divider(color: Colors.white12),
                              _buildTile(
                                context,
                                icon: Icons.closed_caption,
                                title: 'Subtitles',
                                subtitle: 'Text captions for pet sounds',
                                trailing: Switch.adaptive(
                                  value: false,
                                  activeColor: AppConstants.primaryPurple,
                                  onChanged: (v) {},
                                ),
                              ),
                              const Divider(color: Colors.white12),
                              _buildTile(
                                context,
                                icon: Icons.notifications_off,
                                title: 'Reduce Loud Sounds',
                                subtitle: 'Minimize sudden sounds',
                                trailing: Switch.adaptive(
                                  value: false,
                                  activeColor: AppConstants.primaryPurple,
                                  onChanged: (v) {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Motor
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.touch_app, color: Colors.white.withOpacity(0.8), size: 20),
                                  const SizedBox(width: 8),
                                  Text('Motor & Dexterity',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildTile(
                                context,
                                icon: Icons.vibration,
                                title: 'Haptic Feedback',
                                subtitle: 'Vibrate on interactions',
                                trailing: Switch.adaptive(
                                  value: true,
                                  activeColor: AppConstants.primaryPurple,
                                  onChanged: (v) {},
                                ),
                              ),
                              const Divider(color: Colors.white12),
                              _buildTile(
                                context,
                                icon: Icons.timer,
                                title: 'Long Press Duration',
                                subtitle: 'Shorter (0.3s)',
                                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                              ),
                              const Divider(color: Colors.white12),
                              _buildTile(
                                context,
                                icon: Icons.swipe,
                                title: 'Reduce Drag Sensitivity',
                                subtitle: 'Require more movement to drag',
                                trailing: Switch.adaptive(
                                  value: false,
                                  activeColor: AppConstants.primaryPurple,
                                  onChanged: (v) {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // General
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.settings_accessibility, color: Colors.white.withOpacity(0.8), size: 20),
                                  const SizedBox(width: 8),
                                  Text('General',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildTile(
                                context,
                                icon: Icons.animation,
                                title: 'Reduce Motion',
                                subtitle: 'Minimize animations',
                                trailing: Switch.adaptive(
                                  value: false,
                                  activeColor: AppConstants.primaryPurple,
                                  onChanged: (v) {},
                                ),
                              ),
                              const Divider(color: Colors.white12),
                              _buildTile(
                                context,
                                icon: Icons.translate,
                                title: 'Language',
                                subtitle: 'English (US)',
                                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
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

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.primaryPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppConstants.primaryPurple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.5)),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}