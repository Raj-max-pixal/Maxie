import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';

class MemoryImportanceWeights {
  const MemoryImportanceWeights._();

  static int score(MemoryImportance importance) => importance.weight;
}
