import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maxie_mobile/config/app_constants.dart';
import 'package:maxie_mobile/features/monetization/domain/models/monetization_state.dart';
import 'package:maxie_mobile/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('MAXie sign-in screen renders', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: const MaterialApp(home: LoginScreen())),
    );
    await tester.pump();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  test('MAXie identity is stable for store and app surfaces', () {
    expect(AppConstants.appName, 'MAXie');
    expect(AppConstants.appTitle, 'MAXie - Your AI Companion');
  });

  test('RevenueCat demo state never represents an active entitlement', () {
    const state = MonetizationState.demo();

    expect(state.status, MonetizationStatus.demo);
    expect(state.isPremium, isFalse);
    expect(state.packageCount, 0);
  });
}
