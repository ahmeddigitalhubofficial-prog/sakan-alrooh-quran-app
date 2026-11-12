// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/owner_service.dart';

class AppTheme {
  final String id;
  final String name;
  final Color primaryColor;
  final Color accentColor;
  final Color scaffoldBackgroundColor;
  final Color cardColor;
  final Color textColor;
  final Color subtitleColor;
  final List<Color> gradientColors;
  final bool isDark;
  final double ornamentOpacity;
  final Color dividerColor;

  AppTheme({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.accentColor,
    required this.scaffoldBackgroundColor,
    required this.cardColor,
    required this.textColor,
    required this.subtitleColor,
    required this.gradientColors,
    required this.isDark,
    required this.ornamentOpacity,
    required this.dividerColor,
  });
}

/// خلفيات المصحف الشريف الـ 10
class QuranPageBackground {
  final String id;
  final String name;
  final Color backgroundColor;
  final Color textColor;
  final Color frameColor;
  final Color ayaMarkColor;
  final bool isDark;

  const QuranPageBackground({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required this.textColor,
    required this.frameColor,
    required this.ayaMarkColor,
    required this.isDark,
  });
}

/// تصاميم خرزات السبحة الـ 10
class MasbahaBeadStyle {
  final String id;
  final String name;
  final Color beadColor;
  final Color glowColor;
  final Color stringColor;
  final String materialName;

  const MasbahaBeadStyle({
    required this.id,
    required this.name,
    required this.beadColor,
    required this.glowColor,
    required this.stringColor,
    required this.materialName,
  });
}

class AppThemeManager extends ChangeNotifier {
  static const String _themeKey = 'selected_app_theme';
  static const String _quranBgKey = 'selected_quran_background';
  static const String _masbahaStyleKey = 'selected_masbaha_style';
  static const String _hasanatPointsKey = 'user_hasanat_points';
  static const String _unlockedItemsKey = 'user_unlocked_store_items';

