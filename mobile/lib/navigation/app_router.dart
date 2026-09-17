import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/features/auth/application/auth_providers.dart';
import 'package:maxie_mobile/features/auth/presentation/forgot_password_screen.dart';
import 'package:maxie_mobile/features/auth/presentation/login_screen.dart';
import 'package:maxie_mobile/features/auth/presentation/signup_screen.dart';
import 'package:maxie_mobile/features/ai_chat/presentation/ai_chat_screen.dart';
import 'package:maxie_mobile/features/home/presentation/home_screen.dart';
import 'package:maxie_mobile/features/memory/presentation/memory_screen.dart';
import 'package:maxie_mobile/features/mission_control/presentation/mission_control_screen.dart';
import 'package:maxie_mobile/features/onboarding/presentation/onboarding_screen.dart';
import 'package:maxie_mobile/features/pet/presentation/pet_screen.dart';
import 'package:maxie_mobile/features/profile/presentation/profile_screen.dart';
import 'package:maxie_mobile/features/settings/presentation/settings_screen.dart';
import 'package:maxie_mobile/features/shimeji/presentation/shimeji_screen.dart';
import 'package:maxie_mobile/features/splash/presentation/splash_screen.dart';
import 'package:maxie_mobile/features/subscription/presentation/subscription_screen.dart';
import 'package:maxie_mobile/features/tasks/presentation/tasks_screen.dart';
import 'package:maxie_mobile/navigation/app_routes.dart';

final rootNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
  (ref) => GlobalKey<NavigatorState>(),
);

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authServiceProvider);
  return GoRouter(
    navigatorKey: ref.watch(rootNavigatorKeyProvider),
    initialLocation: AppRoutes.splash,
    refreshListenable: auth,
    redirect: (context, state) async {
      if (!auth.isReady) return state.matchedLocation == AppRoutes.splash ? null : AppRoutes.splash;

      final publicRoutes = {
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.signup,
        AppRoutes.forgotPassword,
      };
      final isPublic = publicRoutes.contains(state.matchedLocation);
      if (auth.user == null) return isPublic ? null : AppRoutes.login;

      final user = auth.user!;
      await ref.read(userProfileRepositoryProvider).ensureProfile(user);
      if (isPublic) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
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
      GoRoute(
        path: AppRoutes.shimeji,
        name: 'shimeji',
        builder: (context, state) => const ShimejiScreen(),
      ),
      GoRoute(
        path: AppRoutes.tasks,
        name: 'tasks',
        builder: (context, state) => const TasksScreen(),
      ),
      GoRoute(
        path: AppRoutes.missionControl,
        name: 'missionControl',
        builder: (context, state) => const MissionControlScreen(),
      ),
    ],
  );
});
