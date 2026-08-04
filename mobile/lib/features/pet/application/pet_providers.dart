import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/pet/data/placeholder_pet_repository.dart';
import 'package:maxie_mobile/features/pet/domain/models/pet_state.dart';
import 'package:maxie_mobile/features/pet/domain/repositories/pet_repository.dart';

final petRepositoryProvider = Provider<PetRepository>(
  (ref) => const PlaceholderPetRepository(),
);

final petStateProvider = FutureProvider<PetState>((ref) {
  return ref.watch(petRepositoryProvider).readPet();
});
