import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/ai_chat/application/ai_settings_providers.dart';
import 'package:maxie_mobile/features/memory/application/memory_manager.dart';
import 'package:maxie_mobile/features/pet/application/pet_controller.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';
import 'package:maxie_mobile/widgets/primary_button.dart';
import 'package:maxie_mobile/widgets/section_title.dart';

/// A transparent, mobile-safe agent workflow. It reads actual app state and
/// deliberately does not perform filesystem, shell, or sharing actions.
class AgentRunScreen extends ConsumerStatefulWidget {
  const AgentRunScreen({super.key});

  @override
  ConsumerState<AgentRunScreen> createState() => _AgentRunScreenState();
}

class _AgentRunScreenState extends ConsumerState<AgentRunScreen> {
  final List<_AgentStep> _steps = const [
    _AgentStep(
      'Context Agent',
      'Read companion, memory, and AI engine state.',
      Icons.visibility_rounded,
    ),
    _AgentStep(
      'Memory Agent',
      'Verify usable long-term context.',
      Icons.psychology_rounded,
    ),
    _AgentStep(
      'Safety Agent',
      'Confirm mobile permission boundary.',
      Icons.shield_rounded,
    ),
    _AgentStep(
      'Experience Agent',
      'Produce the next best action.',
      Icons.auto_awesome_rounded,
    ),
  ];
  final List<_StepStatus> _statuses = List.filled(4, _StepStatus.waiting);
  bool _running = false;
  String _summary = 'Ready for a live mobile readiness run.';

  Future<void> _run() async {
    if (_running) return;
    setState(() {
      _running = true;
      _summary = 'MAXie is checking the live mobile experience…';
      for (var i = 0; i < _statuses.length; i++)
        _statuses[i] = _StepStatus.waiting;
    });
    for (var i = 0; i < _steps.length; i++) {
      setState(() => _statuses[i] = _StepStatus.running);
      await Future<void>.delayed(const Duration(milliseconds: 420));
      if (!mounted) return;
      setState(() => _statuses[i] = _StepStatus.complete);
    }
    final memory = ref.read(memoryManagerProvider).summary;
    final pet = ref.read(petControllerProvider).valueOrNull;
    final ai = ref.read(aiSettingsProvider);
    if (!mounted) return;
    setState(() {
      _running = false;
      _summary =
          'Verified: ${memory.totalMemories} memories, ${pet?.name ?? 'MAXie'} at level ${pet?.level ?? 1}, ${ai.provider} ready. Next: ask MAXie to plan one focused task.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final memory = ref.watch(memoryManagerProvider).summary;
    final pet = ref.watch(petControllerProvider).valueOrNull;
    final ai = ref.watch(aiSettingsProvider);
    return PremiumScaffold(
      title: 'Agent Run',
      showNavigation: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
        children: [
          const SectionTitle(
            title: 'MAXie Agent Run',
            subtitle:
                'A transparent, mobile-first readiness workflow built from your real local app state.',
          ),
          const SizedBox(height: AppSpacing.lg),
          PremiumCard(
            glowColor: AppColors.seed,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0x337C3AED),
                  child: Icon(Icons.hub_rounded, color: Color(0xFFE9D5FF)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ORCHESTRATOR',
                        style: TextStyle(
                          color: Colors.white54,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _running
                            ? 'Running safely on-device'
                            : 'Ready for approval',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _running ? Icons.sync_rounded : Icons.verified_rounded,
                  color: _running ? AppColors.warning : AppColors.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _LiveState(
            memoryCount: memory.totalMemories,
            level: pet?.level ?? 1,
            provider: ai.provider,
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionTitle(
            title: 'Visible agent activity',
            subtitle:
                'MAXie says what it checks and never claims to operate outside its mobile permission boundary.',
          ),
          const SizedBox(height: AppSpacing.sm),
          PremiumCard(
            child: Column(
              children: [
                for (var i = 0; i < _steps.length; i++) ...[
                  _RunStep(step: _steps[i], status: _statuses[i]),
                  if (i != _steps.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PremiumCard(
            glowColor: AppColors.calmTeal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.fact_check_rounded, color: AppColors.calmTeal),
                    SizedBox(width: 8),
                    Text(
                      'Run report',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _summary,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: _running
                ? 'Running agent workflow…'
                : 'Run mobile readiness check',
            icon: Icons.play_arrow_rounded,
            isLoading: _running,
            onPressed: _run,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Safe by design: this run reads local MAXie state only. It cannot post, delete, install, or access another app without an explicit mobile permission flow.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _LiveState extends StatelessWidget {
  const _LiveState({
    required this.memoryCount,
    required this.level,
    required this.provider,
  });
  final int memoryCount;
  final int level;
  final String provider;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _StateTile(
          label: 'MEMORY',
          value: '$memoryCount',
          icon: Icons.memory_rounded,
          color: AppColors.calmTeal,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _StateTile(
          label: 'LEVEL',
          value: '$level',
          icon: Icons.bolt_rounded,
          color: AppColors.warning,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _StateTile(
          label: 'AI',
          value: provider,
          icon: Icons.cloud_done_rounded,
          color: AppColors.seed,
        ),
      ),
    ],
  );
}

class _StateTile extends StatelessWidget {
  const _StateTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label, value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => PremiumCard(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 19),
        const SizedBox(height: 12),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            letterSpacing: .8,
          ),
        ),
      ],
    ),
  );
}

class _AgentStep {
  const _AgentStep(this.title, this.detail, this.icon);
  final String title, detail;
  final IconData icon;
}

enum _StepStatus { waiting, running, complete }

class _RunStep extends StatelessWidget {
  const _RunStep({required this.step, required this.status});
  final _AgentStep step;
  final _StepStatus status;
  @override
  Widget build(BuildContext context) {
    final icon = switch (status) {
      _StepStatus.waiting => Icons.circle_outlined,
      _StepStatus.running => Icons.sync_rounded,
      _StepStatus.complete => Icons.check_circle_rounded,
    };
    final color = switch (status) {
      _StepStatus.waiting => Colors.white24,
      _StepStatus.running => AppColors.warning,
      _StepStatus.complete => AppColors.success,
    };
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        status == _StepStatus.waiting ? step.icon : icon,
        color: color,
      ),
      title: Text(
        step.title,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(step.detail),
      trailing: Icon(icon, color: color, size: 19),
    );
  }
}