  // ==================== 1. الـ 10 ثيمات الفاخرة ====================
  static final List<AppTheme> themes = [
    // 1. الزمردي الروحاني (الروضة الشريفة)
    AppTheme(
      id: 'emerald',
      name: 'الروضة الشريفة (الزمردي)',
      primaryColor: const Color(0xFF0F5A3E),
      accentColor: const Color(0xFFD4AF37),
      scaffoldBackgroundColor: const Color(0xFF05140E),
      cardColor: const Color(0xFF0B281B),
      textColor: const Color(0xFFE6EFEA),
      subtitleColor: const Color(0xFF90B5A6),
      gradientColors: [const Color(0xFF05140E), const Color(0xFF0B281B)],
      isDark: true,
      ornamentOpacity: 0.12,
      dividerColor: const Color(0xFF1B4E38),
    ),
    // 2. كسوة الكعبة المذهبة
    AppTheme(
      id: 'kaaba_gold',
      name: 'كسوة الكعبة المذهبة',
      primaryColor: const Color(0xFF1A1A1A),
      accentColor: const Color(0xFFFFD700),
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      cardColor: const Color(0xFF161616),
      textColor: const Color(0xFFFFFDF0),
      subtitleColor: const Color(0xFFC5B358),
      gradientColors: [const Color(0xFF0A0A0A), const Color(0xFF1A1810)],
      isDark: true,
      ornamentOpacity: 0.18,
      dividerColor: const Color(0xFF332B12),
    ),
    // 3. أزرق الليل الساحر
    AppTheme(
      id: 'midnight',
      name: 'أزرق الليل الساحر',
      primaryColor: const Color(0xFF1D3557),
      accentColor: const Color(0xFFE9C46A),
      scaffoldBackgroundColor: const Color(0xFF0A1128),
      cardColor: const Color(0xFF101F42),
      textColor: const Color(0xFFF1FAEE),
      subtitleColor: const Color(0xFF8ECAE6),
      gradientColors: [const Color(0xFF0A1128), const Color(0xFF101F42)],
      isDark: true,
      ornamentOpacity: 0.15,
      dividerColor: const Color(0xFF263D74),
    ),
    // 4. الأندلسي الملكي
    AppTheme(
      id: 'andalusian',
      name: 'الأندلسي الملكي',
      primaryColor: const Color(0xFF1E3A5F),
      accentColor: const Color(0xFFE5A93B),
      scaffoldBackgroundColor: const Color(0xFF0D1B2A),
      cardColor: const Color(0xFF1B263B),
      textColor: const Color(0xFFE0E1DD),
      subtitleColor: const Color(0xFF778DA9),
      gradientColors: [const Color(0xFF0D1B2A), const Color(0xFF1B263B)],
      isDark: true,
      ornamentOpacity: 0.16,
      dividerColor: const Color(0xFF415A77),
    ),
    // 5. قبة الصخرة القدسية
    AppTheme(
      id: 'quds_turquoise',
      name: 'قبة الصخرة القدسية',
      primaryColor: const Color(0xFF026873),
      accentColor: const Color(0xFFF2B705),
      scaffoldBackgroundColor: const Color(0xFF012E40),
      cardColor: const Color(0xFF024959),
      textColor: const Color(0xFFF2F2F2),
      subtitleColor: const Color(0xFF73A8A4),
      gradientColors: [const Color(0xFF012E40), const Color(0xFF024959)],
      isDark: true,
      ornamentOpacity: 0.14,
      dividerColor: const Color(0xFF036577),
    ),
    // 6. فجر المدينة الهادئ
    AppTheme(
      id: 'fajr_dawn',
      name: 'فجر المدينة الهادئ',
      primaryColor: const Color(0xFF2B3A4A),
      accentColor: const Color(0xFF88C0D0),
      scaffoldBackgroundColor: const Color(0xFF151E28),
      cardColor: const Color(0xFF202C3A),
      textColor: const Color(0xFFECEFF4),
      subtitleColor: const Color(0xFFD8DEE9),
      gradientColors: [const Color(0xFF151E28), const Color(0xFF202C3A)],
      isDark: true,
      ornamentOpacity: 0.10,
      dividerColor: const Color(0xFF3B4A5A),
    ),
    // 7. رمال الصحراء الذهبية
    AppTheme(
      id: 'desert_dune',
      name: 'رمال الصحراء الذهبية',
      primaryColor: const Color(0xFF7C5A35),
      accentColor: const Color(0xFFE0A96D),
      scaffoldBackgroundColor: const Color(0xFF1A120B),
      cardColor: const Color(0xFF2B1E14),
      textColor: const Color(0xFFF7ECE1),
      subtitleColor: const Color(0xFFC7B198),
      gradientColors: [const Color(0xFF1A120B), const Color(0xFF2B1E14)],
      isDark: true,
      ornamentOpacity: 0.14,
      dividerColor: const Color(0xFF4E3726),
    ),
    // 8. السكينة البنفسجي الليلي
    AppTheme(
      id: 'sakina_purple',
      name: 'السكينة البنفسجي الليلي',
      primaryColor: const Color(0xFF3F2B63),
      accentColor: const Color(0xFFCBB2FE),
      scaffoldBackgroundColor: const Color(0xFF160D27),
      cardColor: const Color(0xFF251740),
      textColor: const Color(0xFFF3EEFF),
      subtitleColor: const Color(0xFFA594C9),
      gradientColors: [const Color(0xFF160D27), const Color(0xFF251740)],
      isDark: true,
      ornamentOpacity: 0.13,
      dividerColor: const Color(0xFF4C3675),
    ),
    // 9. الرخام الأبيض النقي
    AppTheme(
      id: 'marble',
      name: 'الرخام الأبيض النقي',
      primaryColor: const Color(0xFF6B5B4B),
      accentColor: const Color(0xFFD4AF37),
      scaffoldBackgroundColor: const Color(0xFFF7F6F0),
      cardColor: Colors.white,
      textColor: const Color(0xFF2B2D42),
      subtitleColor: const Color(0xFF7D8597),
      gradientColors: [const Color(0xFFF7F6F0), const Color(0xFFFFFDF9)],
      isDark: false,
      ornamentOpacity: 0.08,
      dividerColor: const Color(0xFFE2E1D9),
    ),
    // 10. الظلام المطلق OLED
    AppTheme(
      id: 'oled',
      name: 'الظلام المطلق OLED',
      primaryColor: const Color(0xFF1A1A1A),
      accentColor: const Color(0xFFD4AF37),
      scaffoldBackgroundColor: const Color(0xFF000000),
      cardColor: const Color(0xFF121212),
      textColor: const Color(0xFFE0E0E0),
      subtitleColor: const Color(0xFF888888),
      gradientColors: [const Color(0xFF000000), const Color(0xFF121212)],
      isDark: true,
      ornamentOpacity: 0.05,
      dividerColor: const Color(0xFF2C2C2C),
    ),
  ];

