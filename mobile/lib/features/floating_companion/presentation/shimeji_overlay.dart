import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';
import 'package:maxie_mobile/widgets/maxie_companion_view.dart';

/// Floating Screen Companion Overlay for MAXie.
/// Floats on top of other apps (movies, music, browser, social media)
/// and gives live compliments, movie reactions, song praise, and encouragement.
class ShimejiOverlay extends StatefulWidget {
  const ShimejiOverlay({super.key});

  @override
  State<ShimejiOverlay> createState() => _ShimejiOverlayState();
}

class _ShimejiOverlayState extends State<ShimejiOverlay> {
  // Keep the animated content inside the 360 x 360 native overlay canvas.
  // The bounds include room for MAXie's speech bubble as well as its body.
  static const double _minX = 20;
  static const double _maxX = 120;
  static const double _minY = 96;
  static const double _maxY = 160;
  static const double _petSize = 104;

  CompanionPresence _presence = CompanionPresence.idle;
  double _x = 70;
  double _y = 132;
  final Random _random = Random();
  Timer? _behaviorTimer;
  Timer? _complimentTimer;
  Timer? _speechBubbleDismissTimer;

  String? _currentSpeech;
  String _speechCategory = 'general';

  // Compliment & Reaction Library for Movie Watching, Music, & General Use
  static const List<String> _movieReactions = [
    '🍿 What an awesome movie scene!',
    '🎬 10/10 scene right here!',
    '✨ Loving this movie with you!',
    '😮 That plot twist was epic!',
    '🍿 Pass the popcorn, this is good!',
    '🎥 Cinematic masterpiece moment!',
  ];

  static const List<String> _musicReactions = [
    '🎵 This song is a whole vibe!',
    '🎧 Turn it up! Great music choice!',
    '🎶 100% fire track right now!',
    '💃 Loving this rhythm & tune!',
    '🔊 Best song on your playlist!',
  ];

  static const List<String> _compliments = [
    '🌟 You are doing incredible today!',
    '💕 MAXie is super proud of you!',
    '🚀 Keep shining! You\'ve got this!',
    '🌸 Hope you\'re having an amazing day!',
    '✨ You make everything look easy!',
    '💪 You are unstoppable!',
  ];

  static const List<String> _wellness = [
    '💧 Stay hydrated! Take a quick sip!',
    '👁️ Remember to rest your eyes a sec!',
    '🧠 Taking a gentle breather with you 💕',
    '😊 Smile! You\'re awesome!',
  ];

  @override
  void initState() {
    super.initState();
    _startBehaviorLoop();
    _startComplimentLoop();
  }

  @override
  void dispose() {
    _behaviorTimer?.cancel();
    _complimentTimer?.cancel();
    _speechBubbleDismissTimer?.cancel();
    super.dispose();
  }

  void _startBehaviorLoop() {
    _behaviorTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!mounted) return;

      final action = _random.nextInt(10);
      if (action < 4) {
        _walk();
      } else if (action < 6) {
        setState(() => _presence = CompanionPresence.sleepy);
      } else {
        setState(() => _presence = CompanionPresence.idle);
      }
    });
  }

  void _startComplimentLoop() {
    // Speak a compliment / movie / music reaction every 14 seconds
    _complimentTimer = Timer.periodic(const Duration(seconds: 14), (timer) {
      if (!mounted) return;
      _triggerRandomSpeech();
    });

    // Speak initial welcome compliment after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _speak('✨ MAXie is here floating with you!', category: 'welcome');
      }
    });
  }

  void _triggerRandomSpeech() {
    final cat = _random.nextInt(4);
    String speech;
    String category;

    switch (cat) {
      case 0:
        speech = _movieReactions[_random.nextInt(_movieReactions.length)];
        category = 'movie';
        break;
      case 1:
        speech = _musicReactions[_random.nextInt(_musicReactions.length)];
        category = 'music';
        break;
      case 2:
        speech = _wellness[_random.nextInt(_wellness.length)];
        category = 'wellness';
        break;
      default:
        speech = _compliments[_random.nextInt(_compliments.length)];
        category = 'compliment';
        break;
    }

    _speak(speech, category: category);
  }

  void _speak(String text, {required String category}) {
    _speechBubbleDismissTimer?.cancel();
    setState(() {
      _currentSpeech = text;
      _speechCategory = category;
      _presence = category == 'movie' || category == 'music'
          ? CompanionPresence.excited
          : CompanionPresence.idle;
    });

    // Auto-hide speech bubble after 4.5 seconds
    _speechBubbleDismissTimer = Timer(const Duration(milliseconds: 4500), () {
      if (mounted) {
        setState(() {
          _currentSpeech = null;
        });
      }
    });
  }

  void _walk() {
    setState(() {
      _presence = CompanionPresence.walking;
      _x += (_random.nextDouble() - 0.5) * 80;
      _y += (_random.nextDouble() - 0.5) * 80;

      // Keep the full speech bubble and companion inside the native window.
      _x = _x.clamp(_minX, _maxX);
      _y = _y.clamp(_minY, _maxY);
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _presence = CompanionPresence.idle);
      }
    });
  }

  void _onTapCompanion() {
    _triggerRandomSpeech();
    setState(() {
      _presence = CompanionPresence.excited;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _presence == CompanionPresence.excited) {
        setState(() => _presence = CompanionPresence.idle);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1800),
            curve: Curves.easeInOut,
            left: _x,
            top: _y,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Speech Bubble Float Above Head
                if (_currentSpeech != null)
                  Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        constraints: const BoxConstraints(maxWidth: 200),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF101B2B,
                          ).withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _speechCategoryColor(_speechCategory),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _speechCategoryColor(
                                _speechCategory,
                              ).withValues(alpha: 0.35),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          _currentSpeech!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 250.ms)
                      .scale(begin: const Offset(0.8, 0.8)),

                // Floating MAXie Pet Character
                GestureDetector(
                  onTap: _onTapCompanion,
                  child: MaxieCompanionView(state: _presence, size: _petSize),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _speechCategoryColor(String category) {
    switch (category) {
      case 'movie':
        return const Color(0xFFFFCD89); // Warm Gold
      case 'music':
        return const Color(0xFFB6A3FF); // Soft Purple
      case 'wellness':
        return const Color(0xFF9CEED1); // Teal Mint
      case 'welcome':
        return const Color(0xFF67C6BF);
      default:
        return const Color(0xFFF39AB7); // Pinkish Rose
    }
  }
}
