import 'package:flutter/foundation.dart';
import 'package:maxie_mobile/features/monetization/domain/models/monetization_state.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

class RevenueCatService {
  RevenueCatService();

  static const String _androidApiKey = String.fromEnvironment(
    'REVENUECAT_ANDROID_API_KEY',
  );
  static const String _iosApiKey = String.fromEnvironment(
    'REVENUECAT_IOS_API_KEY',
  );
  static const String _premiumEntitlement = String.fromEnvironment(
    'REVENUECAT_PREMIUM_ENTITLEMENT',
    defaultValue: 'maxie_plus',
  );

  bool _configured = false;

  bool get isConfigured => _configured;

  Future<MonetizationState> initialize() async {
    final key = _platformKey;
    if (key.isEmpty) {
      return const MonetizationState.demo();
    }

    try {
      await rc.Purchases.setLogLevel(
        kReleaseMode ? rc.LogLevel.info : rc.LogLevel.debug,
      );
      await rc.Purchases.configure(rc.PurchasesConfiguration(key));
      _configured = true;
      return customerState();
    } catch (error) {
      return MonetizationState(
        status: MonetizationStatus.error,
        message: 'RevenueCat setup needs attention: $error',
      );
    }
  }

  Future<MonetizationState> customerState() async {
    if (!_configured) {
      return const MonetizationState.demo();
    }

    try {
      final customerInfo = await rc.Purchases.getCustomerInfo();
      final offerings = await rc.Purchases.getOfferings();
      final current = offerings.current;
      final isPremium = customerInfo.entitlements.active.containsKey(
        _premiumEntitlement,
      );

      return MonetizationState(
        status: isPremium
            ? MonetizationStatus.active
            : MonetizationStatus.ready,
        message: isPremium
            ? 'MAXie Plus is active.'
            : current == null
            ? 'RevenueCat is active. Add a MAXie Plus offering in the dashboard.'
            : 'MAXie Plus is ready for purchase.',
        isPremium: isPremium,
        offeringId: current?.identifier,
        packageCount: current?.availablePackages.length ?? 0,
      );
    } catch (error) {
      return MonetizationState(
        status: MonetizationStatus.error,
        message: 'Could not read RevenueCat products: $error',
      );
    }
  }

  Future<MonetizationState> purchaseMaxiePlus() async {
    if (!_configured) {
      return const MonetizationState.demo();
    }

    try {
      final offerings = await rc.Purchases.getOfferings();
      final packages = offerings.current?.availablePackages ?? [];
      final package = packages.isEmpty ? null : packages.first;
      if (package == null) {
        return const MonetizationState(
          status: MonetizationStatus.unavailable,
          message: 'No RevenueCat package is available yet.',
        );
      }

      final result = await rc.Purchases.purchase(
        rc.PurchaseParams.package(package),
      );
      final customerInfo = result.customerInfo;
      final isPremium = customerInfo.entitlements.active.containsKey(
        _premiumEntitlement,
      );
      return MonetizationState(
        status: isPremium
            ? MonetizationStatus.active
            : MonetizationStatus.ready,
        message: isPremium ? 'MAXie Plus unlocked.' : 'Purchase finished.',
        isPremium: isPremium,
        offeringId: offerings.current?.identifier,
        packageCount: offerings.current?.availablePackages.length ?? 0,
      );
    } catch (error) {
      return MonetizationState(
        status: MonetizationStatus.error,
        message: 'Purchase could not be completed: $error',
      );
    }
  }

  Future<MonetizationState> restorePurchases() async {
    if (!_configured) {
      return const MonetizationState.demo();
    }

    try {
      final customerInfo = await rc.Purchases.restorePurchases();
      final isPremium = customerInfo.entitlements.active.containsKey(
        _premiumEntitlement,
      );
      return MonetizationState(
        status: isPremium
            ? MonetizationStatus.active
            : MonetizationStatus.ready,
        message: isPremium ? 'MAXie Plus restored.' : 'No active plan found.',
        isPremium: isPremium,
      );
    } catch (error) {
      return MonetizationState(
        status: MonetizationStatus.error,
        message: 'Restore failed: $error',
      );
    }
  }

  String get _platformKey {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidApiKey;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _iosApiKey;
    }
    return '';
  }
}
