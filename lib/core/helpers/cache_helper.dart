import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveData({
    required String key,
    required dynamic value,
  }) async {
    if (value is String) {
      await _prefs.setString(
        key,
        value,
      );
    }

    if (value is bool) {
      await _prefs.setBool(
        key,
        value,
      );
    }

    if (value is int) {
      await _prefs.setInt(
        key,
        value,
      );
    }

    if (value is double) {
      await _prefs.setDouble(
        key,
        value,
      );
    }
  }

  static dynamic getData(
    String key,
  ) {
    return _prefs.get(key);
  }

  static Future<void> removeData(
    String key,
  ) async {
    await _prefs.remove(key);
  }

  static Future<void> clearData() async {
    await _prefs.clear();
  }
}
