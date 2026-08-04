import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/navigation/app_routes.dart';
import 'package:maxie_mobile/shared/app_page.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/animated_card.dart';
import 'package:maxie_mobile/widgets/primary_button.dart';
import 'package:maxie_mobile/widgets/section_title.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPage(
      title: 'Home',
      child: ListView(
        children: [
          Text(
            'Good to see you.',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'MAXie is ready to listen, organize, and keep you moving.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'Companion check-in',
                  subtitle: 'Start with a simple conversation.',
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Open AI Chat',
                  icon: Icons.auto_awesome_rounded,
                  onPressed: () => context.go(AppRoutes.aiChat),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: const [
              _HomeMetric(label: 'Mood', value: 'Calm'),
              _HomeMetric(label: 'Focus', value: 'Ready'),
              _HomeMetric(label: 'Plan', value: 'Open'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeMetric extends StatelessWidget {
  const _HomeMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 180,
      child: AnimatedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
