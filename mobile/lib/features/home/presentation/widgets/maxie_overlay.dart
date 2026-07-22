import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/overlay_provider.dart';

class MaxieOverlay extends ConsumerWidget {
  const MaxieOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlayState = ref.watch(overlayProvider);

    if (!overlayState.isEnabled) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: overlayState.position.dx,
      top: overlayState.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          ref.read(overlayProvider.notifier).updatePosition(
            overlayState.position + details.delta,
          );
        },
        child: Container(
          width: overlayState.size,
          height: overlayState.size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Opacity(
            opacity: overlayState.transparency,
            child: const MaxieOverlayCharacter(),
          ),
        ),
      ),
    );
  }
}

class MaxieOverlayCharacter extends StatelessWidget {
  const MaxieOverlayCharacter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.pets,
        size: 48,
        color: Colors.purple,
      ),
    );
  }
}
