import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SharedPrefsHelper {
  SharedPrefsHelper._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<String> getString(String key) async {
    return await _storage.read(key: key) ?? '';
  }

  static Future<void> setString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }
}