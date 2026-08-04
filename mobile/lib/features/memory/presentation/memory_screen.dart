import 'package:flutter/material.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/app_text_field.dart';
import 'package:maxie_mobile/widgets/content_cards.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';
import 'package:maxie_mobile/widgets/section_title.dart';

class MemoryScreen extends StatelessWidget {
  const MemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Memory',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 108),
        children: [
          const SectionTitle(
            title: 'Memory Timeline',
            subtitle: "The foundation for MAXie's long-term context.",
          ),
          const SizedBox(height: AppSpacing.lg),
          const AppTextField(
            label: 'Search memories',
            prefixIcon: Icons.search_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final label in const ['Pinned', 'Work', 'Personal', 'Goals'])
                FilterChip(
                  label: Text(label),
                  selected: label == 'Pinned',
                  onSelected: (_) {},
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const MemoryCard(
            title: 'Pinned: Morning planning works best',
            subtitle: 'Relationship timeline placeholder',
            isPinned: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          const MemoryCard(
            title: 'Project Nebula review preference',
            subtitle: 'Saved context will appear here later.',
          ),
          const SizedBox(height: AppSpacing.lg),
          const PremiumCard(
            glowColor: AppColors.calmTeal,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.timeline_rounded, color: AppColors.calmTeal),
              title: Text("Let's create your first memory."),
              subtitle: Text('Future memory logic will plug into this timeline.'),
            ),
          ),
        ],
      ),
    );
  }
}
