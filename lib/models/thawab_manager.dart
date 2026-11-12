import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DedicatedSoul {
  final String id;
  final String name;
  final String relationType; // متوفى، مريض، والدين، صديق
  final String customDua;
  int totalPrayers;
  int totalQuranAyat;
  int totalTasbih;
  final DateTime createdAt;

  DedicatedSoul({
    required this.id,
    required this.name,
    required this.relationType,
    required this.customDua,
    this.totalPrayers = 0,
    this.totalQuranAyat = 0,
    this.totalTasbih = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'relationType': relationType,
        'customDua': customDua,
        'totalPrayers': totalPrayers,
        'totalQuranAyat': totalQuranAyat,
        'totalTasbih': totalTasbih,
        'createdAt': createdAt.toIso8601String(),
      };

  factory DedicatedSoul.fromJson(Map<String, dynamic> json) => DedicatedSoul(
        id: json['id'],
        name: json['name'],
        relationType: json['relationType'] ?? 'متوفى',
        customDua: json['customDua'] ?? '',
        totalPrayers: json['totalPrayers'] ?? 0,
        totalQuranAyat: json['totalQuranAyat'] ?? 0,
        totalTasbih: json['totalTasbih'] ?? 0,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      );
}

class ThawabManager extends ChangeNotifier {
  static final ThawabManager _instance = ThawabManager._internal();
  factory ThawabManager() => _instance;
  ThawabManager._internal() {
    _loadSouls();
  }

  List<DedicatedSoul> _souls = [];
  List<DedicatedSoul> get souls => _souls;

  Future<void> _loadSouls() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('dedicated_souls_list');
    if (data != null) {
      final List decoded = jsonDecode(data);
      _souls = decoded.map((e) => DedicatedSoul.fromJson(e)).toList();
    } else {
      // Default sample
      _souls = [
        DedicatedSoul(
          id: 'sample_1',
          name: 'جميع موتى المسلمين 🕊️',
          relationType: 'متوفى',
          customDua: 'اللَّهُمَّ اغْفِرْ لَهُمْ وَارْحَمْهُمْ وَعَافِهِمْ وَاعْفُ عَنْهُمْ وَأَكْرِمْ نُزُلَهُمْ',
          totalPrayers: 124,
          totalQuranAyat: 340,
          totalTasbih: 1520,
          createdAt: DateTime.now(),
        ),
      ];
    }
    notifyListeners();
  }

  Future<void> _saveSouls() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_souls.map((e) => e.toJson()).toList());
    await prefs.setString('dedicated_souls_list', encoded);
    notifyListeners();
  }

  Future<void> addSoul(String name, String relationType, String customDua) async {
    final newSoul = DedicatedSoul(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      relationType: relationType,
      customDua: customDua.isEmpty
          ? 'اللَّهُمَّ اجْعَلْ ثَوَابَ هَذَا الْعَمَلِ فِي صَحِيفَتِهِ وَارْفَعْ دَرَجَتَهُ فِي الْمَهْدِيِّينَ'
          : customDua,
      createdAt: DateTime.now(),
    );
    _souls.insert(0, newSoul);
    await _saveSouls();
  }

  Future<void> recordDhikrForSoul(String soulId, {int count = 1}) async {
    final idx = _souls.indexWhere((s) => s.id == soulId);
    if (idx != -1) {
      _souls[idx].totalTasbih += count;
      await _saveSouls();
    }
  }

  Future<void> recordDuaForSoul(String soulId) async {
    final idx = _souls.indexWhere((s) => s.id == soulId);
    if (idx != -1) {
      _souls[idx].totalPrayers += 1;
      await _saveSouls();
    }
  }

  Future<void> deleteSoul(String soulId) async {
    _souls.removeWhere((s) => s.id == soulId);
    await _saveSouls();
  }
}
