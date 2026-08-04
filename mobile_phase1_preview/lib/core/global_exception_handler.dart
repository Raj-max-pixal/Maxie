import 'dart:developer';

import 'package:flutter/foundation.dart';

class GlobalExceptionHandler {
  const GlobalExceptionHandler._();

  static void onFlutterError(FlutterErrorDetails details) {
    FlutterError.presentError(details);
    log(
      details.exceptionAsString(),
      name: 'MAXieFlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
  }

  static void onPlatformError(Object error, StackTrace stackTrace) {
    log(
      error.toString(),
      name: 'MAXiePlatformError',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
