import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maxie_mobile/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('MAXie sign-in screen renders', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
