import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsSection(
            title: 'MAXie Appearance',
            children: [
              SettingsTile(
                icon: Icons.pets,
                title: 'MAXie Size',
                subtitle: 'Adjust MAXie\'s size',
                trailing: DropdownButton<double>(
                  value: settings.maxieSize,
                  items: const [
                    DropdownMenuItem(value: 0.8, child: Text('Small')),
                    DropdownMenuItem(value: 1.0, child: Text('Medium')),
                    DropdownMenuItem(value: 1.2, child: Text('Large')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(settingsProvider.notifier).updateMaxieSize(value);
                    }
                  },
                ),
              ),
              SettingsTile(
                icon: Icons.opacity,
                title: 'Transparency',
                subtitle: 'Adjust overlay transparency',
                trailing: Slider(
                  value: settings.overlayTransparency,
                  min: 0.3,
                  max: 1.0,
                  divisions: 7,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).updateOverlayTransparency(value);
                  },
                ),
              ),
              SettingsTile(
                icon: Icons.animation,
                title: 'Animation Speed',
                subtitle: 'Adjust animation smoothness',
                trailing: DropdownButton<String>(
                  value: settings.animationSpeed,
                  items: const [
                    DropdownMenuItem(value: 'slow', child: Text('Slow')),
                    DropdownMenuItem(value: 'normal', child: Text('Normal')),
                    DropdownMenuItem(value: 'fast', child: Text('Fast')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(settingsProvider.notifier).updateAnimationSpeed(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSection(
            title: 'Overlay Mode',
            children: [
              SettingsTile(
                icon: Icons.overlay_outlined,
                title: 'Enable Overlay',
                subtitle: 'Show MAXie over other apps',
                trailing: Switch(
                  value: settings.overlayEnabled,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).toggleOverlay(value);
                  },
                ),
              ),
              SettingsTile(
                icon: Icons.lock_outline,
                title: 'Lock Position',
                subtitle: 'Prevent accidental movement',
                trailing: Switch(
                  value: settings.overlayLocked,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).toggleOverlayLock(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSection(
            title: 'Voice & Sound',
            children: [
              SettingsTile(
                icon: Icons.volume_up,
                title: 'Voice Output',
                subtitle: 'MAXie speaks to you',
                trailing: Switch(
                  value: settings.voiceEnabled,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).toggleVoice(value);
                  },
                ),
              ),
              SettingsTile(
                icon: Icons.mic,
                title: 'Voice Input',
                subtitle: 'Talk to MAXie',
                trailing: Switch(
                  value: settings.speechToTextEnabled,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).toggleSpeechToText(value);
                  },
                ),
              ),
              SettingsTile(
                icon: Icons.music_note,
                title: 'Sound Effects',
                subtitle: 'Play MAXie sounds',
                trailing: Switch(
                  value: settings.soundEffectsEnabled,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).toggleSoundEffects(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSection(
            title: 'AI Settings',
            children: [
              SettingsTile(
                icon: Icons.psychology,
                title: 'AI Provider',
                subtitle: settings.aiProvider,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Show AI provider selection
                },
              ),
              SettingsTile(
                icon: Icons.key,
                title: 'API Key',
                subtitle: 'Configure Gemini API key',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showApiKeyDialog(context, ref);
                },
              ),
              SettingsTile(
                icon: Icons.cloud_off,
                title: 'Offline Mode',
                subtitle: 'Use local AI when possible',
                trailing: Switch(
                  value: settings.offlineMode,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).toggleOfflineMode(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSection(
            title: 'Notifications',
            children: [
              SettingsTile(
                icon: Icons.notifications,
                title: 'Notification Reactions',
                subtitle: 'React to incoming notifications',
                trailing: Switch(
                  value: settings.notificationReactionsEnabled,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).toggleNotificationReactions(value);
                  },
                ),
              ),
              SettingsTile(
                icon: Icons.phone,
                title: 'Call Reactions',
                subtitle: 'React to phone calls',
                trailing: Switch(
                  value: settings.callReactionsEnabled,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).toggleCallReactions(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSection(
            title: 'Theme',
            children: [
              SettingsTile(
                icon: Icons.palette,
                title: 'App Theme',
                subtitle: settings.theme,
                trailing: DropdownButton<String>(
                  value: settings.theme,
                  items: const [
                    DropdownMenuItem(value: 'system', child: Text('System')),
                    DropdownMenuItem(value: 'light', child: Text('Light')),
                    DropdownMenuItem(value: 'dark', child: Text('Dark')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(settingsProvider.notifier).updateTheme(value);
                    }
                  },
                ),
              ),
              SettingsTile(
                icon: Icons.style,
                title: 'MAXie Theme',
                subtitle: 'Customize MAXie appearance',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Show MAXie theme selection
               },
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSection(
            title: 'Privacy & Data',
            children: [
              SettingsTile(
                icon: Icons.delete_outline,
                title: 'Clear Chat History',
                subtitle: 'Delete all conversation history',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showClearChatDialog(context, ref);
                },
              ),
              SettingsTile(
                icon: Icons.refresh,
                title: 'Reset MAXie',
                subtitle: 'Reset friendship and memory',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showResetDialog(context, ref);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSection(
            title: 'About',
            children: [
              SettingsTile(
                icon: Icons.info,
                title: 'Version',
                subtitle: '1.0.0',
              ),
              SettingsTile(
                icon: Icons.favorite,
                title: 'Rate MAXie',
                subtitle: 'Love MAXie? Leave a review!',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Open Play Store
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Gemini API Key'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your API key',
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).updateApiKey(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat History?'),
        content: const Text('This will delete all your conversations with MAXie. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).clearChatHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset MAXie?'),
        content: const Text('This will reset your friendship level, memory, and all settings. MAXie will be like a new companion. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).resetMaxie();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
