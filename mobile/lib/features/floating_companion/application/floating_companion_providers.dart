import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/floating_companion/domain/models/floating_companion_state.dart';

final floatingCompanionStateProvider = StateProvider<FloatingCompanionState>(
  (ref) => const FloatingCompanionState(),
);
