import 'package:maxie_mobile/features/pet/domain/models/pet_state.dart';

abstract interface class PetRepository {
  Future<PetState> readPet();

  Future<void> savePet(PetState state);
}
