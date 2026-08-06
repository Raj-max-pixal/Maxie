import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/ai_chat/data/hive_conversation_repository.dart';
import 'package:maxie_mobile/features/ai_chat/domain/repositories/conversation_repository.dart';
import 'package:maxie_mobile/services/storage/storage_providers.dart';

final conversationRepositoryProvider = Provider<ConversationRepository>(
  (ref) => HiveConversationRepository(ref.watch(storageServiceProvider)),
);
