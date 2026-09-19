import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/ai_chat/application/chat_controller.dart';
import 'package:maxie_mobile/features/shared/widgets/glass_card.dart';
import 'package:maxie_mobile/features/voice/domain/services/voice_service.dart';

class VoiceChatScreen extends ConsumerStatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  ConsumerState<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends ConsumerState<VoiceChatScreen>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  bool _isWorking = false;
  String? _error;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Chat')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) => Container(
                width: 200 + _animController.value * 40,
                height: 200 + _animController.value * 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.3),
                      theme.colorScheme.tertiary.withValues(alpha: 0.3),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isListening
                          ? theme.colorScheme.primary.withValues(alpha: 0.3)
                          : Colors.transparent,
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 48),
            GlassCard(
              child: Text(
                _error ??
                    (_isWorking
                        ? 'Thinking...'
                        : (_isListening ? 'Listening...' : 'Tap to speak')),
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _toggleListening,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  color: theme.colorScheme.onPrimary,
                  size: 36,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleListening() async {
    final voice = ref.read(voiceServiceProvider);
    if (_isListening) {
      await voice.stopListening();
      setState(() => _isListening = false);
      final words = voice.lastWords.trim();
      if (words.isEmpty) {
        setState(() => _error = 'MAXie did not hear anything. Try again.');
        return;
      }
      setState(() {
        _isWorking = true;
        _error = null;
      });
      await ref.read(chatControllerProvider.notifier).sendMessage(words);
      if (mounted) setState(() => _isWorking = false);
      return;
    }

    setState(() => _error = null);
    try {
      await voice.initialize();
      final available = await voice.startListening();
      if (!available && mounted) {
        setState(
          () => _error = 'Microphone access is unavailable. Check permissions.',
        );
        return;
      }
      if (mounted) setState(() => _isListening = true);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'MAXie needs microphone access to listen.');
      }
    }
  }
}
