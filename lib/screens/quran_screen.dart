// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/app_spacing.dart';
import '../models/theme_manager.dart';
import '../models/task_manager.dart';
import 'surah_detail_screen.dart';
import 'quran_index_screen.dart';
import 'islamic_radio_screen.dart';
import '../widgets/common/quick_language_button.dart';
import '../core/localization/app_translations.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({
    super.key,
  });

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _SurahMetadata {
  final int number;
  final String arabicName;
  final String englishName;
  final int versesCount;
  final bool isMeccan;
  final String normalizedArabic;

  const _SurahMetadata({
    required this.number,
    required this.arabicName,
    required this.englishName,
    required this.versesCount,
    required this.isMeccan,
    required this.normalizedArabic,
  });
}

String _staticNormalizeArabic(String text) {
  return text
      .replaceAll(RegExp(r'[ًٌٍَُِّْٰ]'), '')
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي');
}

class _QuranScreenState extends State<QuranScreen> {
  final TextEditingController _searchController = TextEditingController();

  static final List<_SurahMetadata> _allSurahs = List.generate(
    114,
    (index) {
      final num = index + 1;
      final ar = quran.getSurahNameArabic(num);
      return _SurahMetadata(
        number: num,
        arabicName: ar,
        englishName: quran.getSurahName(num),
        versesCount: quran.getVerseCount(num),
        isMeccan: quran.getPlaceOfRevelation(num) == 'Makkah',
        normalizedArabic: _staticNormalizeArabic(ar),
      );
    },
  );

  List<int> _filteredSurahNumbers = [];

  Set<int> _favoriteSurahs = {};

  List<int> _recentSurahs = [];

  int? _resumeSurahNumber;
  String? _resumeSurahName;
  int? _resumeVerseNumber;

