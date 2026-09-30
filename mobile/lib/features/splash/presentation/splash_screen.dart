import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/config/app_constants.dart';
import 'package:maxie_mobile/navigation/app_routes.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        context.go(AppRoutes.home);
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF071225),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // MAXie Official Logo Container
              Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF102B31),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFF84E4C5).withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF84E4C5).withValues(alpha: 0.2),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF84E4C5),
                    size: 52,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppConstants.appName,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppConstants.appTagline,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF98A5B8),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const LoadingIndicator(message: 'Initializing MAXie AI Companion...'),
            ],
          ),
        ),
      ),
    );
  }
}
