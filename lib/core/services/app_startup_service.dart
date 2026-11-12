import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../services/device_ecosystem_service.dart';
import '../../services/notification_service.dart';
import '../../services/background_service.dart';
import '../../services/cloud_sync_service.dart';
import '../../services/home_widget_service.dart';
import 'analytics_service.dart';

/// خدمة تهيئة التطبيق المركزية (تعمل أثناء الـ Splash Screen دون حجب الواجهة)
class AppStartupService {
  static bool _initialized = false;
  static Completer<void>? _completer;

  /// مؤشر نسبة التقدم الحقيقي (من 0.0 إلى 1.0)
  static final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0.1);

  /// رسالة الحالة الحالية المعروضة للمستخدم
  static final ValueNotifier<String> statusNotifier =
      ValueNotifier<String>('جاري تحضير التطبيق...');

  static bool get isInitialized => _initialized;

  static void _updateStatus(double progress, String message) {
    progressNotifier.value = progress.clamp(0.0, 1.0);
    statusNotifier.value = message;
  }

  static Future<void> initialize() async {
    if (_initialized) {
      _updateStatus(1.0, 'مرحباً بك في سكن الروح');
      return;
    }
    if (_completer != null) return _completer!.future;

    _completer = Completer<void>();

    try {
      _updateStatus(0.15, 'التحقق من بيئة ونظام التشغيل...');
      // 0. اكتشاف بيئة الجهاز (Apple / Huawei / Google) لتكييف الخدمات
      try {
        await DeviceEcosystemService().initialize();
      } catch (e) {
        debugPrint('AppStartup: Ecosystem detection error: $e');
      }

      _updateStatus(0.30, 'تهيئة التقويم والتوقيت المحلي...');
      // 1. تهيئة التواريخ باللغة العربية
      try {
        await initializeDateFormatting('ar', null);
      } catch (e) {
        debugPrint('AppStartup: Date formatting init bypass: $e');
      }

      _updateStatus(0.45, 'التحقق من الخدمات السحابية...');
      // 2. تهيئة Firebase و Crashlytics والتحليلات
      try {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp();
        }
        if (Firebase.apps.isNotEmpty) {
          FlutterError.onError = (errorDetails) {
            FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
          };
          PlatformDispatcher.instance.onError = (error, stack) {
            FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
            return true;
          };
        }
        CloudSyncService.enableOfflinePersistence();
        unawaited(AnalyticsService().init().then((_) {
          AnalyticsService().logAppOpen();
        }));
      } catch (e) {
        debugPrint('AppStartup: Firebase safe init bypass: $e');
      }

      _updateStatus(0.70, 'ضبط مواقيت الصلاة والتنبيهات...');
      // 3. تهيئة خدمة الإشعارات وجدولة الصلوات
      try {
        final notificationService = NotificationService();
        await notificationService.init();
        unawaited(notificationService.schedulePrayerNotifications(force: true));
      } catch (e) {
        debugPrint('AppStartup: Notification service init bypass: $e');
      }

      _updateStatus(0.90, 'تحديث الودجات والخدمات الخلفية...');
      // 4. تهيئة الخدمة الخلفية المستمرة للعد التنازلي
      try {
        await initializeBackgroundService();
      } catch (e) {
        debugPrint('AppStartup: Background service init bypass: $e');
      }

      // 5. تحديث ودجات الشاشة الرئيسية بالبيانات والمواقيت فوراً
      try {
        unawaited(HomeWidgetService.updateAllPrayerWidgets());
      } catch (e) {
        debugPrint('AppStartup: HomeWidget init bypass: $e');
      }

      _updateStatus(1.0, 'مرحباً بك في سكن الروح');
      _initialized = true;
      if (!_completer!.isCompleted) {
        _completer!.complete();
      }
    } catch (e) {
      debugPrint('AppStartup: Global startup error: $e');
      _updateStatus(1.0, 'مرحباً بك في سكن الروح');
      _initialized = true;
      if (!_completer!.isCompleted) {
        _completer!.complete();
      }
    }

    return _completer!.future;
  }
}
