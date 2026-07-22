import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/chat/presentation/pages/chat_page.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/onboarding_provider.dart';

class MaxieApp extends ConsumerWidget {
  const MaxieApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCompletedOnboarding = ref.watch(onboardingProvider);

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
