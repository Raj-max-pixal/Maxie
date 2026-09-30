import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maxie_mobile/features/auth/presentation/auth_widgets.dart';

void main() {
  test('auth errors are converted into user-facing messages', () {
    expect(
      authErrorMessage(FirebaseAuthException(code: 'email-already-in-use')),
      'An account already exists for this email.',
    );
    expect(
      authErrorMessage(FirebaseAuthException(code: 'invalid-email')),
      'Enter a valid email address.',
    );
  });
}
