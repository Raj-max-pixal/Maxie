import 'package:flutter/material.dart';
import 'package:maxie_mobile/shared/app_page.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/animated_card.dart';
import 'package:maxie_mobile/widgets/primary_button.dart';
import 'package:maxie_mobile/widgets/section_title.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPage(
      title: 'Subscription',
      child: ListView(
        children: [
          const SectionTitle(
            title: 'MAXie Plus',
            subtitle: 'A clean surface for Shipaton monetization work.',
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Companion plan',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Subscription UI is ready for RevenueCat integration in a later phase.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Continue',
                  icon: Icons.workspace_premium_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text(
                            'RevenueCat subscription flow is ready to connect.',
                          ),
                        ),
                      );
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
