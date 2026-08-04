import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SnackbarService {
  const SnackbarService();

  void showSuccess(BuildContext context, String message) {
    _show(context, message, Icons.check_circle_outline);
  }

  void showError(BuildContext context, String message) {
    _show(context, message, Icons.error_outline);
  }

  void showInfo(BuildContext context, String message) {
    _show(context, message, Icons.info_outline);
  }

  void _show(BuildContext context, String message, IconData icon) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onInverseSurface),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

final snackbarServiceProvider = Provider<SnackbarService>(
  (ref) => const SnackbarService(),
);