  @override
  void initState() {
    super.initState();

    _filteredSurahNumbers = List.generate(
      114,
      (index) => index + 1,
    );

    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _favoriteSurahs = prefs
            .getStringList(
              'favorite_surahs',
            )
            ?.map(
              (e) => int.tryParse(e) ?? 0,
            )
            .where((e) => e > 0)
            .toSet() ??
        {};

    _recentSurahs = prefs
            .getStringList(
              'recent_surahs',
            )
            ?.map(
              (e) => int.parse(e),
            )
            .toList() ??
        [];

    if (prefs.getBool('save_last_read') ?? true) {
      _resumeSurahNumber = prefs.getInt('last_read_surah');
      _resumeSurahName = prefs.getString('last_read_surah_name');
      _resumeVerseNumber = prefs.getInt('last_read_verse');
    } else {
      _resumeSurahNumber = null;
      _resumeSurahName = null;
      _resumeVerseNumber = null;
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleFavorite(
    int surahNumber,
  ) async {
    HapticFeedback.lightImpact();

    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (_favoriteSurahs.contains(surahNumber)) {
        _favoriteSurahs.remove(surahNumber);
      } else {
        _favoriteSurahs.add(surahNumber);
      }
    });

    await prefs.setStringList(
      'favorite_surahs',
      _favoriteSurahs.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _saveRecentSurah(
    int surahNumber,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    _recentSurahs.remove(
      surahNumber,
    );

    _recentSurahs.insert(
      0,
      surahNumber,
    );

    if (_recentSurahs.length > 6) {
      _recentSurahs = _recentSurahs.sublist(
        0,
        6,
      );
    }

    await prefs.setStringList(
      'recent_surahs',
      _recentSurahs
          .map(
            (e) => e.toString(),
          )
          .toList(),
    );

    if (mounted) {
      setState(() {});
    }
  }

  void _filterSurahs(
    String query,
  ) {
    if (query.isEmpty) {
      setState(() {
        _filteredSurahNumbers = List.generate(
          114,
          (index) => index + 1,
        );
      });

      return;
    }

    final normalizedQuery = _staticNormalizeArabic(
      query,
    );

    final results = <int>[];

    for (final surah in _allSurahs) {
      if (surah.normalizedArabic.contains(normalizedQuery) ||
          surah.englishName.toLowerCase().contains(query.toLowerCase())) {
        results.add(surah.number);
      }
    }

    setState(() {
      _filteredSurahNumbers = results;
    });
  }



  @override
  Widget build(
    BuildContext context,
  ) {
    final themeManager = Provider.of<AppThemeManager>(
      context,
    );

    final theme = themeManager.currentTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.gradientColors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 10.h,
              ),
              _buildHeader(theme),
              SizedBox(
                height: 24.h,
              ),
              _buildSearchField(theme),
              _buildResumeReadingCard(theme),
              if (_recentSurahs.isNotEmpty) ...[
                AppSpacing.h20,
                _buildRecentSection(
                  theme,
                ),
              ],
              AppSpacing.h20,
              Expanded(
                child: _filteredSurahNumbers.isEmpty
                    ? _buildEmptyState(
                        theme,
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(
                          bottom: 120.h,
                        ),
                        itemCount: _filteredSurahNumbers.length,
                        itemBuilder: (
                          context,
                          index,
                        ) {
                          final surahNumber = _filteredSurahNumbers[index];

                          return _buildSurahTile(
                            theme: theme,
                            surahNumber: surahNumber,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    AppTheme theme,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Elegant index icon button on the left (RTL)
          IconButton(
            icon: Icon(
              Icons.format_list_bulleted_rounded,
              color: theme.accentColor,
              size: 28.sp,
            ),
            tooltip: 'فهرس السور والأجزاء والسجدات',
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const QuranIndexScreen(),
                ),
              );
            },
          ),
          // Centered title and icon
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_rounded,
                color: theme.accentColor,
                size: 32.sp,
              ),
              SizedBox(
                width: 10.w,
              ),
              Text(
                context.tr('quran_title'),
                style: GoogleFonts.cairo(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const QuickLanguageButton(isCompact: true),
              SizedBox(width: 4.w),
              IconButton(
                icon: Icon(
                  Icons.radio_rounded,
                  color: theme.accentColor,
                  size: 24.sp,
                ),
                tooltip: 'إذاعات القرآن الكريم المباشرة 📻',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IslamicRadioScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(
    AppTheme theme,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: 0.06,
          ),
          borderRadius: BorderRadius.circular(
            24.r,
          ),
          border: Border.all(
            color: Colors.white.withValues(
              alpha: 0.10,
            ),
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _filterSurahs,
          style: GoogleFonts.cairo(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'ابحث عن سورة...',
            hintStyle: GoogleFonts.cairo(
              color: Colors.white38,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: theme.accentColor,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      _searchController.clear();

                      _filterSurahs(
                        '',
                      );
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              vertical: 18.h,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSection(
    AppTheme theme,
  ) {
    return SizedBox(
      height: 58.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
        ),
        itemCount: _recentSurahs.length,
        itemBuilder: (
          context,
          index,
        ) {
          final surah = _recentSurahs[index];

          return Padding(
            padding: EdgeInsets.only(
              left: 10.w,
            ),
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (
                      context,
                    ) =>
                        SurahDetailScreen(
                      surahNumber: surah,
                      surahName: quran.getSurahNameArabic(
                        surah,
                      ),
                    ),
                  ),
                );
                _loadData();
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 18.w,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color: theme.accentColor,
                  borderRadius: BorderRadius.circular(
                    18.r,
                  ),
                ),
                child: Center(
                  child: Text(
                    quran.getSurahNameArabic(
                      surah,
                    ),
                    style: GoogleFonts.cairo(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    AppTheme theme,
  ) {
    return Center(
      child: Text(
        'لم يتم العثور على نتائج',
        style: GoogleFonts.cairo(
          color: theme.subtitleColor,
        ),
      ),
    );
  }

  Widget _buildSurahTile({
    required AppTheme theme,
    required int surahNumber,
  }) {
    final surah = _allSurahs[surahNumber - 1];
    final isFavorite = _favoriteSurahs.contains(surahNumber);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 6.h,
      ),
      child: GestureDetector(
        onTap: () async {
          await _saveRecentSurah(
            surahNumber,
          );

          if (mounted) {
            Provider.of<SpiritualTaskManager>(
              context,
              listen: false,
            ).setTaskCompleted(
              'quran_ward',
              true,
            );
          }

          if (!mounted) {
            return;
          }

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (
                context,
              ) =>
                  SurahDetailScreen(
                surahNumber: surahNumber,
                surahName: surah.arabicName,
              ),
            ),
          );
          _loadData();
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              22.r,
            ),
            color: Colors.white.withValues(
              alpha: 0.04,
            ),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.08,
              ),
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 18.w,
              vertical: 8.h,
            ),
            leading: Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.accentColor,
                    theme.accentColor.withValues(
                      alpha: 0.75,
                    ),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  '$surahNumber',
                  style: GoogleFonts.cairo(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    surah.arabicName,
                    style: GoogleFonts.cairo(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _toggleFavorite(
                      surahNumber,
                    );
                  },
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.redAccent : Colors.white54,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(
                top: 6.h,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${surah.englishName} • ${surah.versesCount} آية',
                      style: GoogleFonts.cairo(
                        color: theme.subtitleColor,
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: surah.isMeccan
                          ? Colors.amber.withValues(
                              alpha: 0.15,
                            )
                          : Colors.green.withValues(
                              alpha: 0.15,
                            ),
                      borderRadius: BorderRadius.circular(
                        8.r,
                      ),
                    ),
                    child: Text(
                      surah.isMeccan ? 'مكية' : 'مدنية',
                      style: GoogleFonts.cairo(
                        color: surah.isMeccan ? Colors.amber : Colors.green,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: theme.accentColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResumeReadingCard(AppTheme theme) {
    if (_resumeSurahNumber == null ||
        _resumeSurahName == null ||
        _resumeVerseNumber == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: 20.h, left: 16.w, right: 16.w),
      child: GestureDetector(
        onTap: () async {
          HapticFeedback.lightImpact();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SurahDetailScreen(
                surahNumber: _resumeSurahNumber!,
                surahName: _resumeSurahName!,
              ),
            ),
          );
          _loadData();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: theme.accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bookmark_added_rounded,
                  color: theme.accentColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'استئناف القراءة',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                        color: theme.textColor,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'سورة $_resumeSurahName - الآية $_resumeVerseNumber',
                      style: GoogleFonts.cairo(
                        color: theme.subtitleColor,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: theme.accentColor,
                size: 14.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
