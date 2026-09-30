import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/features/auth/application/auth_providers.dart';
import 'package:maxie_mobile/features/auth/domain/models/user_profile.dart';
import 'package:maxie_mobile/navigation/app_routes.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/premium_card.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';

const _shareUrl = String.fromEnvironment('MAXIE_SHARE_URL');

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).user;
    final profile = ref.watch(currentUserProfileProvider);
    return PremiumScaffold(
      title: 'You',
      actions: [
        IconButton(
          tooltip: 'Settings',
          onPressed: () => context.go(AppRoutes.settings),
          icon: const Icon(Icons.settings_rounded),
        ),
      ],
      child: user == null
          ? _SignedOut(onSignIn: () => context.go(AppRoutes.login))
          : profile.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Could not load your profile: $error')),
              data: (data) => _ProfileBody(
                profile: data,
                email: user.email ?? '',
                onEdit: () => _edit(context, ref, data),
                onShare: _shareUrl.isEmpty ? null : () => _copyLink(context),
                onLogout: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) context.go(AppRoutes.login);
                },
              ),
            ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, UserProfile? profile) async {
    final name = TextEditingController(text: profile?.displayName ?? '');
    final age = TextEditingController(text: profile?.age?.toString() ?? '');
    final bio = TextEditingController(text: profile?.bio ?? '');
    final companion = TextEditingController(text: profile?.maxieName ?? 'MAXie');
    final uid = ref.read(authServiceProvider).user?.uid;
    if (uid == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Edit your profile', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Display name')),
              const SizedBox(height: 12),
              TextField(
                controller: age,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Age (optional)'),
              ),
              const SizedBox(height: 12),
              TextField(controller: bio, maxLength: 160, maxLines: 3, decoration: const InputDecoration(labelText: 'Bio (optional)')),
              const SizedBox(height: 12),
              TextField(controller: companion, maxLength: 24, decoration: const InputDecoration(labelText: 'Your companion name')),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  final parsedAge = age.text.trim().isEmpty ? null : int.tryParse(age.text.trim());
                  if (parsedAge != null && (parsedAge < 13 || parsedAge > 120)) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(const SnackBar(content: Text('Enter an age from 13 to 120.')));
                    return;
                  }
                  await ref.read(userProfileRepositoryProvider).updateProfile(
                    uid,
                    displayName: name.text,
                    age: parsedAge,
                    bio: bio.text,
                    maxieName: companion.text,
                  );
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
                child: const Text('Save profile'),
              ),
            ],
          ),
        ),
      ),
    );
    name.dispose(); age.dispose(); bio.dispose(); companion.dispose();
  }

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _shareUrl));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('MAXie link copied. Share it with your friends!')));
    }
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile, required this.email, required this.onEdit, required this.onShare, required this.onLogout});
  final UserProfile? profile;
  final String email;
  final VoidCallback onEdit;
  final VoidCallback? onShare;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = profile?.displayName?.trim().isNotEmpty == true ? profile!.displayName! : email;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 108),
      children: [
        PremiumCard(
          glowColor: AppColors.calmTeal,
          child: Column(children: [
            CircleAvatar(radius: 38, backgroundColor: AppColors.calmTeal.withValues(alpha: .2), child: const Icon(Icons.person_rounded, size: 38)),
            const SizedBox(height: AppSpacing.sm),
            Text(name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(email, style: theme.textTheme.bodySmall),
            if ((profile?.bio ?? '').trim().isNotEmpty) ...[const SizedBox(height: 12), Text(profile!.bio!, textAlign: TextAlign.center)],
            const SizedBox(height: 16),
            OutlinedButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit_rounded), label: const Text('Edit profile')),
          ]),
        ),
        const SizedBox(height: AppSpacing.md),
        PremiumCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Account details', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _DetailRow('Companion', profile?.maxieName ?? 'MAXie'),
          if (profile?.age != null) _DetailRow('Age', '${profile!.age}'),
          _DetailRow('Email', email),
        ])),
        const SizedBox(height: AppSpacing.md),
        PremiumCard(child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.ios_share_rounded),
          title: const Text('Share MAXie'),
          subtitle: Text(onShare == null ? 'Available when your Play Store link is configured.' : 'Copy your official MAXie app link.'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onShare,
        )),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(onPressed: onLogout, icon: const Icon(Icons.logout_rounded), label: const Text('Log out')),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      SizedBox(width: 96, child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
      Expanded(child: Text(value, textAlign: TextAlign.end)),
    ]),
  );
}

class _SignedOut extends StatelessWidget {
  const _SignedOut({required this.onSignIn});
  final VoidCallback onSignIn;
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.account_circle_rounded, size: 72),
      const SizedBox(height: 16),
      Text('Make MAXie yours', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      const Text('Sign in to securely sync your profile, memories and companion progress.', textAlign: TextAlign.center),
      const SizedBox(height: 20),
      FilledButton(onPressed: onSignIn, child: const Text('Sign in or create account')),
    ]),
  ));
}
