import 'package:hive_flutter/hive_flutter.dart';
import 'package:maxie_mobile/config/app_constants.dart';
import 'package:maxie_mobile/services/storage/storage_service.dart';

class HiveStorageService implements StorageService {
  const HiveStorageService();

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<Object?>(AppConstants.hiveSettingsBox),
      Hive.openBox<Object?>(AppConstants.hiveMemoryBox),
      Hive.openBox<Object?>(AppConstants.hiveCompanionBox),
      Hive.openBox<Object?>(AppConstants.hivePetBox),
    ]);
  }

  @override
  Future<void> openBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Object?>(boxName);
    }
  }

  @override
  Future<T?> read<T>(String boxName, String key) async {
    await openBox(boxName);
    return Hive.box<Object?>(boxName).get(key) as T?;
  }

  @override
  Future<void> write<T>(String boxName, String key, T value) async {
    await openBox(boxName);
    await Hive.box<Object?>(boxName).put(key, value);
  }

  @override
  Future<void> delete(String boxName, String key) async {
    await openBox(boxName);
    await Hive.box<Object?>(boxName).delete(key);
  }

  @override
  Future<void> clear(String boxName) async {
    await openBox(boxName);
    await Hive.box<Object?>(boxName).clear();
  }
}
