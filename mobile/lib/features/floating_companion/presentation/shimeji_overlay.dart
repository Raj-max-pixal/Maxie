import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';
import 'package:maxie_mobile/widgets/maxie_companion_view.dart';

class ShimejiOverlay extends StatefulWidget {
  const ShimejiOverlay({super.key});

  @override
  State<ShimejiOverlay> createState() => _ShimejiOverlayState();
}

class _ShimejiOverlayState extends State<ShimejiOverlay> {
  CompanionPresence _presence = CompanionPresence.idle;
  double _x = 150;
  double _y = 150;
  final Random _random = Random();
  Timer? _moveTimer;

  @override
  void initState() {
    super.initState();
    _startBehaviorLoop();
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    super.dispose();
  }

  void _startBehaviorLoop() {
    _moveTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      
      final action = _random.nextInt(10);
      if (action < 3) {
        _walk();
      } else if (action < 5) {
        setState(() => _presence = CompanionPresence.sleepy);
      } else {
        setState(() => _presence = CompanionPresence.idle);
      }
    });
  }

  void _walk() {
    setState(() {
      _presence = CompanionPresence.walking;
      _x += (_random.nextDouble() - 0.5) * 100;
      _y += (_random.nextDouble() - 0.5) * 100;
      
      // Keep within bounds of the 400x400 overlay window
      _x = _x.clamp(0, 300);
      _y = _y.clamp(0, 300);
    });
    
    Future.delayed(2.seconds, () {
      if (mounted) {
        setState(() => _presence = CompanionPresence.idle);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: 2.seconds,
            curve: Curves.easeInOut,
            left: _x,
            top: _y,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _presence = CompanionPresence.excited;
                });
                Future.delayed(2.seconds, () {
                  if (mounted) {
                    setState(() => _presence = CompanionPresence.idle);
                  }
                });
              },
              child: MaxieCompanionView(
                state: _presence,
                size: 80,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
