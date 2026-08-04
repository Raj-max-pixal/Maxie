import 'package:maxie_mobile/services/storage/hive_storage_service.dart';

class AppBootstrap {
  const AppBootstrap._();

  static Future<void> initialize() async {
    await HiveStorageService.initialize();
  }
}
