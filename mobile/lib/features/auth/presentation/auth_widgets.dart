import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/navigation/app_routes.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';

String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-credential' ||
      'wrong-password' => 'The email or password is incorrect.',
      'email-already-in-use' => 'An account already exists for this email.',
      'invalid-email' => 'Enter a valid email address.',
      'weak-password' => 'Choose a stronger password.',
      'user-not-found' => 'No account was found for this email.',
      'too-many-requests' => 'Too many attempts. Try again later.',
      _ => error.message ?? 'Authentication failed. Try again.',
    };
  }
  return error.toString().replaceFirst('StateError: ', '');
}

class AuthFrame extends StatelessWidget {
  const AuthFrame({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    autofillHints: keyboardType == TextInputType.emailAddress
        ? const [AutofillHints.email]
        : null,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    validator: (value) {
      if (value == null || value.trim().isEmpty) return 'Enter $label';
      if (keyboardType == TextInputType.emailAddress && !value.contains('@'))
        return 'Enter a valid email';
      if (obscureText && value.length < 6) return 'Use at least 6 characters';
      return null;
    },
  );
}

class AuthLink extends StatelessWidget {
  const AuthLink({required this.label, required this.route, super.key});

  final String label;
  final String route;

  @override
  Widget build(BuildContext context) =>
      TextButton(onPressed: () => context.go(route), child: Text(label));
}

void goHome(BuildContext context) => context.go(AppRoutes.home);
