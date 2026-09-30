import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/features/mission_control/data/maxie_roadmap.dart';
import 'package:maxie_mobile/features/mission_control/domain/models/maxie_phase.dart';
import 'package:maxie_mobile/navigation/app_routes.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';
import 'package:maxie_mobile/widgets/section_title.dart';

final maxieRoadmapProvider = Provider<List<MaxiePhase>>(
  (ref) => maxieRoadmapPhases,
);

class MissionControlScreen extends ConsumerWidget {
  const MissionControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final phases = ref.watch(maxieRoadmapProvider);
    final progress = roadmapProgressPercent(phases);
    final current = currentMissionPhase(phases);
    final completed =
        phases.where((p) => p.status == MaxiePhaseStatus.complete).length;

    return PremiumScaffold(
      title: 'Mission Control',
      showNavigation: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            '🚀 MAXie Mission Control',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF93C5FD),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cross-platform AI companion — build order and phase status.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: AppSpacing.lg),
          PremiumCard(
            glowColor: AppColors.seed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Project progress', style: TextStyle(fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Text(
                      '${progress.round()}%',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFE9D5FF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 10,
                    backgroundColor: const Color(0xFF202A3D),
                    color: AppColors.calmTeal,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$completed of ${phases.length} phases shipped',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 280.ms),
          if (current != null) ...[
            const SizedBox(height: AppSpacing.lg),
            PremiumCard(
              glowColor: AppColors.warmCoral,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT MISSION',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white54,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    current.missionLabel ?? current.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Phase ${current.paddedNumber} · ${current.summary}',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 80.ms),
          ],
          const SizedBox(height: AppSpacing.lg),
          const SectionTitle(
            title: 'Phases',
            subtitle: 'Stable layers first — AI, desktop, and Universe plug in later.',
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final phase in phases)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _PhaseTile(phase: phase),
            ),
          const SizedBox(height: AppSpacing.md),
          PremiumCard(
            glowColor: AppColors.calmTeal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🚢 Shipathon mission',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: AppSpacing.sm),
                const ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  child: LinearProgressIndicator(
                    value: 0.78,
                    minHeight: 8,
                    backgroundColor: Color(0xFF202A3D),
                    color: Color(0xFF93C5FD),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Demo loop: Chat → Memory → Home → Pet / Shimeji',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.go(AppRoutes.aiChat),
                      icon: const Icon(Icons.chat_rounded, size: 18),
                      label: const Text('Open Chat'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go(AppRoutes.shimeji),
                      icon: const Icon(Icons.auto_awesome_motion_rounded, size: 18),
                      label: const Text('Shimeji demo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseTile extends StatelessWidget {
  const _PhaseTile({required this.phase});

  final MaxiePhase phase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = phase.status == MaxiePhaseStatus.locked;

    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      glowColor: phase.status == MaxiePhaseStatus.inProgress
          ? AppColors.warmCoral
          : AppColors.darkStroke,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(phase.statusEmoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${phase.paddedNumber} ${phase.title}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: muted ? Colors.white38 : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phase.summary,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: muted ? Colors.white30 : Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
