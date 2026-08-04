abstract interface class StorageService {
  Future<void> openBox(String boxName);

  Future<T?> read<T>(String boxName, String key);

  Future<void> write<T>(String boxName, String key, T value);

  Future<void> delete(String boxName, String key);

  Future<void> clear(String boxName);
}
