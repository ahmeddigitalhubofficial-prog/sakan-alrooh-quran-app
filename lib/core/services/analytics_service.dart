import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics? _analytics;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// تهيئة Firebase Analytics بأمان
  Future<void> init() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _analytics = FirebaseAnalytics.instance;
        await _analytics?.setAnalyticsCollectionEnabled(true);
        _isInitialized = true;
        debugPrint('AnalyticsService: Firebase Analytics initialized successfully.');
      } else {
        debugPrint('AnalyticsService: Firebase app not initialized yet.');
      }
    } catch (e) {
      _isInitialized = false;
      debugPrint('AnalyticsService Init Warning: $e');
    }
  }

  /// تسجيل فتح التطبيق
  Future<void> logAppOpen() async {
    if (!_isInitialized || _analytics == null) return;
    try {
      await _analytics?.logAppOpen();
    } catch (e) {
      debugPrint('AnalyticsService logAppOpen Error: $e');
    }
  }

  /// تسجيل زيارة الشاشات
  Future<void> logScreenView(String screenName) async {
    if (!_isInitialized || _analytics == null) return;
    try {
      await _analytics?.logScreenView(screenName: screenName);
    } catch (e) {
      debugPrint('AnalyticsService logScreenView Error: $e');
    }
  }

  /// تسجيل إتمام المهام والأوراد اليومية
  Future<void> logTaskCompleted(String taskId, String category) async {
    if (!_isInitialized || _analytics == null) return;
    try {
      await _analytics?.logEvent(
        name: 'task_completed',
        parameters: {
          'task_id': taskId,
          'category': category,
        },
      );
    } catch (e) {
      debugPrint('AnalyticsService logTaskCompleted Error: $e');
    }
  }

  /// تسجيل قراءة الأذكار
  Future<void> logAzkarRead(String azkarCategory) async {
    if (!_isInitialized || _analytics == null) return;
    try {
      await _analytics?.logEvent(
        name: 'azkar_read',
        parameters: {
          'category': azkarCategory,
        },
      );
    } catch (e) {
      debugPrint('AnalyticsService logAzkarRead Error: $e');
    }
  }

  /// تسجيل استخدام التسبيح
  Future<void> logTasbih(int count) async {
    if (!_isInitialized || _analytics == null) return;
    try {
      await _analytics?.logEvent(
        name: 'tasbih_count',
        parameters: {
          'count': count,
        },
      );
    } catch (e) {
      debugPrint('AnalyticsService logTasbih Error: $e');
    }
  }
}
