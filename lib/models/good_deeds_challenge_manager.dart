import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_manager.dart';

class DeedQuest {
  final String id;
  final String title;
  final String description;
  final int pointsReward;
  final String iconName;
  bool isCompleted;

  DeedQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsReward,
    required this.iconName,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'pointsReward': pointsReward,
        'iconName': iconName,
        'isCompleted': isCompleted,
      };

  factory DeedQuest.fromJson(Map<String, dynamic> json) => DeedQuest(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        pointsReward: json['pointsReward'] ?? 50,
        iconName: json['iconName'] ?? 'star',
        isCompleted: json['isCompleted'] ?? false,
      );
}

class GoodDeedsChallengeManager extends ChangeNotifier {
  static final GoodDeedsChallengeManager _instance = GoodDeedsChallengeManager._internal();
  factory GoodDeedsChallengeManager() => _instance;
  GoodDeedsChallengeManager._internal() {
    _loadDailyQuests();
  }

  int _streakDays = 1;
  int get streakDays => _streakDays;

  List<DeedQuest> _quests = [];
  List<DeedQuest> get quests => _quests;

  int get completedCount => _quests.where((q) => q.isCompleted).length;
  double get dailyProgress => _quests.isEmpty ? 0 : completedCount / _quests.length;

  Future<void> _loadDailyQuests() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString('good_deeds_date');
    _streakDays = prefs.getInt('good_deeds_streak') ?? 1;

    final defaultQuests = [
      DeedQuest(
        id: 'fajr_prayer',
        title: 'صلاة الفجر في وقتها 🌅',
        description: 'أداء صلاة الفجر حاضراً مع ركعتي الفجر خير من الدنيا وما فيها',
        pointsReward: 100,
        iconName: 'wb_twilight',
      ),
      DeedQuest(
        id: 'morning_azkar',
        title: 'أذكار الصباح والمساء 🕊️',
        description: 'تحصين نفسك بأذكار الصباح والمساء للحفظ والتوفيق',
        pointsReward: 80,
        iconName: 'spa',
      ),
      DeedQuest(
        id: 'quran_juz',
        title: 'قراءة صفحة من المصحف وتدبرها 📖',
        description: 'تلاوة آيات بينات من كلام الله العزيز بتدبر وخشوع',
        pointsReward: 90,
        iconName: 'menu_book',
      ),
      DeedQuest(
        id: 'duha_prayer',
        title: 'صلاة الضحى (صلاة الأوابين) ☀️',
        description: 'ركعتان في وقت الضحى تجزئ عن صدقة 360 مفصلاً في جسدك',
        pointsReward: 70,
        iconName: 'wb_sunny',
      ),
      DeedQuest(
        id: 'tasbih_1000',
        title: 'ألف تسبيحة واستغفار 📿',
        description: 'ترطيب اللسان بذكر الله والصلاة على النبي ﷺ 1000 مرة',
        pointsReward: 120,
        iconName: 'touch_app',
      ),
      DeedQuest(
        id: 'kindness_deed',
        title: 'صنائع المعروف وبر الوالدين 🤍',
        description: 'إدخال سرور على قلب مسلم، بر والدين، أو تفريج كربة',
        pointsReward: 100,
        iconName: 'volunteer_activism',
      ),
    ];

    if (savedDate == todayKey) {
      final data = prefs.getString('good_deeds_quests');
      if (data != null) {
        final List decoded = jsonDecode(data);
        _quests = decoded.map((e) => DeedQuest.fromJson(e)).toList();
      } else {
        _quests = defaultQuests;
      }
    } else {
      // New Day: Reset quests
      _quests = defaultQuests;
      await prefs.setString('good_deeds_date', todayKey);
      await _saveQuests();
    }
    notifyListeners();
  }

  Future<void> _saveQuests() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_quests.map((e) => e.toJson()).toList());
    await prefs.setString('good_deeds_quests', encoded);
    notifyListeners();
  }

  Future<void> toggleQuest(String questId, BuildContext? context) async {
    final quest = _quests.firstWhere((q) => q.id == questId);
    quest.isCompleted = !quest.isCompleted;

    if (quest.isCompleted) {
      // Reward points in ThemeManager
      AppThemeManager().addHasanatPoints(quest.pointsReward);
    } else {
      AppThemeManager().addHasanatPoints(-quest.pointsReward);
    }

    await _saveQuests();
  }
}
