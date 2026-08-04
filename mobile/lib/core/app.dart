import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/config/app_constants.dart';
import 'package:maxie_mobile/config/app_state.dart';
import 'package:maxie_mobile/config/foundation_providers.dart';
import 'package:maxie_mobile/navigation/app_router.dart';
import 'package:maxie_mobile/theme/app_theme.dart';

class MaxieApp extends ConsumerWidget {
  const MaxieApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appFoundationProvider);

    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
