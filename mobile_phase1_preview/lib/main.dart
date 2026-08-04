import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/core/app.dart';
import 'package:maxie_mobile/core/app_bootstrap.dart';
import 'package:maxie_mobile/core/global_exception_handler.dart';

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
