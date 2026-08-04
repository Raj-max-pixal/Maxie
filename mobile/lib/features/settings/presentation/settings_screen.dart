import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/config/app_state.dart';
import 'package:maxie_mobile/services/connectivity_service.dart';
import 'package:maxie_mobile/services/snackbar_service.dart';
import 'package:maxie_mobile/shared/app_page.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/animated_card.dart';
import 'package:maxie_mobile/widgets/section_title.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isOffline = ref.watch(offlineProvider);

    return AppPage(
      title: 'Settings',
      child: ListView(
        children: [
          const SectionTitle(
            title: 'App preferences',
            subtitle: 'Control the foundation-level experience.',
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedCard(
            child: Column(
              children: [
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
                const Divider(height: AppSpacing.xl),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Offline mode'),
                  subtitle: const Text('Preview global offline handling.'),
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
        ],
      ),
    );
  }
}
