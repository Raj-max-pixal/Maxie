import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/pc_companion_service.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../../core/constants/app_constants.dart';

class PCCompanionScreen extends ConsumerWidget {
  const PCCompanionScreen({super.key});

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
                      'PC Companion',
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
                      // Connection Status
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppConstants.primaryPurple, AppConstants.primaryPink],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.computer, color: Colors.white, size: 32),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Desktop App',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Disconnected',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: Colors.redAccent,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.wifi_find, color: Colors.white.withOpacity(0.4), size: 28),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // System Info
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.monitor_heart, color: Colors.white.withOpacity(0.8), size: 20),
                                  const SizedBox(width: 8),
                                  Text('System Information',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(context, 'CPU', '--', Icons.memory),
                              const SizedBox(height: 12),
                              _buildInfoRow(context, 'RAM', '--', Icons.storage),
                              const SizedBox(height: 12),
                              _buildInfoRow(context, 'Battery', '--', Icons.battery_unknown),
                              const SizedBox(height: 12),
                              _buildInfoRow(context, 'OS', '--', Icons.desktop_windows),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Actions
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.flash_on, color: Colors.white.withOpacity(0.8), size: 20),
                                  const SizedBox(width: 8),
                                  Text('Quick Actions',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildActionButton(context, Icons.content_paste, 'Clipboard Sync', 'Sync clipboard across devices'),
                              const SizedBox(height: 12),
                              _buildActionButton(context, Icons.sync, 'Notification Sync', 'Receive PC notifications'),
                              const SizedBox(height: 12),
                              _buildActionButton(context, Icons.file_present, 'File Transfer', 'Send files between devices'),
                              const Divider(color: Colors.white12, height: 24),
                              _buildDangerAction(context, Icons.lock, 'Lock PC', 'Lock your computer remotely'),
                              const SizedBox(height: 8),
                              _buildDangerAction(context, Icons.power_settings_new, 'Shutdown PC', 'Turn off your computer'),
                              const SizedBox(height: 8),
                              _buildDangerAction(context, Icons.restart_alt, 'Restart PC', 'Reboot your computer'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Pair Info
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.white.withOpacity(0.6), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Install MAXie Desktop on your PC to enable remote control features.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withOpacity(0.6),
                                  ),
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

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: AppConstants.primaryPurple.withOpacity(0.7), size: 18),
        const SizedBox(width: 10),
        Text(label + ':',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.6)),
        ),
        const Spacer(),
        Text(value,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String title, String subtitle) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Padding(
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
                  Text(subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.4), size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerAction(BuildContext context, IconData icon, String title, String subtitle) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.redAccent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  Text(subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.4), size: 28),
          ],
        ),
      ),
    );
  }
}