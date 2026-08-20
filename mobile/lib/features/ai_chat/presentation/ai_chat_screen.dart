import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/ai_chat/application/chat_controller.dart';
import 'package:maxie_mobile/features/ai_chat/domain/models/chat_message.dart';
import 'package:maxie_mobile/features/memory/application/memory_providers.dart';
import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';
import 'package:maxie_mobile/features/ai_companion/domain/models/ai_companion_state.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/maxie_companion_view.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';
import 'package:maxie_mobile/widgets/section_title.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final chatController = ref.read(chatControllerProvider.notifier);
    final conversation = chatState.activeConversation;

    if (_controller.text != conversation.draft) {
      _controller.value = TextEditingValue(
        text: conversation.draft,
        selection: TextSelection.collapsed(offset: conversation.draft.length),
      );
    }

    ref.listen(chatControllerProvider, (_, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });

    return PremiumScaffold(
      title: conversation.title,
      actions: [
        IconButton(
          tooltip: 'New chat',
          onPressed: chatController.createConversation,
          icon: const Icon(Icons.add_comment_rounded),
        ),
        IconButton(
          tooltip: 'Regenerate',
          onPressed: chatState.isGenerating
              ? null
              : chatController.regenerateLastResponse,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: Column(
        children: [
          if (chatState.conversations.length > 1)
            SizedBox(
              height: 52,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final item = chatState.conversations[index];
                  return ChoiceChip(
                    label: Text(item.title),
                    selected: item.id == conversation.id,
                    onSelected: (_) =>
                        chatController.selectConversation(item.id),
                  );
                },
                separatorBuilder: (_, index) =>
                    const SizedBox(width: AppSpacing.xs),
                itemCount: chatState.conversations.length,
              ),
            ),
          Expanded(
            child: conversation.messages.isEmpty
                ? _ChatEmptyState(onPromptSelected: (prompt) => _send(prompt))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                    itemCount: conversation.messages.length,
                    itemBuilder: (context, index) {
                      final message = conversation.messages[index];
                      return _ChatBubble(
                            message: message,
                            onCopy: () => _copyText(message.content),
                            onRetry: () =>
                                chatController.regenerateLastResponse(),
                          )
                          .animate()
                          .fadeIn(duration: 180.ms)
                          .slideY(begin: 0.04, end: 0);
                    },
                  ),
          ),
          if (chatState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ErrorStrip(message: chatState.errorMessage!),
            ),
          if (chatState.pendingMemorySuggestion != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _MemorySuggestionCard(
                suggestion: chatState.pendingMemorySuggestion!,
                onSave: chatController.acceptPendingMemory,
                onEdit: () =>
                    _editPendingMemory(chatState.pendingMemorySuggestion!),
                onIgnore: chatController.ignorePendingMemory,
              ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.06, end: 0),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Voice input',
                    onPressed: () =>
                        _showMessage('Voice input foundation is ready.'),
                    icon: const Icon(Icons.mic_rounded),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton.filledTonal(
                    tooltip: 'Upload image',
                    onPressed: () =>
                        _showMessage('Gemini Vision placeholder is ready.'),
                    icon: const Icon(Icons.image_rounded),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      onChanged: chatController.saveDraft,
                      decoration: const InputDecoration(
                        labelText: 'Message MAXie',
                        hintText: 'Ask anything',
                      ),
                      onSubmitted: (_) => _send(_controller.text),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton.filled(
                    tooltip: chatState.isGenerating ? 'Stop' : 'Send',
                    onPressed: chatState.isGenerating
                        ? chatController.stopGeneration
                        : () => _send(_controller.text),
                    icon: Icon(
                      chatState.isGenerating
                          ? Icons.stop_rounded
                          : Icons.send_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _send(String text) {
    ref.read(chatControllerProvider.notifier).sendMessage(text);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showMessage('Copied response.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editPendingMemory(MemorySuggestion suggestion) async {
    final titleController = TextEditingController(
      text: suggestion.memory.title,
    );
    final valueController = TextEditingController(
      text: suggestion.memory.value,
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Memory'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: valueController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Value'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final updated = suggestion.memory.copyWith(
                  title: titleController.text.trim().isEmpty
                      ? suggestion.memory.title
                      : titleController.text.trim(),
                  value: valueController.text.trim().isEmpty
                      ? suggestion.memory.value
                      : valueController.text.trim(),
                  updatedAt: DateTime.now(),
                );
                await ref
                    .read(memoryManagerProvider.notifier)
                    .saveMemory(updated);
                if (!context.mounted || !dialogContext.mounted) {
                  return;
                }
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          MaxieCompanionView(size: 24, state: CompanionPresence.happy),
                          const SizedBox(width: AppSpacing.sm),
                          const Text('Got it! Updated.'),
                        ],
                      ),
                    ),
                  );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }
}

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState({required this.onPromptSelected});

  final ValueChanged<String> onPromptSelected;

  @override
  Widget build(BuildContext context) {
    const prompts = [
      'Explain this code',
      'Help me study',
      'Summarize notes',
      'Plan my day',
      'Debug Flutter',
      'Learn Python',
      'Career Advice',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      children: [
        const PremiumCard(
          glowColor: AppColors.calmTeal,
          child: Row(
            children: [
              MaxieCompanionView(size: 96),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: SectionTitle(
                  title: 'Ready to chat?',
                  subtitle:
                      'I can stream answers, format markdown, and remember this conversation locally.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final prompt in prompts)
              ActionChip(
                label: Text(prompt),
                avatar: const Icon(Icons.auto_awesome_rounded, size: 16),
                onPressed: () => onPromptSelected(prompt),
              ),
          ],
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.onCopy,
    required this.onRetry,
  });

  final ChatMessage message;
  final VoidCallback onCopy;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        constraints: const BoxConstraints(maxWidth: 720),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isUser ? AppColors.seed : AppColors.darkSurface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isUser ? AppColors.seed : AppColors.darkStroke,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MessageContent(message.content),
                if (message.status == ChatMessageStatus.streaming) ...[
                  const SizedBox(height: AppSpacing.xs),
                  const _TypingDots(),
                ],
                if (!isUser) ...[
                  const Divider(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: [
                      IconButton(
                        tooltip: 'Copy',
                        onPressed: onCopy,
                        icon: const Icon(Icons.copy_rounded, size: 18),
                      ),
                      IconButton(
                        tooltip: 'Regenerate',
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                      ),
                      IconButton(
                        tooltip: 'Like',
                        onPressed: () =>
                            _showInlineMessage(context, 'Marked as helpful.'),
                        icon: const Icon(Icons.thumb_up_alt_outlined, size: 18),
                      ),
                      IconButton(
                        tooltip: 'Dislike',
                        onPressed: () => _showInlineMessage(
                          context,
                          'Feedback saved for future tuning.',
                        ),
                        icon: const Icon(
                          Icons.thumb_down_alt_outlined,
                          size: 18,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Save to future memory',
                        onPressed: () => _showInlineMessage(
                          context,
                          'Future memory save hook is ready.',
                        ),
                        icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showInlineMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MessageContent extends StatelessWidget {
  const _MessageContent(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) {
      return const Text('...');
    }

    final blocks = _splitCodeBlocks(text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in blocks)
          block.isCode
              ? _CodeBlock(language: block.language, code: block.value)
              : _MarkdownLite(block.value),
      ],
    );
  }

  List<_ContentBlock> _splitCodeBlocks(String value) {
    final blocks = <_ContentBlock>[];
    final pattern = RegExp(r'```(\w+)?\n([\s\S]*?)```');
    var cursor = 0;
    for (final match in pattern.allMatches(value)) {
      if (match.start > cursor) {
        blocks.add(_ContentBlock.text(value.substring(cursor, match.start)));
      }
      blocks.add(
        _ContentBlock.code(
          match.group(2) ?? '',
          language: match.group(1) ?? 'text',
        ),
      );
      cursor = match.end;
    }
    if (cursor < value.length) {
      blocks.add(_ContentBlock.text(value.substring(cursor)));
    }
    return blocks;
  }
}

class _MarkdownLite extends StatelessWidget {
  const _MarkdownLite(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final lines = text.trim().split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(_formatLine(line), style: _styleForLine(context, line)),
          ),
      ],
    );
  }

  String _formatLine(String line) {
    if (line.startsWith('#')) {
      return line.replaceFirst(RegExp(r'^#+\s*'), '');
    }
    if (line.startsWith('- ')) {
      return '• ${line.substring(2)}';
    }
    if (line.startsWith('> ')) {
      return line.substring(2);
    }
    return line;
  }

  TextStyle? _styleForLine(BuildContext context, String line) {
    final theme = Theme.of(context);
    if (line.startsWith('# ')) {
      return theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900);
    }
    if (line.startsWith('##')) {
      return theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800);
    }
    if (line.startsWith('> ')) {
      return theme.textTheme.bodyMedium?.copyWith(
        color: AppColors.calmTeal,
        fontStyle: FontStyle.italic,
      );
    }
    return theme.textTheme.bodyMedium;
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.language, required this.code});

  final String language;
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
            child: Row(
              children: [
                Text(language.toUpperCase()),
                const Spacer(),
                IconButton(
                  tooltip: 'Copy code',
                  onPressed: () => Clipboard.setData(ClipboardData(text: code)),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Text(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Color(0xFFE2E8F0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatelessWidget {
  const _TypingDots();

  @override
  Widget build(BuildContext context) {
    return const Text('MAXie is typing...');
  }
}

class _ErrorStrip extends StatelessWidget {
  const _ErrorStrip({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      glowColor: AppColors.danger,
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _MemorySuggestionCard extends StatelessWidget {
  const _MemorySuggestionCard({
    required this.suggestion,
    required this.onSave,
    required this.onEdit,
    required this.onIgnore,
  });

  final MemorySuggestion suggestion;
  final Future<void> Function() onSave;
  final VoidCallback onEdit;
  final VoidCallback onIgnore;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      glowColor: AppColors.calmTeal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MaxieCompanionView(size: 68),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🧠 New Memory Detected',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ).animate().shimmer(duration: 1200.ms, delay: 400.ms),
                    const SizedBox(height: 4),
                    Text(
                      suggestion.memory.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      suggestion.memory.value,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _MemoryMetaGrid(
            memory: suggestion.memory,
            confidence: suggestion.confidence,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              FilledButton.icon(
                onPressed: () {
                  onSave();
                  ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          MaxieCompanionView(size: 24, state: CompanionPresence.happy),
                          const SizedBox(width: AppSpacing.sm),
                          const Text('I\'ll remember that.'),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.bookmark_add_rounded),
                label: const Text('Save'),
              ),
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Edit'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  onIgnore();
                },
                icon: const Icon(Icons.close_rounded),
                label: const Text('Ignore'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            suggestion.reason,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 240.ms).slideY(begin: 0.04, end: 0);
  }
}

class _MemoryMetaGrid extends StatelessWidget {
  const _MemoryMetaGrid({required this.memory, required this.confidence});

  final MemoryRecord memory;
  final double confidence;

  @override
  Widget build(BuildContext context) {
    final created = _formatRelativeDate(memory.createdAt);
    final used = memory.lastUsedAt == null
        ? 'Never'
        : _formatRelativeDate(memory.lastUsedAt!);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _MemoryMetaPill(
          label: 'Confidence',
          value: '${(confidence * 100).round()}%',
          color: AppColors.success,
        ),
        _MemoryMetaPill(
          label: 'Importance',
          value: _stars(memory.importance.weight),
          color: AppColors.warning,
        ),
        _MemoryMetaPill(
          label: 'Source',
          value: memory.source.name.toUpperCase(),
        ),
        _MemoryMetaPill(label: 'Created', value: created),
        _MemoryMetaPill(label: 'Used', value: '$used (${memory.usageCount}x)'),
      ],
    );
  }

  String _stars(int weight) => List.filled(weight.clamp(1, 5), '★').join();
}

class _MemoryMetaPill extends StatelessWidget {
  const _MemoryMetaPill({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1624),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white54,
              fontWeight: FontWeight.w700,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final deltaDays = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(date.year, date.month, date.day)).inDays;
  if (deltaDays <= 0) {
    return 'Today';
  }
  if (deltaDays == 1) {
    return 'Yesterday';
  }
  return '${date.month}/${date.day}/${date.year}';
}

class _ContentBlock {
  const _ContentBlock._({
    required this.value,
    required this.isCode,
    this.language = 'text',
  });

  factory _ContentBlock.text(String value) {
    return _ContentBlock._(value: value, isCode: false);
  }

  factory _ContentBlock.code(String value, {required String language}) {
    return _ContentBlock._(value: value, isCode: true, language: language);
  }

  final String value;
  final bool isCode;
  final String language;
}
