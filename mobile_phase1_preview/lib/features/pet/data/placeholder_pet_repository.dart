import 'package:maxie_mobile/features/pet/domain/models/pet_state.dart';
import 'package:maxie_mobile/features/pet/domain/repositories/pet_repository.dart';

class PlaceholderPetRepository implements PetRepository {
  const PlaceholderPetRepository();

  @override
  Future<PetState> readPet() async {
    return const PetState();
  }

  @override
  Future<void> savePet(PetState state) async {}
}
