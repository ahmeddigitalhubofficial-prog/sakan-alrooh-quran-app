import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/in_app_telemetry_service.dart';

class KhatmaPlan {
  final String id;
  final String title;
  final int totalDays;
  final DateTime startDate;
  int lastReadPage; // 0 to 604
  int streakDays;
  DateTime? lastReadDate;

  KhatmaPlan({
    required this.id,
    required this.title,
    required this.totalDays,
    required this.startDate,
    this.lastReadPage = 0,
    this.streakDays = 0,
    this.lastReadDate,
  });

  /// The daily page reading target.
  double get pagesPerDay => 604.0 / totalDays;

  /// Percent progress of the Khatma (0.0 to 100.0).
  double get progressPercentage => (lastReadPage / 604.0) * 100.0;

  /// Remaining pages to read.
  int get remainingPages => 604 - lastReadPage;

  /// Estimated days remaining.
  int get remainingDaysEstimate => pagesPerDay > 0 ? (remainingPages / pagesPerDay).ceil() : 0;

  /// Map representations for JSON storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'totalDays': totalDays,
        'startDate': startDate.toIso8601String(),
        'lastReadPage': lastReadPage,
        'streakDays': streakDays,
        'lastReadDate': lastReadDate?.toIso8601String(),
      };

  factory KhatmaPlan.fromJson(Map<String, dynamic> json) => KhatmaPlan(
        id: json['id'] as String,
        title: json['title'] as String,
        totalDays: json['totalDays'] as int,
        startDate: DateTime.parse(json['startDate'] as String),
        lastReadPage: json['lastReadPage'] as int? ?? 0,
        streakDays: json['streakDays'] as int? ?? 0,
        lastReadDate: json['lastReadDate'] != null ? DateTime.parse(json['lastReadDate'] as String) : null,
      );
}

class KhatmaService {
  static const String _khatmaKey = 'active_khatma_plan';

  /// Saves the active Khatma plan to SharedPreferences.
  static Future<void> savePlan(KhatmaPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(plan.toJson());
    await prefs.setString(_khatmaKey, jsonStr);
  }

  /// Loads the active Khatma plan, returning null if none exists.
  static Future<KhatmaPlan?> loadPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_khatmaKey);
    if (jsonStr == null) return null;
    try {
      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      return KhatmaPlan.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  /// Clears the active plan.
  static Future<void> clearPlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_khatmaKey);
  }

  /// Logs reading progress (e.g. read up to page [pageNumber]).
  /// Dynamically computes and updates reading streaks.
  static Future<KhatmaPlan> logProgress(KhatmaPlan plan, int pageNumber) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Clamp pages between 0 and 604
    final targetPage = pageNumber.clamp(0, 604);
    
    if (targetPage > plan.lastReadPage) {
      plan.lastReadPage = targetPage;
      
      // Streak Calculation
      if (plan.lastReadDate != null) {
        final lastDate = DateTime(
          plan.lastReadDate!.year,
          plan.lastReadDate!.month,
          plan.lastReadDate!.day,
        );
        
        final differenceInDays = today.difference(lastDate).inDays;
        
        if (differenceInDays == 1) {
          // Consecutive day: increment streak
          plan.streakDays += 1;
        } else if (differenceInDays > 1) {
          // Skipped a day: reset streak to 1
          plan.streakDays = 1;
        }
        // If difference is 0 (same day), streak remains the same
      } else {
        // First time reading
        plan.streakDays = 1;
      }
      
      plan.lastReadDate = now;
      await savePlan(plan);
    }
    
    return plan;
  }

  /// Checks if the streak was broken due to inactivity (over 1 day since last reading).
  /// Updates and returns the plan with adjusted streak if needed.
  static Future<KhatmaPlan?> checkAndResetStreak(KhatmaPlan plan) async {
    if (plan.lastReadDate == null) return plan;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      plan.lastReadDate!.year,
      plan.lastReadDate!.month,
      plan.lastReadDate!.day,
    );
    
    final differenceInDays = today.difference(lastDate).inDays;
    
    if (differenceInDays > 1) {
      plan.streakDays = 0;
      await savePlan(plan);
    }
    
    return plan;
  }

  static const String _sharedKhatmaKey = 'active_shared_khatma_plan';

  /// Saves the active Shared Khatma plan to SharedPreferences and syncs to Firestore cloud.
  static Future<void> saveSharedPlan(SharedKhatmaPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(plan.toJson());
    await prefs.setString(_sharedKhatmaKey, jsonStr);

    // Sync to Firestore Cloud in background
    try {
      await FirebaseFirestore.instance
          .collection('shared_khatmas')
          .doc(plan.id)
          .set(plan.toJson(), SetOptions(merge: true));
      InAppTelemetryService.logFeaturePulse('family_khatmah_created', metadata: {
        'room': plan.id,
        'title': plan.title,
      });
    } catch (e) {
      debugPrint('Firestore Shared Khatma sync bypass: $e');
    }
  }

  /// Loads the active Shared Khatma plan, returning null if none exists.
  static Future<SharedKhatmaPlan?> loadSharedPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_sharedKhatmaKey);
    if (jsonStr == null) return null;
    try {
      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      final localPlan = SharedKhatmaPlan.fromJson(jsonMap);

      // Attempt background cloud refresh if connected
      try {
        final doc = await FirebaseFirestore.instance
            .collection('shared_khatmas')
            .doc(localPlan.id)
            .get();
        if (doc.exists && doc.data() != null) {
          final cloudPlan = SharedKhatmaPlan.fromJson(doc.data()!);
          await prefs.setString(_sharedKhatmaKey, jsonEncode(cloudPlan.toJson()));
          return cloudPlan;
        }
      } catch (_) {}

      return localPlan;
    } catch (_) {
      return null;
    }
  }

  /// Fetches a shared Khatma by its Room ID from Firestore cloud.
  static Future<SharedKhatmaPlan?> fetchSharedPlanFromCloud(String khatmaId) async {
    try {
      final cleanId = khatmaId.trim();
      final doc = await FirebaseFirestore.instance
          .collection('shared_khatmas')
          .doc(cleanId)
          .get();
      if (doc.exists && doc.data() != null) {
        final cloudPlan = SharedKhatmaPlan.fromJson(doc.data()!);
        await saveSharedPlan(cloudPlan);
        InAppTelemetryService.logFeaturePulse('family_khatmah_joined', metadata: {
          'room': cleanId,
        });
        return cloudPlan;
      }
    } catch (e) {
      debugPrint('Error fetching cloud khatma: $e');
    }
    return null;
  }

  /// Clears the active Shared Khatma plan.
  static Future<void> clearSharedPlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sharedKhatmaKey);
  }

  /// Updates status/reader of a specific Juz in the active Shared Khatma.
  static Future<SharedKhatmaPlan> updateSharedJuz({
    required SharedKhatmaPlan plan,
    required int juzNumber,
    required String readerName,
    required String status,
  }) async {
    final index = plan.juzList.indexWhere((j) => j.juzNumber == juzNumber);
    if (index != -1) {
      plan.juzList[index].readerName = readerName;
      plan.juzList[index].status = status;
      if (status == 'completed') {
        plan.juzList[index].completionDate = DateTime.now();
      } else {
        plan.juzList[index].completionDate = null;
      }
      await saveSharedPlan(plan);
    }
    return plan;
  }
}

