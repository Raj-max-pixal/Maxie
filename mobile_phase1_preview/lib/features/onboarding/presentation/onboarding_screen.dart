import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/config/app_constants.dart';
import 'package:maxie_mobile/navigation/app_routes.dart';
import 'package:maxie_mobile/shared/responsive_layout.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/primary_button.dart';
import 'package:maxie_mobile/widgets/secondary_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveLayout.of(context) == DeviceLayout.mobile
                  ? double.infinity
                  : 720,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.psychology_alt_rounded,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    AppConstants.appName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    AppConstants.appTagline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    label: 'Enter MAXie',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => context.go(AppRoutes.home),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SecondaryButton(
                    label: 'View plans',
                    icon: Icons.workspace_premium_rounded,
                    onPressed: () => context.go(AppRoutes.subscription),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
