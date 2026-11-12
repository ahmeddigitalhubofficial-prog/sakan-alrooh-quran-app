import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_version.dart';
import 'owner_service.dart';
import 'notification_service.dart';

/// خدمة المزامنة السحابية المعمارية (4-Tier Enterprise Architecture)
class CloudSyncService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static Timer? _syncDebounceTimer;

  /// تفعيل التخزين السحابي المؤقت أوفلاين لحفظ التغييرات ومزامنتها فور توفر الإنترنت
  static void enableOfflinePersistence() {
    try {
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      debugPrint('CloudSync Offline Persistence notice: $e');
    }
  }

  /// المزامنة التلقائية اللحظية في الخلفية مع كل تغيير دون ضغط أي زر
  static void autoSyncOnDataChange({Duration delay = const Duration(seconds: 3)}) {
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = Timer(delay, () {
      syncUserDataToCloud();
    });
  }

  /// الحصول على معرّف المستخدم الحالي أو إنشائه تلقائياً
  static Future<User?> _ensureUser() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        final credential = await _auth.signInAnonymously();
        user = credential.user;
      }
      return user;
    } catch (e) {
      debugPrint('CloudSync Auth Error: $e');
      return null;
    }
  }

  /// رفع وحفظ بيانات المستخدم الحالية إلى السحابة بهيكل الـ 4 طبقات المنظم
  static Future<bool> syncUserDataToCloud() async {
    try {
      final user = await _ensureUser();
      if (user == null) return false;

      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final int lastSurah = prefs.getInt('last_surah') ?? prefs.getInt('last_read_surah') ?? 1;
      final int lastVerse = prefs.getInt('last_verse') ?? prefs.getInt('last_read_verse') ?? 1;
      final int lastPage = prefs.getInt('last_page') ?? 1;
      final String lastSurahName = prefs.getString('last_read_surah_name') ?? '';
      final List<String> favoriteSurahs = prefs.getStringList('favorite_surahs') ?? [];
      final List<String> bookmarks = prefs.getStringList('quran_bookmarks') ?? [];

      // بيانات الختمة
      dynamic activeKhatma;
      final activeKhatmaStr = prefs.getString('active_khatma_plan');
      if (activeKhatmaStr != null && activeKhatmaStr.isNotEmpty) {
        try {
          activeKhatma = jsonDecode(activeKhatmaStr);
        } catch (_) {
          activeKhatma = activeKhatmaStr;
        }
      }

      dynamic sharedKhatma;
      final sharedKhatmaStr = prefs.getString('shared_khatma_plan');
      if (sharedKhatmaStr != null && sharedKhatmaStr.isNotEmpty) {
        try {
          sharedKhatma = jsonDecode(sharedKhatmaStr);
        } catch (_) {
          sharedKhatma = sharedKhatmaStr;
        }
      }

      // إحصائيات التسبيح
      final int tasbihCounter = prefs.getInt('tasbih_counter') ?? 0;
      final int tasbihDaily = prefs.getInt('tasbih_daily') ?? prefs.getInt('tasbih_daily_count') ?? 0;
      final int tasbihTotal = prefs.getInt('tasbih_total') ?? prefs.getInt('tasbih_total_count') ?? 0;
      final int tasbihStreak = prefs.getInt('tasbih_streak') ?? 1;

      // بيانات الصيام
      final List<String> fastedDays = prefs.getStringList('fasting_history_days') ?? prefs.getStringList('fasted_days_list') ?? [];
      final int qadaaRemaining = prefs.getInt('fasting_qada_remaining') ?? prefs.getInt('qadaa_days_remaining') ?? 0;
      final int qadaaCompleted = prefs.getInt('fasting_qada_completed') ?? prefs.getInt('qadaa_days_completed') ?? 0;

      // بيانات السنن
      final sunanJsonStr = prefs.getString('sunan_state_$todayStr');
      Map<String, dynamic> todaySunan = {};
      if (sunanJsonStr != null) {
        try {
          todaySunan = jsonDecode(sunanJsonStr);
        } catch (_) {}
      }

      // بيانات المتجر والحسنات
      final int hasanatPoints = prefs.getInt('user_hasanat_points') ?? prefs.getInt('hasanat_points_balance') ?? 150;
      final List<String> unlockedStoreItems = prefs.getStringList('user_unlocked_store_items') ?? prefs.getStringList('unlocked_store_items') ?? [];

      String appVersion = '${AppVersion.version}+${AppVersion.buildNumber}';
      try {
        final info = await PackageInfo.fromPlatform();
        appVersion = '${info.version}+${info.buildNumber}';
      } catch (_) {}

      final isOwner = OwnerService().isOwner || (user.email != null && user.email!.toLowerCase() == OwnerService.ownerEmail.toLowerCase());

      // 1️⃣ المستوى الأول: الملف التعريفي السريع والإعدادات العامة (users/{uid})
      final Map<String, dynamic> profileData = {
        'profile': {
          'user_id': user.uid,
          'email': user.email ?? 'anonymous',
          'is_anonymous': user.isAnonymous,
          'is_owner': isOwner,
          'platform': defaultTargetPlatform.name,
          'app_version': appVersion,
          'last_active_at': FieldValue.serverTimestamp(),
          'created_at': user.metadata.creationTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
        },
        'preferences': {
          'theme_id': prefs.getString('selected_app_theme') ?? 'kaaba_gold',
          'quran_bg_id': prefs.getString('quran_background_style') ?? 'ivory',
          'hasanat_points': hasanatPoints,
          'unlocked_items': unlockedStoreItems,
          'azan_enabled': prefs.getBool('azan_enabled') ?? true,
          'fasting_reminder': prefs.getBool('fasting_reminder_enabled') ?? true,
        },
        'quran_summary': {
          'last_read_surah': lastSurah,
          'last_read_verse': lastVerse,
          'last_read_page': lastPage,
          'last_read_surah_name': lastSurahName,
          'bookmarks_count': bookmarks.length,
          'favorite_surahs': favoriteSurahs,
          'active_khatma': activeKhatma,
        },
        'tasbih_summary': {
          'counter': tasbihCounter,
          'daily_count': tasbihDaily,
          'total_count': tasbihTotal,
          'streak': tasbihStreak,
        },
        'fasting_summary': {
          'total_fasted_days': fastedDays.length,
          'qadaa_remaining': qadaaRemaining,
          'qadaa_completed': qadaaCompleted,
        },
        'sync_status': {
          'is_synced': true,
          'last_sync_local_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
          'timestamp': FieldValue.serverTimestamp(),
        },
      };

      final userDocRef = _firestore.collection('users').doc(user.uid);
      await userDocRef.set(profileData, SetOptions(merge: true));

      // 2️⃣ المستوى الثاني: السجلات اليومية المنظمة (users/{uid}/daily_logs/{YYYY-MM-DD})
      final dailyLogData = {
        'date': todayStr,
        'sunan_rakats_details': todaySunan,
        'fasted_today': fastedDays.contains(todayStr),
        'tasbih_today_count': tasbihDaily,
        'qadaa_remaining': qadaaRemaining,
        'updated_at': FieldValue.serverTimestamp(),
      };
      await userDocRef.collection('daily_logs').doc(todayStr).set(dailyLogData, SetOptions(merge: true));

      // 3️⃣ المستوى الثالث: الختمات التشاركية الحية (shared_khatmat/{khatma_id})
      if (sharedKhatma != null && sharedKhatma is Map && sharedKhatma['id'] != null) {
        final khatmaId = sharedKhatma['id'].toString();
        await _firestore.collection('shared_khatmat').doc(khatmaId).set(
          Map<String, dynamic>.from(sharedKhatma),
          SetOptions(merge: true),
        );
      }

      // تسجيل التثبيت الأول على هذا الجهاز وزيادة عداد التنزيلات في السحابة
      final bool isFirstInstallRecorded = prefs.getBool('is_first_install_recorded') ?? false;
      if (!isFirstInstallRecorded) {
        await _firestore.collection('admin_dashboard').doc('live_overview').set({
          'total_installations': FieldValue.increment(1),
          'install_timestamps': FieldValue.arrayUnion([DateTime.now().toIso8601String()]),
        }, SetOptions(merge: true));
        await prefs.setBool('is_first_install_recorded', true);
      }

      // حساب الزيادة الفعلية (Delta) في التسبيح وأيام الصيام لمنع التكرار والتضخم العشوائي
      final int lastSyncedTasbih = prefs.getInt('last_synced_total_tasbih') ?? 0;
      final int tasbihDelta = (tasbihTotal > lastSyncedTasbih) ? (tasbihTotal - lastSyncedTasbih) : 0;
      if (tasbihDelta > 0) {
        await prefs.setInt('last_synced_total_tasbih', tasbihTotal);
      }

      final int lastSyncedFasting = prefs.getInt('last_synced_total_fasting') ?? 0;
      final int totalFastingDaysCount = fastedDays.length;
      final int fastingDelta = (totalFastingDaysCount > lastSyncedFasting) ? (totalFastingDaysCount - lastSyncedFasting) : 0;
      if (fastingDelta > 0) {
        await prefs.setInt('last_synced_total_fasting', totalFastingDaysCount);
      }

      // 4️⃣ المستوى الرابع: إحصائيات المالك الحية (admin_dashboard/live_overview)
      final adminDocRef = _firestore.collection('admin_dashboard').doc('live_overview');
      final Map<String, dynamic> harvestUpdate = {
        'total_sync_events': FieldValue.increment(1),
      };
      if (tasbihDelta > 0) {
        harvestUpdate['total_tasbih_counted'] = FieldValue.increment(tasbihDelta);
      }
      if (fastingDelta > 0) {
        harvestUpdate['total_fasting_days'] = FieldValue.increment(fastingDelta);
      }

      await adminDocRef.set({
        'last_active_ping': FieldValue.serverTimestamp(),
        'app_versions': {
          AppVersion.version: FieldValue.increment(1),
        },
        'spiritual_harvest': harvestUpdate,
      }, SetOptions(merge: true));

      debugPrint('CloudSync 4-Tier: Success sync for ${user.uid} (Owner: $isOwner)');
      unawaited(checkAndApplyRemoteNotificationResync());
      return true;
    } catch (e) {
      debugPrint('CloudSync Error: $e');
      return false;
    }
  }

  /// التحقق وتطبيق أمر المالك لإعادة مزامنة وجدولة إشعارات الأذان والأذكار لجميع المستخدمين
  static Future<bool> checkAndApplyRemoteNotificationResync() async {
    try {
      final doc = await _firestore.collection('admin_dashboard').doc('live_overview').get();
      if (!doc.exists || doc.data() == null) return false;

      final data = doc.data()!;
      final remoteVersion = data['remote_notification_sync_version'] as int?;
      if (remoteVersion == null) return false;

      final prefs = await SharedPreferences.getInstance();
      final localVersion = prefs.getInt('applied_remote_notif_sync_version') ?? 0;

      if (remoteVersion > localVersion) {
        debugPrint('[CloudSync] Newer remote notification sync version found ($remoteVersion > $localVersion). Forcing full reschedule...');
        await NotificationService().schedulePrayerNotifications(force: true);
        await prefs.setInt('applied_remote_notif_sync_version', remoteVersion);
        return true;
      }
    } catch (e) {
      debugPrint('CloudSync Notification Resync Error: $e');
    }
    return false;
  }

  /// أمر المالك: إجبار جميع هواتف المستخدمين حول العالم على إعادة جدولة وتثبيت الإشعارات فوراً
  static Future<void> triggerGlobalNotificationResync({String? note}) async {
    try {
      final newVersion = DateTime.now().millisecondsSinceEpoch;
      await _firestore.collection('admin_dashboard').doc('live_overview').set({
        'remote_notification_sync_version': newVersion,
        'remote_notification_sync_updated_at': FieldValue.serverTimestamp(),
        'remote_notification_sync_note': note ?? 'إعادة ضبط شامل لجدولة الأذان والأذكار',
      }, SetOptions(merge: true));

      final prefs = await SharedPreferences.getInstance();
      await NotificationService().schedulePrayerNotifications(force: true);
      await prefs.setInt('applied_remote_notif_sync_version', newVersion);
    } catch (e) {
      debugPrint('CloudSync triggerGlobalNotificationResync Error: $e');
      rethrow;
    }
  }

  /// جلب معلومات آخر مزامنة إشعارات سحابية عالمية
  static Future<Map<String, dynamic>?> getRemoteNotificationSyncInfo() async {
    try {
      final doc = await _firestore.collection('admin_dashboard').doc('live_overview').get();
      if (doc.exists && doc.data() != null) {
        final d = doc.data()!;
        return {
          'version': d['remote_notification_sync_version'],
          'updated_at': d['remote_notification_sync_updated_at'],
          'note': d['remote_notification_sync_note'],
        };
      }
    } catch (_) {}
    return null;
  }


  /// استرجاع بيانات المستخدم السحابية عند تسجيل الدخول بجهاز جديد
  static Future<bool> restoreUserDataFromCloud() async {
    try {
      final user = await _ensureUser();
      if (user == null) return false;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists || doc.data() == null) return false;

      final data = doc.data()!;
      final prefs = await SharedPreferences.getInstance();

      // 1. استرجاع القرآن
      if (data.containsKey('quran_summary')) {
        final quran = Map<String, dynamic>.from(data['quran_summary']);
        if (quran['last_read_surah'] != null) await prefs.setInt('last_surah', quran['last_read_surah']);
        if (quran['last_read_verse'] != null) await prefs.setInt('last_verse', quran['last_read_verse']);
        if (quran['last_read_page'] != null) await prefs.setInt('last_page', quran['last_read_page']);
        if (quran['last_read_surah_name'] != null) await prefs.setString('last_read_surah_name', quran['last_read_surah_name']);
        if (quran['favorite_surahs'] != null) await prefs.setStringList('favorite_surahs', List<String>.from(quran['favorite_surahs']));
      }

      // 2. استرجاع التفضيلات
      if (data.containsKey('preferences')) {
        final pref = Map<String, dynamic>.from(data['preferences']);
        if (pref['theme_id'] != null) await prefs.setString('selected_app_theme', pref['theme_id']);
        if (pref['quran_bg_id'] != null) await prefs.setString('quran_background_style', pref['quran_bg_id']);
        if (pref['hasanat_points'] != null) await prefs.setInt('hasanat_points_balance', pref['hasanat_points']);
        if (pref['unlocked_items'] != null) await prefs.setStringList('unlocked_store_items', List<String>.from(pref['unlocked_items']));
        if (pref['azan_enabled'] != null) await prefs.setBool('azan_enabled', pref['azan_enabled']);
        if (pref['fasting_reminder'] != null) await prefs.setBool('fasting_reminder_enabled', pref['fasting_reminder']);
      }

      debugPrint('CloudSync: Restored successfully from 4-Tier cloud');
      unawaited(checkAndApplyRemoteNotificationResync());
      return true;
    } catch (e) {
      debugPrint('CloudSync Restore Error: $e');
      return false;
    }
  }

  /// بث حي لإحصائيات المالك الحصرية
  static Stream<DocumentSnapshot<Map<String, dynamic>>> getAdminOverviewStream() {
    return _firestore.collection('admin_dashboard').doc('live_overview').snapshots();
  }

  /// بث حي للإعلانات العامة
  static Stream<String?> getGlobalAnnouncementStream() {
    return _firestore.collection('admin_dashboard').doc('live_overview').snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!['global_announcement'] as String?;
      }
      return null;
    });
  }

  /// تحديث الإعلان العام لجميع المستخدمين من قبل المالك
  static Future<void> updateGlobalAnnouncement(String text) async {
    await _firestore.collection('admin_dashboard').doc('live_overview').set({
      'global_announcement': text.trim(),
      'announcement_updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// حساب عدد المستخدمين النشطين (المحتفظين بالتطبيق) خلال آخر 7 أيام
  static Future<int> getRetainedUsersCount() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final snapshot = await _firestore
          .collection('users')
          .where('profile.last_active_at', isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (_) {
      try {
        final totalUsers = await _firestore.collection('users').count().get();
        return totalUsers.count ?? 1;
      } catch (_) {
        return 1;
      }
    }
  }

  /// إجمالي عدد المستخدمين المسجلين في النظام
  static Future<int> getTotalRegisteredUsersCount() async {
    try {
      final snapshot = await _firestore.collection('users').count().get();
      return snapshot.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// ربط حساب المستخدم الحالي بهوية هواوي Huawei ID
  static Future<bool> linkHuaweiId({
    required String openId,
    String? displayName,
    String? email,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('linked_huawei_openid', openId);
      if (displayName != null) await prefs.setString('linked_huawei_name', displayName);
      if (email != null) await prefs.setString('linked_huawei_email', email);

      await _firestore.collection('users').doc(user.uid).set({
        'profile': {
          'huawei_openid': openId,
          'huawei_display_name': displayName,
          'huawei_email': email,
          'huawei_linked_at': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));

      debugPrint('CloudSync: Linked Huawei ID $openId successfully');
      return true;
    } catch (e) {
      debugPrint('CloudSync Link Huawei ID Error: $e');
      return false;
    }
  }

  /// توليد أو جلب كود النقل السحابي العالمي المكون من 6 خانات (مثل: SKN-7429)
  static Future<String> getOrGenerateUniversalSyncCode() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedCode = prefs.getString('universal_cloud_sync_code');
    if (cachedCode != null && cachedCode.isNotEmpty) {
      return cachedCode;
    }

    final user = _auth.currentUser;
    if (user == null) return 'ERR-AUTH';

    try {
      // توليد كود فريد يبدأ بـ SKN متبوعاً بأرقام وحروف سهلة القراءة
      const chars = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
      final random = Random.secure();
      final randomPart = List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
      final newCode = 'SKN-$randomPart';

      // حفظ الكود في جدول أكواد المزامنة السريعة
      await _firestore.collection('sync_codes').doc(newCode).set({
        'uid': user.uid,
        'created_at': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
      });

      // حفظ الكود في ملف المستخدم وفي التفضيلات المحلية
      await _firestore.collection('users').doc(user.uid).set({
        'profile': {'universal_sync_code': newCode}
      }, SetOptions(merge: true));

      await prefs.setString('universal_cloud_sync_code', newCode);
      return newCode;
    } catch (e) {
      debugPrint('Error generating sync code: $e');
      return 'SKN-ERROR';
    }
  }

  /// استيراد واسترجاع كافة البيانات عبر كود النقل السحابي العالمي
  static Future<bool> restoreFromUniversalSyncCode(String syncCode) async {
    try {
      final cleanCode = syncCode.trim().toUpperCase();
      if (cleanCode.isEmpty) return false;

      // 1. البحث عن الكود في جدول الأكواد
      final codeDoc = await _firestore.collection('sync_codes').doc(cleanCode).get();
      if (!codeDoc.exists || codeDoc.data() == null) {
        debugPrint('CloudSync: Invalid or expired sync code $cleanCode');
        return false;
      }

      final targetUid = codeDoc.data()!['uid'] as String?;
      if (targetUid == null || targetUid.isEmpty) return false;

      // 2. قراءة بيانات المستخدم المستهدف
      final userDoc = await _firestore.collection('users').doc(targetUid).get();
      if (!userDoc.exists || userDoc.data() == null) return false;

      final data = userDoc.data()!;
      final prefs = await SharedPreferences.getInstance();

      // 3. استرجاع التفضيلات والإعدادات
      if (data.containsKey('preferences')) {
        final p = data['preferences'] as Map<String, dynamic>;
        if (p['theme_id'] != null) await prefs.setString('selected_app_theme', p['theme_id']);
        if (p['quran_bg_id'] != null) await prefs.setString('quran_background_style', p['quran_bg_id']);
        if (p['hasanat_points'] != null) await prefs.setInt('hasanat_points_balance', p['hasanat_points']);
        if (p['unlocked_items'] != null) await prefs.setStringList('unlocked_store_items', List<String>.from(p['unlocked_items']));
        if (p['azan_enabled'] != null) await prefs.setBool('azan_enabled', p['azan_enabled']);
        if (p['fasting_reminder'] != null) await prefs.setBool('fasting_reminder_enabled', p['fasting_reminder']);
      }

      // 4. استرجاع القرآن والختمات
      if (data.containsKey('quran_summary')) {
        final q = data['quran_summary'] as Map<String, dynamic>;
        if (q['last_read_surah'] != null) await prefs.setInt('last_read_surah', q['last_read_surah']);
        if (q['last_read_verse'] != null) await prefs.setInt('last_read_verse', q['last_read_verse']);
        if (q['last_read_page'] != null) await prefs.setInt('last_read_page', q['last_read_page']);
        if (q['last_read_surah_name'] != null) await prefs.setString('last_read_surah_name', q['last_read_surah_name']);
        if (q['active_khatma'] != null) await prefs.setString('user_khatma_plan', jsonEncode(q['active_khatma']));
      }

      // 5. استرجاع التسبيح
      if (data.containsKey('tasbih_summary')) {
        final t = data['tasbih_summary'] as Map<String, dynamic>;
        if (t['counter'] != null) await prefs.setInt('tasbih_counter', t['counter']);
        if (t['daily_count'] != null) await prefs.setInt('tasbih_daily_count', t['daily_count']);
        if (t['total_count'] != null) await prefs.setInt('tasbih_total_count', t['total_count']);
        if (t['streak'] != null) await prefs.setInt('tasbih_streak', t['streak']);
      }

      // 6. استرجاع الصيام
      if (data.containsKey('fasting_summary')) {
        final f = data['fasting_summary'] as Map<String, dynamic>;
        if (f['qadaa_remaining'] != null) await prefs.setInt('qadaa_remaining_days', f['qadaa_remaining']);
        if (f['qadaa_completed'] != null) await prefs.setInt('qadaa_completed_days', f['qadaa_completed']);
      }

      // مزامنة فورية مع الحساب المحلي الحالي لربطه بالبيانات المستوردة
      unawaited(syncUserDataToCloud());
      debugPrint('CloudSync: Successfully imported all data from code $cleanCode');
      return true;
    } catch (e) {
      debugPrint('CloudSync Restore From Code Error: $e');
      return false;
    }
  }
}
