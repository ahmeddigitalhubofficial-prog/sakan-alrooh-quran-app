import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguageInfo {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final bool isRtl;

  const AppLanguageInfo({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.isRtl,
  });
}

class LocaleManager extends ChangeNotifier {
  static const String _prefKey = 'app_language';

  static const List<AppLanguageInfo> supportedLanguages = [
    AppLanguageInfo(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      flag: '🇸🇦',
      isRtl: true,
    ),
    AppLanguageInfo(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇬🇧',
      isRtl: false,
    ),
    AppLanguageInfo(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
      flag: '🇫🇷',
      isRtl: false,
    ),
    AppLanguageInfo(
      code: 'id',
      name: 'Indonesian',
      nativeName: 'Bahasa Indonesia',
      flag: '🇮🇩',
      isRtl: false,
    ),
    AppLanguageInfo(
      code: 'tr',
      name: 'Turkish',
      nativeName: 'Türkçe',
      flag: '🇹🇷',
      isRtl: false,
    ),
    AppLanguageInfo(
      code: 'ur',
      name: 'Urdu',
      nativeName: 'اردو',
      flag: '🇵🇰',
      isRtl: true,
    ),
  ];

  String _currentLocaleCode = 'ar';

  LocaleManager() {
    _loadSavedLocale();
  }

  String get currentLocaleCode => _currentLocaleCode;

  Locale get currentLocale => Locale(_currentLocaleCode);

  bool get isRtl => _currentLocaleCode == 'ar' || _currentLocaleCode == 'ur';

  TextDirection get textDirection => isRtl ? TextDirection.rtl : TextDirection.ltr;

  AppLanguageInfo get currentLanguageInfo =>
      supportedLanguages.firstWhere(
        (lang) => lang.code == _currentLocaleCode,
        orElse: () => supportedLanguages.first,
      );

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefKey);
      if (savedCode != null && supportedLanguages.any((l) => l.code == savedCode)) {
        _currentLocaleCode = savedCode;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setLocale(String code) async {
    if (_currentLocaleCode == code) return;
    if (!supportedLanguages.any((l) => l.code == code)) return;

    _currentLocaleCode = code;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, code);
    } catch (_) {}
  }
}
