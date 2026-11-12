import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DhikrCampaign {
  final String id;
  final String title;
  final String phrase;
  final String rewardHadith;
  final int targetCount;
  int currentCount;
  int userContribution;

  DhikrCampaign({
    required this.id,
    required this.title,
    required this.phrase,
    required this.rewardHadith,
    required this.targetCount,
    required this.currentCount,
    this.userContribution = 0,
  });

  double get progress => (currentCount / targetCount).clamp(0.0, 1.0);
  bool get isCompleted => currentCount >= targetCount;
}

class GlobalDhikrManager extends ChangeNotifier {
  static final GlobalDhikrManager _instance = GlobalDhikrManager._internal();
  factory GlobalDhikrManager() => _instance;
  GlobalDhikrManager._internal() {
    _loadState();
  }

  final List<DhikrCampaign> _campaigns = [
    DhikrCampaign(
      id: 'salawat_million',
      title: 'مليونية الصلاة على النبي ﷺ 🌺',
      phrase: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
      rewardHadith: 'قال ﷺ: «مَنْ صَلَّى عَلَيَّ صَلَاةً صَلَّى اللَّهُ عَلَيْهِ بِهَا عَشْرًا»',
      targetCount: 1000000,
      currentCount: 684290,
    ),
    DhikrCampaign(
      id: 'istighfar_campaign',
      title: 'حملة تفريج الكرب (100 ألف استغفار) 🌧️',
      phrase: 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ',
      rewardHadith: 'قال ﷺ: «مَنْ لَزِمَ الِاسْتِغْفَارَ جَعَلَ اللَّهُ لَهُ مِنْ كُلِّ ضِيقٍ مَخْرَجًا»',
      targetCount: 100000,
      currentCount: 78940,
    ),
    DhikrCampaign(
      id: 'hawqala_million',
      title: 'مليونية كنز الجنة (الحوقلة) 💎',
      phrase: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ',
      rewardHadith: 'قال ﷺ: «أَلا أَدُلُّكَ عَلَى كَنْزٍ مِنْ كُنُوزِ الْجَنَّةِ: لا حَوْلَ وَلا قُوَّةَ إِلا بِاللَّهِ»',
      targetCount: 1000000,
      currentCount: 432150,
    ),
    DhikrCampaign(
      id: 'subhanallah_trees',
      title: 'حملة غراس الجنة (500 ألف تسبيحة) 🌴',
      phrase: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
      rewardHadith: 'قال ﷺ: «كَلِمَتَانِ خَفِيفَتَانِ عَلَى اللِّسَانِ، ثَقِيلَتَانِ فِي الْمِيزَانِ...»',
      targetCount: 500000,
      currentCount: 312500,
    ),
  ];

  List<DhikrCampaign> get campaigns => _campaigns;

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    for (final camp in _campaigns) {
      final userKey = 'global_dhikr_user_${camp.id}';
      final totalKey = 'global_dhikr_total_${camp.id}';
      camp.userContribution = prefs.getInt(userKey) ?? 0;
      camp.currentCount = (prefs.getInt(totalKey) ?? camp.currentCount) + camp.userContribution;
    }
    notifyListeners();
  }

  Future<void> incrementDhikr(String campaignId, {int count = 1}) async {
    final camp = _campaigns.firstWhere((c) => c.id == campaignId);
    camp.currentCount += count;
    camp.userContribution += count;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('global_dhikr_user_${camp.id}', camp.userContribution);
    await prefs.setInt('global_dhikr_total_${camp.id}', camp.currentCount);

    notifyListeners();
  }
}