  // ==================== 2. الـ 10 خلفيات للمصحف الشريف ====================
  static const List<QuranPageBackground> quranBackgrounds = [
    QuranPageBackground(
      id: 'ottoman_vintage',
      name: 'الورق العثماني العتيق',
      backgroundColor: Color(0xFFFDF7E7),
      textColor: Color(0xFF1F1C18),
      frameColor: Color(0xFFB58A40),
      ayaMarkColor: Color(0xFF9E7730),
      isDark: false,
    ),
    QuranPageBackground(
      id: 'shami_gold',
      name: 'ورق الشام الملكي المذهب',
      backgroundColor: Color(0xFFFAF3DD),
      textColor: Color(0xFF2C1810),
      frameColor: Color(0xFFD4AF37),
      ayaMarkColor: Color(0xFFB8860B),
      isDark: false,
    ),
    QuranPageBackground(
      id: 'oled_night',
      name: 'المصحف الليلي المريح (OLED)',
      backgroundColor: Color(0xFF000000),
      textColor: Color(0xFFE6E6E6),
      frameColor: Color(0xFF333333),
      ayaMarkColor: Color(0xFFD4AF37),
      isDark: true,
    ),
    QuranPageBackground(
      id: 'papyrus',
      name: 'ورق البردي الكلاسيكي',
      backgroundColor: Color(0xFFF4ECD8),
      textColor: Color(0xFF281E15),
      frameColor: Color(0xFFA2845E),
      ayaMarkColor: Color(0xFF856A47),
      isDark: false,
    ),
    QuranPageBackground(
      id: 'cloud_silk',
      name: 'الورق الحريري السحابي',
      backgroundColor: Color(0xFFF8F9FA),
      textColor: Color(0xFF212529),
      frameColor: Color(0xFF4A6B82),
      ayaMarkColor: Color(0xFF2B5B84),
      isDark: false,
    ),
    QuranPageBackground(
      id: 'ivory',
      name: 'ورق العاج الطبيعي',
      backgroundColor: Color(0xFFFFFFF0),
      textColor: Color(0xFF1A1A1A),
      frameColor: Color(0xFFC0A060),
      ayaMarkColor: Color(0xFFA68030),
      isDark: false,
    ),
    QuranPageBackground(
      id: 'cordoba_marble',
      name: 'الرخام القرطبي الأزرق',
      backgroundColor: Color(0xFFF0F4F8),
      textColor: Color(0xFF102A43),
      frameColor: Color(0xFF334E68),
      ayaMarkColor: Color(0xFF102A43),
      isDark: false,
    ),
    QuranPageBackground(
      id: 'andalusian_manuscript',
      name: 'المخطوطة الأندلسية المزخرفة',
      backgroundColor: Color(0xFFF5EBE6),
      textColor: Color(0xFF381E11),
      frameColor: Color(0xFF9C4121),
      ayaMarkColor: Color(0xFF7A2E14),
      isDark: false,
    ),
    QuranPageBackground(
      id: 'emerald_tint',
      name: 'الورق الزمردي المريح للعين',
      backgroundColor: Color(0xFFEBF5EE),
      textColor: Color(0xFF0F3822),
      frameColor: Color(0xFF2D6A4F),
      ayaMarkColor: Color(0xFF1B4332),
      isDark: false,
    ),
    QuranPageBackground(
      id: 'deep_slate',
      name: 'الرمادي الملكي الليلي',
      backgroundColor: Color(0xFF1E242B),
      textColor: Color(0xFFECEFF1),
      frameColor: Color(0xFF455A64),
      ayaMarkColor: Color(0xFFFFD54F),
      isDark: true,
    ),
  ];

