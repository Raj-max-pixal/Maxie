import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/navigation/app_router.dart';
import 'package:mobile/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MAXieApp(),
    ),
  );
}

class MAXieApp extends ConsumerWidget {
  const MAXieApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'MAXie',
      theme: ref.watch(lightThemeProvider),
      darkTheme: ref.watch(darkThemeProvider),
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
