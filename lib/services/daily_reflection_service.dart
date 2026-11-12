import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  static const List<DailyReflection> reflections = [
    DailyReflection(
      id: 1,
      verseArabic: '﴿ وَتَوَكَّلْ عَلَى الْحَيِّ الَّذِي لَا يَمُوتُ ﴾',
      surahAndVerse: 'سورة الفرقان - آية 58',
      reflection:
          'مهما تعلقت بآمال الدنيا وانقطعت بك الأسباب، تذكّر أن لك رباً حياً قيوماً لا يعجزه شيء في الأرض ولا في السماء، فسلّم أمرك إليه واطمئن.',
      moodCategory: 'طمأنينة',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/025058.mp3',
    ),
    DailyReflection(
      id: 2,
      verseArabic: '﴿ لَا تَدْرِي لَعَلَّ اللَّهَ يُحْدِثُ بَعْدَ ذَٰلِكَ أَمْرًا ﴾',
      surahAndVerse: 'سورة الطلاق - آية 1',
      reflection:
          'في كل لحظة يأس، قد يكون الفرج يرتّب لك في الخفاء بطريقة تفوق كل حساباتك البشرية، فأحسن الظن بربك.',
      moodCategory: 'تفريج هم',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/065001.mp3',
    ),
    DailyReflection(
      id: 3,
      verseArabic: '﴿ فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۝ إِنَّ مَعَ الْعُسْرِ يُسْرًا ﴾',
      surahAndVerse: 'سورة الشرح - آية 5-6',
      reflection:
          'لم يقل الله "بعد العسر" بل "مع العسر"؛ فمع كل ضيق ينزل اللطف واليسر ملازماً له، ولن يغلب عسر يسرين.',
      moodCategory: 'تيسير',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/094005.mp3',
    ),
    DailyReflection(
      id: 4,
      verseArabic: '﴿ وَقَالَ رَبُّكُمُ ادْعُونِي أَسْتَجِبْ لَكُمْ ﴾',
      surahAndVerse: 'سورة غافر - آية 60',
      reflection:
          'ما ألهمك الله الدعاء إلا وهو يريد أن يعطيك، فابسط يدك واطرق بابه بيقين ولا تستعجل الإجابة.',
      moodCategory: 'طمأنينة',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/040060.mp3',
    ),
    DailyReflection(
      id: 5,
      verseArabic: '﴿ وَلَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ ﴾',
      surahAndVerse: 'سورة إبراهيم - آية 7',
      reflection:
          'الشكر قيد النعم الموجودة وصيد النعم المفقودة، فكلما حمدت الله على عافيتك ورزقك فاض عليك بمزيد فضله.',
      moodCategory: 'شكر',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/014007.mp3',
    ),
    DailyReflection(
      id: 6,
      verseArabic:
          '﴿ وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا ۝ وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ ﴾',
      surahAndVerse: 'سورة الطلاق - آية 2-3',
      reflection:
          'الأبواب المغلقة في وجهك ليست نهاية الطريق، فتقوى الله تفتح لك مخارج لم تخطر على بالك من أوسع الأبواب.',
      moodCategory: 'تيسير',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/065002.mp3',
    ),
    DailyReflection(
      id: 7,
      verseArabic:
          '﴿ وَاسْتَغْفِرُوا رَبَّكُمْ ثُمَّ تُوبُوا إِلَيْهِ إِنَّ رَبِّي رَحِيمٌ وَدُودٌ ﴾',
      surahAndVerse: 'سورة هود - آية 90',
      reflection:
          'الاستغفار يمحو ما مضى ويصلح ما بقي، وربك الرحيم الودود يفرح بتوبتك وإقبالك عليه أكثر من فرحك بعفوه.',
      moodCategory: 'استغفار',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/011090.mp3',
    ),
  ];

  static DailyReflection getFallbackTodayReflection() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % reflections.length;
    return reflections[index];
  }

  /// المستمع اللحظي لتحديثات الخاطرة اليومية
  static final ValueNotifier<DailyReflection> currentReflectionNotifier =
      ValueNotifier<DailyReflection>(getFallbackTodayReflection());

  /// إرجاع الخاطرة اليومية الحالية (سحابية أو محلية)
  static DailyReflection getTodayReflection() {
    return currentReflectionNotifier.value;
  }

  /// تهيئة المزامنة السحابية للخاطرة اليومية مع Firebase Firestore
  static Future<void> initCloudSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. تحميل الخاطرة المخزنة محلياً إن وجدت لسرعة العرض الفوري
      final cachedJson = prefs.getString(_prefKeyCachedReflection);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        try {
          final Map<String, dynamic> data = jsonDecode(cachedJson);
          currentReflectionNotifier.value = DailyReflection.fromJson(data);
        } catch (_) {}
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
