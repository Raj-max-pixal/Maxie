import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/features/memory/application/memory_manager.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/pet/application/pet_controller.dart';
import 'package:maxie_mobile/features/pet/application/pet_providers.dart';
import 'package:maxie_mobile/features/pet/domain/models/pet_state.dart';
import 'package:maxie_mobile/navigation/app_routes.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/maxie_companion_view.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';

/// MAXie's calm command centre. It shows live local state only; connected-app
/// context is a permission surface until the user enables a real integration.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petStateProvider).valueOrNull ?? const PetState();
    final summary = ref.watch(memoryBrainSummaryProvider).valueOrNull;
    final memories = ref.watch(memoryBrainListProvider).valueOrNull ?? const [];
    final now = DateTime.now();
    final greeting = switch (now.hour) {
      >= 5 && < 12 => 'Good morning',
      >= 12 && < 18 => 'Good afternoon',
      _ => 'Good evening',
    };
    final recent = memories
        .where((memory) => !memory.isArchived)
        .take(2)
        .toList();

    return PremiumScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
        children: [
          _HomeHeader(greeting: greeting, pet: pet),
          const SizedBox(height: AppSpacing.lg),
          _CompanionHero(pet: pet),
          const SizedBox(height: AppSpacing.md),
          const _QuickActions(),
          const SizedBox(height: AppSpacing.xl),
          _SectionHeading(
            eyebrow: 'YOUR DAY',
            title: 'A little more in sync',
            action: TextButton(
              onPressed: () => context.push(AppRoutes.settings),
              child: const Text('Manage'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ContextCard(onConnect: () => _showConnections(context)),
          const SizedBox(height: AppSpacing.md),
          _PetPulseCard(pet: pet, ref: ref),
          const SizedBox(height: AppSpacing.md),
          _MemoryCard(
            count: summary?.totalMemories ?? memories.length,
            recent: recent,
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionHeading(eyebrow: 'EXPLORE', title: 'Your MAXie space'),
          const SizedBox(height: AppSpacing.sm),
          const _ExploreGrid(),
        ],
      ),
    ).animate().fadeIn(duration: 260.ms).slideY(begin: .015, end: 0);
  }

  void _showConnections(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.darkSurface,
      builder: (context) => const _ConnectionSheet(),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.greeting, required this.pet});
  final String greeting;
  final PetState pet;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: .58);
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [Color(0xFFB8F4DE), Color(0xFF67C6BF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFF102B31),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: muted),
              ),
              Text(
                'You and ${pet.name}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('MAXie will surface important notifications here.'),
            ),
          ),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}

class _CompanionHero extends StatelessWidget {
  const _CompanionHero({required this.pet});
  final PetState pet;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return PremiumCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
      glowColor: const Color(0xFF84E4C5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF84E4C5).withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    'MAXie is here',
                    style: TextStyle(
                      color: Color(0xFF9CEED1),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                Text(
                  pet.recentInteraction,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: onSurface,
                    fontWeight: FontWeight.w800,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Ask, plan, remember or just hang out.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: onSurface.withValues(alpha: .62),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 15),
                FilledButton.icon(
                  onPressed: () => context.push(AppRoutes.aiChat),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 17),
                  label: const Text('Talk to MAXie'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFB8F4DE),
                    foregroundColor: const Color(0xFF102B31),
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 125,
            height: 155,
            child: MaxieCompanionView(size: 132),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _QuickChip(
          icon: Icons.auto_awesome_rounded,
          label: 'Ask anything',
          onTap: () => context.push(AppRoutes.aiChat),
        ),
        _QuickChip(
          icon: Icons.bookmark_add_outlined,
          label: 'Remember this',
          onTap: () => context.push(AppRoutes.memory),
        ),
        _QuickChip(
          icon: Icons.route_rounded,
          label: 'Plan my day',
          onTap: () => context.push(AppRoutes.agentRun),
        ),
      ],
    ),
  );
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ActionChip(
      onPressed: onTap,
      avatar: Icon(icon, size: 16, color: const Color(0xFF9CEED1)),
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      side: BorderSide(color: Colors.white.withValues(alpha: .08)),
      backgroundColor: Colors.white.withValues(alpha: .055),
      padding: const EdgeInsets.symmetric(horizontal: 6),
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    this.action,
  });
  final String eyebrow;
  final String title;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFF8ADCC5),
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
      if (action != null) action!,
    ],
  );
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({required this.onConnect});
  final VoidCallback onConnect;
  @override
  Widget build(BuildContext context) => PremiumCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Row(
          children: [
            const _ContextIcon(
              icon: Icons.hub_outlined,
              color: Color(0xFF9CEED1),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Across your apps',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Choose what MAXie can notice and react to.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF98A5B8)),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: onConnect, child: const Text('Connect')),
          ],
        ),
        const SizedBox(height: 15),
        const Row(
          children: [
            Expanded(
              child: _AppPill(icon: Icons.chat_outlined, label: 'Messages'),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _AppPill(
                icon: Icons.play_circle_outline_rounded,
                label: 'YouTube',
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _AppPill(icon: Icons.music_note_rounded, label: 'Music'),
            ),
          ],
        ),
      ],
    ),
  );
}

class _ContextIcon extends StatelessWidget {
  const _ContextIcon({required this.icon, required this.color});
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Icon(icon, color: color, size: 20),
  );
}

