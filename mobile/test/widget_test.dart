import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maxie_mobile/core/app.dart';

void main() {
  testWidgets('MAXie app starts at splash screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaxieApp()));

    expect(find.text('MAXie'), findsOneWidget);
    expect(find.text('Your AI Companion'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
