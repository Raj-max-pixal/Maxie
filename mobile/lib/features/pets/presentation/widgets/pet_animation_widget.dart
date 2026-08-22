import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pet_provider.dart';
import '../../data/models/pet_model.dart';

/// The main Shimeji-style pet animation widget that renders the pet
/// with smooth 60fps animations, emotions, and interactions.
class PetAnimationWidget extends ConsumerStatefulWidget {
  final String petId;
  final double size;

  const PetAnimationWidget({
    super.key,
    required this.petId,
    this.size = 120,
  });

  @override
  ConsumerState<PetAnimationWidget> createState() => _PetAnimationWidgetState();
}

class _PetAnimationWidgetState extends ConsumerState<PetAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _breatheController;
  late AnimationController _bounceController;
  late AnimationController _emoteController;
  final Random _random = Random();

  // Visual effects
  Color _auraColor = Colors.transparent;
  bool _showSparkles = false;
  List<Offset> _sparklePositions = [];
  List<double> _sparkleOpacities = [];

  @override
  void initState() {
    super.initState();

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _emoteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Generate sparkle positions
    for (int i = 0; i < 5; i++) {
      _sparklePositions.add(
        Offset(
          -20 + _random.nextDouble() * (widget.size + 40),
          _random.nextDouble() * widget.size,
        ),
      );
      _sparkleOpacities.add(0.0);
    }
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _bounceController.dispose();
    _emoteController.dispose();
    super.dispose();
  }

  void _triggerBounce() {
    _bounceController.forward(from: 0);
  }

  void _triggerEmote() {
    _emoteController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final petsState = ref.watch(petEngineProvider);
    final pet = petsState.pets.firstWhere(
      (p) => p.id == widget.petId,
      orElse: () => PetModel(id: '', type: PetType.maxie),
    );

    if (!pet.isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Update aura based on emotion
    _updateAura(pet);

    return GestureDetector(
      onTap: () => _handleTap(pet),
      onDoubleTap: () => _handleDoubleTap(pet),
      onLongPress: () => _handleLongPress(pet),
      onPanStart: (_) => _handleDragStart(pet),
      onPanUpdate: (details) => _handleDragUpdate(pet, details),
      onPanEnd: (_) => _handleDragEnd(pet),
      child: AnimatedBuilder(
        animation: Listenable.merge([_breatheController, _bounceController, _emoteController]),
        builder: (context, child) {
          return Transform.translate(
            offset: pet.position,
            child: SizedBox(
              width: widget.size * pet.customization.size,
              height: widget.size * pet.customization.size * 1.2,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Aura effect
                  if (pet.customization.aura != null || _auraColor != Colors.transparent)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _auraColor.withOpacity(0.3 + 0.1 * sin(_breatheController.value * pi)),
                                blurRadius: 20 + _breatheController.value * 10,
                                spreadRadius: 5 + _breatheController.value * 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Trail effect
                  if (pet.customization.trail != null)
                    Positioned(
                      left: -10,
                      top: widget.size * pet.customization.size * 0.5,
                      child: IgnorePointer(
                        child: CustomPaint(
                          size: Size(widget.size * pet.customization.size + 20, 4),
                          painter: _TrailPainter(
                            color: pet.customization.color,
                            progress: _breatheController.value,
                          ),
                        ),
                      ),
                    ),

                  // Sparkle effects
                  if (_showSparkles)
                    ...List.generate(_sparklePositions.length, (i) {
                      return Positioned(
                        left: _sparklePositions[i].dx,
                        top: _sparklePositions[i].dy,
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: _sparkleOpacities[i] * sin(_breatheController.value * pi),
                            child: Icon(
                              Icons.star,
                              size: 8 + _sparkleOpacities[i] * 6,
                              color: pet.customization.color.withOpacity(0.8),
                            ),
                          ),
                        ),
                      );
                    }),

                  // Main pet body
                  Positioned.fill(
                    child: _buildPetBody(pet, isDark, colorScheme),
                  ),

                  // Emotion indicator
                  if (pet.currentEmotion != PetEmotion.happy)
                    Positioned(
                      top: -15,
                      right: -5,
                      child: IgnorePointer(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(
                            milliseconds: (500 / pet.customization.animationSpeed).round(),
                          ),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                          child: _buildEmotionBadge(pet),
                        ),
                      ),
                    ),

                  // Speech bubble
                  if (pet.speechBubble != null && pet.speechBubble!.isNotEmpty)
                    Positioned(
                      top: -55,
                      left: -20,
                      right: -20,
                      child: IgnorePointer(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 300),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, -10 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2D2D3F)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: pet.customization.color.withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              pet.speechBubble!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Sleep Zzz
                  if (pet.isSleeping)
                    Positioned(
                      top: -10,
                      right: 10,
                      child: IgnorePointer(
                        child: Text(
                          '💤',
                          style: TextStyle(
                            fontSize: 16 + 4 * sin(_breatheController.value * pi),
                          ),
                        ),
                      ),
                    ),

                  // Friendship level badge
                  Positioned(
                    bottom: -5,
                    right: -5,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: pet.customization.color.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite, size: 10, color: Colors.white),
                            const SizedBox(width: 2),
                            Text(
                              '${pet.friendshipLevel}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetBody(PetModel pet, bool isDark, ColorScheme colorScheme) {
    final size = widget.size * pet.customization.size;
    final mainColor = pet.customization.color;
    final secondaryColor = mainColor.withOpacity(0.7);
    final accentColor = mainColor.computeLuminance() > 0.5
        ? Colors.black26
        : Colors.white.withOpacity(0.3);
    final bounceOffset = _bounceController.value * -20;
    final breatheScale = 1.0 + 0.02 * sin(_breatheController.value * pi);

    return Transform.translate(
      offset: Offset(0, bounceOffset),
      child: Transform.scale(
        scale: breatheScale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D2D3F) : const Color(0xFFF0F0FF),
            borderRadius: BorderRadius.circular(size * 0.35),
          ),
          child: CustomPaint(
            painter: _PetBodyPainter(
              petType: pet.type,
              activity: pet.currentActivity,
              emotion: pet.currentEmotion,
              mainColor: mainColor,
              secondaryColor: secondaryColor,
              accentColor: accentColor,
              animationFrame: pet.animationFrame,
              isSleeping: pet.isSleeping,
              isDark: isDark,
            ),
            size: Size(size, size * 1.2),
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionBadge(PetModel pet) {
    final emojiMap = {
      PetEmotion.happy: '😊',
      PetEmotion.sad: '😢',
      PetEmotion.excited: '🤩',
      PetEmotion.hungry: '🍽️',
      PetEmotion.sleepy: '😴',
      PetEmotion.curious: '🤔',
      PetEmotion.thinking: '🧐',
      PetEmotion.laughing: '😆',
      PetEmotion.celebrating: '🎉',
      PetEmotion.angry: '😤',
      PetEmotion.surprised: '😮',
      PetEmotion.playful: '😜',
      PetEmotion.loving: '🥰',
      PetEmotion.dizzy: '😵',
      PetEmotion.shy: '😳',
    };

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        emojiMap[pet.currentEmotion] ?? '😊',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  void _updateAura(PetModel pet) {
    Color newColor;
    switch (pet.currentEmotion) {
      case PetEmotion.happy:
      case PetEmotion.excited:
      case PetEmotion.celebrating:
      case PetEmotion.laughing:
      case PetEmotion.playful:
      case PetEmotion.loving:
        newColor = Colors.yellow;
        _showSparkles = true;
        break;
      case PetEmotion.sad:
        newColor = Colors.blue;
        _showSparkles = false;
        break;
      case PetEmotion.angry:
        newColor = Colors.red;
        _showSparkles = false;
        break;
      case PetEmotion.hungry:
        newColor = Colors.orange;
        _showSparkles = false;
        break;
      case PetEmotion.sleepy:
        newColor = Colors.purple;
        _showSparkles = false;
        break;
      case PetEmotion.surprised:
      case PetEmotion.curious:
      case PetEmotion.thinking:
        newColor = Colors.cyan;
        _showSparkles = true;
        break;
      case PetEmotion.dizzy:
      case PetEmotion.shy:
        newColor = Colors.pink;
        _showSparkles = false;
        break;
    }
    _auraColor = newColor;
  }

  void _handleTap(PetModel pet) {
    ref.read(petEngineProvider.notifier).handleTap(pet.id);
    _triggerBounce();
  }

  void _handleDoubleTap(PetModel pet) {
    ref.read(petEngineProvider.notifier).handleDoubleTap(pet.id);
    _triggerBounce();
    _triggerEmote();
  }

  void _handleLongPress(PetModel pet) {
    ref.read(petEngineProvider.notifier).handleLongPress(pet.id);
  }

  void _handleDragStart(PetModel pet) {
    ref.read(petEngineProvider.notifier).handleDragStart(pet.id);
  }

  void _handleDragUpdate(PetModel pet, DragUpdateDetails details) {
    final newPos = pet.position + details.delta;
    ref.read(petEngineProvider.notifier).handleDragUpdate(pet.id, newPos);
  }

  void _handleDragEnd(PetModel pet) {
    ref.read(petEngineProvider.notifier).handleDragEnd(pet.id);
  }
}

// ---- Custom Painters ----

class _PetBodyPainter extends CustomPainter {
  final PetType petType;
  final PetActivity activity;
  final PetEmotion emotion;
  final Color mainColor;
  final Color secondaryColor;
  final Color accentColor;
  final double animationFrame;
  final bool isSleeping;
  final bool isDark;

  _PetBodyPainter({
    required this.petType,
    required this.activity,
    required this.emotion,
    required this.mainColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.animationFrame,
    required this.isSleeping,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    _drawPetShape(canvas, size, centerX, centerY);
  }

  void _drawPetShape(Canvas canvas, Size size, double cx, double cy) {
    final paint = Paint()..style = PaintingStyle.fill;
    final r = min(size.width, size.height) / 2;
    final blink = (activity == PetActivity.blinking) && (animationFrame % 2 < 0.5);
    final wave = sin(animationFrame * 2) * 0.2;

    switch (petType) {
      case PetType.maxie:
        _drawMaxie(canvas, cx, cy, r, paint, blink);
        break;
      case PetType.cat:
        _drawCat(canvas, cx, cy, r, paint, blink, wave);
        break;
      case PetType.dog:
        _drawDog(canvas, cx, cy, r, paint, blink, wave);
        break;
      case PetType.panda:
        _drawPanda(canvas, cx, cy, r, paint, blink, wave);
        break;
      case PetType.fox:
        _drawFox(canvas, cx, cy, r, paint, blink, wave);
        break;
      case PetType.rabbit:
        _drawRabbit(canvas, cx, cy, r, paint, blink, wave);
        break;
      case PetType.penguin:
        _drawPenguin(canvas, cx, cy, r, paint, blink, wave);
        break;
      case PetType.dragon:
        _drawDragon(canvas, cx, cy, r, paint, blink, wave);
        break;
      case PetType.slime:
        _drawSlime(canvas, cx, cy, r, paint, blink, wave);
        break;
      case PetType.robot:
        _drawRobot(canvas, cx, cy, r, paint, blink, wave);
        break;
      case PetType.capybara:
        _drawCapybara(canvas, cx, cy, r, paint, blink, wave);
        break;
      case PetType.axolotl:
        _drawAxolotl(canvas, cx, cy, r, paint, blink, wave);
        break;
    }
  }

  void _drawMaxie(Canvas canvas, double cx, double cy, double r, Paint paint, bool blink) {
    // Body - rounded rectangle
    paint.color = mainColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + r * 0.1), width: r * 1.5, height: r * 1.3),
        Radius.circular(r * 0.3),
      ),
      paint,
    );

    // Head
    paint.color = mainColor;
    canvas.drawCircle(Offset(cx, cy - r * 0.3), r * 0.7, paint);

    // Ears (antenna)
    paint.color = secondaryColor;
    canvas.drawCircle(Offset(cx - r * 0.5, cy - r * 0.9), r * 0.15, paint);
    canvas.drawCircle(Offset(cx + r * 0.5, cy - r * 0.9), r * 0.15, paint);

    // Eyes
    if (isSleeping) {
      paint.color = accentColor;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.25, cy - r * 0.35), Offset(cx - r * 0.05, cy - r * 0.35), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.35), Offset(cx + r * 0.25, cy - r * 0.35), paint);
      paint.style = PaintingStyle.fill;
    } else if (blink) {
      paint.color = accentColor;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.25, cy - r * 0.35), Offset(cx - r * 0.05, cy - r * 0.35), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.35), Offset(cx + r * 0.25, cy - r * 0.35), paint);
      paint.style = PaintingStyle.fill;
    } else {
      paint.color = accentColor;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx - r * 0.15, cy - r * 0.35), r * 0.08, paint);
      canvas.drawCircle(Offset(cx + r * 0.15, cy - r * 0.35), r * 0.08, paint);
      // Highlights
      paint.color = Colors.white.withOpacity(0.6);
      canvas.drawCircle(Offset(cx - r * 0.12, cy - r * 0.38), r * 0.03, paint);
      canvas.drawCircle(Offset(cx + r * 0.18, cy - r * 0.38), r * 0.03, paint);
    }

    // Smile
    paint.color = accentColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    final smilePath = Path()
      ..moveTo(cx - r * 0.15, cy - r * 0.1)
      ..quadraticBezierTo(cx, cy - r * 0.05, cx + r * 0.15, cy - r * 0.1);
    canvas.drawPath(smilePath, paint);
    paint.style = PaintingStyle.fill;

    // Screen/face display
    paint.color = Colors.white.withOpacity(0.2);
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + r * 0.2), width: r * 0.8, height: r * 0.4),
        Radius.circular(r * 0.1),
      ),
      paint,
    );

    // Blush
    paint.color = Colors.pink.withOpacity(0.3);
    canvas.drawCircle(Offset(cx - r * 0.4, cy - r * 0.15), r * 0.1, paint);
    canvas.drawCircle(Offset(cx + r * 0.4, cy - r * 0.15), r * 0.1, paint);
  }

  void _drawCat(Canvas canvas, double cx, double cy, double r, Paint paint, bool blink, double wave) {
    // Body
    paint.color = mainColor;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.2), width: r * 1.4, height: r * 1.2), paint);

    // Head
    canvas.drawCircle(Offset(cx, cy - r * 0.35), r * 0.65, paint);

    // Ears (triangles)
    paint.color = mainColor;
    final earPath1 = Path()
      ..moveTo(cx - r * 0.5, cy - r * 0.5)
      ..lineTo(cx - r * 0.7, cy - r * 1.0)
      ..lineTo(cx - r * 0.2, cy - r * 0.6)
      ..close();
    canvas.drawPath(earPath1, paint);
    final earPath2 = Path()
      ..moveTo(cx + r * 0.5, cy - r * 0.5)
      ..lineTo(cx + r * 0.7, cy - r * 1.0)
      ..lineTo(cx + r * 0.2, cy - r * 0.6)
      ..close();
    canvas.drawPath(earPath2, paint);

    // Inner ears
    paint.color = Colors.pink.withOpacity(0.4);
    final innerEar1 = Path()
      ..moveTo(cx - r * 0.48, cy - r * 0.52)
      ..lineTo(cx - r * 0.62, cy - r * 0.85)
      ..lineTo(cx - r * 0.25, cy - r * 0.58)
      ..close();
    canvas.drawPath(innerEar1, paint);
    final innerEar2 = Path()
      ..moveTo(cx + r * 0.48, cy - r * 0.52)
      ..lineTo(cx + r * 0.62, cy - r * 0.85)
      ..lineTo(cx + r * 0.25, cy - r * 0.58)
      ..close();
    canvas.drawPath(innerEar2, paint);

    // Eyes
    if (isSleeping) {
      paint.color = accentColor;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.25, cy - r * 0.35), Offset(cx - r * 0.05, cy - r * 0.35), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.35), Offset(cx + r * 0.25, cy - r * 0.35), paint);
      paint.style = PaintingStyle.fill;
    } else if (blink) {
      paint.color = accentColor;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.25, cy - r * 0.35), Offset(cx - r * 0.05, cy - r * 0.35), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.35), Offset(cx + r * 0.25, cy - r * 0.35), paint);
      paint.style = PaintingStyle.fill;
    } else {
      paint.color = accentColor;
      paint.style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.15, cy - r * 0.35), width: r * 0.12, height: r * 0.16), paint);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.15, cy - r * 0.35), width: r * 0.12, height: r * 0.16), paint);
      paint.color = Colors.white.withOpacity(0.6);
      canvas.drawCircle(Offset(cx - r * 0.12, cy - r * 0.38), r * 0.03, paint);
      canvas.drawCircle(Offset(cx + r * 0.18, cy - r * 0.38), r * 0.03, paint);
    }

    // Nose
    paint.color = Colors.pink;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy - r * 0.22), r * 0.04, paint);

    // Whiskers
    paint.color = accentColor.withOpacity(0.5);
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - r * 0.1, cy - r * 0.2), Offset(cx - r * 0.5, cy - r * 0.3), paint);
    canvas.drawLine(Offset(cx - r * 0.1, cy - r * 0.2), Offset(cx - r * 0.5, cy - r * 0.2), paint);
    canvas.drawLine(Offset(cx - r * 0.1, cy - r * 0.2), Offset(cx - r * 0.5, cy - r * 0.1), paint);
    canvas.drawLine(Offset(cx + r * 0.1, cy - r * 0.2), Offset(cx + r * 0.5, cy - r * 0.3), paint);
    canvas.drawLine(Offset(cx + r * 0.1, cy - r * 0.2), Offset(cx + r * 0.5, cy - r * 0.2), paint);
    canvas.drawLine(Offset(cx + r * 0.1, cy - r * 0.2), Offset(cx + r * 0.5, cy - r * 0.1), paint);
    paint.style = PaintingStyle.fill;

    // Tail
    paint.color = mainColor;
    paint.strokeWidth = r * 0.12;
    paint.style = PaintingStyle.stroke;
    final tailPath = Path()
      ..moveTo(cx + r * 0.7, cy + r * 0.1)
      ..cubicTo(cx + r * 1.0, cy - r * 0.1, cx + r * 1.2, cy - r * 0.5, cx + r * 0.9, cy - r * 0.7);
    canvas.drawPath(tailPath, paint);
    paint.style = PaintingStyle.fill;

    // Blush
    paint.color = Colors.pink.withOpacity(0.25);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - r * 0.35, cy - r * 0.15), r * 0.08, paint);
    canvas.drawCircle(Offset(cx + r * 0.35, cy - r * 0.15), r * 0.08, paint);
  }

  void _drawDog(Canvas canvas, double cx, double cy, double r, Paint paint, bool blink, double wave) {
    // Body
    paint.color = mainColor;
    paint.style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.25), width: r * 1.5, height: r * 1.15), paint);

    // Head
    canvas.drawCircle(Offset(cx, cy - r * 0.3), r * 0.7, paint);

    // Floppy ears
    paint.color = secondaryColor;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.65, cy - r * 0.2 + wave * r * 0.1), width: r * 0.2, height: r * 0.4), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.65, cy - r * 0.2 + wave * r * 0.1), width: r * 0.2, height: r * 0.4), paint);

    // Eyes
    if (isSleeping) {
      paint.color = accentColor;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.25, cy - r * 0.3), Offset(cx - r * 0.05, cy - r * 0.3), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.3), Offset(cx + r * 0.25, cy - r * 0.3), paint);
      paint.style = PaintingStyle.fill;
    } else if (blink) {
      paint.color = accentColor;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.25, cy - r * 0.3), Offset(cx - r * 0.05, cy - r * 0.3), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.3), Offset(cx + r * 0.25, cy - r * 0.3), paint);
      paint.style = PaintingStyle.fill;
    } else {
      paint.color = accentColor;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx - r * 0.15, cy - r * 0.3), r * 0.08, paint);
      canvas.drawCircle(Offset(cx + r * 0.15, cy - r * 0.3), r * 0.08, paint);
      paint.color = Colors.white.withOpacity(0.6);
      canvas.drawCircle(Offset(cx - r * 0.12, cy - r * 0.33), r * 0.03, paint);
      canvas.drawCircle(Offset(cx + r * 0.18, cy - r * 0.33), r * 0.03, paint);
    }

    // Nose
    paint.color = Colors.black45;
    paint.style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - r * 0.15), width: r * 0.12, height: r * 0.08), paint);

    // Tongue
    paint.color = Colors.pink;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - r * 0.02), width: r * 0.08, height: r * 0.12), paint);

    // Tail (wagging)
    paint.color = mainColor;
    paint.strokeWidth = r * 0.1;
    paint.style = PaintingStyle.stroke;
    final tailWag = sin(animationFrame * 5) * r * 0.15;
    final tailPath = Path()
      ..moveTo(cx + r * 0.7, cy - r * 0.1)
      ..lineTo(cx + r * 1.0 + tailWag, cy - r * 0.5);
    canvas.drawPath(tailPath, paint);
    paint.style = PaintingStyle.fill;

    // Blush
    paint.color = Colors.pink.withOpacity(0.2);
    canvas.drawCircle(Offset(cx - r * 0.35, cy - r * 0.1), r * 0.08, paint);
    canvas.drawCircle(Offset(cx + r * 0.35, cy - r * 0.1), r * 0.08, paint);
  }

  void _drawPanda(Canvas canvas, double cx, double cy, double r, Paint paint, bool blink, double wave) {
    // Body
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.2), width: r * 1.5, height: r * 1.2), paint);

    // Head
    canvas.drawCircle(Offset(cx, cy - r * 0.3), r * 0.7, paint);

    // Ears
    paint.color = Colors.black87;
    canvas.drawCircle(Offset(cx - r * 0.55, cy - r * 0.75), r * 0.18, paint);
    canvas.drawCircle(Offset(cx + r * 0.55, cy - r * 0.75), r * 0.18, paint);

    // Eye patches
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.18, cy - r * 0.3), width: r * 0.25, height: r * 0.25), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.18, cy - r * 0.3), width: r * 0.25, height: r * 0.25), paint);

    // Eyes
    if (isSleeping) {
      paint.color = Colors.white70;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.25, cy - r * 0.3), Offset(cx - r * 0.05, cy - r * 0.3), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.3), Offset(cx + r * 0.25, cy - r * 0.3), paint);
      paint.style = PaintingStyle.fill;
    } else if (blink) {
      paint.color = Colors.white70;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.25, cy - r * 0.3), Offset(cx - r * 0.05, cy - r * 0.3), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.3), Offset(cx + r * 0.25, cy - r * 0.3), paint);
      paint.style = PaintingStyle.fill;
    } else {
      paint.color = Colors.white;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx - r * 0.18, cy - r * 0.3), r * 0.06, paint);
      canvas.drawCircle(Offset(cx + r * 0.18, cy - r * 0.3), r * 0.06, paint);
      paint.color = Colors.black87;
      canvas.drawCircle(Offset(cx - r * 0.18, cy - r * 0.3), r * 0.04, paint);
      canvas.drawCircle(Offset(cx + r * 0.18, cy - r * 0.3), r * 0.04, paint);
    }

    // Nose
    paint.color = Colors.black87;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy - r * 0.15), r * 0.04, paint);

    // Arms and legs
    paint.color = Colors.black87;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.55, cy + r * 0.2), width: r * 0.2, height: r * 0.3), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.55, cy + r * 0.2), width: r * 0.2, height: r * 0.3), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.35, cy + r * 0.55), width: r * 0.25, height: r * 0.15), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.35, cy + r * 0.55), width: r * 0.25, height: r * 0.15), paint);

    // Blush
    paint.color = Colors.pink.withOpacity(0.2);
    canvas.drawCircle(Offset(cx - r * 0.35, cy - r * 0.1), r * 0.08, paint);
    canvas.drawCircle(Offset(cx + r * 0.35, cy - r * 0.1), r * 0.08, paint);
  }

  void _drawFox(Canvas canvas, double cx, double cy, double r, Paint paint, bool blink, double wave) {
    paint.color = Colors.orange.shade400;
    paint.style = PaintingStyle.fill;
    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.2), width: r * 1.3, height: r * 1.2), paint);
    // Head
    canvas.drawCircle(Offset(cx, cy - r * 0.3), r * 0.65, paint);
    // Pointy ears
    paint.color = Colors.orange.shade600;
    final earPath1 = Path()
      ..moveTo(cx - r * 0.5, cy - r * 0.5)
      ..lineTo(cx - r * 0.8, cy - r * 1.1)
      ..lineTo(cx - r * 0.2, cy - r * 0.6)
      ..close();
    canvas.drawPath(earPath1, paint);
    final earPath2 = Path()
      ..moveTo(cx + r * 0.5, cy - r * 0.5)
      ..lineTo(cx + r * 0.8, cy - r * 1.1)
      ..lineTo(cx + r * 0.2, cy - r * 0.6)
      ..close();
    canvas.drawPath(earPath2, paint);
    // Inner ears
    paint.color = Colors.pink.shade100;
    final inner1 = Path()
      ..moveTo(cx - r * 0.48, cy - r * 0.52)
      ..lineTo(cx - r * 0.7, cy - r * 0.95)
      ..lineTo(cx - r * 0.25, cy - r * 0.58)
      ..close();
    canvas.drawPath(inner1, paint);
    final inner2 = Path()
      ..moveTo(cx + r * 0.48, cy - r * 0.52)
      ..lineTo(cx + r * 0.7, cy - r * 0.95)
      ..lineTo(cx + r * 0.25, cy - r * 0.58)
      ..close();
    canvas.drawPath(inner2, paint);
    // White face
    paint.color = Colors.white;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - r * 0.15), width: r * 0.6, height: r * 0.5), paint);
    // Eyes
    if (isSleeping) {
      paint.color = Colors.black54;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.2, cy - r * 0.3), Offset(cx - r * 0.05, cy - r * 0.3), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.3), Offset(cx + r * 0.2, cy - r * 0.3), paint);
      paint.style = PaintingStyle.fill;
    } else if (blink) {
      paint.color = Colors.black54;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.2, cy - r * 0.3), Offset(cx - r * 0.05, cy - r * 0.3), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.3), Offset(cx + r * 0.2, cy - r * 0.3), paint);
      paint.style = PaintingStyle.fill;
    } else {
      paint.color = Colors.black87;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx - r * 0.12, cy - r * 0.3), r * 0.06, paint);
      canvas.drawCircle(Offset(cx + r * 0.12, cy - r * 0.3), r * 0.06, paint);
    }
    // Nose
    paint.color = Colors.black87;
    canvas.drawCircle(Offset(cx, cy - r * 0.15), r * 0.04, paint);
    // Tail
    paint.color = Colors.orange.shade600;
    paint.strokeWidth = r * 0.12;
    paint.style = PaintingStyle.stroke;
    final tailPath = Path()
      ..moveTo(cx - r * 0.6, cy + r * 0.1)
      ..cubicTo(cx - r * 1.0, cy - r * 0.2, cx - r * 1.1, cy - r * 0.6, cx - r * 0.8, cy - r * 0.8);
    canvas.drawPath(tailPath, paint);
    // Tail tip
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - r * 0.8, cy - r * 0.8), r * 0.08, paint);
  }

  void _drawRabbit(Canvas canvas, double cx, double cy, double r, Paint paint, bool blink, double wave) {
    paint.color = Colors.pink.shade100;
    paint.style = PaintingStyle.fill;
    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.25), width: r * 1.3, height: r * 1.15), paint);
    // Head
    canvas.drawCircle(Offset(cx, cy - r * 0.25), r * 0.6, paint);
    // Long ears
    paint.color = Colors.pink.shade200;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - r * 0.25, cy - r * 1.2), width: r * 0.2, height: r * 0.7), Radius.circular(r * 0.1)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + r * 0.25, cy - r * 1.2), width: r * 0.2, height: r * 0.7), Radius.circular(r * 0.1)), paint);
    // Inner ears
    paint.color = Colors.pink.shade50;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - r * 0.25, cy - r * 1.2), width: r * 0.1, height: r * 0.55), Radius.circular(r * 0.05)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + r * 0.25, cy - r * 1.2), width: r * 0.1, height: r * 0.55), Radius.circular(r * 0.05)), paint);
    // Eyes
    if (isSleeping) {
      paint.color = Colors.black54;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.2, cy - r * 0.3), Offset(cx - r * 0.05, cy - r * 0.3), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.3), Offset(cx + r * 0.2, cy - r * 0.3), paint);
      paint.style = PaintingStyle.fill;
    } else if (blink) {
      paint.color = Colors.black54;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.2, cy - r * 0.3), Offset(cx - r * 0.05, cy - r * 0.3), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.3), Offset(cx + r * 0.2, cy - r * 0.3), paint);
      paint.style = PaintingStyle.fill;
    } else {
      paint.color = Colors.black87;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx - r * 0.12, cy - r * 0.3), r * 0.06, paint);
      canvas.drawCircle(Offset(cx + r * 0.12, cy - r * 0.3), r * 0.06, paint);
      paint.color = Colors.white.withOpacity(0.7);
      canvas.drawCircle(Offset(cx - r * 0.1, cy - r * 0.33), r * 0.025, paint);
      canvas.drawCircle(Offset(cx + r * 0.14, cy - r * 0.33), r * 0.025, paint);
    }
    // Nose
    paint.color = Colors.pink;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy - r * 0.15), r * 0.03, paint);
    // Blush
    paint.color = Colors.pink.withOpacity(0.3);
    canvas.drawCircle(Offset(cx - r * 0.3, cy - r * 0.1), r * 0.07, paint);
    canvas.drawCircle(Offset(cx + r * 0.3, cy - r * 0.1), r * 0.07, paint);
    // Tail
    paint.color = Colors.white;
    canvas.drawCircle(Offset(cx + r * 0.5, cy + r * 0.3), r * 0.1, paint);
  }

  void _drawPenguin(Canvas canvas, double cx, double cy, double r, Paint paint, bool blink, double wave) {
    // Body
    paint.color = Colors.blueGrey.shade800;
    paint.style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: r * 1.2, height: r * 1.5), paint);
    // White belly
    paint.color = Colors.white;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.1), width: r * 0.7, height: r * 1.0), paint);
    // Head
    paint.color = Colors.blueGrey.shade900;
    canvas.drawCircle(Offset(cx, cy - r * 0.55), r * 0.55, paint);
    // White face
    paint.color = Colors.white;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - r * 0.45), width: r * 0.4, height: r * 0.35), paint);
    // Eyes
    if (isSleeping) {
      paint.color = Colors.black54;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.2, cy - r * 0.55), Offset(cx - r * 0.05, cy - r * 0.55), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.55), Offset(cx + r * 0.2, cy - r * 0.55), paint);
      paint.style = PaintingStyle.fill;
    } else if (blink) {
      paint.color = Colors.black54;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.2, cy - r * 0.55), Offset(cx - r * 0.05, cy - r * 0.55), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.55), Offset(cx + r * 0.2, cy - r * 0.55), paint);
      paint.style = PaintingStyle.fill;
    } else {
      paint.color = Colors.black87;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx - r * 0.12, cy - r * 0.55), r * 0.05, paint);
      canvas.drawCircle(Offset(cx + r * 0.12, cy - r * 0.55), r * 0.05, paint);
    }
    // Beak
    paint.color = Colors.orange;
    final beakPath = Path()
      ..moveTo(cx - r * 0.06, cy - r * 0.45)
      ..lineTo(cx, cy - r * 0.38)
      ..lineTo(cx + r * 0.06, cy - r * 0.45)
      ..close();
    canvas.drawPath(beakPath, paint);
    // Feet
    paint.color = Colors.orange;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.2, cy + r * 0.65), width: r * 0.25, height: r * 0.1), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.2, cy + r * 0.65), width: r * 0.25, height: r * 0.1), paint);
    // Flippers
    paint.color = Colors.blueGrey.shade800;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.6, cy + r * 0.1), width: r * 0.15, height: r * 0.35), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.6, cy + r * 0.1), width: r * 0.15, height: r * 0.35), paint);
  }

  void _drawDragon(Canvas canvas, double cx, double cy, double r, Paint paint, bool blink, double wave) {
    paint.color = Colors.green.shade600;
    paint.style = PaintingStyle.fill;
    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.2), width: r * 1.4, height: r * 1.3), paint);
    // Head
    canvas.drawCircle(Offset(cx, cy - r * 0.3), r * 0.65, paint);
    // Horns
    paint.color = Colors.green.shade800;
    final horn1 = Path()
      ..moveTo(cx - r * 0.3, cy - r * 0.7)
      ..lineTo(cx - r * 0.5, cy - r * 1.1)
      ..lineTo(cx - r * 0.15, cy - r * 0.8)
      ..close();
    canvas.drawPath(horn1, paint);
    final horn2 = Path()
      ..moveTo(cx + r * 0.3, cy - r * 0.7)
      ..lineTo(cx + r * 0.5, cy - r * 1.1)
      ..lineTo(cx + r * 0.15, cy - r * 0.8)
      ..close();
    canvas.drawPath(horn2, paint);
    // Spikes on back
    paint.color = Colors.green.shade400;
    for (int i = -2; i <= 2; i++) {
      canvas.drawCircle(Offset(cx + i * r * 0.2, cy - r * 0.1 + i.abs() * r * 0.05), r * 0.06, paint);
    }
    // Eyes
    if (isSleeping) {
      paint.color = Colors.white70;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.25, cy - r * 0.3), Offset(cx - r * 0.05, cy - r * 0.3), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.3), Offset(cx + r * 0.25, cy - r * 0.3), paint);
      paint.style = PaintingStyle.fill;
    } else if (blink) {
      paint.color = Colors.white70;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.25, cy - r * 0.3), Offset(cx - r * 0.05, cy - r * 0.3), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.3), Offset(cx + r * 0.25, cy - r * 0.3), paint);
      paint.style = PaintingStyle.fill;
    } else {
      paint.color = Colors.yellow;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx - r * 0.15, cy - r * 0.3), r * 0.07, paint);
      canvas.drawCircle(Offset(cx + r * 0.15, cy - r * 0.3), r * 0.07, paint);
      paint.color = Colors.black87;
      canvas.drawCircle(Offset(cx - r * 0.15, cy - r * 0.3), r * 0.04, paint);
      canvas.drawCircle(Offset(cx + r * 0.15, cy - r * 0.3), r * 0.04, paint);
    }
    // Nostrils
    paint.color = Colors.green.shade900;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - r * 0.06, cy - r * 0.15), r * 0.025, paint);
    canvas.drawCircle(Offset(cx + r * 0.06, cy - r * 0.15), r * 0.025, paint);
    // Fire breath (when excited)
    if (emotion == PetEmotion.excited || emotion == PetEmotion.celebrating) {
      paint.color = Colors.orange;
      paint.strokeWidth = r * 0.08;
      paint.style = PaintingStyle.stroke;
      final firePath = Path()
        ..moveTo(cx, cy - r * 0.12)
        ..cubicTo(cx + r * 0.3, cy - r * 0.2, cx + r * 0.5, cy - r * 0.1, cx + r * 0.6, cy - r * 0.3);
      canvas.drawPath(firePath, paint);
      paint.color = Colors.yellow;
      paint.strokeWidth = r * 0.04;
      final firePath2 = Path()
        ..moveTo(cx, cy - r * 0.12)
        ..cubicTo(cx + r * 0.2, cy - r * 0.15, cx + r * 0.4, cy - r * 0.05, cx + r * 0.5, cy - r * 0.2);
      canvas.drawPath(firePath2, paint);
    }
    // Wings
    paint.color = Colors.green.shade400.withOpacity(0.7);
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 0;
    final wing1 = Path()
      ..moveTo(cx - r * 0.5, cy - r * 0.1)
      ..quadraticBezierTo(cx - r * 1.0, cy - r * 0.6, cx - r * 0.8, cy - r * 0.1)
      ..lineTo(cx - r * 0.5, cy - r * 0.1);
    canvas.drawPath(wing1, paint);
    final wing2 = Path()
      ..moveTo(cx + r * 0.5, cy - r * 0.1)
      ..quadraticBezierTo(cx + r * 1.0, cy - r * 0.6, cx + r * 0.8, cy - r * 0.1)
      ..lineTo(cx + r * 0.5, cy - r * 0.1);
    canvas.drawPath(wing2, paint);
    // Tail
    paint.color = Colors.green.shade600;
    paint.strokeWidth = r * 0.1;
    paint.style = PaintingStyle.stroke;
    final tailPath = Path()
      ..moveTo(cx - r * 0.6, cy + r * 0.3)
      ..cubicTo(cx - r * 1.0, cy + r * 0.5, cx - r * 1.1, cy + r * 0.8, cx - r * 0.7, cy + r * 0.9);
    canvas.drawPath(tailPath, paint);
    // Tail spike
    paint.color = Colors.green.shade800;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - r * 0.7, cy + r * 0.9), r * 0.06, paint);
  }

  void _drawSlime(Canvas canvas, double cx, double cy, double r, Paint paint, bool blink, double wave) {
    final squish = 0.05 * sin(animationFrame * 2);
    // Body (bouncy blob)
    paint.color = mainColor;
    paint.style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.1 + squish * r), width: r * 1.4, height: r * 1.1 + squish * r * 0.3), paint);
    // Highlight
    paint.color = mainColor.withOpacity(0.4);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.15, cy - r * 0.15), width: r * 0.4, height: r * 0.25), paint);
    // Eyes
    if (isSleeping) {
      paint.color = Colors.white70;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.2, cy - r * 0.1), Offset(cx - r * 0.05, cy - r * 0.1), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.1), Offset(cx + r * 0.2, cy - r * 0.1), paint);
      paint.style = PaintingStyle.fill;
    } else if (blink) {
      paint.color = Colors.white70;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.2, cy - r * 0.1), Offset(cx - r * 0.05, cy - r * 0.1), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.1), Offset(cx + r * 0.2, cy - r * 0.1), paint);
      paint.style = PaintingStyle.fill;
    } else {
      paint.color = Colors.white;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx - r * 0.12, cy - r * 0.1), r * 0.08, paint);
      canvas.drawCircle(Offset(cx + r * 0.12, cy - r * 0.1), r * 0.08, paint);
      paint.color = Colors.black87;
      canvas.drawCircle(Offset(cx - r * 0.12, cy - r * 0.1), r * 0.04, paint);
      canvas.drawCircle(Offset(cx + r * 0.12, cy - r * 0.1), r * 0.04, paint);
    }
    // Smile
    paint.color = Colors.white.withOpacity(0.7);
    paint.strokeWidth = 1.5;
    paint.style = PaintingStyle.stroke;
    final smilePath = Path()
      ..moveTo(cx - r * 0.1, cy + r * 0.05)
      ..quadraticBezierTo(cx, cy + r * 0.12, cx + r * 0.1, cy + r * 0.05);
    canvas.drawPath(smilePath, paint);
    paint.style = PaintingStyle.fill;
  }

  void _drawRobot(Canvas canvas, double cx, double cy, double r, Paint paint, bool blink, double wave) {
    // Body
    paint.color = Colors.grey.shade300;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + r * 0.15), width: r * 1.3, height: r * 1.2), Radius.circular(r * 0.15)), paint);
    // Head
    paint.color = Colors.grey.shade200;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy - r * 0.35), width: r * 0.9, height: r * 0.7), Radius.circular(r * 0.15)), paint);
    // Antenna
    paint.color = Colors.grey.shade400;
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, cy - r * 0.7), Offset(cx, cy - r * 0.9), paint);
    paint.style = PaintingStyle.fill;
    paint.color = Colors.red;
    canvas.drawCircle(Offset(cx, cy - r * 0.93), r * 0.06, paint);
    // Eyes
    if (isSleeping) {
      paint.color = Colors.grey.shade600;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.2, cy - r * 0.35), Offset(cx - r * 0.05, cy - r * 0.35), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.35), Offset(cx + r * 0.2, cy - r * 0.35), paint);
      paint.style = PaintingStyle.fill;
    } else if (blink) {
      paint.color = Colors.grey.shade600;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.2, cy - r * 0.35), Offset(cx - r * 0.05, cy - r * 0.35), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.35), Offset(cx + r * 0.2, cy - r * 0.35), paint);
      paint.style = PaintingStyle.fill;
    } else {
      paint.color = Colors.cyan;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx - r * 0.12, cy - r * 0.35), r * 0.06, paint);
      canvas.drawCircle(Offset(cx + r * 0.12, cy - r * 0.35), r * 0.06, paint);
      paint.color = Colors.white.withOpacity(0.7);
      canvas.drawCircle(Offset(cx - r * 0.1, cy - r * 0.37), r * 0.025, paint);
      canvas.drawCircle(Offset(cx + r * 0.14, cy - r * 0.37), r * 0.025, paint);
    }
    // Mouth (LED display)
    paint.color = Colors.cyan.withOpacity(0.6);
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy - r * 0.2), width: r * 0.3, height: r * 0.05), Radius.circular(r * 0.025)), paint);
    // Chest display
    paint.color = Colors.cyan.withOpacity(0.3);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + r * 0.1), width: r * 0.4, height: r * 0.15), Radius.circular(r * 0.03)), paint);
    // Bolts
    paint.color = Colors.grey.shade500;
    canvas.drawCircle(Offset(cx - r * 0.35, cy - r * 0.4), r * 0.04, paint);
    canvas.drawCircle(Offset(cx + r * 0.35, cy - r * 0.4), r * 0.04, paint);
  }

  void _drawCapybara(Canvas canvas, double cx, double cy, double r, Paint paint, bool blink, double wave) {
    paint.color = Colors.brown.shade300;
    paint.style = PaintingStyle.fill;
    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.2), width: r * 1.5, height: r * 1.1), paint);
    // Head
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - r * 0.35), width: r * 0.9, height: r * 0.65), paint);
    // Ears
    paint.color = Colors.brown.shade400;
    canvas.drawCircle(Offset(cx - r * 0.35, cy - r * 0.65), r * 0.08, paint);
    canvas.drawCircle(Offset(cx + r * 0.35, cy - r * 0.65), r * 0.08, paint);
    // Eyes
    if (isSleeping) {
      paint.color = Colors.brown.shade700;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.2, cy - r * 0.35), Offset(cx - r * 0.05, cy - r * 0.35), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.35), Offset(cx + r * 0.2, cy - r * 0.35), paint);
      paint.style = PaintingStyle.fill;
    } else if (blink) {
      paint.color = Colors.brown.shade700;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.2, cy - r * 0.35), Offset(cx - r * 0.05, cy - r * 0.35), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.35), Offset(cx + r * 0.2, cy - r * 0.35), paint);
      paint.style = PaintingStyle.fill;
    } else {
      paint.color = Colors.brown.shade900;
      paint.style = PaintingStyle.fill;
      paint.strokeWidth = 0;
      canvas.drawCircle(Offset(cx - r * 0.12, cy - r * 0.35), r * 0.045, paint);
      canvas.drawCircle(Offset(cx + r * 0.12, cy - r * 0.35), r * 0.045, paint);
    }
    // Nose
    paint.color = Colors.brown.shade700;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - r * 0.25), width: r * 0.1, height: r * 0.06), paint);
    // Mouth (half-lidded expression)
    paint.color = Colors.brown.shade600;
    paint.strokeWidth = 1.5;
    paint.style = PaintingStyle.stroke;
    final mouthPath = Path()
      ..moveTo(cx - r * 0.05, cy - r * 0.2)
      ..quadraticBezierTo(cx + r * 0.05, cy - r * 0.15, cx + r * 0.1, cy - r * 0.2);
    canvas.drawPath(mouthPath, paint);
    paint.style = PaintingStyle.fill;
  }

  void _drawAxolotl(Canvas canvas, double cx, double cy, double r, Paint paint, bool blink, double wave) {
    paint.color = Colors.pink.shade200;
    paint.style = PaintingStyle.fill;
    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.15), width: r * 1.3, height: r * 1.1), paint);
    // Head
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - r * 0.3), width: r * 0.8, height: r * 0.6), paint);
    // Gills (frills on head)
    paint.color = Colors.pink.shade300;
    for (int i = -1; i <= 1; i += 2) {
      for (int j = 0; j < 3; j++) {
        canvas.drawCircle(Offset(cx + i * r * (0.4 + j * 0.08), cy - r * (0.4 + j * 0.08)), r * 0.05, paint);
      }
    }
    // Eyes
    if (isSleeping) {
      paint.color = Colors.pink.shade700;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.2, cy - r * 0.3), Offset(cx - r * 0.05, cy - r * 0.3), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.3), Offset(cx + r * 0.2, cy - r * 0.3), paint);
      paint.style = PaintingStyle.fill;
    } else if (blink) {
      paint.color = Colors.pink.shade700;
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - r * 0.2, cy - r * 0.3), Offset(cx - r * 0.05, cy - r * 0.3), paint);
      canvas.drawLine(Offset(cx + r * 0.05, cy - r * 0.3), Offset(cx + r * 0.2, cy - r * 0.3), paint);
      paint.style = PaintingStyle.fill;
    } else {
      paint.color = Colors.black87;
      paint.style = PaintingStyle.fill;
      paint.strokeWidth = 0;
      canvas.drawCircle(Offset(cx - r * 0.12, cy - r * 0.3), r * 0.055, paint);
      canvas.drawCircle(Offset(cx + r * 0.12, cy - r * 0.3), r * 0.055, paint);
      paint.color = Colors.white;
      canvas.drawCircle(Offset(cx - r * 0.1, cy - r * 0.32), r * 0.02, paint);
      canvas.drawCircle(Offset(cx + r * 0.14, cy - r * 0.32), r * 0.02, paint);
    }
    // Permanent smile
    paint.color = Colors.pink.shade400;
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    final smilePath = Path()
      ..moveTo(cx - r * 0.12, cy - r * 0.15)
      ..quadraticBezierTo(cx, cy - r * 0.08, cx + r * 0.12, cy - r * 0.15);
    canvas.drawPath(smilePath, paint);
    paint.style = PaintingStyle.fill;
    // Blush
    paint.color = Colors.pink.withOpacity(0.3);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - r * 0.25, cy - r * 0.18), r * 0.07, paint);
    canvas.drawCircle(Offset(cx + r * 0.25, cy - r * 0.18), r * 0.07, paint);
    // Little legs
    paint.color = Colors.pink.shade300;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.4, cy + r * 0.5), width: r * 0.18, height: r * 0.12), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.4, cy + r * 0.5), width: r * 0.18, height: r * 0.12), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.3, cy + r * 0.55), width: r * 0.18, height: r * 0.12), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.3, cy + r * 0.55), width: r * 0.18, height: r * 0.12), paint);
    // Tail
    paint.color = Colors.pink.shade100;
    paint.strokeWidth = r * 0.08;
    paint.style = PaintingStyle.stroke;
    final tailPath = Path()
      ..moveTo(cx + r * 0.6, cy + r * 0.2)
      ..cubicTo(cx + r * 1.0, cy + r * 0.3, cx + r * 1.1, cy + r * 0.5, cx + r * 0.8, cy + r * 0.6);
    canvas.drawPath(tailPath, paint);
    paint.style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(covariant _PetBodyPainter oldDelegate) {
    return oldDelegate.animationFrame != animationFrame ||
        oldDelegate.activity != activity ||
        oldDelegate.emotion != emotion ||
        oldDelegate.isSleeping != isSleeping;
  }
}

class _TrailPainter extends CustomPainter {
  final Color color;
  final double progress;

  _TrailPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3 * (1 - progress))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    for (double t = 0; t <= 1; t += 0.05) {
      final x = t * size.width;
      final y = size.height / 2 + sin((t + progress) * pi * 4) * 5;
      if (t == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrailPainter oldDelegate) => oldDelegate.progress != progress;
}