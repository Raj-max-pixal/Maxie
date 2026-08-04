import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/splash/splash_screen.dart';
import 'package:mobile/features/onboarding/onboarding_screen.dart';
import 'package:mobile/features/home/home_screen.dart';
import 'package:mobile/features/settings/settings_screen.dart';
import 'package:mobile/features/subscription/subscription_screen.dart';
import 'package:mobile/features/profile/profile_screen.dart';
import 'package:mobile/features/ai_chat/ai_chat_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/ai-chat',
        builder: (context, state) => const AiChatScreen(),
      ),
    ],
  );
});
