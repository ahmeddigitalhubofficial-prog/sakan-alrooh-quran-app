// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan/adhan.dart';
import 'package:hijri/hijri_calendar.dart';
import '../services/prayer_service.dart';
import '../services/world_location_service.dart';
import '../services/app_review_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/notification_service.dart';
import '../core/services/analytics_service.dart';
import '../services/in_app_telemetry_service.dart';
import 'sunan_manager.dart';


class IslamicTask {
  final String id;
  String title;
  bool isCompleted;
  final bool isCustom;
  final String category; // 'prayer', 'azkar', 'tasbih', 'quran', 'custom'
  int countTarget;
  int countCurrent;
  String? completionTime;
  bool isLateCompletion;
  int? prayerDuration; // Duration in seconds

  IslamicTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.isCustom = false,
    required this.category,
    this.countTarget = 1,
    this.countCurrent = 0,
    this.completionTime,
    this.isLateCompletion = false,
    this.prayerDuration,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        'isCustom': isCustom,
        'category': category,
        'countTarget': countTarget,
        'countCurrent': countCurrent,
        'completionTime': completionTime,
        'isLateCompletion': isLateCompletion,
        'prayerDuration': prayerDuration,
      };

  factory IslamicTask.fromJson(Map<String, dynamic> json) => IslamicTask(
        id: json['id'],
        title: json['title'],
        isCompleted: json['isCompleted'] ?? false,
        isCustom: json['isCustom'] ?? false,
        category: json['category'] ?? 'custom',
        countTarget: json['countTarget'] ?? 1,
        countCurrent: json['countCurrent'] ?? 0,
        completionTime: json['completionTime'],
        isLateCompletion: json['isLateCompletion'] ?? false,
        prayerDuration: json['prayerDuration'],
      );

  IslamicTask copyWith({
    String? title,
    bool? isCompleted,
    int? countTarget,
    int? countCurrent,
    String? completionTime,
    bool? isLateCompletion,
    int? prayerDuration,
  }) {
    return IslamicTask(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      isCustom: isCustom,
      category: category,
      countTarget: countTarget ?? this.countTarget,
      countCurrent: countCurrent ?? this.countCurrent,
      completionTime: completionTime ?? this.completionTime,
      isLateCompletion: isLateCompletion ?? this.isLateCompletion,
      prayerDuration: prayerDuration ?? this.prayerDuration,
    );
  }
}


class SpiritualTaskManager extends ChangeNotifier {
  static const String _tasksKey = 'islamic_daily_tasks';
  static const String _lastResetKey = 'islamic_tasks_last_reset_date';
  static const String _historyKey = 'islamic_tasks_history';

  List<IslamicTask> _tasks = []; // Tasks for _selectedDate
  List<IslamicTask> _todayTasks = []; // Tasks for today
  Map<String, double> _history = {}; // Date string -> Completion percentage
  final Map<String, List<IslamicTask>> _cachedTasks = {}; // Cache of last 7 days tasks
  Set<String> _fastingHistoryDays = {}; // سجل أيام الصيام الفعلي من متابع الصيام
  int _completedQadaDaysCount = 0; // إجمالي أيام القضاء المقضية من متابع الصيام
  DateTime _selectedDate = DateTime.now();
  Coordinates? _coordinates;

  List<IslamicTask> get tasks => _tasks;
  Map<String, double> get history => _history;
  Map<String, List<IslamicTask>> get cachedTasks => _cachedTasks;
  DateTime get selectedDate => _selectedDate;
  Set<String> get fastingHistoryDays => _fastingHistoryDays;
  int get completedQadaDaysCount => _completedQadaDaysCount;

  bool _isTaskMandatoryForStreak(IslamicTask task) {
    if (task.id == 'ramadan_fasting') return true;
    if (task.category == 'fasting' || task.id.startsWith('fasting')) {
      return false; // سنن الصيام التطوعية لا تخصم من التزام المستخدم إذا لم يصمها
    }
    if (task.category == 'occasional') {
      return false; // المناسبات الموسمية
    }
    return true;
  }

