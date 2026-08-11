import 'package:maxie_mobile/config/app_constants.dart';
import 'package:maxie_mobile/config/storage_keys.dart';
import 'package:maxie_mobile/features/pet/domain/models/pet_state.dart';
import 'package:maxie_mobile/features/pet/domain/repositories/pet_repository.dart';
import 'package:maxie_mobile/services/storage/storage_service.dart';

class HivePetRepository implements PetRepository {
  const HivePetRepository(this._storage);

  final StorageService _storage;

  @override
  Future<PetState> readPet() async {
    final data = await _storage.read<Map<dynamic, dynamic>>(
      AppConstants.hivePetBox,
      StorageKeys.petState,
    );
    if (data == null) {
      return const PetState();
    }
    return PetState.fromJson(data);
  }

  @override
  Future<void> savePet(PetState state) {
    return _storage.write<Map<String, Object?>>(
      AppConstants.hivePetBox,
      StorageKeys.petState,
      state.toJson(),
    );
  }
}