class SharedKhatmaJuz {
  final int juzNumber;
  String readerName;
  String status; // 'free', 'reading', 'completed'
  DateTime? completionDate;

  SharedKhatmaJuz({
    required this.juzNumber,
    this.readerName = '',
    this.status = 'free',
    this.completionDate,
  });

  Map<String, dynamic> toJson() => {
        'juzNumber': juzNumber,
        'readerName': readerName,
        'status': status,
        'completionDate': completionDate?.toIso8601String(),
      };

  factory SharedKhatmaJuz.fromJson(Map<String, dynamic> json) => SharedKhatmaJuz(
        juzNumber: json['juzNumber'] as int,
        readerName: json['readerName'] as String? ?? '',
        status: json['status'] as String? ?? 'free',
        completionDate: json['completionDate'] != null
            ? DateTime.parse(json['completionDate'] as String)
            : null,
      );
}

class SharedKhatmaPlan {
  final String id;
  final String title;
  final DateTime startDate;
  final List<SharedKhatmaJuz> juzList;

  SharedKhatmaPlan({
    required this.id,
    required this.title,
    required this.startDate,
    required this.juzList,
  });

  int get completedJuzCount => juzList.where((j) => j.status == 'completed').length;
  int get readingJuzCount => juzList.where((j) => j.status == 'reading').length;
  int get freeJuzCount => juzList.where((j) => j.status == 'free').length;

  double get progressPercentage => (completedJuzCount / 30.0) * 100.0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'startDate': startDate.toIso8601String(),
        'juzList': juzList.map((j) => j.toJson()).toList(),
      };

  factory SharedKhatmaPlan.fromJson(Map<String, dynamic> json) {
    var juzListJson = json['juzList'] as List? ?? [];
    List<SharedKhatmaJuz> juzList = juzListJson
        .map((j) => SharedKhatmaJuz.fromJson(j as Map<String, dynamic>))
        .toList();
    if (juzList.isEmpty) {
      juzList = List.generate(
        30,
        (index) => SharedKhatmaJuz(juzNumber: index + 1),
      );
    }
    return SharedKhatmaPlan(
      id: json['id'] as String,
      title: json['title'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      juzList: juzList,
    );
  }
}