  double _calculateDayPercentage(List<IslamicTask> tasksList) {
    if (tasksList.isEmpty) return 0.0;
    final relevant = tasksList.where((t) => _isTaskMandatoryForStreak(t) || t.isCompleted).toList();
    if (relevant.isEmpty) return 0.0;
    final completedCount = relevant.where((t) => t.isCompleted).length;
    return (completedCount / relevant.length) * 100.0;
  }

  double get completionPercentage {
    return _calculateDayPercentage(_tasks);
  }

  double get todayCompletionPercentage {
    return _calculateDayPercentage(_todayTasks);
  }

  SpiritualTaskManager() {
    loadTasks();
  }

  String _getDateString(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> setSelectedDate(DateTime date) async {
    _selectedDate = date;
    await loadTasksForSelectedDate();
    notifyListeners();
  }

  Future<void> loadTasksForSelectedDate() async {
    _tasks = await _getTasksForDate(_selectedDate);
  }

  Future<void> _loadCoordinates(SharedPreferences prefs) async {
    _coordinates = await WorldLocationService.getSavedCoordinates();
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load coordinates
    await _loadCoordinates(prefs);

    // Load actual fasting history days from SharedPreferences
    final fastingHistory = prefs.getStringList('fasting_history_days') ?? [];
    _fastingHistoryDays = Set<String>.from(fastingHistory);
    _completedQadaDaysCount = prefs.getInt('fasting_qada_completed') ?? 0;

    // استرجاع كافة أيام الصيام الموثقة تاريخياً في أي يوم داخل islamic_tasks_*
    try {
      final allKeys = prefs.getKeys();
      for (final key in allKeys) {
        if (key.startsWith('islamic_tasks_')) {
          final dateStr = key.replaceFirst('islamic_tasks_', '');
          final jsonStr = prefs.getString(key);
          if (jsonStr != null) {
            final List<dynamic> decoded = json.decode(jsonStr);
            final hasCompletedFasting = decoded.any((item) =>
                (item['category'] == 'fasting' ||
                    (item['id'] is String && (item['id'] as String).startsWith('fasting'))) &&
                item['isCompleted'] == true);
            if (hasCompletedFasting) {
              _fastingHistoryDays.add(dateStr);
            }
          }
        }
      }
    } catch (_) {}

    // Load history
    final historyJson = prefs.getString(_historyKey);
    if (historyJson != null) {
      try {
        _history = Map<String, double>.from(json.decode(historyJson));
      } catch (e) {
        _history = {};
      }
    }

    // Load today's tasks
    _todayTasks = await _getTasksForDate(DateTime.now());

    // Reset selected date to today initially
    _selectedDate = DateTime.now();
    _tasks = List.from(_todayTasks);

    // Load last 7 days tasks in cache for stats
    _cachedTasks.clear();
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = _getDateString(date);
      _cachedTasks[dateStr] = await _getTasksForDate(date);
    }

    notifyListeners();
  }

  Future<List<IslamicTask>> _getTasksForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = _getDateString(date);
    final dateKey = 'islamic_tasks_$dateStr';
    final hijriOffset = prefs.getInt('hijri_offset') ?? 0;

    final defaultDynamicTasks =
        _getDefaultTasksListForDate(date, hijriOffset: hijriOffset);

    final tasksJson = prefs.getString(dateKey);
    if (tasksJson != null) {
      try {
        final List<dynamic> decoded = json.decode(tasksJson);
        final loadedTasks =
            decoded.map((item) => IslamicTask.fromJson(item)).toList();

        // دمج المهام السنية والدورية الجديدة إذا لم تكن موجودة وتحديث العناوين القديمة تلقائياً
        for (var dt in defaultDynamicTasks) {
          final existingIndex = loadedTasks.indexWhere((t) => t.id == dt.id);
          if (existingIndex == -1) {
            loadedTasks.add(dt);
          } else {
            // تحديث العنوان تلقائياً ليعكس أحدث التعديلات الفقهية
            loadedTasks[existingIndex].title = dt.title;
            if (dt.id == 'daily_tasbih') {
              loadedTasks[existingIndex].countTarget = 33;
            }
          }
        }
        // مزامنة مهام الصيام مع سجل الصيام الفعلي
        if (_fastingHistoryDays.contains(dateStr)) {
          final fastingTasks = loadedTasks.where((t) => t.category == 'fasting' || t.id.startsWith('fasting'));
          if (fastingTasks.isNotEmpty) {
            for (var ft in fastingTasks) {
              ft.isCompleted = true;
            }
          } else {
            loadedTasks.add(
              IslamicTask(
                id: 'fasting_registered_$dateStr',
                title: 'صيام اليوم (موثق في سجل الصيام) 🌙',
                category: 'fasting',
                isCompleted: true,
              ),
            );
          }
        }

        // ترتيب المهام دائماً طبقاً للترتيب الشرعي المعتمد
        loadedTasks.sort((a, b) {
          final idxA = defaultDynamicTasks.indexWhere((dt) => dt.id == a.id);
          final idxB = defaultDynamicTasks.indexWhere((dt) => dt.id == b.id);
          if (idxA != -1 && idxB != -1) return idxA.compareTo(idxB);
          if (idxA != -1) return -1;
          if (idxB != -1) return 1;
          return 0;
        });
        return loadedTasks;
      } catch (_) {}
    }

