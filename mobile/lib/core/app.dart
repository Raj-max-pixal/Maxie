import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/core/providers/onboarding_provider.dart';
import 'package:maxie_mobile/core/theme/app_theme.dart';
import 'package:maxie_mobile/features/chat/presentation/pages/chat_page.dart';
import 'package:maxie_mobile/features/home/presentation/pages/home_page.dart';
import 'package:maxie_mobile/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:maxie_mobile/features/settings/presentation/pages/settings_page.dart';

class MaxieApp extends ConsumerWidget {
  const MaxieApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCompletedOnboarding = ref.watch(onboardingNotifierProvider);

    return MaterialApp(
      title: 'MAXie Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: hasCompletedOnboarding ? const HomePage() : const OnboardingPage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
        '/chat': (context) => const ChatPage(),
      },
    );
  }
}
