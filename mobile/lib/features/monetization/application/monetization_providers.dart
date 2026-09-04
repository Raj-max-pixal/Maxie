import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/monetization/data/revenuecat_service.dart';
import 'package:maxie_mobile/features/monetization/domain/models/monetization_state.dart';

final revenueCatServiceProvider = Provider<RevenueCatService>(
  (ref) => RevenueCatService(),
);

final monetizationStateProvider = FutureProvider<MonetizationState>(
  (ref) => ref.watch(revenueCatServiceProvider).initialize(),
);
