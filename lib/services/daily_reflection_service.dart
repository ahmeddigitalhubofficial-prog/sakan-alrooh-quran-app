import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/daily_reflections_data.dart';
import 'notification_service.dart';

class DailyReflection {
  final int id;
  final String verseArabic;
  final String surahAndVerse;
  final String reflection;
  final String moodCategory; // 'طمأنينة', 'تفريج هم', 'شكر', 'تيسير', 'استغفار'
  final String audioUrl;
  final String? date;

  const DailyReflection({
    required this.id,
    required this.verseArabic,
    required this.surahAndVerse,
    required this.reflection,
    required this.moodCategory,
    required this.audioUrl,
    this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'verseArabic': verseArabic,
        'surahAndVerse': surahAndVerse,
        'reflection': reflection,
        'moodCategory': moodCategory,
        'audioUrl': audioUrl,
        'date': date,
      };

  static String _cleanString(dynamic val) {
    if (val == null) return '';
    String s = val.toString().trim();
    if (s.startsWith('"') && s.endsWith('"') && s.length >= 2) {
      s = s.substring(1, s.length - 1).trim();
    }
    return s;
  }

  factory DailyReflection.fromJson(Map<String, dynamic> json) {
    return DailyReflection(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      verseArabic: _cleanString(json['verseArabic']),
      surahAndVerse: _cleanString(json['surahAndVerse']),
      reflection: _cleanString(json['reflection']),
      moodCategory: _cleanString(json['moodCategory']).isEmpty
          ? 'طمأنينة'
          : _cleanString(json['moodCategory']),
      audioUrl: _cleanString(json['audioUrl']),
      date: json['date']?.toString(),
    );
  }
}

class DailyReflectionService {
  static const String _prefKeyCachedReflection = 'cached_daily_reflection';
  static const String _prefKeyLastNotifiedDate = 'last_notified_reflection_date';

  static List<DailyReflection> get reflections => kDailyReflectionsLibrary;

  /// إرجاع خاطرة اليوم الافتراضية بشكل قطعي ومتغير يومياً طوال العام
  static DailyReflection getFallbackTodayReflection([DateTime? targetDate]) {
    final now = targetDate ?? DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = (dayOfYear + (now.year * 7)) % reflections.length;
    return reflections[index];
  }

  /// إرجاع تدبر يوم محدد
  static DailyReflection getReflectionByDay(int dayNumber) {
    final index = (dayNumber - 1).abs() % reflections.length;
    return reflections[index];
  }

  /// المستمع اللحظي لتحديثات الخاطرة اليومية
  static final ValueNotifier<DailyReflection> currentReflectionNotifier =
      ValueNotifier<DailyReflection>(getFallbackTodayReflection());

  /// إرجاع الخاطرة اليومية الحالية (سحابية أو محلية) مع الفحص الذكي لتغير التاريخ
  static DailyReflection getTodayReflection() {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final current = currentReflectionNotifier.value;
    if (current.date != null && current.date != todayStr) {
      currentReflectionNotifier.value = getFallbackTodayReflection();
    }
    return currentReflectionNotifier.value;
  }

  /// التبديل التفاعلي إلى تدبر وخاطرة أخرى عند رغبة المستخدم
  static void nextReflection() {
    final current = currentReflectionNotifier.value;
    final currentIndex = reflections.indexWhere((r) => r.id == current.id);
    final nextIndex = (currentIndex + 1) % reflections.length;
    currentReflectionNotifier.value = reflections[nextIndex];
  }

  /// تهيئة المزامنة السحابية للخاطرة اليومية مع Firebase Firestore
  static Future<void> initCloudSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);

      // 1. تحميل الخاطرة المخزنة محلياً إذا كانت تخص اليوم الحالي فقط لسرعة العرض الفوري
      final cachedJson = prefs.getString(_prefKeyCachedReflection);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        try {
          final Map<String, dynamic> data = jsonDecode(cachedJson);
          final cached = DailyReflection.fromJson(data);
          if (cached.date == todayStr) {
            currentReflectionNotifier.value = cached;
          } else {
            // يوم جديد! استخدم تدبر اليوم الجديد
            currentReflectionNotifier.value = getFallbackTodayReflection();
          }
        } catch (_) {
          currentReflectionNotifier.value = getFallbackTodayReflection();
        }
      } else {
        currentReflectionNotifier.value = getFallbackTodayReflection();
      }

      // 2. الاستماع اللحظي لسحابة Firestore المباشرة (admin_dashboard / live_overview)
      FirebaseFirestore.instance
          .collection('admin_dashboard')
          .doc('live_overview')
          .snapshots()
          .listen((snapshot) async {
        if (!snapshot.exists || snapshot.data() == null) return;

        try {
          final data = snapshot.data()!;
          final rawReflection = data['daily_reflection'];
          if (rawReflection == null) return;

          final Map<String, dynamic> reflectionMap =
              Map<String, dynamic>.from(rawReflection as Map);
          final reflection = DailyReflection.fromJson(reflectionMap);

          // تحديث الواجهة فورياً
          currentReflectionNotifier.value = reflection;

          // حفظها في التخزين المحلي
          await prefs.setString(
            _prefKeyCachedReflection,
            jsonEncode(reflection.toJson()),
          );

          // 3. فحص إرسال الإشعار اليومي الصباحي إذا لم يتم إرساله اليوم
          final todayStr = DateTime.now().toIso8601String().substring(0, 10);
          final lastNotified = prefs.getString(_prefKeyLastNotifiedDate);

          if (lastNotified != todayStr) {
            await prefs.setString(_prefKeyLastNotifiedDate, todayStr);
            await NotificationService().showNotification(
              'سكن الروح 🌸 | تدبر اليوم',
              '${reflection.verseArabic}\n${reflection.reflection}',
            );
          }
        } catch (e) {
          debugPrint('Error updating daily reflection from cloud: $e');
        }
      }, onError: (err) {
        debugPrint('DailyReflection Cloud stream notice: $err');
      });
    } catch (e) {
      debugPrint('DailyReflection initCloudSync error: $e');
    }
  }
}
