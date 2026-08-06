import 'package:maxie_mobile/features/memory/domain/models/memory_brain_models.dart';

class MemoryPriorityWeights {
  const MemoryPriorityWeights._();

  static int score(MemoryPriority priority) => priority.weight;
}
