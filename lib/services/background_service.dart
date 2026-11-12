import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:adhan/adhan.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'notification_service.dart';
import 'prayer_service.dart';
import 'world_location_service.dart';
import 'home_widget_service.dart';
import '../models/theme_manager.dart';

Timer? _prayerTransitionTimer;



Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      autoStartOnBoot: false,
      isForegroundMode: false,
      notificationChannelId: NotificationService.ongoingChannelId,
      initialNotificationTitle: 'سكن الروح | Sakan Al-Rooh',
      initialNotificationContent: 'جاري حساب الوقت للصلاة القادمة...',
      foregroundServiceNotificationId:
          NotificationService.ongoingNotificationId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  requestPrayerCountdownUpdate();
}

void requestPrayerCountdownUpdate() {
  try {
    FlutterBackgroundService().invoke('update');
  } catch (e) {
    debugPrint('Error invoking background service update: $e');
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

int? _lastUpdatedMinute;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Initialize date symbol formatting in the background isolate
  try {
    await initializeDateFormatting('ar', null);
  } catch (e) {
    debugPrint('Error initializing date formatting in background: $e');
  }

  // Initialize the NotificationService for scheduled athan notifications
  final notificationService = NotificationService();
  try {
    await notificationService.init();
  } catch (e) {
    debugPrint('Error initializing notification service in background: $e');
  }

  // Run the update task immediately on start
  try {
    await _updatePrayerCountdown(service);
  } catch (e) {
    debugPrint('Error updating countdown in background startup: $e');
  }

  // Listen for manual update events from the UI
  service.on('update').listen((event) async {
    try {
      await _updatePrayerCountdown(service);
    } catch (e) {
      debugPrint('Error in background service on manual update: $e');
    }
  });

  // Periodic check running every 15 minutes (or on manual UI update / prayer transition)
  // The ongoing notification uses native Android Chronometer and HomeWidgets use Kotlin epoch calculation.
  Timer.periodic(const Duration(minutes: 15), (timer) async {
    try {
      await _updatePrayerCountdown(service);
    } catch (e) {
      debugPrint('Error in periodic countdown update: $e');
    }
  });
}


/// Updates the foreground notification using NotificationService (with native Chronometer)
/// and updates the HomeWidget on minute changes.
Future<void> _updatePrayerCountdown(ServiceInstance service) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final selectedCity = prefs.getString('saved_city') ?? 'القاهرة';

    // 1. Get GPS or manual coordinates stored in preferences
    final coordinates = await WorldLocationService.getSavedCoordinates();

    // 2. Fetch prayer times
    final now = DateTime.now();
    final todayDateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // Auto-reschedule 7-day notifications at midnight / new day
    final lastRescheduledDay = prefs.getString('last_auto_rescheduled_day');
    if (lastRescheduledDay != todayDateStr) {
      debugPrint('[BackgroundService] New day detected ($todayDateStr != $lastRescheduledDay). Rescheduling 7-day notifications...');
      await prefs.setString('last_auto_rescheduled_day', todayDateStr);
      try {
        final notificationService = NotificationService();
        await notificationService.schedulePrayerNotifications(force: true);
      } catch (e) {
        debugPrint('[BackgroundService] Error in midnight auto-reschedule: $e');
      }
    }

    final prayerTimes = PrayerService.getPrayerTimes(coordinates, now);

    // Live Dual-Engine Azan Trigger: Check all 5 prayers today
    final prayersToCheck = [
      {'id': 1000, 'name': 'الفجر', 'time': prayerTimes.fajr, 'sound': prefs.getString('fajr_sound') ?? 'fajr_athan'},
      {'id': 1001, 'name': 'الظهر', 'time': prayerTimes.dhuhr, 'sound': prefs.getString('regular_sound') ?? 'athan1'},
      {'id': 1002, 'name': 'العصر', 'time': prayerTimes.asr, 'sound': prefs.getString('regular_sound') ?? 'athan1'},
      {'id': 1003, 'name': 'المغرب', 'time': prayerTimes.maghrib, 'sound': prefs.getString('regular_sound') ?? 'athan1'},
      {'id': 1004, 'name': 'العشاء', 'time': prayerTimes.isha, 'sound': prefs.getString('regular_sound') ?? 'athan1'},
    ];

    for (final p in prayersToCheck) {
      final pTime = p['time'] as DateTime;
      final pId = p['id'] as int;
      final pName = p['name'] as String;
      final pSound = p['sound'] as String;

      final isEnabled = prefs.getBool('notify_prayer_$pId') ?? true;
      if (!isEnabled) continue;

      final diffFromPrayer = now.difference(pTime);
      final firedKey = 'azan_fired_${todayDateStr}_$pId';
      final alreadyFired = prefs.getBool(firedKey) ?? false;

      if (!alreadyFired && diffFromPrayer.inSeconds >= 0 && diffFromPrayer.inMinutes < 15) {
        debugPrint('[BackgroundService] Firing live Azan notification for $pName at $now (prayer time was $pTime)');
        await prefs.setBool(firedKey, true);
        try {
          final notificationService = NotificationService();
          await notificationService.showInstantAzanNotification(
            prayerId: pId,
            prayerName: pName,
            sound: pSound,
            cityName: selectedCity,
          );
        } catch (e) {
          debugPrint('[BackgroundService] Error firing instant azan for $pName: $e');
        }
      }
    }

    // Live Azkar & Kahf Triggers
    final dailyRemindersEnabled = prefs.getBool('daily_reminder') ?? true;
    if (dailyRemindersEnabled) {
      // Morning Azkar: 15 min after sunrise
      final morningTime = prayerTimes.sunrise.add(const Duration(minutes: 15));
      final diffMorning = now.difference(morningTime);
      final morningFiredKey = 'morning_azkar_fired_$todayDateStr';
      if (!(prefs.getBool(morningFiredKey) ?? false) &&
          diffMorning.inSeconds >= 0 &&
          diffMorning.inMinutes < 30 &&
          !_isTaskCompletedInPrefs(prefs, 'azkar_sabah')) {
        await prefs.setBool(morningFiredKey, true);
        try {
          await NotificationService().showInstantAzkarNotification(
            id: 2000,
            title: 'أذكار الصباح ☀️',
            body: 'ابتدئ يومك بذكر الله وطمأنينة قلبك، حان الآن وقت أذكار الصباح.',
            payload: 'azkar_sabah',
          );
        } catch (e) {
          debugPrint('[BackgroundService] Error firing instant morning azkar: $e');
        }
      }

      // Evening Azkar: 30 min before Maghrib
      final eveningTime = prayerTimes.maghrib.subtract(const Duration(minutes: 30));
      final diffEvening = now.difference(eveningTime);
      final eveningFiredKey = 'evening_azkar_fired_$todayDateStr';
      if (!(prefs.getBool(eveningFiredKey) ?? false) &&
          diffEvening.inSeconds >= 0 &&
          diffEvening.inMinutes < 30 &&
          !_isTaskCompletedInPrefs(prefs, 'azkar_masaa')) {
        await prefs.setBool(eveningFiredKey, true);
        try {
          await NotificationService().showInstantAzkarNotification(
            id: 3000,
            title: 'أذكار المساء 🌙',
            body: 'حصن نفسك وأهلك بذكر الله، حان الآن وقت أذكار المساء.',
            payload: 'azkar_masaa',
          );
        } catch (e) {
          debugPrint('[BackgroundService] Error firing instant evening azkar: $e');
        }
      }

      // Friday Kahf: Friday at 9:00 AM
      if (now.weekday == DateTime.friday) {
        final kahfTime = DateTime(now.year, now.month, now.day, 9, 0);
        final diffKahf = now.difference(kahfTime);
        final kahfFiredKey = 'kahf_fired_$todayDateStr';
        if (!(prefs.getBool(kahfFiredKey) ?? false) &&
            diffKahf.inSeconds >= 0 &&
            diffKahf.inMinutes < 60 &&
            !_isTaskCompletedInPrefs(prefs, 'friday_kahf')) {
          await prefs.setBool(kahfFiredKey, true);
          try {
            await NotificationService().showInstantAzkarNotification(
              id: 4000,
              title: 'سنن يوم الجمعة 📖',
              body: 'نور ما بين الجمعتين، لا تنسَ قراءة سورة الكهف اليوم والصلاة على النبي ﷺ.',
              payload: 'friday_kahf',
            );
          } catch (e) {
            debugPrint('[BackgroundService] Error firing instant Friday kahf: $e');
          }
        }
      }
    }

    Prayer nextPrayer = prayerTimes.nextPrayer();
    DateTime? nextPrayerTime;

    if (nextPrayer == Prayer.none) {
      // After Isha — next prayer is Fajr tomorrow
      final tomorrowPrayer = PrayerService.getPrayerTimes(
        coordinates,
        now.add(const Duration(days: 1)),
      );
      nextPrayer = Prayer.fajr;
      nextPrayerTime = tomorrowPrayer.fajr;
    } else {
      nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer);
    }

    if (nextPrayer == Prayer.sunrise) {
      nextPrayer = Prayer.dhuhr;
      nextPrayerTime = prayerTimes.dhuhr;
    }

    if (nextPrayerTime == null) return;

    // 3. Calculate remaining duration (auto-advance if passed)
    var difference = nextPrayerTime.difference(now);
    if (difference.isNegative) {
      final tomorrowPrayer = PrayerService.getPrayerTimes(
        coordinates,
        now.add(const Duration(days: 1)),
      );
      nextPrayer = Prayer.fajr;
      nextPrayerTime = tomorrowPrayer.fajr;
      difference = nextPrayerTime.difference(now);
    }

    // Zero-latency exact transition timer: fires precisely when countdown hits 0
    _prayerTransitionTimer?.cancel();
    if (difference.inMilliseconds > 0 && difference.inMinutes <= 30) {
      _prayerTransitionTimer = Timer(difference, () async {
        try {
          await _updatePrayerCountdown(service);
        } catch (e) {
          debugPrint('Error in exact prayer transition timer: $e');
        }
      });
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    // Arabic name of the next prayer
    final prayerName = _getPrayerName(nextPrayer);

    // Format notification content
    final timeFmt = DateFormat('h:mm a', 'ar');
    final formattedTime = timeFmt.format(nextPrayerTime);
    final title = 'الصلاة القادمة: $prayerName ($formattedTime)';

    final fajrStr = timeFmt.format(prayerTimes.fajr);
    final dhuhrStr = timeFmt.format(prayerTimes.dhuhr);
    final asrStr = timeFmt.format(prayerTimes.asr);
    final maghribStr = timeFmt.format(prayerTimes.maghrib);
    final ishaStr = timeFmt.format(prayerTimes.isha);
    final notificationBody = 'الفجر $fajrStr • الظهر $dhuhrStr • العصر $asrStr • المغرب $maghribStr • العشاء $ishaStr';

    // Retrieve active theme color for notification tint
    final themeId = prefs.getString('selected_app_theme') ?? 'emerald';
    final matchedTheme = AppThemeManager.themes.firstWhere(
      (t) => t.id == themeId,
      orElse: () => AppThemeManager.themes.first,
    );
    final themeColor = matchedTheme.primaryColor;

    // 4. Update ongoing notification with native Chronometer & action chips
    try {
      final notificationService = NotificationService();
      await notificationService.updateOngoingNotification(
        title: title,
        body: notificationBody,
        color: themeColor,
        whenMs: nextPrayerTime.millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Error updating ongoing notification via plugin: $e');
      // Fallback to default setForegroundNotificationInfo
      if (service is AndroidServiceInstance) {
        await service.setForegroundNotificationInfo(
          title: title,
          content: notificationBody,
        );
      }
    }

    // 5. Also broadcast the prayer data to UI if anyone is listening
    service.invoke('prayer_update', {
      'prayerName': prayerName,
      'prayerTime': formattedTime,
      'hoursLeft': hours,
      'minutesLeft': minutes,
      'secondsLeft': seconds,
    });

    // 6. Push data update to Home Screen Smart Widgets (only update once a minute to save battery/API quota)
    final currentMinute = now.minute;
    if (_lastUpdatedMinute != currentMinute) {
      _lastUpdatedMinute = currentMinute;
      try {
        await HomeWidgetService.updatePrayerWidget(
          prayerName: prayerName,
          prayerTime: formattedTime,
          hoursLeft: hours,
          minutesLeft: minutes,
          cityName: selectedCity,
        );
      } catch (e) {
        debugPrint('Error updating HomeWidget from background task: $e');
      }
    }
  } catch (e) {
    debugPrint('Error in _updatePrayerCountdown: $e');
  }
}


String _getPrayerName(Prayer prayer) {
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

bool _isTaskCompletedInPrefs(SharedPreferences prefs, String taskId) {
  try {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final tasksJson = prefs.getString('islamic_tasks_$todayStr');
    if (tasksJson != null) {
      final List<dynamic> list = jsonDecode(tasksJson);
      for (var item in list) {
        if (item['id'] == taskId && item['isCompleted'] == true) {
          return true;
        }
      }
    }
  } catch (_) {}
  return false;
}

