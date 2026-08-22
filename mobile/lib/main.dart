import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:maxie_mobile/core/app.dart';
import 'package:maxie_mobile/core/app_bootstrap.dart';
import 'package:maxie_mobile/core/global_exception_handler.dart';
import 'package:maxie_mobile/features/floating_companion/presentation/shimeji_overlay.dart';

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ShimejiOverlay(),
    ),
  );
}

Future<void> main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = GlobalExceptionHandler.onFlutterError;
      await AppBootstrap.initialize();

      runApp(const ProviderScope(child: MaxieApp()));
    },
    GlobalExceptionHandler.onPlatformError,
  );
}
