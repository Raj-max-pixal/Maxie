import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/overlay_provider.dart';
import '../../../music/domain/services/music_detector.dart';

class FloatingMusicPlayer extends ConsumerWidget {
  const FloatingMusicPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlayState = ref.watch(overlayProvider);
    final musicDetector = ref.watch(musicDetectorProvider);
    final widget = overlayState.getWidget('music_player');
    
    if (widget == null || !widget.isVisible || !musicDetector.isPlaying) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          ref.read(overlayProvider.notifier).updateWidgetPosition(
            'music_player',
            Offset(widget.position.dx + details.delta.dx, widget.position.dy + details.delta.dy),
          );
        },
        child: Container(
          width: 200,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(overlayState.transparency),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: const Icon(Icons.music_note, color: Colors.purple),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        musicDetector.currentSong ?? 'Unknown Song',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        musicDetector.currentArtist ?? 'Unknown Artist',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.play_arrow, color: Colors.purple),
                onPressed: () {
                  // Toggle play/pause
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
