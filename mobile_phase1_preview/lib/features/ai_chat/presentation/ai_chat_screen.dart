import 'package:flutter/material.dart';
import 'package:maxie_mobile/shared/app_page.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/animated_card.dart';
import 'package:maxie_mobile/widgets/app_text_field.dart';
import 'package:maxie_mobile/widgets/primary_button.dart';
import 'package:maxie_mobile/widgets/section_title.dart';

class AiChatScreen extends StatelessWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'AI Chat',
      child: Column(
        children: [
          const SectionTitle(
            title: 'AI Chat',
            subtitle: 'Placeholder route for the Phase 2 conversation engine.',
          ),
          const SizedBox(height: AppSpacing.lg),
          const Expanded(
            child: AnimatedCard(
              child: Center(
                child: Text('AI companion chat will be connected next.'),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Expanded(
                child: AppTextField(
                  label: 'Message',
                  hintText: 'Say hello to MAXie',
                  prefixIcon: Icons.chat_bubble_outline_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 132,
                child: PrimaryButton(
                  label: 'Send',
                  icon: Icons.send_rounded,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
