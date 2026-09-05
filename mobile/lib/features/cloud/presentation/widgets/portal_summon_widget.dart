import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:maxie_mobile/features/cloud/data/services/device_sync_service.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';
import 'package:maxie_mobile/widgets/maxie_companion_view.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';

class PortalSummonWidget extends ConsumerWidget {
  const PortalSummonWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(deviceSyncServiceProvider);
    final syncNotifier = ref.read(deviceSyncServiceProvider.notifier);
    final theme = Theme.of(context);

    // Auto-arrive after a few seconds of cloud portal animation
    ref.listen<DeviceSyncState>(deviceSyncServiceProvider, (prev, next) {
      if (next.activeDevice == 'mobile' && next.status == 'traveling') {
        Future.delayed(const Duration(seconds: 4), () {
          syncNotifier.markArrived();
        });
      }
    });

    final isTraveling = syncState.status == 'traveling';
    final isMobileActive = syncState.activeDevice == 'mobile';

    return PremiumCard(
      glowColor: isTraveling
          ? const Color(0xFFC084FC)
          : (isMobileActive ? AppColors.calmTeal : Colors.blueGrey),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            if (isTraveling) ...[
              // Cosmic Portal Animation
              const MaxieCompanionView(
                state: CompanionPresence.traveling,
                size: 110,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'MAXie is traveling...',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .shimmer(duration: 1.seconds),
              Text(
                syncState.activeDevice == 'mobile'
                    ? 'Flying off your PC screen into your phone portal! ☁️✈️'
                    : 'Leaving your phone and returning to your PC desktop...',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ] else if (isMobileActive) ...[
              // Pet is Active on Mobile
              const MaxieCompanionView(
                state: CompanionPresence.happy,
                size: 110,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'MAXie is here on your Phone! 📱',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton.icon(
                onPressed: syncNotifier.sendPetToPC,
                icon: const Icon(Icons.cloud_upload_rounded),
                label: const Text('Send MAXie back to PC'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.seed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ] else ...[
              // Pet is Active on PC
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.computer_rounded, color: Colors.white54, size: 40),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'MAXie is currently on your PC 💻',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton.icon(
                onPressed: syncNotifier.summonPetFromPC,
                icon: const Icon(Icons.cloud_download_rounded),
                label: const Text('Summon MAXie to Phone'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.calmTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
