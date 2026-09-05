
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/shared/widgets/glass_card.dart';
import 'package:maxie_mobile/core/constants/app_constants.dart';

class VoiceSettingsScreen extends ConsumerWidget {
  const VoiceSettingsScreen({super.key});

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
                      'Voice Settings',
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
                      // Speech to Text
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildTile(
                                context,
                                icon: Icons.mic,
                                title: 'Voice Input',
                                subtitle: 'Speech to text recognition',
                                trailing: Switch.adaptive(
                                  value: true,
                                  activeColor: AppConstants.primaryPurple,
                                  onChanged: (v) {},
                                ),
                              ),
                              const Divider(color: Colors.white12),
                              _buildTile(
                                context,
                                icon: Icons.language,
                                title: 'Input Language',
                                subtitle: 'English (US)',
                                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                              ),
                              const Divider(color: Colors.white12),
                              _buildTile(
                                context,
                                icon: Icons.volume_up,
                                title: 'Text to Speech',
                                subtitle: 'Voice responses from MAXie',
                                trailing: Switch.adaptive(
                                  value: true,
                                  activeColor: AppConstants.primaryPurple,
                                  onChanged: (v) {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // TTS Settings
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.record_voice_over, color: Colors.white.withOpacity(0.8), size: 20),
                                  const SizedBox(width: 8),
                                  Text('Voice Assistant',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTile(
                                context,
                                icon: Icons.speed,
                                title: 'Speech Rate',
                                subtitle: 'Normal',
                                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                              ),
                              const Divider(color: Colors.white12),
                              _buildTile(
                                context,
                                icon: Icons.tune,
                                title: 'Voice Pitch',
                                subtitle: 'Default',
                                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                              ),
                              const Divider(color: Colors.white12),
                              _buildTile(
                                context,
                                icon: Icons.wifi_tethering,
                                title: 'Wake Word Detection',
                                subtitle: 'Say "Hey MAXie" to activate',
                                trailing: Switch.adaptive(
                                  value: true,
                                  activeColor: AppConstants.primaryPurple,
                                  onChanged: (v) {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Test Voice
                      GlassCard(
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_circle_fill, color: AppConstants.primaryPurple, size: 32),
                                const SizedBox(width: 12),
                                Text('Test Voice',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ],
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