import 'package:flutter/material.dart';
import 'package:maxie_mobile/shared/app_page.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/animated_card.dart';
import 'package:maxie_mobile/widgets/app_empty_state.dart';
import 'package:maxie_mobile/widgets/app_text_field.dart';
import 'package:maxie_mobile/widgets/section_title.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Profile',
      child: ListView(
        children: const [
          SectionTitle(
            title: 'Your space',
            subtitle: 'Basic identity settings for the companion experience.',
          ),
          SizedBox(height: AppSpacing.lg),
          AnimatedCard(
            child: Column(
              children: [
                AppTextField(
                  label: 'Display name',
                  hintText: 'How should MAXie greet you?',
                  prefixIcon: Icons.badge_rounded,
                ),
                SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Primary goal',
                  hintText: 'Focus, learning, planning',
                  prefixIcon: Icons.flag_rounded,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 260,
            child: AppEmptyState(
              title: 'No saved memories yet',
              message: 'Memories will appear after companion features are built.',
              icon: Icons.bookmark_border_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
