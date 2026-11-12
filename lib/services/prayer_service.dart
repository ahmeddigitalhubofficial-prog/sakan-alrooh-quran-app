import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'world_location_service.dart';

class PrayerService {
  static String? _cachedMethod;

  static Future<void> loadCachedMethod() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedMethod = prefs.getString(WorldLocationService.keyMethod);
    } catch (_) {}
  }

  static PrayerTimes getPrayerTimes(
    Coordinates coordinates,
    DateTime date, {
    String? calculationMethod,
  }) {
    String method = calculationMethod ?? _cachedMethod ?? 'egyptian';
    
    // إذا لم تُحدد طريقة صراحة ولم تكن محفوظة، استنتج الطريقة تلقائياً من الإحداثيات
    if (calculationMethod == null && _cachedMethod == null) {
      final nearest = WorldLocationService.findNearestCity(coordinates.latitude, coordinates.longitude);
      if (nearest != null) {
        method = nearest.calculationMethod;
      }
    }

    final params = WorldLocationService.getCalculationParameters(method);

    return PrayerTimes(
      coordinates,
      DateComponents.from(date),
      params,
    );
  }
}
