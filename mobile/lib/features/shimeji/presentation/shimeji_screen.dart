import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/shimeji/application/shimeji_providers.dart';
import 'package:maxie_mobile/features/shimeji/domain/models/shimeji_models.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';
import 'package:maxie_mobile/widgets/primary_button.dart';
import 'package:maxie_mobile/widgets/section_title.dart';

class ShimejiScreen extends ConsumerStatefulWidget {
  const ShimejiScreen({super.key});

  @override
  ConsumerState<ShimejiScreen> createState() => _ShimejiScreenState();
}

class _ShimejiScreenState extends ConsumerState<ShimejiScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  DateTime _lastTick = DateTime.now();
  Size _arenaSize = Size.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_arenaSize == Size.zero || !mounted) {
        return;
      }
      final now = DateTime.now();
      final dt = now.difference(_lastTick).inMilliseconds / 1000;
      _lastTick = now;
      ref.read(shimejiControllerProvider.notifier).tick(_arenaSize, dt);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = ref.read(shimejiControllerProvider.notifier);
    final settings = ref.read(shimejiControllerProvider).settings;
    controller.updateSettings(
      settings.copyWith(paused: state != AppLifecycleState.resumed),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    ref.read(shimejiControllerProvider.notifier).save();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shimejiControllerProvider);
    final controller = ref.read(shimejiControllerProvider.notifier);
    final selected = state.selectedPet;

    return PremiumScaffold(
      title: 'Shimeji',
      actions: [
        IconButton(
          tooltip: 'Debug',
          onPressed: () => controller.updateSettings(
            state.settings.copyWith(debugEnabled: !state.settings.debugEnabled),
          ),
          icon: Icon(
            state.settings.debugEnabled
                ? Icons.bug_report_rounded
                : Icons.bug_report_outlined,
          ),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        children: [
          _ShimejiStage(
            state: state,
            onTapPet: (id) => controller.interact(id, ShimejiAnimation.love),
            onDoubleTapPet: (id) =>
                controller.interact(id, ShimejiAnimation.dance),
            onLongPressPet: (pet) => _showPetControls(context, pet),
            onDragStart: controller.startDrag,
            onDragUpdate: (id, delta) =>
                controller.dragPet(id, delta, _arenaSize),
            onDragEnd: controller.throwPet,
            onSizeChanged: (size) => _arenaSize = size,
          ),
          const SizedBox(height: AppSpacing.lg),
          _StatusStrip(state: state),
          const SizedBox(height: AppSpacing.lg),
          const SectionTitle(
            title: 'Characters',
            subtitle:
                'Original free companions; more packs can be added later.',
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 154,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.pets.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final pet = state.pets[index];
                return _CharacterCard(
                  pet: pet,
                  selected: pet.id == state.selectedPetId,
                  onTap: () => pet.unlocked
                      ? controller.selectPet(pet.id)
                      : controller.unlockWithXp(pet.id),
                  onSpawn: () => controller.spawnPet(pet.id),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (selected != null) ...[
            const SectionTitle(
              title: 'Actions',
              subtitle: 'Tap, drag, throw, or trigger an animation.',
            ),
            const SizedBox(height: AppSpacing.sm),
            _ActionGrid(
              selectedPetId: selected.id,
              onAction: controller.interact,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          _CustomizationPanel(
            state: state,
            onSettingsChanged: controller.updateSettings,
            onOverlayChanged: controller.toggleOverlay,
            onReset: controller.resetPositions,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (state.settings.debugEnabled) _DebugPanel(state: state),
        ],
      ),
    );
  }

  void _showPetControls(BuildContext context, ShimejiPet pet) {
    final controller = ref.read(shimejiControllerProvider.notifier);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkSurface,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.visibility_off_rounded),
                  title: Text('Hide ${pet.displayName}'),
                  onTap: () {
                    controller.despawnPet(pet.id);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.my_location_rounded),
                  title: const Text('Reset positions'),
                  onTap: () {
                    controller.resetPositions();
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report_rounded),
                  title: const Text('Toggle debug tools'),
                  onTap: () {
                    final settings = ref
                        .read(shimejiControllerProvider)
                        .settings;
                    controller.updateSettings(
                      settings.copyWith(debugEnabled: !settings.debugEnabled),
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShimejiStage extends StatelessWidget {
  const _ShimejiStage({
    required this.state,
    required this.onTapPet,
    required this.onDoubleTapPet,
    required this.onLongPressPet,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onSizeChanged,
  });

  final ShimejiState state;
  final ValueChanged<String> onTapPet;
  final ValueChanged<String> onDoubleTapPet;
  final ValueChanged<ShimejiPet> onLongPressPet;
  final ValueChanged<String> onDragStart;
  final void Function(String id, Offset delta) onDragUpdate;
  final ValueChanged<String> onDragEnd;
  final ValueChanged<Size> onSizeChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stageSize = Size(constraints.maxWidth, 430);
        onSizeChanged(stageSize);

        return PremiumCard(
          child: SizedBox(
            height: stageSize.height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _StagePainter(
                      paused: state.settings.paused,
                      overlayEnabled: state.settings.overlayEnabled,
                    ),
                  ),
                ),
                if (state.settings.hidden)
                  const Center(child: Text('Screen pets are hidden')),
                for (final pet in state.pets)
                  if (pet.visible && !state.settings.hidden)
                    _PositionedPet(
                      pet: pet,
                      selected: pet.id == state.selectedPetId,
                      settings: state.settings,
                      onTap: () => onTapPet(pet.id),
                      onDoubleTap: () => onDoubleTapPet(pet.id),
                      onLongPress: () => onLongPressPet(pet),
                      onDragStart: () => onDragStart(pet.id),
                      onDragUpdate: (delta) => onDragUpdate(pet.id, delta),
                      onDragEnd: () => onDragEnd(pet.id),
                    ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: _OverlayBanner(status: state.overlayStatus),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PositionedPet extends StatelessWidget {
  const _PositionedPet({
    required this.pet,
    required this.selected,
    required this.settings,
    required this.onTap,
    required this.onDoubleTap,
    required this.onLongPress,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final ShimejiPet pet;
  final bool selected;
  final ShimejiSettings settings;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback onLongPress;
  final VoidCallback onDragStart;
  final ValueChanged<Offset> onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    final petSize = 78 * pet.scale * settings.petSize;

    return AnimatedPositioned(
      duration: settings.reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 80),
      left: pet.x,
      top: pet.y,
      child: Opacity(
        opacity: settings.opacity,
        child: GestureDetector(
          onTap: settings.interactionEnabled ? onTap : null,
          onDoubleTap: settings.interactionEnabled ? onDoubleTap : null,
          onLongPress: settings.interactionEnabled ? onLongPress : null,
          onPanStart: settings.interactionEnabled ? (_) => onDragStart() : null,
          onPanUpdate: settings.interactionEnabled
              ? (details) => onDragUpdate(details.delta)
              : null,
          onPanEnd: settings.interactionEnabled ? (_) => onDragEnd() : null,
          child: SizedBox.square(
            dimension: petSize,
            child: CustomPaint(
              painter: _AnimePetPainter(
                pet: pet,
                selected: selected,
                tick: DateTime.now().millisecondsSinceEpoch,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.state});

  final ShimejiState state;

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedPet;
    return Row(
      children: [
        Expanded(
          child: _MiniMetric(
            icon: Icons.groups_rounded,
            label: 'Pets',
            value: '${state.visiblePetCount}/${state.pets.length}',
            color: AppColors.calmTeal,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MiniMetric(
            icon: Icons.favorite_rounded,
            label: 'XP',
            value: '${selected?.xp ?? 0}',
            color: AppColors.warmCoral,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MiniMetric(
            icon: Icons.movie_filter_rounded,
            label: 'State',
            value: selected?.currentAnimation.name ?? 'idle',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({
    required this.pet,
    required this.selected,
    required this.onTap,
    required this.onSpawn,
  });

  final ShimejiPet pet;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onSpawn;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: PremiumCard(
          glowColor: selected ? Color(pet.accentColor) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox.square(
                    dimension: 38,
                    child: CustomPaint(
                      painter: _AnimePetPainter(
                        pet: pet.copyWith(
                          currentAnimation: pet.unlocked
                              ? ShimejiAnimation.happy
                              : ShimejiAnimation.sleep,
                        ),
                        selected: selected,
                        tick: 0,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    pet.unlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                    size: 18,
                    color: pet.unlocked ? AppColors.success : Colors.white54,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                pet.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                pet.personality.name,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                pet.unlocked ? (pet.visible ? 'Active' : 'Owned') : 'Unlock XP',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: pet.unlocked ? AppColors.calmTeal : AppColors.warning,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (pet.unlocked && !pet.visible)
                TextButton(onPressed: onSpawn, child: const Text('Show')),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.selectedPetId, required this.onAction});

  final String selectedPetId;
  final void Function(String id, ShimejiAnimation animation) onAction;

  @override
  Widget build(BuildContext context) {
    final actions = <(String, IconData, ShimejiAnimation)>[
      ('Walk', Icons.directions_walk_rounded, ShimejiAnimation.walk),
      ('Run', Icons.directions_run_rounded, ShimejiAnimation.run),
      ('Jump', Icons.arrow_upward_rounded, ShimejiAnimation.jump),
      ('Sit', Icons.event_seat_rounded, ShimejiAnimation.sit),
      ('Sleep', Icons.bedtime_rounded, ShimejiAnimation.sleep),
      ('Dance', Icons.music_note_rounded, ShimejiAnimation.dance),
      ('Eat', Icons.restaurant_rounded, ShimejiAnimation.eat),
      ('Listen', Icons.hearing_rounded, ShimejiAnimation.listen),
      ('Think', Icons.psychology_rounded, ShimejiAnimation.think),
      ('Wave', Icons.waving_hand_rounded, ShimejiAnimation.wave),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: 2.8,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        for (final action in actions)
          OutlinedButton.icon(
            onPressed: () => onAction(selectedPetId, action.$3),
            icon: Icon(action.$2),
            label: Text(action.$1),
          ),
      ],
    );
  }
}

class _CustomizationPanel extends StatelessWidget {
  const _CustomizationPanel({
    required this.state,
    required this.onSettingsChanged,
    required this.onOverlayChanged,
    required this.onReset,
  });

  final ShimejiState state;
  final ValueChanged<ShimejiSettings> onSettingsChanged;
  final ValueChanged<bool> onOverlayChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final settings = state.settings;
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Screen Pet Settings',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            value: settings.overlayEnabled,
            onChanged: onOverlayChanged,
            contentPadding: EdgeInsets.zero,
            title: const Text('Show over other apps'),
            subtitle: const Text(
              'Demo stage today; Android overlay is the next release step.',
            ),
          ),
          SwitchListTile(
            value: !settings.hidden,
            onChanged: (value) =>
                onSettingsChanged(settings.copyWith(hidden: !value)),
            contentPadding: EdgeInsets.zero,
            title: const Text('Show pets'),
          ),
          SwitchListTile(
            value: settings.autoMovement,
            onChanged: (value) =>
                onSettingsChanged(settings.copyWith(autoMovement: value)),
            contentPadding: EdgeInsets.zero,
            title: const Text('Auto movement'),
          ),
          SwitchListTile(
            value: settings.interactionEnabled,
            onChanged: (value) =>
                onSettingsChanged(settings.copyWith(interactionEnabled: value)),
            contentPadding: EdgeInsets.zero,
            title: const Text('Touch interaction'),
          ),
          SwitchListTile(
            value: settings.batterySaver,
            onChanged: (value) =>
                onSettingsChanged(settings.copyWith(batterySaver: value)),
            contentPadding: EdgeInsets.zero,
            title: const Text('Battery saver'),
          ),
          SwitchListTile(
            value: settings.reducedMotion,
            onChanged: (value) =>
                onSettingsChanged(settings.copyWith(reducedMotion: value)),
            contentPadding: EdgeInsets.zero,
            title: const Text('Reduced motion'),
          ),
          SwitchListTile(
            value: settings.soundEnabled,
            onChanged: (value) =>
                onSettingsChanged(settings.copyWith(soundEnabled: value)),
            contentPadding: EdgeInsets.zero,
            title: const Text('Pet sounds'),
            subtitle: const Text('Prepared; no copyrighted audio is bundled.'),
          ),
          SwitchListTile(
            value: settings.notificationsEnabled,
            onChanged: (value) => onSettingsChanged(
              settings.copyWith(notificationsEnabled: value),
            ),
            contentPadding: EdgeInsets.zero,
            title: const Text('Pet notifications'),
          ),
          _SliderRow(
            label: 'Pet size',
            value: settings.petSize,
            min: 0.7,
            max: 1.6,
            onChanged: (value) =>
                onSettingsChanged(settings.copyWith(petSize: value)),
          ),
          _SliderRow(
            label: 'Movement speed',
            value: settings.movementSpeed,
            min: 0.5,
            max: 1.8,
            onChanged: (value) =>
                onSettingsChanged(settings.copyWith(movementSpeed: value)),
          ),
          _SliderRow(
            label: 'Opacity',
            value: settings.opacity,
            min: 0.35,
            max: 1,
            onChanged: (value) =>
                onSettingsChanged(settings.copyWith(opacity: value)),
          ),
          _SliderRow(
            label: 'Volume',
            value: settings.volume,
            min: 0,
            max: 1,
            onChanged: (value) =>
                onSettingsChanged(settings.copyWith(volume: value)),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: settings.hidden ? 'Show Pet' : 'Hide Pet',
                  icon: settings.hidden
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  onPressed: () => onSettingsChanged(
                    settings.copyWith(hidden: !settings.hidden),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.my_location_rounded),
                  label: const Text('Reset'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DebugPanel extends StatelessWidget {
  const _DebugPanel({required this.state});

  final ShimejiState state;

  @override
  Widget build(BuildContext context) {
    final pet = state.selectedPet;
    return PremiumCard(
      glowColor: AppColors.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Developer Debug',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          _DebugLine(
            'FPS target',
            state.settings.batterySaver ? '15-20' : '30-60',
          ),
          _DebugLine('Pet count', '${state.visiblePetCount} visible'),
          _DebugLine('Overlay', state.overlayStatus),
          _DebugLine('Current state', pet?.currentAnimation.name ?? 'none'),
          _DebugLine('Mood', pet?.mood.name ?? 'none'),
          _DebugLine(
            'Position',
            pet == null ? 'none' : '${pet.x.round()}, ${pet.y.round()}',
          ),
          _DebugLine(
            'Velocity',
            pet == null ? 'none' : '${pet.vx.round()}, ${pet.vy.round()}',
          ),
          _DebugLine('Friendship', '${pet?.friendship ?? 0}'),
          _DebugLine('XP', '${pet?.xp ?? 0}'),
          const _DebugLine('Memory', 'local Hive state'),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ${(value * 100).round()}%'),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}

class _DebugLine extends StatelessWidget {
  const _DebugLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 116,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayBanner extends StatelessWidget {
  const _OverlayBanner({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            const Icon(Icons.layers_rounded, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                status,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StagePainter extends CustomPainter {
  const _StagePainter({required this.paused, required this.overlayEnabled});

  final bool paused;
  final bool overlayEnabled;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF111827), Color(0xFF0F172A), Color(0xFF182136)],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18)),
      paint,
    );

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y < size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final groundPaint = Paint()
      ..color = (overlayEnabled ? AppColors.calmTeal : AppColors.seed)
          .withValues(alpha: 0.35)
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(10, size.height - 6),
      Offset(size.width - 10, size.height - 6),
      groundPaint,
    );

    if (paused) {
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'Paused',
          style: TextStyle(color: Colors.white54, fontSize: 18),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset((size.width - textPainter.width) / 2, 18),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StagePainter oldDelegate) {
    return paused != oldDelegate.paused ||
        overlayEnabled != oldDelegate.overlayEnabled;
  }
}

class _AnimePetPainter extends CustomPainter {
  const _AnimePetPainter({
    required this.pet,
    required this.selected,
    required this.tick,
  });

  final ShimejiPet pet;
  final bool selected;
  final int tick;

  @override
  void paint(Canvas canvas, Size size) {
    final wobble = sin(tick / 140) * size.height * 0.035;
    final bodyRect = Rect.fromLTWH(
      size.width * 0.18,
      size.height * 0.18 + wobble,
      size.width * 0.64,
      size.height * 0.64,
    );
    final color = Color(pet.color);
    final accent = Color(pet.accentColor);

    final shadowPaint = Paint()
      ..color = color.withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.86),
        width: size.width * 0.56,
        height: size.height * 0.14,
      ),
      shadowPaint,
    );

    final hairPaint = Paint()..color = color.withValues(alpha: 0.82);
    final hairPath = Path()
      ..moveTo(size.width * 0.24, size.height * 0.36 + wobble)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.02 + wobble,
        size.width * 0.76,
        size.height * 0.36 + wobble,
      )
      ..quadraticBezierTo(
        size.width * 0.70,
        size.height * 0.22 + wobble,
        size.width * 0.62,
        size.height * 0.34 + wobble,
      )
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.18 + wobble,
        size.width * 0.38,
        size.height * 0.34 + wobble,
      )
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.22 + wobble,
        size.width * 0.24,
        size.height * 0.36 + wobble,
      );
    canvas.drawPath(hairPath, hairPaint);

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color, accent],
      ).createShader(bodyRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, Radius.circular(size.width * 0.18)),
      bodyPaint,
    );

    final facePaint = Paint()..color = const Color(0xFF111827);
    final faceRect = Rect.fromLTWH(
      size.width * 0.28,
      size.height * 0.40 + wobble,
      size.width * 0.44,
      size.height * 0.25,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(size.width * 0.11)),
      facePaint,
    );

    final eyePaint = Paint()..color = _eyeColor(accent);
    final leftEye = Offset(size.width * 0.42, size.height * 0.52 + wobble);
    final rightEye = Offset(size.width * 0.58, size.height * 0.52 + wobble);
    if (pet.currentAnimation == ShimejiAnimation.sleep) {
      final sleepPaint = Paint()
        ..color = eyePaint.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(
        Rect.fromCircle(center: leftEye, radius: size.width * 0.035),
        0,
        pi,
        false,
        sleepPaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: rightEye, radius: size.width * 0.035),
        0,
        pi,
        false,
        sleepPaint,
      );
    } else {
      canvas.drawCircle(leftEye, size.width * 0.035, eyePaint);
      canvas.drawCircle(rightEye, size.width * 0.035, eyePaint);
    }

    final mouthPaint = Paint()
      ..color = eyePaint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final mouthCenter = Offset(size.width * 0.50, size.height * 0.61 + wobble);
    if (pet.mood == ShimejiMood.love) {
      _drawHeart(canvas, Offset(size.width * 0.78, size.height * 0.26), accent);
    } else if (pet.mood == ShimejiMood.angry) {
      canvas.drawLine(
        mouthCenter.translate(-5, 2),
        mouthCenter.translate(5, -2),
        mouthPaint,
      );
    } else {
      canvas.drawArc(
        Rect.fromCenter(center: mouthCenter, width: 14, height: 8),
        0,
        pi,
        false,
        mouthPaint,
      );
    }

    final limbPaint = Paint()
      ..color = accent.withValues(alpha: 0.9)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final legShift = sin(tick / 90) * 5;
    canvas.drawLine(
      Offset(size.width * 0.38, size.height * 0.78 + wobble),
      Offset(size.width * 0.33, size.height * 0.91 + legShift),
      limbPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.62, size.height * 0.78 + wobble),
      Offset(size.width * 0.67, size.height * 0.91 - legShift),
      limbPaint,
    );

    if (selected) {
      final ringPaint = Paint()
        ..color = accent.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width * 0.48,
        ringPaint,
      );
    }
  }

  Color _eyeColor(Color accent) {
    if (pet.currentAnimation == ShimejiAnimation.angry) {
      return AppColors.danger;
    }
    if (pet.mood == ShimejiMood.sleepy) {
      return Colors.white70;
    }
    return accent.computeLuminance() > 0.65 ? AppColors.darkSurface : accent;
  }

  void _drawHeart(Canvas canvas, Offset center, Color color) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(center.dx, center.dy + 8)
      ..cubicTo(
        center.dx - 18,
        center.dy - 4,
        center.dx - 10,
        center.dy - 18,
        center.dx,
        center.dy - 8,
      )
      ..cubicTo(
        center.dx + 10,
        center.dy - 18,
        center.dx + 18,
        center.dy - 4,
        center.dx,
        center.dy + 8,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AnimePetPainter oldDelegate) {
    return pet != oldDelegate.pet ||
        selected != oldDelegate.selected ||
        tick != oldDelegate.tick;
  }
}
