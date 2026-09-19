import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';
import 'package:maxie_mobile/features/pet/application/pet_controller.dart';
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
    final petAsync = ref.watch(petControllerProvider);

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
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 108),
            children: [
              Center(
                child: GestureDetector(
                  onTap: () => _runAction(ref, context, pet, _PetAction.listen),
                  child: MaxieCompanionView(
                    state: _presenceForActivity(pet.currentActivity),
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
                level: pet.level,
                progress: pet.xpProgress,
                xpLabel: '${pet.xp % 100}/100 XP to level ${pet.level + 1}',
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Energy',
                      value: '${pet.energy.round()}%',
                      icon: Icons.bolt_rounded,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: StatCard(
                      label: 'Happiness',
                      value: '${pet.happiness.round()}%',
                      icon: Icons.sentiment_satisfied_alt_rounded,
                      color: AppColors.calmTeal,
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
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Hunger',
                      value: '${pet.hunger.round()}%',
                      icon: Icons.restaurant_rounded,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: StatCard(
                      label: 'Friendship',
                      value: 'Lv ${pet.friendshipLevel}',
                      icon: Icons.favorite_rounded,
                      color: AppColors.warmCoral,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              StatCard(
                label: 'Total friendship XP',
                value: '${pet.friendship} XP',
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
    final petAction = switch (action) {
      _PetAction.feed => PetAction.feed,
      _PetAction.dance => PetAction.dance,
      _PetAction.sleep => PetAction.sleep,
      _PetAction.listen => PetAction.listen,
    };
    await ref.read(petControllerProvider.notifier).perform(petAction);
    if (context.mounted) {
      _showFoundationMessage(
        context,
        ref.read(petControllerProvider).valueOrNull?.recentInteraction ??
            'MAXie reacted.',
      );
    }
  }

  CompanionPresence _presenceForActivity(PetActivity activity) {
    return switch (activity) {
      PetActivity.eating => CompanionPresence.happy,
      PetActivity.playing => CompanionPresence.happy,
      PetActivity.sleeping => CompanionPresence.sleeping,
      PetActivity.dancing => CompanionPresence.dancing,
      PetActivity.listening => CompanionPresence.listening,
      PetActivity.idle => CompanionPresence.idle,
    };
  }

  String _moodLabel(PetMood mood) {
    return switch (mood) {
      PetMood.happy => 'Happy',
      PetMood.excited => 'Excited',
      PetMood.hungry => 'Hungry',
      PetMood.tired => 'Tired',
      PetMood.sleepy => 'Sleepy',
      PetMood.neutral => 'Neutral',
      PetMood.sad => 'Sad',
      PetMood.focused => 'Focused',
      PetMood.listening => 'Listening',
      PetMood.dancing => 'Dancing',
      PetMood.loving => 'Loving',
    };
  }

  void _showFoundationMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _PetAction { feed, dance, sleep, listen }

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
