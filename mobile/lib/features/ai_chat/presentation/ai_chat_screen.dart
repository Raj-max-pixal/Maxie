import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/app_text_field.dart';
import 'package:maxie_mobile/widgets/maxie_companion_view.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';
import 'package:maxie_mobile/widgets/section_title.dart';

class AiChatScreen extends StatelessWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Chat',
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              children: [
                const SectionTitle(
                  title: 'Ready to chat?',
                  subtitle: 'Voice, image, markdown and streaming are prepared as UI foundations.',
                ),
                const SizedBox(height: AppSpacing.lg),
                const PremiumCard(
                  child: Row(
                    children: [
                      MaxieCompanionView(size: 92),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'I can help you think, plan, reflect, or turn a messy idea into something useful.',
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.08, end: 0),
                const SizedBox(height: AppSpacing.lg),
                const _MessageBubble(
                  message: 'Good morning. What should we focus on first?',
                  isMine: false,
                ),
                const _MessageBubble(
                  message: 'Help me prepare for the afternoon meetings.',
                  isMine: true,
                ),
                const _TypingIndicator(),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final prompt in const [
                      'Plan my day',
                      'Summarize this',
                      'Help me decide',
                      'Create a checklist',
                    ])
                      ActionChip(
                        label: Text(prompt),
                        avatar: const Icon(Icons.auto_awesome_rounded, size: 16),
                        onPressed: () => _showFoundationMessage(
                          context,
                          '$prompt is ready for Phase 3 chat.',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Markdown + code block placeholder'),
                      SizedBox(height: AppSpacing.sm),
                      _CodePreview(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Voice',
                    onPressed: () => _showFoundationMessage(
                      context,
                      'Voice input foundation is ready.',
                    ),
                    icon: const Icon(Icons.mic_rounded),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton.filledTonal(
                    tooltip: 'Upload image',
                    onPressed: () => _showFoundationMessage(
                      context,
                      'Image upload foundation is ready.',
                    ),
                    icon: const Icon(Icons.image_rounded),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Expanded(
                    child: AppTextField(
                      label: 'Message MAXie',
                      hintText: 'Ask anything',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton.filled(
                    tooltip: 'Send',
                    onPressed: () => _showFoundationMessage(
                      context,
                      'Streaming chat connects in Phase 3.',
                    ),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFoundationMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final String message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        constraints: const BoxConstraints(maxWidth: 310),
        decoration: BoxDecoration(
          color: isMine ? AppColors.seed : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isMine ? AppColors.seed : AppColors.darkStroke,
          ),
        ),
        child: Text(message),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text('MAXie is thinking...'),
      ),
    );
  }
}

class _CodePreview extends StatelessWidget {
  const _CodePreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkStroke),
      ),
      child: const Text('final nextStep = maxie.plan(context);'),
    );
  }
}
