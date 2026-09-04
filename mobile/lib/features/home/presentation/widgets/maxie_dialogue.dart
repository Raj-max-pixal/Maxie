import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dialogue main bubble
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getEmotionIcon(emotion),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
            .animate(key: ValueKey(message)) // re-animate on message change
            .fadeIn(duration: 200.ms)
            .scale(begin: const Offset(0.9, 0.9), duration: 200.ms, curve: Curves.easeOutBack),
        
        // Dialogue pointer tail
        CustomPaint(
          size: const Size(12, 6),
          painter: TrianglePainter(color: Colors.white.withOpacity(0.85)),
        ),
      ],
    );
  }

  Widget _getEmotionIcon(String emotion) {
    switch (emotion) {
      case 'happy':
        return const Icon(Icons.sentiment_very_satisfied, color: Colors.pinkAccent, size: 22);
      case 'sleepy':
        return const Icon(Icons.bedtime, color: Colors.blueAccent, size: 22);
      case 'excited':
        return const Icon(Icons.star, color: Colors.orangeAccent, size: 22);
      case 'sad':
        return const Icon(Icons.sentiment_dissatisfied, color: Colors.blueGrey, size: 22);
      case 'focused':
        return const Icon(Icons.psychology_outlined, color: Colors.teal, size: 22);
      default:
        return const Icon(Icons.pets, color: Colors.purpleAccent, size: 22);
    }
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
