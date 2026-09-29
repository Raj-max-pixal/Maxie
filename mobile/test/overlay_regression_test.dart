import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maxie_mobile/features/everywhere_mode/application/everywhere_mode_providers.dart';
import 'package:maxie_mobile/features/floating_companion/presentation/shimeji_overlay.dart';
import 'package:maxie_mobile/widgets/maxie_companion_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final size in [
    const Size(120, 120),
    const Size(240, 254),
    const Size(180, 200),
  ]) {
    testWidgets('pet and welcome text fit overlay $size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: const ShimejiOverlay(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      final window = tester.getRect(find.byType(ShimejiOverlay));
      for (final finder in [
        find.byType(MaxieCompanionView),
        find.text('✨ MAXie is here floating with you!'),
      ]) {
        final rect = tester.getRect(finder);
        expect(rect.left, greaterThanOrEqualTo(window.left));
        expect(rect.top, greaterThanOrEqualTo(window.top));
        expect(rect.right, lessThanOrEqualTo(window.right));
        expect(rect.bottom, lessThanOrEqualTo(window.bottom));
      }
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets(
    'opening on a 3x screen converts dp to pixels without key focus',
    (tester) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      const channel = MethodChannel('x-slayer/overlay_channel');
      MethodCall? show;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        if (call.method == 'isOverlayActive') return false;
        if (call.method == 'checkPermission') return true;
        if (call.method == 'showOverlay') show = call;
        return false;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      await const EverywhereModeFoundation().prepareOverlay();
      expect(show?.arguments['width'], 720);
      expect(show?.arguments['height'], 762);
      expect(show?.arguments['flag'], 'defaultFlag');
    },
  );
}
