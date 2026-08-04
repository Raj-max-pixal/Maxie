import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/config/app_state.dart';
import 'package:maxie_mobile/services/connectivity_service.dart';
import 'package:maxie_mobile/services/snackbar_service.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';
import 'package:maxie_mobile/widgets/section_title.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isOffline = ref.watch(offlineProvider);

    return PremiumScaffold(
      title: 'Settings',
      showNavigation: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
        children: [
          const SectionTitle(
            title: 'Settings',
            subtitle: 'Grouped foundations for premium companion controls.',
          ),
          const SizedBox(height: AppSpacing.lg),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SettingsGroupTitle('Theme'),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_rounded),
                      label: Text('System'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_rounded),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_rounded),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selection) {
                    ref.read(themeModeProvider.notifier).state =
                        selection.first;
                    ref
                        .read(snackbarServiceProvider)
                        .showSuccess(context, 'Theme updated');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PremiumCard(
            child: Column(
              children: [
                _SettingsSwitch(
                  title: 'Voice',
                  subtitle: 'Prepared for speech input and MAXie voice output.',
                  icon: Icons.mic_rounded,
                  value: true,
                  onChanged: (_) => _showFoundationMessage(
                    context,
                    'Voice settings are ready for Phase 3.',
                  ),
                ),
                const Divider(),
                _SettingsSwitch(
                  title: 'Notifications',
                  subtitle: 'Prepared for reminders and companion nudges.',
                  icon: Icons.notifications_rounded,
                  value: true,
                  onChanged: (_) => _showFoundationMessage(
                    context,
                    'Notification settings are ready.',
                  ),
                ),
                const Divider(),
                _SettingsSwitch(
                  title: 'Offline Preview',
                  subtitle: 'Preview global offline handling.',
                  icon: Icons.wifi_off_rounded,
                  value: isOffline,
                  onChanged: (value) {
                    ref
                        .read(connectivityServiceProvider)
                        .setOffline(value: value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const PremiumCard(
            child: Column(
              children: [
                _SettingsRow(
                  title: 'Privacy',
                  subtitle: 'Local-first controls foundation',
                  icon: Icons.lock_rounded,
                ),
                Divider(),
                _SettingsRow(
                  title: 'Developer Mode',
                  subtitle: 'Diagnostics and build information',
                  icon: Icons.code_rounded,
                ),
                Divider(),
                _SettingsRow(
                  title: 'About MAXie',
                  subtitle: 'Your AI Companion',
                  icon: Icons.info_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFoundationMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SettingsGroupTitle extends StatelessWidget {
  const _SettingsGroupTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: AppColors.calmTeal),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.calmTeal),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('$title foundation is ready.')));
      },
    );
  }
}
