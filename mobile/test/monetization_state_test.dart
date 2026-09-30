import 'package:flutter_test/flutter_test.dart';
import 'package:maxie_mobile/features/monetization/domain/models/monetization_state.dart';

void main() {
  group('MonetizationState', () {
    test('demo state explains how to enable live purchases', () {
      const state = MonetizationState.demo();

      expect(state.status, MonetizationStatus.demo);
      expect(state.isPremium, isFalse);
      expect(state.packageCount, 0);
      expect(state.message, contains('RevenueCat'));
    });

    test('active state can represent MAXie Plus entitlement', () {
      const state = MonetizationState(
        status: MonetizationStatus.active,
        message: 'MAXie Plus is active.',
        isPremium: true,
        offeringId: 'default',
        packageCount: 2,
      );

      expect(state.status, MonetizationStatus.active);
      expect(state.isPremium, isTrue);
      expect(state.offeringId, 'default');
      expect(state.packageCount, 2);
    });
  });
}
