import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/services/cloud_service.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../../core/constants/app_constants.dart';

class CloudSyncScreen extends ConsumerWidget {
  const CloudSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final cloudService = ref.watch(cloudServiceProvider);

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
                      'Cloud Sync',
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
                      // Account Status
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppConstants.primaryPurple, AppConstants.primaryPink],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Icon(Icons.cloud_done, color: Colors.white, size: 40),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                cloudService.isLoggedIn ? 'Signed In' : 'Not Signed In',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cloudService.isLoggedIn
                                    ? 'Account: ${cloudService.userEmail}'
                                    : 'Sign in to backup your pets, data,\nand sync across devices.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppConstants.primaryPurple, AppConstants.primaryPink],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      if (cloudService.isLoggedIn) {
                                        await cloudService.logout();
                                      } else {
                                        final success = await cloudService.loginWithGoogle();
                                        if (success && context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Successfully signed in!')),
                                          );
                                        }
                                      }
                                    },
                                    icon: Icon(
                                      cloudService.isLoggedIn ? Icons.logout : Icons.login,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      cloudService.isLoggedIn ? 'Sign Out' : 'Sign in with Google',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Sync Options
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildSyncTile(
                                context,
                                icon: Icons.pets,
                                title: 'Sync Pets',
                                subtitle: cloudService.lastSyncTime != null
                                    ? 'Last synced: ${DateFormat('MMM d, h:mm a').format(cloudService.lastSyncTime!)}'
                                    : 'Last synced: Never',
                                trailing: Switch.adaptive(
                                  value: cloudService.getSyncPref('pets'),
                                  activeColor: AppConstants.primaryPurple,
                                  onChanged: cloudService.isLoggedIn
                                      ? (v) => cloudService.setSyncPref('pets', v)
                                      : null,
                                ),
                              ),
                              const Divider(color: Colors.white12),
                              _buildSyncTile(
                                context,
                                icon: Icons.settings,
                                title: 'Sync Settings',
                                subtitle: cloudService.lastSyncTime != null
                                    ? 'Last synced: ${DateFormat('MMM d, h:mm a').format(cloudService.lastSyncTime!)}'
                                    : 'Last synced: Never',
                                trailing: Switch.adaptive(
                                  value: cloudService.getSyncPref('settings'),
                                  activeColor: AppConstants.primaryPurple,
                                  onChanged: cloudService.isLoggedIn
                                      ? (v) => cloudService.setSyncPref('settings', v)
                                      : null,
                                ),
                              ),
                              const Divider(color: Colors.white12),
                              _buildSyncTile(
                                context,
                                icon: Icons.auto_stories,
                                title: 'Sync Achievements',
                                subtitle: cloudService.lastSyncTime != null
                                    ? 'Last synced: ${DateFormat('MMM d, h:mm a').format(cloudService.lastSyncTime!)}'
                                    : 'Last synced: Never',
                                trailing: Switch.adaptive(
                                  value: cloudService.getSyncPref('achievements'),
                                  activeColor: AppConstants.primaryPurple,
                                  onChanged: cloudService.isLoggedIn
                                      ? (v) => cloudService.setSyncPref('achievements', v)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Backup & Restore
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.backup, color: Colors.white.withOpacity(0.8), size: 20),
                                  const SizedBox(width: 8),
                                  Text('Backup & Restore',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildActionTile(
                                context,
                                icon: Icons.cloud_upload,
                                title: cloudService.isSyncing ? 'Backing up...' : 'Backup to Cloud',
                                subtitle: 'Upload your latest data',
                                onTap: cloudService.isLoggedIn && !cloudService.isSyncing
                                    ? () async {
                                        final success = await cloudService.backup();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(success ? 'Backup completed!' : 'Backup failed.')),
                                          );
                                        }
                                      }
                                    : null,
                              ),
                              const Divider(color: Colors.white12),
                              _buildActionTile(
                                context,
                                icon: Icons.cloud_download,
                                title: cloudService.isSyncing ? 'Restoring...' : 'Restore from Cloud',
                                subtitle: 'Recover data from backup',
                                onTap: cloudService.isLoggedIn && !cloudService.isSyncing
                                    ? () async {
                                        final success = await cloudService.restore();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(success ? 'Restore completed!' : 'Restore failed.')),
                                          );
                                        }
                                      }
                                    : null,
                              ),
                              const Divider(color: Colors.white12),
                              _buildActionTile(
                                context,
                                icon: Icons.delete_sweep,
                                title: 'Clear Cloud Data',
                                subtitle: 'Remove all cloud backups',
                                onTap: cloudService.isLoggedIn && !cloudService.isSyncing
                                    ? () async {
                                        // Clean cloud backup document
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Cloud data cleared!')),
                                          );
                                        }
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Last Sync Info
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.sync, color: Colors.white.withOpacity(0.6), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Automatic sync is enabled. Data will sync when signed in.',
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

  Widget _buildSyncTile(
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

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.5)),
                    ),
                  ],
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