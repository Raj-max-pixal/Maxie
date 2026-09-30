import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';
import 'package:maxie_mobile/features/shimeji/application/shimeji_providers.dart';
import 'package:maxie_mobile/features/shimeji/domain/models/shimeji_models.dart';
import 'package:maxie_mobile/widgets/maxie_companion_view.dart';

class FloatingCompanionAnchor extends ConsumerWidget {
  const FloatingCompanionAnchor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shimejiControllerProvider);
    final pet = state.pets.where((item) => item.id == 'maxie').firstOrNull;

    if (state.settings.hidden || !(pet?.visible ?? true)) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      ignoring: !state.settings.interactionEnabled,
      child: GestureDetector(
        onTap: () => ref
            .read(shimejiControllerProvider.notifier)
            .interact('maxie', ShimejiAnimation.love),
        child: Opacity(
          opacity: state.settings.opacity.clamp(0.2, 1),
          child: Semantics(
            button: true,
            label: 'Open MAXie companion',
            child: MaxieCompanionView(
              state: _presenceFor(pet?.mood ?? ShimejiMood.neutral),
              size: (92 * state.settings.petSize).clamp(72, 132),
            ),
          ),
        ),
      ),
    );
  }

  CompanionPresence _presenceFor(ShimejiMood mood) {
    return switch (mood) {
      ShimejiMood.happy || ShimejiMood.love => CompanionPresence.happy,
      ShimejiMood.excited || ShimejiMood.surprised => CompanionPresence.excited,
      ShimejiMood.sleepy => CompanionPresence.sleeping,
      ShimejiMood.bored => CompanionPresence.idle,
      ShimejiMood.sad => CompanionPresence.listening,
      ShimejiMood.angry => CompanionPresence.thinking,
      _ => CompanionPresence.idle,
    };
  }
}
