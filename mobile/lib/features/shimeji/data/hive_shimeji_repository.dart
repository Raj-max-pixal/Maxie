import 'package:maxie_mobile/config/app_constants.dart';
import 'package:maxie_mobile/config/storage_keys.dart';
import 'package:maxie_mobile/features/shimeji/domain/models/shimeji_models.dart';
import 'package:maxie_mobile/features/shimeji/domain/repositories/shimeji_repository.dart';
import 'package:maxie_mobile/services/storage/storage_service.dart';

class HiveShimejiRepository implements ShimejiRepository {
  const HiveShimejiRepository(this._storage);

  final StorageService _storage;

  @override
  Future<ShimejiState> readState() async {
    final data = await _storage.read<Map<dynamic, dynamic>>(
      AppConstants.hivePetBox,
      StorageKeys.shimejiState,
    );
    if (data == null) {
      return ShimejiState.initial();
    }
    return ShimejiState.fromJson(data);
  }

  @override
  Future<void> saveState(ShimejiState state) {
    return _storage.write<Map<String, Object?>>(
      AppConstants.hivePetBox,
      StorageKeys.shimejiState,
      state.toJson(),
    );
  }
}
