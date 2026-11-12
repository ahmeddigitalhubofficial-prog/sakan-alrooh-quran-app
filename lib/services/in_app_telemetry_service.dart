import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_version.dart';

/// خدمة رصد المؤشرات والتفاعل الحية (Telemetry & Bot Swarm Integration)
/// تنقل نبض استخدام المميزات الجديدة للوحة تحكم المدير التنفيذي وفريق البوتات
class InAppTelemetryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// تسجيل نبضة حدث تفاعلي
  static Future<void> logFeaturePulse(String featureName, {Map<String, dynamic>? metadata}) async {
    try {
      final user = _auth.currentUser;
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('telemetry_device_id') ?? _generateDeviceId(prefs);

      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      // 1. تسجيل النبضة في سجل الأحداث
      await _firestore.collection('app_telemetry').add({
        'feature': featureName,
        'timestamp': FieldValue.serverTimestamp(),
        'date': todayStr,
        'userId': user?.uid ?? 'guest',
        'deviceId': deviceId,
        'appVersion': AppVersion.version,
        'metadata': metadata ?? {},
      });

      // 2. تحديث العداد اليومي المجمّع للميزة
      await _firestore.collection('telemetry_daily_summary').doc(todayStr).set({
        'date': todayStr,
        'lastUpdated': FieldValue.serverTimestamp(),
        'eventsCount': FieldValue.increment(1),
        'features': {
          featureName: FieldValue.increment(1),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('InAppTelemetry error: $e');
    }
  }

  static String _generateDeviceId(SharedPreferences prefs) {
    final id = 'dev_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (DateTime.now().microsecond % 9000))}';
    prefs.setString('telemetry_device_id', id);
    return id;
  }
}
