enum MonetizationStatus { demo, ready, active, unavailable, error }

class MonetizationState {
  const MonetizationState({
    required this.status,
    required this.message,
    this.isPremium = false,
    this.offeringId,
    this.packageCount = 0,
  });

  const MonetizationState.demo()
    : status = MonetizationStatus.demo,
      message =
          'RevenueCat is wired. Add the public SDK key to enable live purchases.',
      isPremium = false,
      offeringId = null,
      packageCount = 0;

  final MonetizationStatus status;
  final String message;
  final bool isPremium;
  final String? offeringId;
  final int packageCount;
}
