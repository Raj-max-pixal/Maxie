import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/features/ai_chat/presentation/ai_chat_screen.dart';
import 'package:maxie_mobile/features/home/presentation/home_screen.dart';
import 'package:maxie_mobile/features/memory/presentation/memory_screen.dart';
import 'package:maxie_mobile/features/onboarding/presentation/onboarding_screen.dart';
import 'package:maxie_mobile/features/pet/presentation/pet_screen.dart';
import 'package:maxie_mobile/features/profile/presentation/profile_screen.dart';
import 'package:maxie_mobile/features/settings/presentation/settings_screen.dart';
import 'package:maxie_mobile/features/splash/presentation/splash_screen.dart';
import 'package:maxie_mobile/features/subscription/presentation/subscription_screen.dart';
import 'package:maxie_mobile/navigation/app_routes.dart';

final rootNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
  (ref) => GlobalKey<NavigatorState>(),
);

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: ref.watch(rootNavigatorKeyProvider),
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.subscription,
        name: 'subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiChat,
        name: 'aiChat',
        builder: (context, state) => const AiChatScreen(),
      ),
      GoRoute(
        path: AppRoutes.memory,
        name: 'memory',
        builder: (context, state) => const MemoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.pet,
        name: 'pet',
        builder: (context, state) => const PetScreen(),
      ),
    ],
  );
});