  // ==================== 3. الـ 10 تصاميم لخرزات السبحة ====================
  static const List<MasbahaBeadStyle> masbahaStyles = [
    MasbahaBeadStyle(
      id: 'agate_yamani',
      name: 'العقيق اليماني الكبدي',
      beadColor: Color(0xFF721C24),
      glowColor: Color(0xFFB71C1C),
      stringColor: Color(0xFF491217),
      materialName: 'عقيق يماني طبيعي',
    ),
    MasbahaBeadStyle(
      id: 'turquoise_sinai',
      name: 'الفيروز السينائي الأزرق',
      beadColor: Color(0xFF00838F),
      glowColor: Color(0xFF00E5FF),
      stringColor: Color(0xFF004D40),
      materialName: 'حجر فيروز سيناء الأصيل',
    ),
    MasbahaBeadStyle(
      id: 'sandalwood',
      name: 'خشب الصندل والعود',
      beadColor: Color(0xFF5D4037),
      glowColor: Color(0xFF8D6E63),
      stringColor: Color(0xFF3E2723),
      materialName: 'خشب صندل عطري فاخر',
    ),
    MasbahaBeadStyle(
      id: 'amber_baltic',
      name: 'الكهرمان البلطيقي الشفاف',
      beadColor: Color(0xFFFF8F00),
      glowColor: Color(0xFFFFD54F),
      stringColor: Color(0xFFE65100),
      materialName: 'كهرمان أصلي كهرماني',
    ),
    MasbahaBeadStyle(
      id: 'lapis_lazuli',
      name: 'حجر اللازورد الملكي',
      beadColor: Color(0xFF1A237E),
      glowColor: Color(0xFF536DFE),
      stringColor: Color(0xFF0D47A1),
      materialName: 'لازورد أفغاني ملكي',
    ),
    MasbahaBeadStyle(
      id: 'emerald_green',
      name: 'الزمرد الأخضر البراق',
      beadColor: Color(0xFF1B5E20),
      glowColor: Color(0xFF69F0AE),
      stringColor: Color(0xFF003300),
      materialName: 'حجر الزمرد النقي',
    ),
    MasbahaBeadStyle(
      id: 'pearl_white',
      name: 'اللؤلؤ الأبيض المشع',
      beadColor: Color(0xFFF5F5F5),
      glowColor: Color(0xFFE0E0E0),
      stringColor: Color(0xFF9E9E9E),
      materialName: 'لؤلؤ طبيعي براق',
    ),
    MasbahaBeadStyle(
      id: 'ruby_red',
      name: 'الياقوت القرمزي',
      beadColor: Color(0xFF880E4F),
      glowColor: Color(0xFFFF4081),
      stringColor: Color(0xFF4A0033),
      materialName: 'ياقوت أحمر زجاجي',
    ),
    MasbahaBeadStyle(
      id: 'tiger_eye',
      name: 'حجر عين النمر الذهبي',
      beadColor: Color(0xFFB78103),
      glowColor: Color(0xFFFFE082),
      stringColor: Color(0xFF4E3600),
      materialName: 'حجر عين النمر المتموج',
    ),
    MasbahaBeadStyle(
      id: 'silver_crystal',
      name: 'الكريستال الفضي المتوهج',
      beadColor: Color(0xFFB0BEC5),
      glowColor: Color(0xFFECEFF1),
      stringColor: Color(0xFF546E7A),
      materialName: 'كريستال نقي عاكس للضوء',
    ),
  ];

