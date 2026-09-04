import 'package:maxie_mobile/features/shimeji/domain/models/shimeji_models.dart';

abstract interface class ShimejiRepository {
  Future<ShimejiState> readState();

  Future<void> saveState(ShimejiState state);
}
