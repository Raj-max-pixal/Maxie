import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MaxieDialogue extends StatelessWidget {
  final String message;
  final String emotion;

  const MaxieDialogue({
    super.key,
    required this.message,
    required this.emotion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _getEmotionIcon(emotion),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.2, end: 0)
        .then()
        .shake(delay: 2.seconds, duration: 500.ms);
  }

  Widget _getEmotionIcon(String emotion) {
    switch (emotion) {
      case 'happy':
        return const Icon(Icons.sentiment_very_satisfied, color: Colors.yellow, size: 28);
      case 'sleepy':
        return const Icon(Icons.bedtime, color: Colors.blue, size: 28);
      case 'excited':
        return const Icon(Icons.star, color: Colors.orange, size: 28);
      case 'sad':
        return const Icon(Icons.sentiment_dissatisfied, color: Colors.grey, size: 28);
      case 'focused':
        return const Icon(Icons.center_focus_strong, color: Colors.purple, size: 28);
      default:
        return const Icon(Icons.pets, color: Colors.pink, size: 28);
    }
  }
}