  AppTheme _currentTheme = themes.first;
  QuranPageBackground _currentQuranBg = quranBackgrounds.first;
  MasbahaBeadStyle _currentMasbahaStyle = masbahaStyles.first;
  int _hasanatPoints = 150; // رصيد ترحيبي أولي 150 نقطة حسنة
  final Set<String> _unlockedItems = {'emerald', 'kaaba_gold', 'midnight', 'ottoman_vintage', 'shami_gold', 'oled_night', 'agate_yamani', 'turquoise_sinai', 'sandalwood'};

  AppTheme get currentTheme => _currentTheme;
  QuranPageBackground get currentQuranBg => _currentQuranBg;
  MasbahaBeadStyle get currentMasbahaStyle => _currentMasbahaStyle;
  int get hasanatPoints => _hasanatPoints;
  Set<String> get unlockedItems => _unlockedItems;

  int get currentThemeIndex => themes.indexOf(_currentTheme);

  AppThemeManager() {
    Future.microtask(() {
      _loadPreferences();
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Load Theme
    final themeId = prefs.getString(_themeKey);
    if (themeId != null) {
      final index = themes.indexWhere((t) => t.id == themeId);
      if (index != -1) {
        _currentTheme = themes[index];
      }
    }

    // 2. Load Quran Background
    final quranBgId = prefs.getString(_quranBgKey);
    if (quranBgId != null) {
      final index = quranBackgrounds.indexWhere((b) => b.id == quranBgId);
      if (index != -1) {
        _currentQuranBg = quranBackgrounds[index];
      }
    }

    // 3. Load Masbaha Style
    final styleId = prefs.getString(_masbahaStyleKey);
    if (styleId != null) {
      final index = masbahaStyles.indexWhere((s) => s.id == styleId);
      if (index != -1) {
        _currentMasbahaStyle = masbahaStyles[index];
      }
    }

    // 4. Load Points & Unlocked Items
    _hasanatPoints = prefs.getInt(_hasanatPointsKey) ?? 150;
    final unlockedList = prefs.getStringList(_unlockedItemsKey);
    if (unlockedList != null) {
      _unlockedItems.addAll(unlockedList);
    }

    if (hasListeners) {
      notifyListeners();
    }
  }

  // ==================== وظائف تغيير الثيمات والتخصيص ====================
  Future<void> selectTheme(String themeId) async {
    final index = themes.indexWhere((t) => t.id == themeId);
    if (index != -1) {
      _currentTheme = themes[index];
      if (hasListeners) notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeId);
    }
  }

  Future<void> selectQuranBackground(String bgId) async {
    final index = quranBackgrounds.indexWhere((b) => b.id == bgId);
    if (index != -1) {
      _currentQuranBg = quranBackgrounds[index];
      if (hasListeners) notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_quranBgKey, bgId);
    }
  }

  Future<void> selectMasbahaStyle(String styleId) async {
    final index = masbahaStyles.indexWhere((s) => s.id == styleId);
    if (index != -1) {
      _currentMasbahaStyle = masbahaStyles[index];
      if (hasListeners) notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_masbahaStyleKey, styleId);
    }
  }

  // ==================== نظام نقاط الحسنات والمتجر ====================
  Future<void> addHasanatPoints(int points) async {
    _hasanatPoints += points;
    if (hasListeners) notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hasanatPointsKey, _hasanatPoints);
  }

  Future<bool> unlockStoreItem(String itemId, int price) async {
    if (_unlockedItems.contains(itemId)) return true;
    if (_hasanatPoints < price) return false;

    _hasanatPoints -= price;
    _unlockedItems.add(itemId);
    if (hasListeners) notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hasanatPointsKey, _hasanatPoints);
    await prefs.setStringList(_unlockedItemsKey, _unlockedItems.toList());
    return true;
  }

  bool isItemUnlocked(String itemId) {
    if (OwnerService().isOwner) return true;
    return _unlockedItems.contains(itemId);
  }
}
