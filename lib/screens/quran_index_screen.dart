import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;

import '../models/theme_manager.dart';
import '../widgets/islamic_number_badge.dart';
import '../data/quran_index_data.dart';
import 'surah_detail_screen.dart';

class QuranIndexScreen extends StatefulWidget {
  /// Callback invoked when a user selects a page in the index.
  /// Passes the 1-indexed destination page number (1 to 604).
  final void Function(int pageNumber)? onPageSelected;

  const QuranIndexScreen({
    super.key,
    this.onPageSelected,
  });

  @override
  State<QuranIndexScreen> createState() => _QuranIndexScreenState();
}

class _QuranIndexScreenState extends State<QuranIndexScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<SurahIndexItem> _filteredSurahs = [];

  final TextEditingController _verseSearchController = TextEditingController();
  List<QuranSearchResult> _verseSearchResults = [];
  bool _isSearchingVerses = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _filteredSurahs = List.from(quranSurahs);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _verseSearchController.dispose();
    super.dispose();
  }

  void _filterSurahs(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredSurahs = List.from(quranSurahs);
      });
      return;
    }

    final normalizedQuery = _normalizeArabicText(query);
    setState(() {
      _filteredSurahs = quranSurahs.where((surah) {
        final normalizedSurahName = _normalizeArabicText(surah.name);
        
        // Match Arabic names (with or without diacritics)
        // Also support basic English search via indices or hardcoded transliterations
        final englishName = quran.getSurahName(surah.id).toLowerCase();
        
        return normalizedSurahName.contains(normalizedQuery) ||
               englishName.contains(query.toLowerCase()) ||
               surah.id.toString() == query.trim();
      }).toList();
    });
  }

  String _normalizeArabicText(String text) {
    return text
        .replaceAll(RegExp(r'[ًٌٍَُِّْٰ]'), '') // Remove diacritics
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }

  int _getSurahNumberFromPage(int pageNumber) {
    int matchedSurahId = 1;
    for (final surah in quranSurahs) {
      if (surah.page <= pageNumber) {
        matchedSurahId = surah.id;
      } else {
        break;
      }
    }
    return matchedSurahId;
  }

  int _getFirstVerseOfPage(int surahNumber, int pageNumber) {
    final versesCount = quran.getVerseCount(surahNumber);
    for (int v = 1; v <= versesCount; v++) {
      if (quran.getPageNumber(surahNumber, v) == pageNumber) {
        return v;
      }
    }
    return 1;
  }

  void _handleItemTap(int pageNumber, {required String title, int? fallbackSurahId, int? initialVerse}) {
    HapticFeedback.lightImpact();
    
    if (widget.onPageSelected != null) {
      widget.onPageSelected!(pageNumber);
      Navigator.pop(context);
    } else {
      int surahId = fallbackSurahId ?? _getSurahNumberFromPage(pageNumber);
      final surahName = quran.getSurahNameArabic(surahId);
      final verse = initialVerse ?? _getFirstVerseOfPage(surahId, pageNumber);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SurahDetailScreen(
            surahNumber: surahId,
            surahName: surahName,
            initialVerse: verse,
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<AppThemeManager>(context);
    final theme = themeManager.currentTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.primaryColor,
          centerTitle: true,
          title: Text(
            'فهرس القرآن الكريم',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
              color: Colors.white,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: theme.accentColor,
            indicatorWeight: 3.h,
            labelColor: theme.accentColor,
            unselectedLabelColor: Colors.white70,
            labelStyle: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
            ),
            unselectedLabelStyle: GoogleFonts.cairo(
              fontWeight: FontWeight.normal,
              fontSize: 12.sp,
            ),
            tabs: const [
              Tab(text: 'السور'),
              Tab(text: 'الأجزاء'),
              Tab(text: 'الموضوعي'),
              Tab(text: 'السجدات'),
              Tab(text: 'بحث الآيات'),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: theme.gradientColors,
            ),
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSurahsTab(theme),
              _buildJuzsTab(theme),
              _buildTopicsTab(theme),
              _buildSajdahsTab(theme),
              _buildSearchVersesTab(theme),
            ],
          ),
        ),
      ),
    );
  }

  // --- TOPICS TAB ---
  Widget _buildTopicsTab(AppTheme theme) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      itemCount: quranTopics.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final topic = quranTopics[index];

        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18.r),
            onTap: () {
              if (widget.onPageSelected != null) {
                widget.onPageSelected!(topic.page);
                Navigator.pop(context);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SurahDetailScreen(
                      surahNumber: topic.surahNumber,
                      surahName: topic.surahName,
                      initialVerse: topic.verseStart,
                    ),
                  ),
                );
              }
            },
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          topic.category,
                          style: GoogleFonts.cairo(color: theme.accentColor, fontWeight: FontWeight.bold, fontSize: 11.sp),
                        ),
                      ),
                      Text(
                        'ص ${topic.page} • سورة ${topic.surahName}',
                        style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 11.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    topic.title,
                    style: GoogleFonts.cairo(
                      color: theme.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    topic.summary,
                    style: GoogleFonts.cairo(
                      color: theme.subtitleColor,
                      fontSize: 12.sp,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'قراءة الآيات (${topic.verseStart} - ${topic.verseEnd})',
                        style: GoogleFonts.cairo(color: theme.accentColor, fontWeight: FontWeight.bold, fontSize: 11.sp),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.arrow_forward_ios_rounded, color: theme.accentColor, size: 12.sp),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- SURAHS TAB ---
  Widget _buildSurahsTab(AppTheme theme) {
    return Column(
      children: [
        SizedBox(height: 16.h),
        _buildSearchField(theme),
        SizedBox(height: 12.h),
        Expanded(
          child: _filteredSurahs.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 24.h),
                  itemCount: _filteredSurahs.length,
                  itemBuilder: (context, index) {
                    final surah = _filteredSurahs[index];
                    final isMeccan = surah.revelationType == 'مكية';

                    return _buildListTile(
                      theme: theme,
                      index: surah.id,
                      title: surah.name,
                      subtitle: '${quran.getSurahName(surah.id)} • ${surah.verses} آية',
                      pageNumber: surah.page,
                      badgeText: surah.revelationType,
                      badgeColor: isMeccan ? Colors.amber : Colors.green,
                      onTap: () => _handleItemTap(
                        surah.page,
                        title: surah.name,
                        fallbackSurahId: surah.id,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // --- JUZS TAB ---
  Widget _buildJuzsTab(AppTheme theme) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      itemCount: quranJuzs.length,
      itemBuilder: (context, index) {
        final juz = quranJuzs[index];
        
        // Find matching surah id to provide a correct detail fallback
        final matchingSurah = quranSurahs.firstWhere(
          (s) => s.name == juz.startingSurahName,
          orElse: () => quranSurahs.first,
        );

        return _buildListTile(
          theme: theme,
          index: juz.juzNumber,
          title: 'الجزء ${juz.juzNumber}',
          subtitle: 'بداية من سورة ${juz.startingSurahName} (الآية ${juz.startingVerse})',
          pageNumber: juz.page,
          onTap: () => _handleItemTap(
            juz.page,
            title: 'الجزء ${juz.juzNumber}',
            fallbackSurahId: matchingSurah.id,
            initialVerse: juz.startingVerse,
          ),

        );
      },
    );
  }

  // --- SAJDAHS TAB ---
  Widget _buildSajdahsTab(AppTheme theme) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      itemCount: quranSajdahs.length,
      itemBuilder: (context, index) {
        final sajdah = quranSajdahs[index];
        final isMeccan = sajdah.revelationType == 'مكية';

        return _buildListTile(
          theme: theme,
          index: sajdah.sajdahNumber,
          title: 'سجدة التلاوة ${sajdah.sajdahNumber}',
          subtitle: 'سورة ${sajdah.surahName} • الآية ${sajdah.verse}',
          pageNumber: sajdah.page,
          badgeText: sajdah.revelationType,
          badgeColor: isMeccan ? Colors.amber : Colors.green,
          onTap: () => _handleItemTap(
            sajdah.page,
            title: 'سجدة ${sajdah.sajdahNumber}',
            fallbackSurahId: sajdah.surahNumber,
            initialVerse: sajdah.verse,
          ),

        );
      },
    );
  }

  // --- HELPER COMPONENT: CUSTOM LIST TILE ---
  Widget _buildListTile({
    required AppTheme theme,
    required int index,
    required String title,
    required String subtitle,
    required int pageNumber,
    String? badgeText,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        leading: IslamicNumberBadge(
          number: index,
          color: theme.accentColor,
          size: 44,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
            ),
            if (badgeText != null) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: (badgeColor ?? theme.accentColor).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.cairo(
                    color: badgeColor ?? theme.accentColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
            ],
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text(
            subtitle,
            style: GoogleFonts.cairo(
              color: theme.subtitleColor,
              fontSize: 12.sp,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: theme.accentColor.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                'صـ $pageNumber',
                style: GoogleFonts.cairo(
                  color: theme.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              Icons.chevron_left_rounded,
              color: theme.accentColor,
              size: 20.sp,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  // --- HELPER COMPONENT: SEARCH FIELD ---
  Widget _buildSearchField(AppTheme theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSurahs,
              style: GoogleFonts.cairo(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'ابحث عن سورة بالاسم أو الرقم...',
                hintStyle: GoogleFonts.cairo(color: Colors.white38, fontSize: 13.sp),
                prefixIcon: Icon(Icons.search_rounded, color: theme.accentColor, size: 22.sp),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close_rounded, color: Colors.white70, size: 20.sp),
                        onPressed: () {
                          _searchController.clear();
                          _filterSurahs('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
        ),
      ),
    );
  }

   // --- HELPER COMPONENT: EMPTY STATE ---
  Widget _buildEmptyState(AppTheme theme) {
    return Center(
      child: Text(
        'لم يتم العثور على نتائج للبحث',
        style: GoogleFonts.cairo(
          color: theme.subtitleColor,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  // --- SEARCH VERSES TAB ---
  Widget _buildSearchVersesTab(AppTheme theme) {
    return Column(
      children: [
        SizedBox(height: 16.h),
        _buildSearchFieldVerses(theme),
        SizedBox(height: 12.h),
        Expanded(
          child: _isSearchingVerses
              ? Center(
                  child: CircularProgressIndicator(
                    color: theme.accentColor,
                  ),
                )
              : _verseSearchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48.sp,
                            color: theme.subtitleColor.withValues(alpha: 0.5),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            _verseSearchController.text.trim().length < 2
                                ? 'اكتب كلمة أو جملة للبحث في المصحف'
                                : 'لا توجد نتائج مطابقة لبحثك',
                            style: GoogleFonts.cairo(
                              color: theme.subtitleColor,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(bottom: 24.h),
                      itemCount: _verseSearchResults.length,
                      itemBuilder: (context, index) {
                        final result = _verseSearchResults[index];
                        final page = quran.getPageNumber(result.surahNumber, result.verseNumber);

                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                          child: InkWell(
                            onTap: () => _handleItemTap(
                              page,
                              title: result.surahName,
                              fallbackSurahId: result.surahNumber,
                              initialVerse: result.verseNumber,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildHighlightedText(
                                  result.text,
                                  _verseSearchController.text.trim(),
                                  GoogleFonts.amiri(
                                    fontSize: 18.sp,
                                    color: theme.textColor,
                                    height: 1.8,
                                  ),
                                  GoogleFonts.amiri(
                                    fontSize: 18.sp,
                                    color: theme.accentColor,
                                    fontWeight: FontWeight.bold,
                                    height: 1.8,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'سورة ${result.surahName} • الآية ${result.verseNumber}',
                                      style: GoogleFonts.cairo(
                                        color: theme.subtitleColor,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: theme.accentColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10.r),
                                        border: Border.all(
                                          color: theme.accentColor.withValues(alpha: 0.15),
                                        ),
                                      ),
                                      child: Text(
                                        'صـ $page',
                                        style: GoogleFonts.cairo(
                                          color: theme.accentColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildSearchFieldVerses(AppTheme theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: TextField(
              controller: _verseSearchController,
              onChanged: _searchVerses,
              style: GoogleFonts.cairo(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'ابحث عن أي كلمة أو آية بالقرآن الكريم...',
                hintStyle: GoogleFonts.cairo(color: Colors.white38, fontSize: 13.sp),
                prefixIcon: Icon(Icons.search_rounded, color: theme.accentColor, size: 22.sp),
                suffixIcon: _verseSearchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close_rounded, color: Colors.white70, size: 20.sp),
                        onPressed: () {
                          _verseSearchController.clear();
                          _searchVerses('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    String text,
    String query,
    TextStyle normalStyle,
    TextStyle highlightStyle,
  ) {
    if (query.isEmpty) {
      return Text(
        text,
        style: normalStyle,
        textAlign: TextAlign.center,
      );
    }

    final normalizedQuery = _normalizeArabicText(query);
    final words = text.split(' ');
    final List<TextSpan> spans = [];

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final normalizedWord = _normalizeArabicText(word);
      final isMatch = normalizedWord.contains(normalizedQuery);

      spans.add(TextSpan(
        text: word,
        style: isMatch ? highlightStyle : normalStyle,
      ));

      if (i < words.length - 1) {
        spans.add(const TextSpan(text: ' '));
      }
    }

    return RichText(
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      text: TextSpan(children: spans),
    );
  }

  void _searchVerses(String query) {
    final cleanQuery = query.trim();
    if (cleanQuery.length < 2) {
      setState(() {
        _verseSearchResults = [];
      });
      return;
    }

    setState(() {
      _isSearchingVerses = true;
    });

    final normalizedQuery = _normalizeArabicText(cleanQuery);
    final results = <QuranSearchResult>[];

    for (int s = 1; s <= 114; s++) {
      final verseCount = quran.getVerseCount(s);
      final sName = quran.getSurahNameArabic(s);
      for (int v = 1; v <= verseCount; v++) {
        String verseText = quran.getVerse(s, v);
        if (s != 1 && v == 1) {
          const basmalaPrefix = 'بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ';
          if (verseText.startsWith(basmalaPrefix)) {
            verseText = verseText.substring(basmalaPrefix.length).trim();
          }
        }
        final normalizedVerse = _normalizeArabicText(verseText);
        if (normalizedVerse.contains(normalizedQuery)) {
          results.add(QuranSearchResult(
            surahNumber: s,
            verseNumber: v,
            text: verseText,
            surahName: sName,
          ));
        }
        if (results.length >= 100) break;
      }
      if (results.length >= 100) break;
    }

    setState(() {
      _verseSearchResults = results;
      _isSearchingVerses = false;
    });
  }
}

class QuranSearchResult {
  final int surahNumber;
  final int verseNumber;
  final String text;
  final String surahName;

  QuranSearchResult({
    required this.surahNumber,
    required this.verseNumber,
    required this.text,
    required this.surahName,
  });
}
