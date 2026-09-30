import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maxie_mobile/features/home/presentation/providers/overlay_provider.dart';

class FloatingNotificationPreview extends ConsumerWidget {
  final String appName;
  final String title;
  final String message;
  final VoidCallback onDismiss;

  const FloatingNotificationPreview({
    super.key,
    required this.appName,
    required this.title,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlayState = ref.watch(overlayProvider);
    final widget = overlayState.getWidget('notification_preview');
    
    if (widget == null || !widget.isVisible) return const SizedBox.shrink();

    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          ref.read(overlayProvider.notifier).updateWidgetPosition(
            'notification_preview',
            Offset(widget.position.dx + details.delta.dx, widget.position.dy + details.delta.dy),
          );
        },
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: overlayState.transparency),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications, size: 16, color: Colors.purple),
                        const SizedBox(width: 8),
                        Text(
                          appName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: onDismiss,
                      child: const Icon(Icons.close, size: 16),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
