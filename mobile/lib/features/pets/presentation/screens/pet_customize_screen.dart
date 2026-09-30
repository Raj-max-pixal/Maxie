 import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/shared/widgets/glass_card.dart';

class PetCustomizeScreen extends ConsumerWidget {
  final String petId;
  const PetCustomizeScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Customize Pet')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              children: [
                const CircleAvatar(radius: 60, child: Icon(Icons.pets, size: 48)),
                const SizedBox(height: 16),
                Text('Pet ID: $petId', style: theme.textTheme.titleMedium),
                const SizedBox(height: 24),
                _buildOption(theme, Icons.palette_outlined, 'Color'),
                _buildOption(theme, Icons.looks_one_outlined, 'Name'),
                _buildOption(theme, Icons.whatshot_outlined, 'Aura'),
                _buildOption(theme, Icons.straighten_outlined, 'Size'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(ThemeData theme, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}