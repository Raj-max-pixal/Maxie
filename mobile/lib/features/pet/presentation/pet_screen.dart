import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/ai_companion/application/companion_state_engine.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/companion_emotion.dart';
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
    final emotionAsync = ref.watch(companionEmotionProvider);
    final engine = ref.read(companionStateEngineProvider.notifier);

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
          final emotion = emotionAsync.valueOrNull ?? CompanionEmotion.initial();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 108),
            children: [
              Center(
                child: MaxieCompanionView(
                  state: _presenceForEmotion(emotion.type),
                  size: 240,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PremiumCard(
                glowColor: _colorForEmotion(emotion.type),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pet.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        Chip(
                          avatar: const Icon(Icons.favorite_rounded, size: 16),
                          label: Text(_emotionLabel(emotion.type)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      emotion.reactionMessage ?? 'Ready when you are.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(
                      value: emotion.intensity,
                      minHeight: 7,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              XpProgressCard(
                level: _levelForAffinity(pet.affinity),
                progress: pet.energy,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: 'Feed',
                      icon: Icons.restaurant_rounded,
                      onPressed: () => _runReaction(
                        context,
                        ref,
                        engine.reactToFeed,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _runReaction(
                        context,
                        ref,
                        engine.reactToPlay,
                      ),
                      icon: const Icon(Icons.sports_esports_rounded),
                      label: const Text('Play'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => _runReaction(
                  context,
                  ref,
                  engine.reactToCustomize,
                ),
                icon: const Icon(Icons.palette_rounded),
                label: const Text('Customize'),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionTitle(
                title: 'Future Accessories',
                subtitle:
                    'Hats, trails, rooms and companion styles will attach here.',
              ),
              const SizedBox(height: AppSpacing.sm),
              StatCard(
                label: 'Affinity',
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

  Future<void> _runReaction(
    BuildContext context,
    WidgetRef ref,
    Future<CompanionEmotion> Function() reaction,
  ) async {
    final emotion = await reaction();
    ref.invalidate(petStateProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(emotion.reactionMessage ?? 'Saved.')),
        );
    }
  }

  CompanionPresence _presenceForEmotion(CompanionEmotionType type) {
    return switch (type) {
      CompanionEmotionType.happy ||
      CompanionEmotionType.satisfied ||
      CompanionEmotionType.comforted =>
        CompanionPresence.happy,
      CompanionEmotionType.excited || CompanionEmotionType.playful =>
        CompanionPresence.excited,
      CompanionEmotionType.sleepy => CompanionPresence.sleeping,
      CompanionEmotionType.curious => CompanionPresence.thinking,
      CompanionEmotionType.hungry => CompanionPresence.listening,
      CompanionEmotionType.angry => CompanionPresence.typing,
      _ => CompanionPresence.idle,
    };
  }

  Color _colorForEmotion(CompanionEmotionType type) {
    return switch (type) {
      CompanionEmotionType.happy ||
      CompanionEmotionType.satisfied ||
      CompanionEmotionType.comforted =>
        AppColors.calmTeal,
      CompanionEmotionType.excited || CompanionEmotionType.playful =>
        AppColors.warmCoral,
      CompanionEmotionType.sleepy => AppColors.seed,
      CompanionEmotionType.curious => AppColors.warning,
      _ => AppColors.calmTeal,
    };
  }

  String _emotionLabel(CompanionEmotionType type) {
    return switch (type) {
      CompanionEmotionType.happy => 'Happy',
      CompanionEmotionType.excited => 'Excited',
      CompanionEmotionType.playful => 'Playful',
      CompanionEmotionType.sleepy => 'Sleepy',
      CompanionEmotionType.hungry => 'Hungry',
      CompanionEmotionType.sad => 'Sad',
      CompanionEmotionType.bored => 'Bored',
      CompanionEmotionType.curious => 'Curious',
      CompanionEmotionType.angry => 'Focused',
      CompanionEmotionType.neutral => 'Calm',
      CompanionEmotionType.satisfied => 'Satisfied',
      CompanionEmotionType.comforted => 'Comforted',
    };
  }

  int _levelForAffinity(int affinity) {
    return (affinity ~/ 100) + 1;
  }
}
