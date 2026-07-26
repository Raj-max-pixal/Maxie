import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/pets/presentation/screens/pet_shop_screen.dart';
import '../../features/pets/presentation/screens/pet_customize_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/productivity/presentation/screens/todo_screen.dart';
import '../../features/productivity/presentation/screens/notes_screen.dart';
import '../../features/productivity/presentation/screens/habits_screen.dart';
import '../../features/productivity/presentation/screens/pomodoro_screen.dart';
import '../../features/game/presentation/screens/achievements_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

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
            pageBuilder: (context, state) => NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/shop',
            pageBuilder: (context, state) => NoTransitionPage(
              child: PetShopScreen(),
            ),
          ),
          GoRoute(
            path: '/chat',
            pageBuilder: (context, state) => NoTransitionPage(
              child: ChatScreen(),
            ),
          ),
          GoRoute(
            path: '/todo',
            pageBuilder: (context, state) => NoTransitionPage(
              child: TodoScreen(),
            ),
          ),
          GoRoute(
            path: '/notes',
            pageBuilder: (context, state) => NoTransitionPage(
              child: NotesScreen(),
            ),
          ),
          GoRoute(
            path: '/habits',
            pageBuilder: (context, state) => NoTransitionPage(
              child: HabitsScreen(),
            ),
          ),
          GoRoute(
            path: '/pomodoro',
            pageBuilder: (context, state) => NoTransitionPage(
              child: PomodoroScreen(),
            ),
          ),
          GoRoute(
            path: '/achievements',
            pageBuilder: (context, state) => NoTransitionPage(
              child: AchievementsScreen(),
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
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => SettingsScreen(),
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
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _calculateSelectedIndex(context),
          onDestinationSelected: (index) => _onItemTapped(index, context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: theme.colorScheme.primaryContainer,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined),
              selectedIcon: Icon(Icons.shopping_bag_rounded),
              label: 'Shop',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.checklist_outlined),
              selectedIcon: Icon(Icons.checklist_rounded),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined),
              selectedIcon: Icon(Icons.emoji_events_rounded),
              label: 'Achieve',
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/shop')) return 1;
    if (location.startsWith('/chat')) return 2;
    if (location.startsWith('/todo') || location.startsWith('/notes') || 
        location.startsWith('/habits') || location.startsWith('/pomodoro')) return 3;
    if (location.startsWith('/achievements')) return 4;
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