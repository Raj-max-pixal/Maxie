import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/home/presentation/providers/overlay_provider.dart';

class MaxieOverlay extends ConsumerWidget {
  const MaxieOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlayState = ref.watch(overlayProvider);

    if (!overlayState.isEnabled) {
      return const SizedBox.shrink();
    }
    final maxieWidget = overlayState.getWidget('maxie_character');
    if (maxieWidget == null || !maxieWidget.isVisible) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: maxieWidget.position.dx,
      top: maxieWidget.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          ref.read(overlayProvider.notifier).updateWidgetPosition(
            maxieWidget.id,
            maxieWidget.position + details.delta,
          );
        },
        child: Container(
          width: maxieWidget.size,
          height: maxieWidget.size,
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
