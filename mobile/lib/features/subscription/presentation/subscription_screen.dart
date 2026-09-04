import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/monetization/application/monetization_providers.dart';
import 'package:maxie_mobile/features/monetization/domain/models/monetization_state.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/loading_indicator.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';
import 'package:maxie_mobile/widgets/primary_button.dart';
import 'package:maxie_mobile/widgets/section_title.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isWorking = false;

  @override
  Widget build(BuildContext context) {
    final monetization = ref.watch(monetizationStateProvider);

    return PremiumScaffold(
      title: 'MAXie Plus',
      child: monetization.when(
        loading: () => const LoadingIndicator(message: 'Checking MAXie Plus'),
        error: (error, stackTrace) => _PaywallBody(
          state: MonetizationState(
            status: MonetizationStatus.error,
            message: error.toString(),
          ),
          isWorking: _isWorking,
          onPurchase: _purchase,
          onRestore: _restore,
        ),
        data: (state) => _PaywallBody(
          state: state,
          isWorking: _isWorking,
          onPurchase: _purchase,
          onRestore: _restore,
        ),
      ),
    );
  }

  Future<void> _purchase() async {
    await _run(() => ref.read(revenueCatServiceProvider).purchaseMaxiePlus());
  }

  Future<void> _restore() async {
    await _run(() => ref.read(revenueCatServiceProvider).restorePurchases());
  }

  Future<void> _run(Future<MonetizationState> Function() action) async {
    setState(() => _isWorking = true);
    final result = await action();
    if (mounted) {
      setState(() => _isWorking = false);
      ref.invalidate(monetizationStateProvider);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.message)));
    }
  }
}

class _PaywallBody extends StatelessWidget {
  const _PaywallBody({
    required this.state,
    required this.isWorking,
    required this.onPurchase,
    required this.onRestore,
  });

  final MonetizationState state;
  final bool isWorking;
  final VoidCallback onPurchase;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLive =
        state.status == MonetizationStatus.ready ||
        state.status == MonetizationStatus.active;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 108),
      children: [
        const SectionTitle(
          title: 'MAXie Plus',
          subtitle: 'RevenueCat-powered upgrade path for Shipathon.',
        ),
        const SizedBox(height: AppSpacing.lg),
        PremiumCard(
          glowColor: state.isPremium ? AppColors.success : AppColors.seed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    state.isPremium
                        ? Icons.verified_rounded
                        : Icons.workspace_premium_rounded,
                    color: state.isPremium ? AppColors.success : AppColors.seed,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      state.isPremium
                          ? 'MAXie Plus active'
                          : 'Unlock MAXie Plus',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                state.message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _BenefitRow(
                icon: Icons.record_voice_over_rounded,
                title: 'Advanced voice companion',
                subtitle: 'A natural next upgrade after the free chat loop.',
              ),
              _BenefitRow(
                icon: Icons.cloud_sync_rounded,
                title: 'Cloud memory sync',
                subtitle: 'Keep personal memories across devices.',
              ),
              _BenefitRow(
                icon: Icons.auto_awesome_rounded,
                title: 'Premium companion styles',
                subtitle: 'A viral reason to share MAXie screenshots.',
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: isWorking
                    ? 'Working'
                    : isLive
                    ? 'Continue'
                    : 'RevenueCat Demo Mode',
                icon: Icons.shopping_bag_rounded,
                onPressed: isWorking ? null : onPurchase,
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: isWorking ? null : onRestore,
                icon: const Icon(Icons.restore_rounded),
                label: const Text('Restore purchases'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        PremiumCard(
          glowColor: AppColors.warmCoral,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Growth strategy',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Free users get the core companion. MAXie Plus monetizes power users with voice, sync, and collectible companion styles without blocking the viral first experience.',
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  Chip(label: Text('Status: ${state.status.name}')),
                  if (state.offeringId != null)
                    Chip(label: Text('Offering: ${state.offeringId}')),
                  Chip(label: Text('Packages: ${state.packageCount}')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.calmTeal),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