    // Initialize default tasks if no data exists
    final defaultJson =
        json.encode(defaultDynamicTasks.map((t) => t.toJson()).toList());
    await prefs.setString(dateKey, defaultJson);
    return defaultDynamicTasks;
  }

  List<IslamicTask> _getDefaultTasksListForDate(DateTime date,
      {int hijriOffset = 0}) {
    final tasks = <IslamicTask>[
      // ==================== الصلوات الخمس والسنن المؤكدة ====================
      IslamicTask(id: 'fajr', title: 'صلاة الفجر في وقتها 🕌', category: 'prayer'),
      IslamicTask(id: 'dhuhr', title: 'صلاة الظهر 🕌', category: 'prayer'),
      IslamicTask(id: 'asr', title: 'صلاة العصر 🕌', category: 'prayer'),
      IslamicTask(id: 'maghrib', title: 'صلاة المغرب 🕌', category: 'prayer'),
      IslamicTask(id: 'isha', title: 'صلاة العشاء 🕌', category: 'prayer'),
      IslamicTask(id: 'witr_sunan', title: 'قيام الليل وصلاة الوتر 🌙', category: 'prayer'),

      // ==================== الأذكار والورد القرآني ====================
      IslamicTask(id: 'azkar_sabah', title: 'أذكار الصباح 🌅', category: 'azkar'),
      IslamicTask(id: 'azkar_masaa', title: 'أذكار المساء 🌆', category: 'azkar'),
      IslamicTask(
        id: 'daily_tasbih',
        title: 'ورد الاستغفار والتسبيح (33 مرة) 📿',
        category: 'tasbih',
        countTarget: 33,
      ),
      IslamicTask(
        id: 'quran_ward',
        title: 'قراءة الورد القرآني اليومي 📖',
        category: 'quran',
      ),
    ];

    // حساب التاريخ الهجري لليوم المحدد مع مراعاة التعديل اليدوي
    final targetDate = date.add(Duration(days: hijriOffset));
    final hijri = HijriCalendar.fromDate(targetDate);
    final hDay = hijri.hDay;
    final hMonth = hijri.hMonth;

    // ==================== 1. صيام النافلة والأيام البيض والإثنين والخميس ====================
    if (date.weekday == DateTime.monday) {
      tasks.add(
        IslamicTask(
          id: 'fasting_monday',
          title: 'صيام سنة يوم الإثنين 🌙',
          category: 'fasting',
        ),
      );
    } else if (date.weekday == DateTime.thursday) {
      tasks.add(
        IslamicTask(
          id: 'fasting_thursday',
          title: 'صيام سنة يوم الخميس 🌙',
          category: 'fasting',
        ),
      );
    }

    // صيام الأيام البيض (13 و 14 و 15 من الشهر الهجري)
    if ((hDay == 13 && hMonth != 12) || hDay == 14 || hDay == 15) {
      tasks.add(
        IslamicTask(
          id: 'fasting_white_days',
          title: 'صيام اليوم الأبيض ($hDay من الشهر الهجري) 🌕',
          category: 'fasting',
        ),
      );
    }

    // التحقق مما إذا كان هذا اليوم موثقاً كصيام في سجل الصيام (سواء نافلة أو قضاء)
    final dateStr = _getDateString(date);
    if (_fastingHistoryDays.contains(dateStr)) {
      final hasFastingTask = tasks.any((t) => t.category == 'fasting' || t.id.startsWith('fasting'));
      if (!hasFastingTask) {
        tasks.add(
          IslamicTask(
            id: 'fasting_registered_$dateStr',
            title: 'صيام اليوم (موثق في سجل الصيام) 🌙',
            category: 'fasting',
            isCompleted: true,
          ),
        );
      }
    }

    // ==================== 2. سنن وآداب يوم الجمعة المبارك ====================
    if (date.weekday == DateTime.friday) {
      tasks.add(
        IslamicTask(
          id: 'friday_kahf',
          title: 'قراءة سورة الكهف يوم الجمعة 📖',
          category: 'quran',
        ),
      );
      tasks.add(
        IslamicTask(
          id: 'friday_salawat',
          title: 'إكثار الصلاة على النبي ﷺ (100 مرة) 🌺',
          category: 'azkar',
          countTarget: 100,
        ),
      );
      tasks.add(
        IslamicTask(
          id: 'friday_duaa',
          title: 'تحري ساعة الإجابة قبل مغرب الجمعة 🤲',
          category: 'occasional',
        ),
      );
      tasks.add(
        IslamicTask(
          id: 'friday_ghusl',
          title: 'غُسل الجمعة والتبكير إلى المسجد 🕌',
          category: 'occasional',
        ),
      );
      tasks.add(
        IslamicTask(
          id: 'friday_sadaqah',
          title: 'صدقة يوم الجمعة وإطعام مسكين 🤝',
          category: 'occasional',
        ),
      );
    }

    // ==================== 3. المناسبات والمواسم المباركة ====================
    // شهر رمضان المبارك (الشهر 9)
    if (hMonth == 9) {
      tasks.add(
        IslamicTask(
          id: 'ramadan_fasting',
          title: 'صيام يوم $hDay من شهر رمضان المبارك 🌙',
          category: 'fasting',
        ),
      );
      tasks.add(
        IslamicTask(
          id: 'ramadan_taraweeh',
          title: 'صلاة التراويح والقيام 🕌',
          category: 'prayer',
        ),
      );
      tasks.add(
        IslamicTask(
          id: 'ramadan_sadaqah',
          title: 'إخراج صدقة اليوم 🤝',
          category: 'occasional',
        ),
      );
    }

    // العشر الأوائل من ذي الحجة (الشهر 12 من 1 إلى 9)
    if (hMonth == 12 && hDay >= 1 && hDay <= 9) {
      if (hDay == 9) {
        tasks.add(
          IslamicTask(
            id: 'arafah_fasting',
            title: 'صيام يوم عرفة (يكفر سنة ماضية وباقية) 🤲',
            category: 'fasting',
          ),
        );
        tasks.add(
          IslamicTask(
            id: 'arafah_duaa',
            title: 'التكبير والدعاء في يوم عرفة 🕋',
            category: 'occasional',
          ),
        );
      } else {
        tasks.add(
          IslamicTask(
            id: 'dhulhijjah_fasting',
            title: 'صيام يوم $hDay من عشر ذي الحجة 🕋',
            category: 'fasting',
          ),
        );
        tasks.add(
          IslamicTask(
            id: 'dhulhijjah_takbeer',
            title: 'إكثار التكبير والتحميد والتهليل 📿',
            category: 'azkar',
          ),
        );
      }
    }

    // يوم عاشوراء وتاسوعاء (محرم - الشهر 1 - يوم 9 و 10)
    if (hMonth == 1 && (hDay == 9 || hDay == 10)) {
      final name = hDay == 9 ? 'تاسوعاء' : 'عاشوراء';
      tasks.add(
        IslamicTask(
          id: 'ashura_fasting_$hDay',
          title: 'صيام يوم $name ($hDay محرم) 🌙',
          category: 'fasting',
        ),
      );
    }

    // صيام الست من شوال (الشهر 10 - من يوم 2 إلى 30)
    if (hMonth == 10 && hDay >= 2) {
      tasks.add(
        IslamicTask(
          id: 'shawwal_fasting',
          title: 'صيام الست من شوال 🌟',
          category: 'fasting',
        ),
      );
    }

    return tasks;
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = _getDateString(_selectedDate);
    final tasksJson = json.encode(_tasks.map((t) => t.toJson()).toList());
    
    // Save to date-specific key
    await prefs.setString('islamic_tasks_$dateStr', tasksJson);
    _cachedTasks[dateStr] = List.from(_tasks);

    // If selected date is today, also save to today cache & legacy keys
    final todayStr = _getDateString(DateTime.now());
    if (dateStr == todayStr) {
      _todayTasks = List.from(_tasks);
      await prefs.setString(_tasksKey, tasksJson);
      await prefs.setString(_lastResetKey, todayStr);
    }

    // Update history completion percentage
    int completed = _tasks.where((t) => t.isCompleted).length;
    double percent = _tasks.isEmpty ? 0.0 : (completed / _tasks.length) * 100;
    _history[dateStr] = percent;
    await prefs.setString(_historyKey, json.encode(_history));
    CloudSyncService.autoSyncOnDataChange();
  }

  bool isTaskEnabled(String taskId, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target.isAfter(today)) {
      return false; // Future dates are disabled
    }
    if (target.isBefore(today)) {
      return true; // Past dates are fully editable
    }

    // Today validation (check prayer times)
    if (taskId != 'fajr' && taskId != 'dhuhr' && taskId != 'asr' && taskId != 'maghrib' && taskId != 'isha') {
      return true; // Non-prayer tasks are always editable
    }

    if (_coordinates == null) {
      return true; // Fallback
    }

    final prayerTimes = PrayerService.getPrayerTimes(_coordinates!, now);
    switch (taskId) {
      case 'fajr':
        return now.isAfter(prayerTimes.fajr);
      case 'dhuhr':
        return now.isAfter(prayerTimes.dhuhr);
      case 'asr':
        return now.isAfter(prayerTimes.asr);
      case 'maghrib':
        return now.isAfter(prayerTimes.maghrib);
      case 'isha':
        return now.isAfter(prayerTimes.isha);
      default:
        return true;
    }
  }

  DateTime? getPrayerTime(String prayerId, DateTime date) {
    if (_coordinates == null) return null;
    final prayerTimes = PrayerService.getPrayerTimes(_coordinates!, date);
    switch (prayerId) {
      case 'fajr':
        return prayerTimes.fajr;
      case 'dhuhr':
        return prayerTimes.dhuhr;
      case 'asr':
        return prayerTimes.asr;
      case 'maghrib':
        return prayerTimes.maghrib;
      case 'isha':
        return prayerTimes.isha;
      default:
        return null;
    }
  }

  static String formatTaskDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// تسجيل الصلاة مباشرة من الخلفية (سواء من الإشعارات أو عند استعادة التطبيق)
  static Future<bool> recordPrayerInBackground(
    String prayerId, {
    DateTime? date,
    int? duration,
    bool isLate = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final targetDate = date ?? DateTime.now();
    final dateStr = formatTaskDate(targetDate);
    final todayStr = formatTaskDate(DateTime.now());
    final dateKey = 'islamic_tasks_$dateStr';

    String? tasksJson = prefs.getString(dateKey);
    List<dynamic> list = [];
    if (tasksJson != null) {
      try {
        list = json.decode(tasksJson);
      } catch (_) {}
    }

    if (list.isEmpty) {
      final defaultList = [
        {'id': 'fajr', 'title': 'صلاة الفجر في وقتها 🕌', 'category': 'prayer', 'isCompleted': false},
        {'id': 'dhuhr', 'title': 'صلاة الظهر 🕌', 'category': 'prayer', 'isCompleted': false},
        {'id': 'asr', 'title': 'صلاة العصر 🕌', 'category': 'prayer', 'isCompleted': false},
        {'id': 'maghrib', 'title': 'صلاة المغرب 🕌', 'category': 'prayer', 'isCompleted': false},
        {'id': 'isha', 'title': 'صلاة العشاء 🕌', 'category': 'prayer', 'isCompleted': false},
      ];
      list = defaultList;
    }

    bool found = false;
    for (var item in list) {
      if (item is Map && item['id'] == prayerId) {
        item['isCompleted'] = true;
        item['completionTime'] = DateTime.now().toIso8601String();
        item['isLateCompletion'] = isLate;
        item['prayerDuration'] = duration ?? 300;
        found = true;
        break;
      }
    }

    if (!found) {
      list.add({
        'id': prayerId,
        'title': 'صلاة $prayerId',
        'category': 'prayer',
        'isCompleted': true,
        'completionTime': DateTime.now().toIso8601String(),
        'isLateCompletion': isLate,
        'prayerDuration': duration ?? 300,
      });
      found = true;
    }

    if (found) {
      final updatedJson = json.encode(list);
      await prefs.setString(dateKey, updatedJson);
      if (dateStr == todayStr) {
        await prefs.setString('islamic_daily_tasks', updatedJson);
        await prefs.setString('last_reset_date', todayStr);
      }

      int currentPoints = prefs.getInt('user_hasanat_points') ?? 150;
      await prefs.setInt('user_hasanat_points', currentPoints + 50);

      await prefs.setBool('prayer_timer_active', false);
      await prefs.remove('prayer_timer_start_ms');
      await prefs.remove('prayer_timer_id');

      NotificationService().cancelTodayWardNotification(prayerId);
      InAppTelemetryService.logFeaturePulse('prayer_recorded', metadata: {
        'prayerId': prayerId,
        'mode': 'background_or_action',
      });
      return true;
    }
    return false;
  }

  Future<bool> markTodayPrayerAsCompleted(String prayerId, {bool isLate = false, int? duration}) async {
    return markPrayerAsCompletedForDate(prayerId, DateTime.now(), isLate: isLate, duration: duration);
  }

  Future<bool> markPrayerAsCompletedForDate(
    String prayerId,
    DateTime date, {
    bool isLate = false,
    int? duration,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = _getDateString(date);
    final todayStr = _getDateString(DateTime.now());

    // Explicitly read and modify tasks list for the given date
    final targetTasks = await _getTasksForDate(date);
    final index = targetTasks.indexWhere((t) => t.id == prayerId);
    if (index != -1) {
      final task = targetTasks[index];
      if (task.isCompleted) {
        return false; // Already marked
      }
      task.isCompleted = true;
      task.completionTime = DateTime.now().toIso8601String();
      task.isLateCompletion = isLate;
      task.prayerDuration = duration;

      final tasksJson = json.encode(targetTasks.map((t) => t.toJson()).toList());
      await prefs.setString('islamic_tasks_$dateStr', tasksJson);
      _cachedTasks[dateStr] = targetTasks;

      // Save to legacy keys if date is today
      if (dateStr == todayStr) {
        _todayTasks = targetTasks;
        await prefs.setString(_tasksKey, tasksJson);
        await prefs.setString(_lastResetKey, todayStr);
      }

      // If active selection is target date, sync UI list
      if (_getDateString(_selectedDate) == dateStr) {
        _tasks = targetTasks;
      }

      // Update history completion percentage
      int completed = targetTasks.where((t) => t.isCompleted).length;
      double percent = targetTasks.isEmpty ? 0.0 : (completed / targetTasks.length) * 100;
      _history[dateStr] = percent;
      await prefs.setString(_historyKey, json.encode(_history));

      // منح نقاط حسنات لصلاة الفريضة
      _awardHasanatPoints(50);
      NotificationService().cancelTodayWardNotification(prayerId);

      AnalyticsService().logTaskCompleted(prayerId, 'prayer');
      InAppTelemetryService.logFeaturePulse('prayer_recorded', metadata: {
        'prayerId': prayerId,
        'mode': 'app_interactive',
        'isLate': isLate,
        'duration': duration,
      });
      AppReviewService.checkAndPromptAutoReview();

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> _awardHasanatPoints(int points) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int currentPoints = prefs.getInt('user_hasanat_points') ?? 150;
      await prefs.setInt('user_hasanat_points', currentPoints + points);
    } catch (_) {}
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      task.isCompleted = !task.isCompleted;
      if (task.isCompleted) {
        if (task.countTarget > 1) {
          task.countCurrent = task.countTarget;
        }
        task.completionTime = DateTime.now().toIso8601String();
        task.isLateCompletion = false; // Regular manual toggle
        
        // إلغاء إشعار الورد فوراً لليوم الحالي
        NotificationService().cancelTodayWardNotification(id);
        
        // مزامنة الصيام تلقائياً مع السجل
        _syncFastingWithHistory(task, true);

        // منح نقاط حسنات حسب تصنيف المهمة
        int points = 30;
        if (task.category == 'prayer') points = 50;
        if (task.category == 'azkar') points = 40;
        if (task.category == 'quran') points = 60;
        if (task.category == 'fasting') points = 100;
        _awardHasanatPoints(points);

        AppReviewService.checkAndPromptAutoReview();
      } else {
        if (task.countTarget > 1) {
          task.countCurrent = 0;
        }
        task.completionTime = null;
        task.isLateCompletion = false;
        
        // مزامنة الصيام تلقائياً مع السجل
        _syncFastingWithHistory(task, false);

        // إعادة جدولة التذكيرات لليوم إذا ألغى المستخدم الإنجاز قبل الموعد
        NotificationService().scheduleDailyReminders();
      }
      saveTasks();
      notifyListeners();
    }
  }

  /// تعيين حالة المهمة كمنجزة أو غير منجزة بشكل صريح ومباشر مع دعم تحديد عدد الركعات أو التكرار
  void setTaskCompleted(String id, bool completed, {int? customCount}) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      if (task.isCompleted == completed && (customCount == null || task.countCurrent == customCount)) {
        return;
      }
      task.isCompleted = completed;
      if (completed) {
        if (customCount != null) {
          task.countCurrent = customCount;
        } else if (task.countTarget > 1) {
          task.countCurrent = task.countTarget;
        }
        task.completionTime = DateTime.now().toIso8601String();
        task.isLateCompletion = false;
        NotificationService().cancelTodayWardNotification(id);
        _syncFastingWithHistory(task, true);
        int points = 30;
        if (task.category == 'prayer') points = 50;
        if (task.category == 'azkar') points = 40;
        if (task.category == 'quran') points = 60;
        if (task.category == 'fasting') points = 100;
        _awardHasanatPoints(points);
        AppReviewService.checkAndPromptAutoReview();
      } else {
        if (task.countTarget > 1) {
          task.countCurrent = 0;
        }
        task.completionTime = null;
        task.isLateCompletion = false;
        _syncFastingWithHistory(task, false);
      }
      saveTasks();
      notifyListeners();
    }
  }

  Future<void> _syncFastingWithHistory(IslamicTask task, bool isFasting) async {
    if (task.category == 'fasting' || task.id.startsWith('fasting')) {
      final prefs = await SharedPreferences.getInstance();
      final targetDateStr = _getDateString(_selectedDate);
      final history = prefs.getStringList('fasting_history_days') ?? [];
      final setHistory = history.toSet();
      if (isFasting) {
        setHistory.add(targetDateStr);
      } else {
        setHistory.remove(targetDateStr);
      }
      _fastingHistoryDays = setHistory;
      await prefs.setStringList('fasting_history_days', setHistory.toList());
      CloudSyncService.autoSyncOnDataChange();
      notifyListeners();
    }
  }

  /// تحديث سجل الصيام فوراً عند التعديل من شاشة متابع الصيام
  void updateFastingHistory(List<String> daysList, {int? qadaCompleted}) async {
    _fastingHistoryDays = Set<String>.from(daysList);
    if (qadaCompleted != null) {
      _completedQadaDaysCount = qadaCompleted;
    } else {
      final prefs = await SharedPreferences.getInstance();
      _completedQadaDaysCount = prefs.getInt('fasting_qada_completed') ?? 0;
    }
    notifyListeners();
  }

  void updateTaskProgress(String id, int current) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      // تحديث العداد دون تصفير الإنجاز إذا كانت المهمة قد اكتملت بالفعل اليوم
      if (current > task.countCurrent || !task.isCompleted) {
        task.countCurrent = current;
      }
      if (task.countCurrent >= task.countTarget) {
        if (!task.isCompleted) {
          task.isCompleted = true;
          task.completionTime = DateTime.now().toIso8601String();
          NotificationService().cancelTodayWardNotification(id);
          _awardHasanatPoints(40);
        }
      }
      saveTasks();
      notifyListeners();
    }
  }

  void addTask(String title, String category, {int countTarget = 1}) {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final newTask = IslamicTask(
      id: id,
      title: title,
      isCustom: true,
      category: category,
      countTarget: countTarget,
    );
    _tasks.add(newTask);
    saveTasks();
    notifyListeners();
  }

  void updateTask(String id, String newTitle, {int countTarget = 1}) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].title = newTitle;
      _tasks[index].countTarget = countTarget;
      if (_tasks[index].countCurrent >= countTarget) {
        _tasks[index].isCompleted = true;
      } else {
        _tasks[index].isCompleted = false;
      }
      saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    saveTasks();
    notifyListeners();
  }

  // Statistics Getters
  double get averageCommitment {
    double total = 0.0;
    int activeDays = 0;
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = _getDateString(date);
      if (dateStr == _getDateString(DateTime.now())) {
        total += todayCompletionPercentage;
        activeDays++;
      } else {
        final cachedList = _cachedTasks[dateStr];
        if (cachedList != null && cachedList.isNotEmpty) {
          final completed = cachedList.where((t) => t.isCompleted).length;
          if (completed > 0 || _history.containsKey(dateStr)) {
            total += _calculateDayPercentage(cachedList);
            activeDays++;
          }
        } else if (_history.containsKey(dateStr)) {
          total += _history[dateStr] ?? 0.0;
          activeDays++;
        }
      }
    }
    return activeDays > 0 ? (total / activeDays) : todayCompletionPercentage;
  }

  /// إجمالي الفروض الخمسة المكتملة في آخر 7 أيام (الفجر، الظهر، العصر، المغرب، العشاء)
  int get completedPrayersLast7Days {
    int count = 0;
    const fardIds = {'fajr', 'dhuhr', 'asr', 'maghrib', 'isha'};
    _cachedTasks.forEach((dateStr, tasksList) {
      count += tasksList.where((t) => fardIds.contains(t.id) && t.isCompleted).length;
    });
    return count;
  }

  /// إجمالي الركعات (الفرض + السنن الرواتب من قصر الجنة + قيام الليل والوتر)
  int get totalRakahsLast7Days {
    int total = 0;
    final fardRakahsMap = {
      'fajr': 2,
      'dhuhr': 4,
      'asr': 4,
      'maghrib': 3,
      'isha': 4,
    };

    _cachedTasks.forEach((dateStr, tasksList) {
      for (var t in tasksList) {
        if (t.isCompleted) {
          if (fardRakahsMap.containsKey(t.id)) {
            total += fardRakahsMap[t.id]!;
          } else if (t.id == 'witr_sunan') {
            total += (t.countCurrent > 0) ? t.countCurrent : 3;
          }
        }
      }
    });

    // إضافة ركعات السنن الرواتب المكتملة من قصر الجنة
    total += SunanManager().totalCompletedRakats;

    return total;
  }

  /// إجمالي الأذكار والأوراد المكتملة في آخر 7 أيام (صباح، مساء، ورد قرآني، استغفار وتسبيح)
  int get completedAzkarLast7Days {
    int count = 0;
    _cachedTasks.forEach((dateStr, tasksList) {
      count += tasksList.where((t) => (t.category == 'azkar' || t.category == 'tasbih' || t.category == 'quran') && t.isCompleted).length;
    });
    return count;
  }

  /// إجمالي أيام الصيام الموثقة في السجل (سجل الصيام)
  int get totalFastingDays {
    return _fastingHistoryDays.length;
  }

  int get currentStreak {
    int streak = 0;
    
    // Check from yesterday backwards
    DateTime checkDate = DateTime.now().subtract(const Duration(days: 1));
    while (true) {
      final checkDateStr = _getDateString(checkDate);
      double percent = 0.0;
      final cachedList = _cachedTasks[checkDateStr];
      if (cachedList != null && cachedList.isNotEmpty) {
        percent = _calculateDayPercentage(cachedList);
      } else {
        percent = _history[checkDateStr] ?? 0.0;
      }

      if (percent >= 100.0) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    // If today is 100%, add 1
    if (todayCompletionPercentage >= 100.0) {
      streak++;
    }
    
    return streak;
  }
}
