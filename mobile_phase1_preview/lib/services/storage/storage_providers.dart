import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/services/storage/hive_storage_service.dart';
import 'package:maxie_mobile/services/storage/storage_service.dart';

final storageServiceProvider = Provider<StorageService>(
  (ref) => const HiveStorageService(),
);
