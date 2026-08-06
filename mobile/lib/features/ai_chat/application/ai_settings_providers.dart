import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/ai_chat/domain/models/ai_settings.dart';

final aiSettingsProvider = StateProvider<AiSettings>(
  (ref) => const AiSettings(),
);
