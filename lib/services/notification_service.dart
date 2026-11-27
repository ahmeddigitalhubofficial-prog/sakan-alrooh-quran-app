import 'dart:convert';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

import 'prayer_service.dart';
import 'world_location_service.dart';
import '../models/task_manager.dart';
import '../screens/ward_tracker_screen.dart';
import '../screens/quran_index_screen.dart';
import '../screens/azkar_screen.dart';
import '../screens/tasbih_screen.dart';
import '../screens/surah_detail_screen.dart';
import '../screens/spiritual_moods_screen.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  final actionId = notificationResponse.actionId;
  if (actionId != null && actionId.startsWith('action_prayed_')) {
    final prayerId = actionId.replaceFirst('action_prayed_', '');
    await SpiritualTaskManager.recordPrayerInBackground(prayerId);
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static String? pendingPayload;
  static String? get pendingPrayerNotification => pendingPayload;
  static set pendingPrayerNotification(String? val) => pendingPayload = val;

  /// التوجيه التلقائي المباشر للشاشة المعنية بالإشعار عند النقر عليه
  static void handleNotificationPayload(String payload, [BuildContext? context]) {
    Widget? targetScreen;

    if (payload.startsWith('prayer_')) {
      final prayerId = payload.substring('prayer_'.length);
      targetScreen = WardTrackerScreen(promptPrayerId: prayerId);
    } else if (payload == 'azkar_sabah' || payload == 'morning') {
      targetScreen = const AzkarCategoryScreen(
        category: 'morning',
        categoryTitle: 'أذكار الصباح',
      );
    } else if (payload == 'azkar_masaa' || payload == 'evening') {
      targetScreen = const AzkarCategoryScreen(
        category: 'evening',
        categoryTitle: 'أذكار المساء',
      );
    } else if (payload == 'friday_kahf' || payload == 'kahf') {
      targetScreen = const SurahDetailScreen(
        surahNumber: 18,
        surahName: 'الكهف',
      );
    } else if (payload == 'tasbih') {
      targetScreen = const TasbihScreen();
    } else if (payload == 'quran') {
      targetScreen = const QuranIndexScreen();
    } else if (payload == 'azkar') {
      targetScreen = const AzkarScreen();
    } else if (payload == 'daily_reflection') {
      targetScreen = const SpiritualMoodsScreen();
    }

    if (targetScreen != null) {
      final route = MaterialPageRoute(builder: (_) => targetScreen!);
      if (context != null) {
        Navigator.push(context, route);
      } else {
        navigatorKey.currentState?.push(route);
      }
    }
  }

  static void checkPendingNotification([BuildContext? context]) {
    final payload = pendingPayload;
    if (payload == null) return;
    pendingPayload = null;
    handleNotificationPayload(payload, context);
  }


  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;

  static const String _notifKey = 'notifications_activated';

  Future<void> init() async {
    tzdata.initializeTimeZones();
    _configureLocalTimeZone();

    final prefs = await SharedPreferences.getInstance();

    _isEnabled = prefs.getBool(
          _notifKey,
        ) ??
        true;

    // Android Settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS Settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // General Settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize Notifications
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (
        NotificationResponse details,
      ) async {
        if (details.actionId != null && details.actionId!.startsWith('action_prayed_')) {
          final prayerId = details.actionId!.replaceFirst('action_prayed_', '');
          await SpiritualTaskManager.recordPrayerInBackground(prayerId);
          return;
        } else if (details.actionId == 'action_quran') {
          NotificationService.navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const QuranIndexScreen()),
          );
          return;
        } else if (details.actionId == 'action_azkar') {
          NotificationService.navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const AzkarScreen()),
          );
          return;
        } else if (details.actionId == 'action_tasbih') {
          NotificationService.navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const TasbihScreen()),
          );
          return;
        }

        final payload = details.payload;
        if (payload != null && payload.isNotEmpty) {
          handleNotificationPayload(payload);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Check if the app was launched by clicking a notification (Terminated startup)
    final NotificationAppLaunchDetails? launchDetails =
        await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      final payload = launchDetails.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        pendingPayload = payload;
      }
    }



    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      try {
        await androidImplementation.requestExactAlarmsPermission();
      } catch (_) {}
      try {
        await androidImplementation.requestNotificationsPermission();
      } catch (_) {}

      try {
        // 1. Ongoing countdown channel
        const AndroidNotificationChannel ongoingChannel = AndroidNotificationChannel(
          ongoingChannelId,
          'الإشعار المستمر لمواقيت الصلاة',
          description: 'يعرض الوقت المتبقي للصلاة القادمة ويحدث كل دقيقة',
          importance: Importance.low,
          playSound: false,
          enableVibration: false,
          showBadge: false,
        );
        await androidImplementation.createNotificationChannel(ongoingChannel);

        // 2. High priority Adhan channels with audio
        final athanSounds = ['athan', 'azan', 'athan_makkah', 'athan_medina', 'athan_abdulbasit', 'athan_aqsa'];
        for (final s in athanSounds) {
          final athanChannel = AndroidNotificationChannel(
            'prayer_channel_sound_${s}_v2',
            'تنبيهات الصلاة بالصوت ($s)',
            description: 'قناة إشعارات مواقيت الصلاة والأذان المسموع',
            importance: Importance.max,
            playSound: true,
            sound: RawResourceAndroidNotificationSound(s),
            enableVibration: true,
            showBadge: true,
            audioAttributesUsage: AudioAttributesUsage.alarm,
          );
          await androidImplementation.createNotificationChannel(athanChannel);
        }

        // 3. Default prayer channel
        const defaultChannel = AndroidNotificationChannel(
          'prayer_channel_default',
          'تنبيهات الصلاة بدون صوت إضافي',
          description: 'قناة إشعارات مواقيت الصلاة الافتراضية',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        );
        await androidImplementation.createNotificationChannel(defaultChannel);
      } catch (_) {}
    }
  }

  void _configureLocalTimeZone() {
    try {
      final now = DateTime.now();
      final deviceOffset = now.timeZoneOffset;
      final timeZoneName = now.timeZoneName;

      tz.Location? localLocation;

      // 1. Direct match by device timezone name
      if (tz.timeZoneDatabase.locations.containsKey(timeZoneName)) {
        localLocation = tz.getLocation(timeZoneName);
      }

      // 2. City-based mappings for key regions
      if (localLocation == null) {
        final Map<String, String> commonCityTz = {
          'القاهرة': 'Africa/Cairo',
          'الإسكندرية': 'Africa/Cairo',
          'الجيزة': 'Africa/Cairo',
          'بورسعيد': 'Africa/Cairo',
          'السويس': 'Africa/Cairo',
          'أسوان': 'Africa/Cairo',
          'الأقصر': 'Africa/Cairo',
          'المنصورة': 'Africa/Cairo',
          'مكة المكرمة': 'Asia/Riyadh',
          'المدينة المنورة': 'Asia/Riyadh',
          'الرياض': 'Asia/Riyadh',
          'جدة': 'Asia/Riyadh',
          'دبي': 'Asia/Dubai',
          'أبوظبي': 'Asia/Dubai',
          'القدس': 'Asia/Jerusalem',
          'عمان': 'Asia/Amman',
          'دمشق': 'Asia/Damascus',
          'بغداد': 'Asia/Baghdad',
          'الكويت': 'Asia/Kuwait',
          'الدوحة': 'Asia/Qatar',
          'المنامة': 'Asia/Bahrain',
          'مسقط': 'Asia/Muscat',
          'صنعاء': 'Asia/Aden',
          'بيروت': 'Asia/Beirut',
          'طرابلس': 'Africa/Tripoli',
          'تونس': 'Africa/Tunis',
          'الجزائر': 'Africa/Algiers',
          'الرباط': 'Africa/Casablanca',
          'الخرطوم': 'Africa/Khartoum',
        };
        for (final entry in commonCityTz.entries) {
          final loc = tz.timeZoneDatabase.locations[entry.value];
          if (loc != null && loc.currentTimeZone.offset == deviceOffset) {
            localLocation = loc;
            break;
          }
        }
      }

      // 3. Fallback: match any location in database with exact current UTC offset
      if (localLocation == null) {
        for (final loc in tz.timeZoneDatabase.locations.values) {
          if (loc.currentTimeZone.offset == deviceOffset) {
            localLocation = loc;
            break;
          }
        }
      }

      if (localLocation != null) {
        tz.setLocalLocation(localLocation);
      }
    } catch (e) {
      debugPrint('Error configuring local timezone: $e');
    }
  }

  Future<void> toggleNotifications(
    bool enable,
  ) async {
    _isEnabled = enable;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      _notifKey,
      enable,
    );

    if (!enable) {
      await cancelAllNotifications();
    }
  }

  Future<void> showNotification(
    String title,
    String body, {
    String? sound,
  }) async {
    if (!_isEnabled) return;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'noor_al_hoda_alerts',
      'تنبيهات نور الهدى',
      channelDescription: 'قناة تنبيهات الأذكار ومواقيت الصلاة',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      playSound: true,
      sound: sound != null
          ? RawResourceAndroidNotificationSound(
              sound,
            )
          : null,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(
            100000,
          ),
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    String? sound,
    String? payload,
    List<AndroidNotificationAction>? actions,
  }) async {

    if (!_isEnabled) return;

    final scheduledTime = time;
    if (scheduledTime.isBefore(DateTime.now())) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      sound != null ? 'prayer_channel_sound_${sound}_v2' : 'prayer_channel_default',
      sound != null ? 'تنبيهات الصلاة بالصوت' : 'تنبيهات الصلاة بدون صوت',
      channelDescription: 'قناة إشعارات مواقيت الصلاة والأذان',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      playSound: true,
      sound: sound != null
          ? RawResourceAndroidNotificationSound(sound)
          : null,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      visibility: NotificationVisibility.public,
      actions: actions,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      sound: sound != null ? '$sound.caf' : null,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(
          scheduledTime,
          tz.local,
        ),
        notificationDetails: NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        payload: payload,
      );
    } catch (_) {
      try {
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tz.TZDateTime.from(
            scheduledTime,
            tz.local,
          ),
          notificationDetails: NotificationDetails(
            android: androidDetails,
            iOS: iosDetails,
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload,
        );
      } catch (_) {
        try {
          await _notificationsPlugin.zonedSchedule(
            id: id,
            title: title,
            body: body,
            scheduledDate: tz.TZDateTime.from(
              scheduledTime,
              tz.local,
            ),
            notificationDetails: NotificationDetails(
              android: androidDetails,
              iOS: iosDetails,
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: payload,
          );
        } catch (_) {}
      }
    }
  }

  /// إطلاق إشعار وصوت الأذان فوراً وبأعلى أولوية من الخدمة الخلفية الحية
  Future<void> showInstantAzanNotification({
    required dynamic prayerId,
    required String prayerName,
    required String sound,
    String? cityName,
  }) async {
    if (!_isEnabled) return;
    final selectedCity = cityName ?? 'القاهرة';

    final androidDetails = AndroidNotificationDetails(
      'prayer_channel_sound_${sound}_v2',
      'تنبيهات الصلاة بالصوت',
      channelDescription: 'قناة إشعارات مواقيت الصلاة والأذان المسموع',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      playSound: true,
      sound: RawResourceAndroidNotificationSound(sound),
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      visibility: NotificationVisibility.public,
      actions: [
        AndroidNotificationAction(
          'action_prayed_$prayerId',
          '✅ صلّيت (تسجيل الصلاة)',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      sound: '$sound.caf',
    );

    final notifId = prayerId is int ? prayerId : 9000;

    await _notificationsPlugin.show(
      id: notifId,
      title: 'حان الآن موعد صلاة $prayerName 🕌',
      body: 'الله أكبر، الله أكبر. حان الآن موعد أذان صلاة $prayerName بتوقيت $selectedCity.',
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: 'prayer_$prayerId',
    );
  }

  /// إطلاق إشعار الأذكار وسنن الجمعة فورياً
  Future<void> showInstantAzkarNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isEnabled) return;

    final androidDetails = AndroidNotificationDetails(
      'noor_al_hoda_alerts',
      'تنبيهات نور الهدى',
      channelDescription: 'قناة تنبيهات الأذكار ومواقيت الصلاة',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      playSound: true,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: payload,
    );
  }

  /// إرسال إشعار أذان تجريبي فوري للتأكد من وصول الإشعارات وسلامة الصوت والمنبهات
  Future<Map<String, dynamic>> sendInstantTestNotification([String? customSound]) async {
    final prefs = await SharedPreferences.getInstance();
    final azanSound = customSound ?? prefs.getString('azan_sound') ?? 'athan';

    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final areNotificationsEnabled = await androidImpl?.areNotificationsEnabled() ?? true;
    final canScheduleExactAlarms = await androidImpl?.canScheduleExactNotifications() ?? true;

    final androidDetails = AndroidNotificationDetails(
      'prayer_channel_sound_${azanSound}_v2',
      'تنبيهات الصلاة بالصوت',
      channelDescription: 'قناة إشعارات مواقيت الصلاة والأذن',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      playSound: true,
      sound: RawResourceAndroidNotificationSound(azanSound),
      fullScreenIntent: true,
    );

    await _notificationsPlugin.show(
      id: 9999,
      title: 'تجربة تنبيه الأذان • صلاة الظهر 🕌',
      body: 'الله أكبر، الله أكبر. هذا إشعار تجريبي للتأكد من وصول الأذان والصوت بنجاح.',
      notificationDetails: NotificationDetails(android: androidDetails),
    );

    return {
      'areNotificationsEnabled': areNotificationsEnabled,
      'canScheduleExactAlarms': canScheduleExactAlarms,
      'sound': azanSound,
    };
  }

  /// فحص الإشعارات المجدولة حالياً في النظام
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (_) {
      return [];
    }
  }

  Coordinates _getSavedCoordinates(SharedPreferences prefs) {
    final lat = prefs.getDouble('saved_lat');
    final lng = prefs.getDouble('saved_lng');
    if (lat != null && lng != null) {
      return Coordinates(lat, lng);
    }

    final selectedCity = prefs.getString('saved_city') ?? 'القاهرة';
    final city = WorldLocationService.findCity(selectedCity);
    if (city != null) {
      return city.toCoordinates();
    }

    return Coordinates(30.0444, 31.2357); // Cairo fallback
  }

  Future<void> cancelPrayerAndReminderNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final scheduledIds = prefs.getStringList('active_scheduled_notification_ids');

    if (scheduledIds != null && scheduledIds.isNotEmpty) {
      for (final idStr in scheduledIds) {
        final id = int.tryParse(idStr);
        if (id != null) {
          await cancelNotification(id);
        }
      }
      await prefs.remove('active_scheduled_notification_ids');
    } else {
      // إلغاء تسلسلي منظم هادئ لتفادي إغلاق الـ Main Looper
      for (int i = 1000; i < 1035; i++) {
        await cancelNotification(i);
      }
      for (int i = 2000; i < 2007; i++) {
        await cancelNotification(i);
      }
      for (int i = 3000; i < 3007; i++) {
        await cancelNotification(i);
      }
      for (int i = 4000; i < 4007; i++) {
        await cancelNotification(i);
      }
    }
  }

  Future<void> schedulePrayerNotifications({bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();

    // Check if azan notifications are enabled globally
    final azanEnabled = prefs.getBool('azan_enabled') ?? true;
    if (!azanEnabled || !_isEnabled) {
      await cancelPrayerAndReminderNotifications();
      return;
    }

    final azanSound = prefs.getString('azan_sound') ?? 'athan';
    final selectedCity = prefs.getString('saved_city') ?? 'القاهرة';
    final selectedCountry = prefs.getString('saved_country');
    final cityDisplay = selectedCountry != null && selectedCountry.isNotEmpty
        ? '$selectedCity ($selectedCountry)'
        : selectedCity;
    final coordinates = _getSavedCoordinates(prefs);

    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";
    final scheduleKey = "$todayStr-$selectedCity-$azanSound-v6";
    final lastScheduledKey = prefs.getString('last_scheduled_prayer_date');

    // التحقق من وجود إشعارات مجدولة فعلياً في النظام
    try {
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      if (pending.isEmpty) {
        force = true;
      }
    } catch (_) {
      force = true;
    }

    // إذا كانت الصلوات مجدولة بالفعل اليوم بنفس الإعدادات والمدينة ولم يُطلب إجبار الجدولة
    if (lastScheduledKey == scheduleKey && !force) {
      return;
    }

    // إلغاء الإشعارات السابقة بهدوء
    await cancelPrayerAndReminderNotifications();

    final List<String> scheduledIds = [];

    // جدولة الأيام الـ 7 القادمة
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final targetDate = DateTime(now.year, now.month, now.day + dayOffset, 12, 0);
      final prayerTimes = PrayerService.getPrayerTimes(coordinates, targetDate);

      final dailyPrayers = [
        {'id': 'fajr', 'name': 'الفجر', 'time': prayerTimes.fajr},
        {'id': 'dhuhr', 'name': 'الظهر', 'time': prayerTimes.dhuhr},
        {'id': 'asr', 'name': 'العصر', 'time': prayerTimes.asr},
        {'id': 'maghrib', 'name': 'المغرب', 'time': prayerTimes.maghrib},
        {'id': 'isha', 'name': 'العشاء', 'time': prayerTimes.isha},
      ];

      for (int pIdx = 0; pIdx < dailyPrayers.length; pIdx++) {
        final prayer = dailyPrayers[pIdx];
        final prayerTime = prayer['time'] as DateTime;
        final prayerName = prayer['name'] as String;
        final prayerId = prayer['id'] as String;

        // الصلاة التي يحين وقتها مستقبلاً تُجدول دائماً لضمان سماع الأذان في موعده
        if (prayerTime.isAfter(now)) {
          final id = 1000 + (dayOffset * 5) + pIdx;
          scheduledIds.add(id.toString());
          await scheduleNotification(
            id: id,
            title: 'حان الآن موعد صلاة $prayerName',
            body:
                'الله أكبر، الله أكبر. حان الآن موعد أذان صلاة $prayerName بتوقيت $cityDisplay.',
            time: prayerTime,
            sound: azanSound,
            payload: 'prayer_$prayerId',
            actions: [
              AndroidNotificationAction(
                'action_prayed_$prayerId',
                '✅ صلّيت (تسجيل الصلاة)',
                showsUserInterface: false,
                cancelNotification: true,
              ),
            ],
          );
        }
      }
    }

    await scheduleDailyReminders(scheduledIdsCollector: scheduledIds);
    await prefs.setStringList('active_scheduled_notification_ids', scheduledIds);
    await prefs.setString('last_scheduled_prayer_date', scheduleKey);
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

  Future<void> scheduleDailyReminders({List<String>? scheduledIdsCollector}) async {
    final prefs = await SharedPreferences.getInstance();
    final dailyRemindersEnabled = prefs.getBool('daily_reminder') ?? true;
    if (!dailyRemindersEnabled || !_isEnabled) {
      return;
    }

    final coordinates = _getSavedCoordinates(prefs);
    final now = DateTime.now();

    final isMorningDoneToday = _isTaskCompletedInPrefs(prefs, 'azkar_sabah');
    final isEveningDoneToday = _isTaskCompletedInPrefs(prefs, 'azkar_masaa');
    final isKahfDoneToday = _isTaskCompletedInPrefs(prefs, 'friday_kahf');

    for (int i = 0; i < 7; i++) {
      final targetDate = now.add(Duration(days: i));
      final prayerTimes = PrayerService.getPrayerTimes(coordinates, targetDate);

      // أذكار الصباح: بعد شروق الشمس بـ 15 دقيقة تلقائياً
      final sunrise = prayerTimes.sunrise;
      final morningTime = sunrise.add(const Duration(minutes: 15));
      if (morningTime.isAfter(now)) {
        if (!(i == 0 && isMorningDoneToday)) {
          final id = 2000 + i;
          scheduledIdsCollector?.add(id.toString());
          await scheduleNotification(
            id: id,
            title: 'أذكار الصباح ☀️',
            body:
                'ابتدئ يومك بذكر الله وطمأنينة قلبك، حان الآن وقت أذكار الصباح.',
            time: morningTime,
            payload: 'azkar_sabah',
          );
        }
      }

      // أذكار المساء: قبل صلاة المغرب بـ 30 دقيقة تلقائياً
      final maghrib = prayerTimes.maghrib;
      final eveningTime = maghrib.subtract(const Duration(minutes: 30));
      if (eveningTime.isAfter(now)) {
        if (!(i == 0 && isEveningDoneToday)) {
          final id = 3000 + i;
          scheduledIdsCollector?.add(id.toString());
          await scheduleNotification(
            id: id,
            title: 'أذكار المساء 🌙',
            body: 'حصن نفسك وأهلك بذكر الله، حان الآن وقت أذكار المساء.',
            time: eveningTime,
            payload: 'azkar_masaa',
          );
        }
      }

      if (targetDate.weekday == DateTime.friday) {
        final kahfTime =
            DateTime(targetDate.year, targetDate.month, targetDate.day, 9, 0);
        if (kahfTime.isAfter(now)) {
          if (!(i == 0 && isKahfDoneToday)) {
            final id = 4000 + i;
            scheduledIdsCollector?.add(id.toString());
            await scheduleNotification(
              id: id,
              title: 'سنن يوم الجمعة 📖',
              body:
                  'نور ما بين الجمعتين، لا تنسَ قراءة سورة الكهف اليوم والصلاة على النبي ﷺ.',
              time: kahfTime,
              payload: 'friday_kahf',
            );
          }
        }
      }
    }
  }

  /// إلغاء إشعار محدد بالمعرّف
  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (_) {}
  }

  /// إلغاء إشعار الورد أو الصلاة عند إتمامه لليوم الحالي
  Future<void> cancelTodayWardNotification(String taskId) async {
    final Map<String, int> taskNotificationIds = {
      'fajr': 1000,
      'dhuhr': 1001,
      'asr': 1002,
      'maghrib': 1003,
      'isha': 1004,
      'azkar_sabah': 2000,
      'morning': 2000,
      'azkar_masaa': 3000,
      'evening': 3000,
      'friday_kahf': 4000,
      'kahf': 4000,
    };

    final id = taskNotificationIds[taskId];
    if (id != null) {
      await cancelNotification(id);
      debugPrint('NotificationService: Cancelled today notification for $taskId (id: $id)');
    }
  }

  static const int ongoingNotificationId = 999;
  static const String ongoingChannelId = 'noor_al_hoda_ongoing';

  Future<void> updateOngoingNotification({
    required String title,
    required String body,
    Color? color,
    int? whenMs,
  }) async {
    if (!_isEnabled) return;

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final bool isFuture = whenMs != null && whenMs > nowMs;

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      ongoingChannelId,
      'الإشعار المستمر لمواقيت الصلاة',
      channelDescription: 'يعرض الوقت المتبقي للصلاة القادمة ومواقيت اليوم',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: color ?? const Color(0xFFD4AF37),
      showWhen: isFuture,
      when: isFuture ? whenMs : null,
      usesChronometer: isFuture,
      chronometerCountDown: isFuture,
      playSound: false,
      enableVibration: false,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'action_quran',
          '📖 المصحف',
          showsUserInterface: true,
          cancelNotification: false,
        ),
        const AndroidNotificationAction(
          'action_azkar',
          '🤲 الأذكار',
          showsUserInterface: true,
          cancelNotification: false,
        ),
        const AndroidNotificationAction(
          'action_tasbih',
          '📿 السبحة',
          showsUserInterface: true,
          cancelNotification: false,
        ),
      ],
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentSound: false,
    );

    try {
      await _notificationsPlugin.show(
        id: ongoingNotificationId,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
      );
    } catch (e) {
      debugPrint('Error showing ongoing notification with custom icon: $e');
      try {
        // Safe fallback without large icon
        final fallbackAndroidDetails = AndroidNotificationDetails(
          ongoingChannelId,
          'الإشعار المستمر لمواقيت الصلاة',
          channelDescription: 'يعرض الوقت المتبقي للصلاة القادمة ومواقيت اليوم',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          color: color ?? const Color(0xFFD4AF37),
          showWhen: whenMs != null,
          when: whenMs,
          usesChronometer: whenMs != null,
          chronometerCountDown: true,
          playSound: false,
          enableVibration: false,
          actions: androidDetails.actions,
        );
        await _notificationsPlugin.show(
          id: ongoingNotificationId,
          title: title,
          body: body,
          notificationDetails: NotificationDetails(
            android: fallbackAndroidDetails,
            iOS: iosDetails,
          ),
        );
      } catch (e2) {
        debugPrint('Fallback ongoing notification failed: $e2');
      }
    }
  }

  Future<void> cancelOngoingNotification() async {
    await _notificationsPlugin.cancel(id: ongoingNotificationId);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
