import 'package:shared_preferences/shared_preferences.dart';
import 'cloud_sync_service.dart';

class StorageService {
  static Future<void> setString(
    String key,
    String value,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      key,
      value,
    );
    CloudSyncService.autoSyncOnDataChange();
  }

  static Future<String?> getString(
    String key,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(key);
  }

  static Future<void> setBool(
    String key,
    bool value,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      key,
      value,
    );
    CloudSyncService.autoSyncOnDataChange();
  }

  static Future<bool?> getBool(
    String key,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(key);
  }
}
