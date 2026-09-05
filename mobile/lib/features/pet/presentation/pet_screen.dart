import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';
import 'package:maxie_mobile/features/pet/application/pet_providers.dart';
import 'package:maxie_mobile/features/pet/domain/models/pet_state.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/app_empty_state.dart';
import 'package:maxie_mobile/widgets/loading_indicator.dart';
import 'package:maxie_mobile/widgets/maxie_companion_view.dart';
import 'package:maxie_mobile/widgets/metric_widgets.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';
import 'package:maxie_mobile/widgets/primary_button.dart';
import 'package:maxie_mobile/widgets/section_title.dart';

class PetScreen extends ConsumerWidget {
  const PetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petAsync = ref.watch(petStateProvider);

    return PremiumScaffold(
      title: 'Companion',
      child: petAsync.when(
        loading: () => const LoadingIndicator(message: 'Calling MAXie over'),
        error: (error, stackTrace) => AppEmptyState(
          title: 'Companion needs a moment',
          message: error.toString(),
          icon: Icons.favorite_rounded,
        ),
        data: (pet) {
          final friendshipLevel = _levelForAffinity(pet.affinity);
          final levelProgress = _progressForAffinity(pet.affinity);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 108),
            children: [
              Center(
                child: GestureDetector(
                  onTap: () => _runAction(ref, context, pet, _PetAction.react),
                  child: MaxieCompanionView(
                    state: _presenceForMood(pet.mood),
                    size: 240,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PremiumCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Last action: ${pet.lastAction}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      avatar: const Icon(Icons.favorite_rounded, size: 16),
                      label: Text(_moodLabel(pet.mood)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              XpProgressCard(
                level: friendshipLevel,
                progress: levelProgress,
                xpLabel:
                    '${pet.affinity % 100}/100 XP to level ${friendshipLevel + 1}',
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Energy',
                      value: '${(pet.energy * 100).round()}%',
                      icon: Icons.bolt_rounded,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: StatCard(
                      label: 'Gifts',
                      value: '${pet.gifts}',
                      icon: Icons.card_giftcard_rounded,
                      color: AppColors.warmCoral,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionTitle(
                title: 'Actions',
                subtitle: 'Interact with MAXie to grow your friendship.',
              ),
              const SizedBox(height: AppSpacing.sm),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 2.7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _ActionButton(
                    label: 'Feed',
                    icon: Icons.restaurant_rounded,
                    filled: true,
                    onPressed: () =>
                        _runAction(ref, context, pet, _PetAction.feed),
                  ),
                  _ActionButton(
                    label: 'Dance',
                    icon: Icons.music_note_rounded,
                    onPressed: () =>
                        _runAction(ref, context, pet, _PetAction.dance),
                  ),
                  _ActionButton(
                    label: 'Sleep',
                    icon: Icons.bedtime_rounded,
                    onPressed: () =>
                        _runAction(ref, context, pet, _PetAction.sleep),
                  ),
                  _ActionButton(
                    label: 'Listen',
                    icon: Icons.hearing_rounded,
                    onPressed: () =>
                        _runAction(ref, context, pet, _PetAction.listen),
                  ),
                  _ActionButton(
                    label: 'Think',
                    icon: Icons.psychology_rounded,
                    onPressed: () =>
                        _runAction(ref, context, pet, _PetAction.think),
                  ),
                  _ActionButton(
                    label: 'Gift',
                    icon: Icons.card_giftcard_rounded,
                    onPressed: () =>
                        _runAction(ref, context, pet, _PetAction.gift),
                  ),
                  _ActionButton(
                    label: 'React',
                    icon: Icons.favorite_rounded,
                    onPressed: () =>
                        _runAction(ref, context, pet, _PetAction.react),
                  ),
                  _ActionButton(
                    label: 'Idle',
                    icon: Icons.pets_rounded,
                    onPressed: () =>
                        _runAction(ref, context, pet, _PetAction.idle),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              StatCard(
                label: 'Total friendship XP',
                value: '${pet.affinity} XP',
                icon: Icons.motion_photos_auto_rounded,
                color: AppColors.calmTeal,
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _runAction(
    WidgetRef ref,
    BuildContext context,
    PetState pet,
    _PetAction action,
  ) async {
    final state = switch (action) {
      _PetAction.feed => pet.copyWith(
        mood: PetMood.happy,
        energy: (pet.energy + 0.16).clamp(0, 1).toDouble(),
        affinity: pet.affinity + 8,
        lastAction: 'Feed',
      ),
      _PetAction.dance => pet.copyWith(
        mood: PetMood.dancing,
        energy: (pet.energy - 0.10).clamp(0, 1).toDouble(),
        affinity: pet.affinity + 10,
        lastAction: 'Dance',
      ),
      _PetAction.sleep => pet.copyWith(
        mood: PetMood.sleepy,
        energy: (pet.energy + 0.28).clamp(0, 1).toDouble(),
        affinity: pet.affinity + 5,
        lastAction: 'Sleep',
      ),
      _PetAction.listen => pet.copyWith(
        mood: PetMood.listening,
        energy: (pet.energy - 0.03).clamp(0, 1).toDouble(),
        affinity: pet.affinity + 7,
        lastAction: 'Listen',
      ),
      _PetAction.think => pet.copyWith(
        mood: PetMood.focused,
        energy: (pet.energy - 0.06).clamp(0, 1).toDouble(),
        affinity: pet.affinity + 7,
        lastAction: 'Think',
      ),
      _PetAction.gift => pet.copyWith(
        mood: PetMood.loving,
        energy: (pet.energy + 0.06).clamp(0, 1).toDouble(),
        affinity: pet.affinity + 12,
        gifts: pet.gifts + 1,
        lastAction: 'Gift',
      ),
      _PetAction.react => pet.copyWith(
        mood: PetMood.loving,
        affinity: pet.affinity + 4,
        lastAction: 'React',
      ),
      _PetAction.idle => pet.copyWith(
        mood: PetMood.neutral,
        energy: (pet.energy + 0.04).clamp(0, 1).toDouble(),
        affinity: pet.affinity + 2,
        lastAction: 'Idle',
      ),
    };
    final message = switch (action) {
      _PetAction.feed => 'MAXie feels recharged.',
      _PetAction.dance => 'MAXie is dancing with you.',
      _PetAction.sleep => 'MAXie is resting.',
      _PetAction.listen => 'MAXie is listening closely.',
      _PetAction.think => 'MAXie is thinking it through.',
      _PetAction.gift => 'Gift saved. Friendship grew.',
      _PetAction.react => 'MAXie reacted happily.',
      _PetAction.idle => 'MAXie is back in idle mode.',
    };

    await ref.read(petRepositoryProvider).savePet(state);
    ref.invalidate(petStateProvider);
    if (context.mounted) {
      _showFoundationMessage(context, message);
    }
  }

  CompanionPresence _presenceForMood(PetMood mood) {
    return switch (mood) {
      PetMood.happy => CompanionPresence.happy,
      PetMood.focused => CompanionPresence.thinking,
      PetMood.sleepy => CompanionPresence.sleeping,
      PetMood.listening => CompanionPresence.listening,
      PetMood.dancing => CompanionPresence.dancing,
      PetMood.loving => CompanionPresence.excited,
      PetMood.neutral => CompanionPresence.idle,
    };
  }

  String _moodLabel(PetMood mood) {
    return switch (mood) {
      PetMood.happy => 'Happy',
      PetMood.focused => 'Focused',
      PetMood.sleepy => 'Sleepy',
      PetMood.listening => 'Listening',
      PetMood.dancing => 'Dancing',
      PetMood.loving => 'Loving',
      PetMood.neutral => 'Neutral',
    };
  }

  int _levelForAffinity(int affinity) {
    return (affinity ~/ 100) + 1;
  }

  double _progressForAffinity(int affinity) {
    return (affinity % 100) / 100;
  }

  void _showFoundationMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _PetAction { feed, dance, sleep, listen, think, gift, react, idle }

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return PrimaryButton(label: label, icon: icon, onPressed: onPressed);
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
