import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final onboardingProvider = FutureProvider<bool>((ref) async {
  final box = await Hive.openBox('maxie_settings');
  return box.get('hasCompletedOnboarding', defaultValue: false);
});

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier();
});

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(false);

  Future<void> completeOnboarding() async {
    final box = await Hive.openBox('maxie_settings');
    await box.put('hasCompletedOnboarding', true);
    state = true;
  }

  Future<void> resetOnboarding() async {
    final box = await Hive.openBox('maxie_settings');
    await box.put('hasCompletedOnboarding', false);
    state = false;
  }
}
