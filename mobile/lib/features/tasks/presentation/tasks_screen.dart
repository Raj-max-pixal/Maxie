import 'package:flutter/material.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/content_cards.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';
import 'package:maxie_mobile/widgets/section_title.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Tasks',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
        children: const [
          SectionTitle(
            title: "Today's Tasks",
            subtitle: 'Demo missions that keep the Shipathon story focused.',
          ),
          SizedBox(height: AppSpacing.lg),
          TaskCard(
            title: 'Prepare afternoon meeting notes',
            subtitle: 'Ask MAXie to summarize or plan the next step.',
          ),
          SizedBox(height: AppSpacing.sm),
          TaskCard(
            title: 'Review Project Nebula draft',
            subtitle: 'Save project facts into Memory Brain from chat.',
          ),
          SizedBox(height: AppSpacing.lg),
          PremiumCard(
            glowColor: AppColors.warning,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.calendar_month_rounded,
                color: AppColors.warning,
              ),
              title: Text('Hackathon demo checklist'),
              subtitle: Text(
                'Chat, save a memory, and show the companion mood change.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
