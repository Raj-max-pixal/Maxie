import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../../core/constants/app_constants.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final List<ColorOption> colorOptions = [
      ColorOption('Purple', AppConstants.primaryPurple),
      ColorOption('Pink', AppConstants.primaryPink),
      ColorOption('Blue', const Color(0xFF2196F3)),
      ColorOption('Teal', const Color(0xFF009688)),
      ColorOption('Orange', const Color(0xFFFF9800)),
      ColorOption('Green', const Color(0xFF4CAF50)),
    ];

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
                      'Appearance',
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
                      // Dark Mode Toggle
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppConstants.primaryPurple.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isDark ? Icons.dark_mode : Icons.light_mode,
                                  color: AppConstants.primaryPurple,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dark Mode',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isDark ? 'Dark theme active' : 'Light theme active',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: isDark,
                                activeColor: AppConstants.primaryPurple,
                                onChanged: (v) {
                                  ref.read(themeStateProvider.notifier).toggleDarkMode();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Accent Color
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.color_lens, color: Colors.white.withOpacity(0.8), size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Accent Color',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: colorOptions.map((option) {
                                  final isSelected = option.color == AppConstants.primaryPurple;
                                  return GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: option.color,
                                        borderRadius: BorderRadius.circular(16),
                                        border: isSelected
                                            ? Border.all(color: Colors.white, width: 3)
                                            : null,
                                        boxShadow: isSelected
                                            ? [BoxShadow(color: option.color.withOpacity(0.5), blurRadius: 12)]
                                            : null,
                                      ),
                                      child: isSelected
                                          ? const Icon(Icons.check, color: Colors.white)
                                          : null,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Animation Settings
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildSettingRow(
                                context,
                                icon: Icons.animation,
                                title: 'Reduce Motion',
                                subtitle: 'Minimize pet animations',
                                trailing: Switch.adaptive(
                                  value: false,
                                  activeColor: AppConstants.primaryPurple,
                                  onChanged: (v) {},
                                ),
                              ),
                              const Divider(color: Colors.white12),
                              _buildSettingRow(
                                context,
                                icon: Icons.blur_on,
                                title: 'Glassmorphism Effect',
                                subtitle: 'Background blur intensity',
                                trailing: Switch.adaptive(
                                  value: true,
                                  activeColor: AppConstants.primaryPurple,
                                  onChanged: (v) {},
                                ),
                              ),
                              const Divider(color: Colors.white12),
                              _buildSettingRow(
                                context,
                                icon: Icons.auto_awesome,
                                title: 'Particle Effects',
                                subtitle: 'Floating sparkles on screen',
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

  Widget _buildSettingRow(
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
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}

class ColorOption {
  final String name;
  final Color color;
  ColorOption(this.name, this.color);
}