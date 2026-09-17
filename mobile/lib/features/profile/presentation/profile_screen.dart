import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/features/auth/application/auth_providers.dart';
import 'package:maxie_mobile/navigation/app_routes.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authUser = ref.watch(authServiceProvider).user;
    final profile = ref.watch(currentUserProfileProvider);

    return PremiumScaffold(
      title: 'Profile',
      actions: [
        IconButton(
          tooltip: 'Settings',
          onPressed: () => context.go(AppRoutes.settings),
          icon: const Icon(Icons.settings_rounded),
        ),
      ],
      child: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Could not load your profile: $error')),
        data: (userProfile) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 108),
          children: [
            PremiumCard(
              glowColor: AppColors.seed,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.seed.withValues(alpha: 0.22),
                    child: const Icon(Icons.person_rounded, size: 34),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProfile?.displayName?.isNotEmpty == true
                              ? userProfile!.displayName!
                              : (authUser?.email ?? 'Your profile'),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          userProfile == null
                              ? (authUser?.email ?? '')
                              : 'Joined ${_joinedDate(userProfile.createdAt)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Chip(label: Text('MAXie account')),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) context.go(AppRoutes.login);
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }

  String _joinedDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
