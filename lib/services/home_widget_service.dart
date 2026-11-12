import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';

import 'prayer_service.dart';
import 'world_location_service.dart';

class HomeWidgetService {
  // Widget identifiers matching native configurations
  static const String androidWidgetName = 'NoorAlHodaWidgetProvider';
  static const String androidCompactWidgetName = 'NoorAlHodaCompactWidgetProvider';
  static const String iosWidgetName = 'NoorAlHodaWidget';

  static final List<Map<String, String>> dailyAyahs = [
    {
      'text': 'لَا تَخَفْ إِنَّنِي مَعَكُمَا أَسْمَعُ وَأَرَى',
      'surah': 'سورة طه - الآية ٤٦',
    },
    {
      'text': 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      'surah': 'سورة الرعد - الآية ٢٨',
    },
    {
      'text': 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
      'surah': 'سورة الشرح - الآية ٦',
    },
    {
      'text': 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
      'surah': 'سورة الطلاق - الآية ٣',
    },
  ];

  /// Comprehensive calculation and sync of prayer times directly from Flutter
  /// into the Home Screen Widget cache.
  static Future<void> updateAllPrayerWidgets() async {
    try {
      final coordinates = await WorldLocationService.getSavedCoordinates();
      final cityDisplayName = await WorldLocationService.getCurrentLocationDisplayName();

      final now = DateTime.now();
      final prayerTimes = PrayerService.getPrayerTimes(coordinates, now);
      final tomorrowPrayer = PrayerService.getPrayerTimes(
        coordinates,
        now.add(const Duration(days: 1)),
      );

      final timeFormatter = DateFormat('h:mm a', 'ar');

      // Save epoch timestamps for Android native auto-calculation
      await HomeWidget.saveWidgetData<String>('saved_city', cityDisplayName);
      await HomeWidget.saveWidgetData<int>('fajr_ms', prayerTimes.fajr.millisecondsSinceEpoch);
      await HomeWidget.saveWidgetData<String>('fajr_formatted', timeFormatter.format(prayerTimes.fajr));

      await HomeWidget.saveWidgetData<int>('dhuhr_ms', prayerTimes.dhuhr.millisecondsSinceEpoch);
      await HomeWidget.saveWidgetData<String>('dhuhr_formatted', timeFormatter.format(prayerTimes.dhuhr));

      await HomeWidget.saveWidgetData<int>('asr_ms', prayerTimes.asr.millisecondsSinceEpoch);
      await HomeWidget.saveWidgetData<String>('asr_formatted', timeFormatter.format(prayerTimes.asr));

      await HomeWidget.saveWidgetData<int>('maghrib_ms', prayerTimes.maghrib.millisecondsSinceEpoch);
      await HomeWidget.saveWidgetData<String>('maghrib_formatted', timeFormatter.format(prayerTimes.maghrib));

      await HomeWidget.saveWidgetData<int>('isha_ms', prayerTimes.isha.millisecondsSinceEpoch);
      await HomeWidget.saveWidgetData<String>('isha_formatted', timeFormatter.format(prayerTimes.isha));

      await HomeWidget.saveWidgetData<int>('tomorrow_fajr_ms', tomorrowPrayer.fajr.millisecondsSinceEpoch);
      await HomeWidget.saveWidgetData<String>('tomorrow_fajr_formatted', timeFormatter.format(tomorrowPrayer.fajr));

      Prayer nextPrayer = prayerTimes.nextPrayer();
      DateTime nextPrayerTime;
      String nextPrayerName;

      if (nextPrayer == Prayer.none || nextPrayer == Prayer.isha && now.isAfter(prayerTimes.isha)) {
        nextPrayer = Prayer.fajr;
        nextPrayerTime = tomorrowPrayer.fajr;
        nextPrayerName = 'الفجر (غداً)';
      } else if (nextPrayer == Prayer.sunrise) {
        // Next actual prayer is Dhuhr
        nextPrayer = Prayer.dhuhr;
        nextPrayerTime = prayerTimes.dhuhr;
        nextPrayerName = 'الظهر';
      } else {
        nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer) ?? tomorrowPrayer.fajr;
        nextPrayerName = _getPrayerNameArabic(nextPrayer);
      }

      final diff = nextPrayerTime.difference(now);
      final hoursLeft = diff.isNegative ? 0 : diff.inHours;
      final minutesLeft = diff.isNegative ? 0 : (diff.inMinutes % 60);

      await updatePrayerWidget(
        prayerName: nextPrayerName,
        prayerTime: timeFormatter.format(nextPrayerTime),
        hoursLeft: hoursLeft,
        minutesLeft: minutesLeft,
        cityName: cityDisplayName,
      );
    } catch (e) {
      debugPrint('Error in updateAllPrayerWidgets: $e');
    }
  }

  /// Updates the home screen widget cache with the latest prayer data.
  /// Also requests the OS to redraw the home screen widgets.
  static Future<void> updatePrayerWidget({
    required String prayerName,
    required String prayerTime,
    required int hoursLeft,
    required int minutesLeft,
    String? cityName,
  }) async {
    try {
      // 1. Save data to shared container (accessible by native extensions)
      await HomeWidget.saveWidgetData<String>('next_prayer_name', prayerName);
      await HomeWidget.saveWidgetData<String>('next_prayer_time', prayerTime);
      await HomeWidget.saveWidgetData<String>('countdown_hours', hoursLeft.toString().padLeft(2, '0'));
      await HomeWidget.saveWidgetData<String>('countdown_minutes', minutesLeft.toString().padLeft(2, '0'));
      if (cityName != null) {
        await HomeWidget.saveWidgetData<String>('saved_city', cityName);
      }

      // 2. Cache "Verse of the Day"
      final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
      final ayah = dailyAyahs[dayOfYear % dailyAyahs.length];
      await HomeWidget.saveWidgetData<String>('daily_ayah_text', ayah['text'] ?? '');
      await HomeWidget.saveWidgetData<String>('daily_ayah_surah', ayah['surah'] ?? '');

      // 3. Request Android OS widget reload for both full and compact widgets
      if (defaultTargetPlatform == TargetPlatform.android) {
        await HomeWidget.updateWidget(
          androidName: androidWidgetName,
        );
        await HomeWidget.updateWidget(
          androidName: androidCompactWidgetName,
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        // 4. Request iOS WidgetKit reload
        await HomeWidget.updateWidget(
          iOSName: iosWidgetName,
        );
      }
    } on PlatformException catch (e) {
      debugPrint('Platform exception updating HomeWidget: $e');
    } catch (e) {
      debugPrint('Error updating HomeWidget: $e');
    }
  }

  static String _getPrayerNameArabic(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.sunrise:
        return 'الشروق';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      default:
        return 'الصلاة القادمة';
    }
  }
}
