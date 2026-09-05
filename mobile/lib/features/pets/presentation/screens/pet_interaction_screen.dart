import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/shared/widgets/glass_card.dart';
import 'package:maxie_mobile/features/pets/presentation/widgets/pet_animation_widget.dart';

class PetInteractionScreen extends ConsumerWidget {
  final String petId;
  const PetInteractionScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Play with Pet')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PetAnimationWidget(petId: petId, size: 200),
                  const SizedBox(height: 24),
                  GlassCard(
                    child: Column(
                      children: [
                        Text('Interact with your pet!', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('Tap to play, double-tap for reaction', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}