class _AppPill extends StatelessWidget {
  const _AppPill({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .035),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: Colors.white.withValues(alpha: .06)),
    ),
    child: Column(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFB5C0D0)),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFFB5C0D0),
          ),
        ),
      ],
    ),
  );
}

class _PetPulseCard extends StatelessWidget {
  const _PetPulseCard({required this.pet, required this.ref});
  final PetState pet;
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) {
    final controller = ref.read(petControllerProvider.notifier);
    return PremiumCard(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.favorite_rounded,
                color: Color(0xFFF39AB7),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'MAXie pulse',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                'Lv ${pet.level}',
                style: const TextStyle(
                  color: Color(0xFF9CEED1),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Meter(
                label: 'Energy',
                value: pet.energy,
                color: const Color(0xFF9CEED1),
              ),
              const SizedBox(width: 10),
              _Meter(
                label: 'Happy',
                value: pet.happiness,
                color: const Color(0xFFF39AB7),
              ),
              const SizedBox(width: 10),
              _Meter(
                label: 'Full',
                value: 100 - pet.hunger,
                color: const Color(0xFFFFCD89),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _CareButton(
                icon: Icons.restaurant_rounded,
                label: 'Feed',
                onTap: () => controller.perform(PetAction.feed),
              ),
              _CareButton(
                icon: Icons.sports_esports_rounded,
                label: 'Play',
                onTap: () => controller.perform(PetAction.play),
              ),
              _CareButton(
                icon: Icons.nightlight_round,
                label: 'Rest',
                onTap: () => controller.perform(PetAction.sleep),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meter extends StatelessWidget {
  const _Meter({required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF98A5B8)),
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0, 1),
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: .07),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.round()}%',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class _CareButton extends StatelessWidget {
  const _CareButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 7),
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 15),
          label: Text(label, style: const TextStyle(fontSize: 11)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 36),
            padding: EdgeInsets.zero,
            foregroundColor: const Color(0xFFC7D1DF),
            side: BorderSide(color: Colors.white.withValues(alpha: .09)),
          ),
        ),
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({required this.count, required this.recent});
  final int count;
  final List<MemoryModel> recent;
  @override
  Widget build(BuildContext context) => PremiumCard(
    onTap: () => context.push(AppRoutes.memory),
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: const Color(0xFFB6A3FF).withValues(alpha: .13),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.psychology_alt_outlined,
            color: Color(0xFFB6A3FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Memory, with control',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                count == 0
                    ? 'MAXie has not saved anything yet.'
                    : '$count things saved for you',
                style: const TextStyle(fontSize: 12, color: Color(0xFF98A5B8)),
              ),
              if (recent.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  recent.first.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFB6A3FF),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: Color(0xFF7E8B9E)),
      ],
    ),
  );
}

class _ExploreGrid extends StatelessWidget {
  const _ExploreGrid();
  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 2,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 1.75,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    children: [
      const _ExploreTile(
        icon: Icons.pets_rounded,
        title: 'Companion studio',
        color: Color(0xFF9CEED1),
        route: AppRoutes.shimeji,
      ),
      const _ExploreTile(
        icon: Icons.layers_outlined,
        title: 'Live overlay',
        color: Color(0xFFFFCD89),
        route: AppRoutes.shimeji,
      ),
      const _ExploreTile(
        icon: Icons.shopping_bag_outlined,
        title: 'Character store',
        color: Color(0xFF9EC4FF),
        route: AppRoutes.subscription,
      ),
      const _ExploreTile(
        icon: Icons.graphic_eq_rounded,
        title: 'Voice + brain',
        color: Color(0xFFB6A3FF),
        route: AppRoutes.aiChat,
      ),
    ],
  );
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.route,
  });
  final IconData icon;
  final String title;
  final Color color;
  final String route;
  @override
  Widget build(BuildContext context) => PremiumCard(
    onTap: () => context.push(route),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ),
        const Icon(
          Icons.arrow_outward_rounded,
          size: 14,
          color: Color(0xFF7E8B9E),
        ),
      ],
    ),
  );
}

class _ConnectionSheet extends StatelessWidget {
  const _ConnectionSheet();
  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MAXie permissions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'MAXie can react to messages, videos and music only after you choose a connection. Nothing is monitored silently.',
              style: TextStyle(color: Color(0xFF98A5B8), height: 1.4),
            ),
            const SizedBox(height: 18),
            const _PermissionRow(
              icon: Icons.chat_outlined,
              label: 'Messages',
              detail: 'Coming with notification access',
            ),
            const _PermissionRow(
              icon: Icons.play_circle_outline_rounded,
              label: 'YouTube',
              detail: 'Coming with accessibility access',
            ),
            const _PermissionRow(
              icon: Icons.music_note_rounded,
              label: 'Music',
              detail: 'Coming with media session access',
            ),
          ],
        ),
      ),
    ),
  );
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.icon,
    required this.label,
    required this.detail,
  });
  final IconData icon;
  final String label;
  final String detail;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: const Color(0xFF9CEED1)),
    title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    subtitle: Text(
      detail,
      style: const TextStyle(fontSize: 11, color: Color(0xFF98A5B8)),
    ),
    trailing: const Icon(
      Icons.lock_outline_rounded,
      size: 17,
      color: Color(0xFF7E8B9E),
    ),
  );
}
