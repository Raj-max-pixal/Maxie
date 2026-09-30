import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maxie_mobile/features/home/presentation/providers/overlay_provider.dart';

class FloatingQuickActions extends ConsumerWidget {
  const FloatingQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlayState = ref.watch(overlayProvider);
    final widget = overlayState.getWidget('quick_actions');
    
    if (widget == null || !widget.isVisible) return const SizedBox.shrink();

    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          ref.read(overlayProvider.notifier).updateWidgetPosition(
            'quick_actions',
            Offset(widget.position.dx + details.delta.dx, widget.position.dy + details.delta.dy),
          );
        },
        child: Container(
          width: widget.size * 2,
          height: widget.size * 2,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: overlayState.transparency),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: 'Chat',
                onTap: () => _navigateToChat(context),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => _navigateToSettings(context),
                    isSmall: true,
                  ),
                  _buildActionButton(
                    icon: Icons.music_note_outlined,
                    label: 'Music',
                    onTap: () => _toggleMusic(),
                    isSmall: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSmall = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isSmall ? 40 : 50,
        height: isSmall ? 40 : 50,
        decoration: BoxDecoration(
          color: Colors.purple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isSmall ? 20 : 24, color: Colors.purple),
            if (!isSmall)
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.purple,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToChat(BuildContext context) {
    Navigator.pushNamed(context, '/chat');
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }

  void _toggleMusic() {
    // Toggle music playback
  }
}
