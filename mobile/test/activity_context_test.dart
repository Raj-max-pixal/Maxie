import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maxie_mobile/features/floating_companion/presentation/shimeji_overlay.dart';
import 'package:maxie_mobile/widgets/maxie_companion_view.dart';
import 'package:maxie_mobile/features/floating_companion/domain/activity_context.dart';

void main() {
  testWidgets('live media reaches the overlay and chat opens without overflow', (tester) async {
    const native = MethodChannel('x-slayer/overlay');
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(native, (call) async { calls.add(call); return true; });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(native, null));
    await tester.pumpWidget(const MaterialApp(home: SizedBox(width: 300, height: 400, child: ShimejiOverlay())));
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'x-slayer/overlay_messenger', const JSONMessageCodec().encodeMessage({
        'type': 'activity_context', 'category': 'music', 'app': 'Spotify',
        'title': 'Test Song', 'artist': 'Test Artist', 'playing': true,
      }), (_) {});
    await tester.pump();
    expect(find.text('Now playing: Test Song by Test Artist. Enjoy!'), findsOneWidget);
    await tester.tap(find.byType(MaxieCompanionView));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Ask MAXie'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Close chat'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(calls.where((c) => c.method == 'updateFlag').last.arguments['flag'], 'defaultFlag');
    await tester.pumpWidget(const SizedBox());
  });
  test('music reaction names only the actual metadata', () {
    final value = ActivityContext.fromMap({'category': 'music', 'app': 'Spotify', 'title': 'Test Song', 'artist': 'Test Artist', 'playing': true});
    expect(value.reaction, contains('Test Song by Test Artist'));
    expect(value.supported, isTrue);
  });
  test('video without a title does not invent a scene', () {
    const value = ActivityContext(category: 'video', app: 'Netflix');
    expect(value.reaction, 'Netflix is open. Ready for a watching break?');
  });
  test('unsupported app is excluded from AI context', () {
    const value = ActivityContext(category: 'app', app: 'Bank', title: 'Private');
    expect(value.supported, isFalse);
    expect(value.description, isNot(contains('Private')));
    expect(value.description, isNot(contains('Bank')));
  });
  test('media pause changes the context fingerprint', () {
    const playing = ActivityContext(category: 'music', playing: true);
    const paused = ActivityContext(category: 'music', playing: false);
    expect(playing.fingerprint, isNot(paused.fingerprint));
  });
}
