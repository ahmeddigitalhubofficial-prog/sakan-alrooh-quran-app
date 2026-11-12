import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cloud_sync_service.dart';
import '../services/prayer_service.dart';
import '../services/world_location_service.dart';

class SunanItem {
  final String key;
  final String prayerName;
  final String title;
  final int rakats;
  final bool isPre; // قبلية أم بعدية

  const SunanItem({
    required this.key,
    required this.prayerName,
    required this.title,
    required this.rakats,
    required this.isPre,
  });
}

/// إدارة السنن الرواتب الـ 12 ركعة وبناء قصر الجنة اليومي بتزامن لحظي
class SunanManager extends ChangeNotifier {
  static final SunanManager _instance = SunanManager._internal();
  factory SunanManager() => _instance;
  SunanManager._internal() {
    loadTodaySunan();
  }

  static const List<SunanItem> allSunan = [
    SunanItem(key: 'fajr_sunnah', prayerName: 'الفجر', title: 'سنة الفجر القبلية 🌅', rakats: 2, isPre: true),
    SunanItem(key: 'dhuhr_pre', prayerName: 'الظهر', title: 'سنة الظهر القبلية (4 ركعات) 🕌', rakats: 4, isPre: true),
    SunanItem(key: 'dhuhr_post', prayerName: 'الظهر', title: 'سنة الظهر البعدية (ركعتان) 🕌', rakats: 2, isPre: false),
    SunanItem(key: 'maghrib_post', prayerName: 'المغرب', title: 'سنة المغرب البعدية 🌇', rakats: 2, isPre: false),
    SunanItem(key: 'isha_post', prayerName: 'العشاء', title: 'سنة العشاء البعدية 🌌', rakats: 2, isPre: false),
  ];

  Map<String, bool> _sunanState = {
    'fajr_sunnah': false,
    'dhuhr_pre': false,
    'dhuhr_post': false,
    'maghrib_post': false,
    'isha_post': false,
  };

  Map<String, bool> get sunanState => _sunanState;

  int get totalCompletedRakats {
    int total = 0;
    for (var s in allSunan) {
      if (_sunanState[s.key] == true) {
        total += s.rakats;
      }
    }
    return total;
  }

  bool get isPalaceCompleted => totalCompletedRakats >= 12;

  double get progressPercentage => (totalCompletedRakats / 12.0).clamp(0.0, 1.0);

  bool isSunnahCompleted(String key) => _sunanState[key] ?? false;

  double? _cachedLat;
  double? _cachedLng;

  bool isSunnahTimeEntered(String key) {
    final lat = _cachedLat ?? 30.0444;
    final lng = _cachedLng ?? 31.2357;
    final coordinates = Coordinates(lat, lng);
    final now = DateTime.now();
    final prayerTimes = PrayerService.getPrayerTimes(coordinates, now);

    switch (key) {
      case 'fajr_sunnah':
        return now.isAfter(prayerTimes.fajr);
      case 'dhuhr_pre':
      case 'dhuhr_post':
        return now.isAfter(prayerTimes.dhuhr);
      case 'maghrib_post':
        return now.isAfter(prayerTimes.maghrib);
      case 'isha_post':
        return now.isAfter(prayerTimes.isha);
      default:
        return true;
    }
  }

  String _getTodayKey() => 'sunan_state_${DateFormat('yyyy-MM-dd').format(DateTime.now())}';

  Future<void> loadTodaySunan() async {
    final prefs = await SharedPreferences.getInstance();
    final coords = await WorldLocationService.getSavedCoordinates();
    _cachedLat = coords.latitude;
    _cachedLng = coords.longitude;
    final key = _getTodayKey();
    final jsonStr = prefs.getString(key);
    if (jsonStr != null) {
      try {
        final decoded = json.decode(jsonStr) as Map<String, dynamic>;
        _sunanState = {
          'fajr_sunnah': decoded['fajr_sunnah'] ?? false,
          'dhuhr_pre': decoded['dhuhr_pre'] ?? false,
          'dhuhr_post': decoded['dhuhr_post'] ?? false,
          'maghrib_post': decoded['maghrib_post'] ?? false,
          'isha_post': decoded['isha_post'] ?? false,
        };
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> toggleSunnah(String sunnahKey) async {
    _sunanState[sunnahKey] = !(_sunanState[sunnahKey] ?? false);
    await _saveState();
  }

  Future<void> setSunnah(String sunnahKey, bool value) async {
    _sunanState[sunnahKey] = value;
    await _saveState();
  }

  Future<void> _saveState() async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final key = _getTodayKey();
    await prefs.setString(key, json.encode(_sunanState));
    CloudSyncService.autoSyncOnDataChange();
  }
}
