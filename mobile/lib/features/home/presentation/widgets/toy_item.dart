import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ToyItem extends StatelessWidget {
  final Offset position;
  final String type; // 'cookie', 'apple', 'ball', 'yarn'

  const ToyItem({
    super.key,
    required this.position,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 24, // center the toy on click
      top: position.dy - 24,
      child: IgnorePointer(
        child: SizedBox(
          width: 48,
          height: 48,
          child: _getVisualForType()
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(end: -6, duration: 800.ms, curve: Curves.easeInOutSine)
              .scale(end: const Offset(1.05, 1.05), duration: 800.ms, curve: Curves.easeInOutSine),
        ),
      ),
    );
  }

  Widget _getVisualForType() {
    String emoji = '🍪';
    Color shadowColor = Colors.orange;

    switch (type) {
      case 'apple':
        emoji = '🍎';
        shadowColor = Colors.red;
        break;
      case 'ball':
        emoji = '⚽';
        shadowColor = Colors.blue;
        break;
      case 'yarn':
        emoji = '🧶';
        shadowColor = Colors.pink;
        break;
      default:
        emoji = '🍪';
        shadowColor = Colors.brown;
    }

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.35),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 32),
      ),
    );
  }
}
