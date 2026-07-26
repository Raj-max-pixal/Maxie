import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/settings/presentation/providers/theme_provider.dart';
import 'package:maxie_mobile/core/routing/app_router.dart';

class MaxieApp extends ConsumerWidget {
  const MaxieApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeStateProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'MAXie - Your AI Best Friend',
      debugShowCheckedModeBanner: false,
      theme: ref.watch(appThemeProvider),
      darkTheme: ref.watch(darkThemeProvider),
      themeMode: themeState.themeMode,
      routerConfig: router,
    );
  }
}
