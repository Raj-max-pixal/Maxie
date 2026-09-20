// Development-only entry point. Production continues to use lib/main.dart.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/config/app_state.dart';
import 'package:maxie_mobile/features/agent_run/presentation/agent_run_screen.dart';
import 'package:maxie_mobile/features/ai_chat/presentation/ai_chat_screen.dart';
import 'package:maxie_mobile/features/auth/application/auth_providers.dart';
import 'package:maxie_mobile/features/home/presentation/home_screen.dart';
import 'package:maxie_mobile/features/focus/presentation/focus_screen.dart';
import 'package:maxie_mobile/features/memory/application/memory_manager.dart';
import 'package:maxie_mobile/features/memory/data/hive_memory_brain_repository.dart';
import 'package:maxie_mobile/features/memory/presentation/memory_screen.dart';
import 'package:maxie_mobile/features/mission_control/presentation/mission_control_screen.dart';
import 'package:maxie_mobile/features/onboarding/presentation/onboarding_screen.dart';
import 'package:maxie_mobile/features/pet/application/pet_providers.dart';
import 'package:maxie_mobile/features/pet/data/hive_pet_repository.dart';
import 'package:maxie_mobile/features/pet/presentation/pet_screen.dart';
import 'package:maxie_mobile/features/settings/presentation/settings_screen.dart';
import 'package:maxie_mobile/features/shimeji/presentation/shimeji_screen.dart';
import 'package:maxie_mobile/features/subscription/presentation/subscription_screen.dart';
import 'package:maxie_mobile/features/tasks/presentation/tasks_screen.dart';
import 'package:maxie_mobile/navigation/app_routes.dart';
import 'package:maxie_mobile/services/storage/hive_storage_service.dart';
import 'package:maxie_mobile/services/storage/storage_providers.dart';
import 'package:maxie_mobile/services/storage/storage_service.dart';
import 'package:maxie_mobile/theme/app_theme.dart';
import 'package:maxie_mobile/widgets/premium_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveStorageService.initialize();
  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(const _PreviewStorage()),
        petRepositoryProvider.overrideWith(
          (ref) => HivePetRepository(ref.watch(storageServiceProvider)),
        ),
        memoryBrainRepositoryProvider.overrideWith(
          (ref) => HiveMemoryBrainRepository(
            ref.watch(storageServiceProvider),
            scope: 'local-preview',
          ),
        ),
        currentUserProfileProvider.overrideWith((ref) => Stream.value(null)),
      ],
      child: const _MobilePreviewApp(),
    ),
  );
}

// Preview state persists separately from the signed-in application's boxes.
class _PreviewStorage implements StorageService {
  const _PreviewStorage();
  static const _local = HiveStorageService();
  String _box(String name) => 'preview_$name';
  @override
  Future<void> openBox(String boxName) => _local.openBox(_box(boxName));
  @override
  Future<T?> read<T>(String boxName, String key) =>
      _local.read<T>(_box(boxName), key);
  @override
  Future<void> write<T>(String boxName, String key, T value) =>
      _local.write<T>(_box(boxName), key, value);
  @override
  Future<void> delete(String boxName, String key) =>
      _local.delete(_box(boxName), key);
  @override
  Future<void> clear(String boxName) => _local.clear(_box(boxName));
}

final _previewRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(path: AppRoutes.splash, redirect: (_, _) => AppRoutes.home),
    GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen()),
    GoRoute(path: AppRoutes.focus, builder: (_, _) => const FocusScreen()),
    GoRoute(path: AppRoutes.aiChat, builder: (_, _) => const AiChatScreen()),
    GoRoute(path: AppRoutes.memory, builder: (_, _) => const MemoryScreen()),
    GoRoute(path: AppRoutes.pet, builder: (_, _) => const PetScreen()),
    GoRoute(path: AppRoutes.shimeji, builder: (_, _) => const ShimejiScreen()),
    GoRoute(path: AppRoutes.tasks, builder: (_, _) => const TasksScreen()),
    GoRoute(
      path: AppRoutes.settings,
      builder: (_, _) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (_, _) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.agentRun,
      builder: (_, _) => const AgentRunScreen(),
    ),
    GoRoute(
      path: AppRoutes.missionControl,
      builder: (_, _) => const MissionControlScreen(),
    ),
    GoRoute(
      path: AppRoutes.subscription,
      builder: (_, _) => const SubscriptionScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (_, _) => const _PreviewProfile(),
    ),
  ],
);

class _MobilePreviewApp extends ConsumerWidget {
  const _MobilePreviewApp();
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'MAXie Mobile · Local preview',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ref.watch(themeModeProvider),
    routerConfig: _previewRouter,
    builder: (context, child) => Column(
      children: [
        Material(
          color: const Color(0xFF25334A),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  'LOCAL PREVIEW · Cloud sign-in unavailable',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        Expanded(child: child ?? const SizedBox.shrink()),
      ],
    ),
  );
}

class _PreviewProfile extends StatelessWidget {
  const _PreviewProfile();
  @override
  Widget build(BuildContext context) => PremiumScaffold(
    title: 'Local preview',
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Icon(Icons.phone_android_rounded, size: 48),
        const SizedBox(height: 16),
        Text(
          'Explore MAXie Mobile',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        const Text(
          'Chat, Memory, Pet and Shimeji use the actual mobile screens. '
          'Preview data is saved separately in this browser. '
          'Cloud authentication is not configured in this build. '
          'Phone overlays and native purchases need an Android or iOS device.',
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => context.push(AppRoutes.settings),
          icon: const Icon(Icons.settings_rounded),
          label: const Text('Settings'),
        ),
      ],
    ),
  );
}
