import 'package:flutter/material.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/maxie_companion_view.dart';
import 'package:maxie_mobile/widgets/metric_widgets.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';
import 'package:maxie_mobile/widgets/primary_button.dart';
import 'package:maxie_mobile/widgets/section_title.dart';

class PetScreen extends StatelessWidget {
  const PetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Companion',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 108),
        children: [
          const Center(
            child: MaxieCompanionView(
              state: CompanionPresence.excited,
              size: 240,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const PremiumCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mood'),
                Chip(
                  avatar: Icon(Icons.favorite_rounded, size: 16),
                  label: Text('Happy'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const XpProgressCard(level: 7, progress: 0.68),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Feed',
                  icon: Icons.restaurant_rounded,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sports_esports_rounded),
                  label: const Text('Play'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.palette_rounded),
            label: const Text('Customize'),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionTitle(
            title: 'Future Accessories',
            subtitle: 'Hats, trails, rooms and companion styles will attach here.',
          ),
          const SizedBox(height: AppSpacing.sm),
          const StatCard(
            label: 'Animation State',
            value: 'Idle',
            icon: Icons.motion_photos_auto_rounded,
            color: AppColors.calmTeal,
          ),
        ],
      ),
    );
  }
}
