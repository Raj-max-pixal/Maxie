import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maxie_mobile/features/home/presentation/providers/apps_provider.dart';

class DraggableAppIcon extends ConsumerStatefulWidget {
  final AppItem app;
  final VoidCallback onTap;

  const DraggableAppIcon({
    super.key,
    required this.app,
    required this.onTap,
  });

  @override
  ConsumerState<DraggableAppIcon> createState() => _DraggableAppIconState();
}

class _DraggableAppIconState extends ConsumerState<DraggableAppIcon> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final app = widget.app;

    return Positioned(
      left: app.position.dx,
      top: app.position.dy,
      child: GestureDetector(
        onPanStart: (_) {
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          ref.read(appsProvider.notifier).updateAppPosition(
                app.id,
                Offset(
                  app.position.dx + details.delta.dx,
                  app.position.dy + details.delta.dy,
                ),
              );
        },
        onPanEnd: (_) {
          setState(() {
            _isDragging = false;
          });
        },
        onTap: widget.onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Beautiful glassmorphic icon body
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: _isDragging ? 0.35 : 0.25),
                      Colors.white.withValues(alpha: _isDragging ? 0.15 : 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: _isDragging ? 0.5 : 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: _isDragging ? 0.25 : 0.1),
                      blurRadius: _isDragging ? 16 : 8,
                      spreadRadius: _isDragging ? 2 : 0,
                      offset: Offset(0, _isDragging ? 8 : 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.purple.shade400.withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                          radius: 1.0,
                        ),
                      ),
                      child: Icon(
                        app.icon,
                        size: 32,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                ),
              )
                  .animate(target: _isDragging ? 1 : 0)
                  .scale(end: const Offset(1.15, 1.15), duration: 150.ms),
              const SizedBox(height: 8),
              // App label with nice text outline shadow
              SizedBox(
                width: 80,
                child: Text(
                  app.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: [
                      const Shadow(
                        offset: Offset(0, 1.5),
                        blurRadius: 4.0,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
