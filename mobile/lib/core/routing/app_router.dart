import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:maxie_mobile/features/chat/presentation/screens/voice_chat_screen.dart';
import 'package:maxie_mobile/features/cloud/presentation/screens/cloud_sync_screen.dart';
import 'package:maxie_mobile/features/dashboard/presentation/screens/calendar_screen.dart';
import 'package:maxie_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:maxie_mobile/features/gamification/presentation/screens/achievements_screen.dart';
import 'package:maxie_mobile/features/gamification/presentation/screens/daily_rewards_screen.dart';
import 'package:maxie_mobile/features/gamification/presentation/screens/profile_screen.dart';
import 'package:maxie_mobile/features/pc_companion/presentation/screens/pc_companion_screen.dart';
import 'package:maxie_mobile/features/pets/presentation/screens/pet_customize_screen.dart';
import 'package:maxie_mobile/features/pets/presentation/screens/pet_interaction_screen.dart';
import 'package:maxie_mobile/features/pets/presentation/screens/pet_shop_screen.dart';
import 'package:maxie_mobile/features/productivity/presentation/screens/goals_screen.dart';
import 'package:maxie_mobile/features/productivity/presentation/screens/habit_screen.dart';
import 'package:maxie_mobile/features/productivity/presentation/screens/notes_screen.dart';
import 'package:maxie_mobile/features/productivity/presentation/screens/pomodoro_screen.dart';
import 'package:maxie_mobile/features/productivity/presentation/screens/todo_screen.dart';
import 'package:maxie_mobile/features/settings/presentation/screens/accessibility_screen.dart';
import 'package:maxie_mobile/features/settings/presentation/screens/appearance_screen.dart';
import 'package:maxie_mobile/features/settings/presentation/screens/settings_screen.dart';
import 'package:maxie_mobile/features/settings/presentation/screens/voice_settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/shop',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PetShopScreen(),
            ),
          ),
          GoRoute(
            path: '/chat',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ChatScreen(),
            ),
          ),
          GoRoute(
            path: '/todo',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TodoScreen(),
            ),
          ),
          GoRoute(
            path: '/notes',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotesScreen(),
            ),
          ),
          GoRoute(
            path: '/habits',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HabitScreen(),
            ),
          ),
          GoRoute(
            path: '/pomodoro',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PomodoroScreen(),
            ),
          ),
          GoRoute(
            path: '/goals',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GoalsScreen(),
            ),
          ),
          GoRoute(
            path: '/achievements',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AchievementsScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/customize/:petId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => PetCustomizeScreen(
          petId: state.pathParameters['petId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/interact/:petId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => PetInteractionScreen(
          petId: state.pathParameters['petId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/voice-chat',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VoiceChatScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/appearance',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AppearanceScreen(),
      ),
      GoRoute(
        path: '/settings/voice',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VoiceSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/accessibility',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AccessibilityScreen(),
      ),
      GoRoute(
        path: '/cloud',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CloudSyncScreen(),
      ),
      GoRoute(
        path: '/pc-companion',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PCCompanionScreen(),
      ),
      GoRoute(
        path: '/calendar',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/daily-rewards',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DailyRewardsScreen(),
      ),
    ],
  );
});

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: bottomInset > 0 ? 0 : 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          child: NavigationBar(
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (index) => _onItemTapped(index, context),
            backgroundColor: Colors.transparent,
            elevation: 0,
            height: 68,
            indicatorColor: theme.colorScheme.primaryContainer,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: theme.colorScheme.onSurfaceVariant),
                selectedIcon: Icon(Icons.home_rounded, color: theme.colorScheme.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_bag_outlined, color: theme.colorScheme.onSurfaceVariant),
                selectedIcon: Icon(Icons.shopping_bag_rounded, color: theme.colorScheme.primary),
                label: 'Shop',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline, color: theme.colorScheme.onSurfaceVariant),
                selectedIcon: Icon(Icons.chat_bubble_rounded, color: theme.colorScheme.primary),
                label: 'Chat',
              ),
              NavigationDestination(
                icon: Icon(Icons.checklist_outlined, color: theme.colorScheme.onSurfaceVariant),
                selectedIcon: Icon(Icons.checklist_rounded, color: theme.colorScheme.primary),
                label: 'Tasks',
              ),
              NavigationDestination(
                icon: Icon(Icons.emoji_events_outlined, color: theme.colorScheme.onSurfaceVariant),
                selectedIcon: Icon(Icons.emoji_events_rounded, color: theme.colorScheme.primary),
                label: 'Achieve',
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/shop')) return 1;
    if (location.startsWith('/chat')) return 2;
    if (location.startsWith('/todo') || location.startsWith('/notes') || 
        location.startsWith('/habits') || location.startsWith('/pomodoro') ||
        location.startsWith('/goals')) {
      return 3;
    }
    if (location.startsWith('/achievements') || location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/');
      case 1: context.go('/shop');
      case 2: context.go('/chat');
      case 3: context.go('/todo');
      case 4: context.go('/achievements');
    }
  }
}