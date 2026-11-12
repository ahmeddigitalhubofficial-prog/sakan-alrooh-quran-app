// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/app_spacing.dart';
import '../data/quran_divisions_data.dart';
import '../models/theme_manager.dart';
import '../services/audio_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/tafsir_service.dart';
import '../widgets/common/auto_scroll_text.dart';
import 'card_studio_screen.dart';

class Reciter {
  final String name;
  final String subfolder;
  final String server;

  const Reciter({
    required this.name,
    required this.subfolder,
    required this.server,
  });
}

const List<Reciter> reciters = [
  Reciter(
    name: 'الشيخ محمود خليل الحصري',
    subfolder: 'husr',
    server: 'server13',
  ),
  Reciter(
    name: 'الشيخ عبد الباسط عبد الصمد',
    subfolder: 'basit',
    server: 'server7',
  ),
  Reciter(
    name: 'الشيخ محمد صديق المنشاوي',
    subfolder: 'minsh',
    server: 'server10',
  ),
  Reciter(
    name: 'الشيخ محمود علي البنا',
    subfolder: 'banna',
    server: 'server8',
  ),
  Reciter(
    name: 'الشيخ مصطفى إسماعيل',
    subfolder: 'mustafa',
    server: 'server8',
  ),
  Reciter(
    name: 'الشيخ مشاري العفاسي',
    subfolder: 'afs',
    server: 'server8',
  ),
  Reciter(
    name: 'الشيخ ماهر المعيقلي',
    subfolder: 'maher',
    server: 'server12',
  ),
  Reciter(
    name: 'الشيخ سعد الغامدي',
    subfolder: 's_gmd',
    server: 'server7',
  ),
  Reciter(
    name: 'الشيخ عبد الرحمن السديس',
    subfolder: 'sudais',
    server: 'server11',
  ),
  Reciter(
    name: 'الشيخ سعود الشريم',
    subfolder: 'shur',
    server: 'server7',
  ),
  Reciter(
    name: 'الشيخ ناصر القطامي',
    subfolder: 'qatami',
    server: 'server6',
  ),
  Reciter(
    name: 'الشيخ ياسر الدوسري',
    subfolder: 'duss',
    server: 'server11',
  ),
];

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final int? initialVerse;

  const SurahDetailScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
    this.initialVerse,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}


class _SurahDetailScreenState extends State<SurahDetailScreen> {
  double _fontSize = 24.sp;
  String _selectedFontFamily = 'Amiri';
  late final AudioPlayer _audioPlayer;

  void _changeFontFamily(String font) {
    setState(() {
      _selectedFontFamily = font;
    });
  }

  void _showFontSelectionSheet() {
    final theme = Provider.of<AppThemeManager>(context, listen: false).currentTheme;
    final fonts = [
      {'name': 'الأميري الرسمية', 'family': 'Amiri'},
      {'name': 'خط القاهرة العريض', 'family': 'Cairo'},
      {'name': 'خط شهرزاد النستعليق', 'family': 'Scheherazade New'},
      {'name': 'خط اللطيف العثماني', 'family': 'Lateef'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختر خط المصحف الشريف ✒️',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: theme.textColor,
              ),
            ),
            SizedBox(height: 12.h),
            ...fonts.map((f) => ListTile(
                  title: Text(
                    f['name']!,
                    style: GoogleFonts.getFont(
                      f['family']!,
                      fontSize: 20.sp,
                      color: theme.textColor,
                    ),
                  ),
                  trailing: _selectedFontFamily == f['family']
                      ? Icon(Icons.check_circle, color: theme.accentColor)
                      : null,
                  onTap: () {
                    _changeFontFamily(f['family']!);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }
  bool _isPlaying = false;
  bool _isLoading = false;
  String _selectedReciterName = 'الشيخ مشاري العفاسي';
  double _playbackSpeed = 1.0;

  void _changeSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    _audioPlayer.setSpeed(speed);
  }

  void _seekRelative(int seconds) {
    final current = _audioPlayer.position;
    final target = current + Duration(seconds: seconds);
    if (target > Duration.zero) {
      _audioPlayer.seek(target);
    } else {
      _audioPlayer.seek(Duration.zero);
    }
  }

  void _showSpeedDialog() {
    final theme = Provider.of<AppThemeManager>(context, listen: false).currentTheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'سرعة التلاوة',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                  final isSel = _playbackSpeed == speed;
                  return InkWell(
                    onTap: () {
                      _changeSpeed(speed);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSel ? theme.accentColor : theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: theme.accentColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        '${speed}x',
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: isSel ? theme.scaffoldBackgroundColor : theme.textColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 12.h),
            ],
          ),
        );
      },
    );
  }
  
  int? _bookmarkedVerse;
  int? _bookmarkedSurahNumber;
  int _currentJuz = 1;
  int _currentPage = 1;
  late final ScrollController _scrollController;
  
  // Continuous Reading Support
  late List<int> _loadedSurahNumbers;
  late int _activeSurahNumber;
  late String _activeSurahName;
  final Map<String, GlobalKey> _verseKeys = {}; // Composite key 'surahNum_verseNum' -> GlobalKey
  final Map<int, GlobalKey> _surahKeys = {};

  // Verse-by-verse audio tracking
  int? _activePlayingSurah;
  int? _activePlayingVerse;

  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  int _downloadedCount = 0;
  int _totalToDownload = 0;
  bool _currentSurahDownloaded = false;
  // Auto-save last read position
  int? _lastSavedSurah;
  int? _lastSavedVerse;
  ConcatenatingAudioSource? _currentPlaylist;
  int? _playlistSurahNumber;
  String? _playlistReciterFolder;

  // Quran Meanings Translation Engine (Independent, Default Pure Arabic 'none')
  String _selectedQuranTranslation = 'none';

  Future<void> _loadQuranTranslationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('quran_translation_lang') ?? 'none';
    if (!mounted) return;
    setState(() {
      _selectedQuranTranslation = saved;
    });
  }

  Future<void> _setQuranTranslationPreference(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quran_translation_lang', langCode);
    if (!mounted) return;
    setState(() {
      _selectedQuranTranslation = langCode;
    });
  }

  quran.Translation? _getQuranTranslationEnum(String code) {
    switch (code) {
      case 'en':
        return quran.Translation.enSaheeh;
      case 'fr':
        return quran.Translation.frHamidullah;
      case 'id':
        return quran.Translation.indonesian;
      case 'tr':
        return quran.Translation.trSaheeh;
      case 'ur':
        return quran.Translation.urdu;
      default:
        return null;
    }
  }

  String _getQuranTranslationTitle(String code) {
    switch (code) {
      case 'en':
        return 'English (Saheeh International)';
      case 'fr':
        return 'Français (Muhammad Hamidullah)';
      case 'id':
        return 'Bahasa Indonesia (Kemenag)';
      case 'tr':
        return 'Türkçe (Diyanet / Saheeh)';
      case 'ur':
        return 'اردو (فتح محمد جالندھری)';
      default:
        return 'بدون ترجمة (مصحف شريف نقي 100%)';
    }
  }

  String _getVerseTranslationText(int surahNum, int verseNum) {
    final transEnum = _getQuranTranslationEnum(_selectedQuranTranslation);
    if (transEnum == null) return '';
    try {
      return quran.getVerseTranslation(surahNum, verseNum, translation: transEnum);
    } catch (_) {
      return '';
    }
  }

  void _showQuranTranslationSelectionSheet() {
    final theme = Provider.of<AppThemeManager>(context, listen: false).currentTheme;
    final options = [
      {
        'code': 'none',
        'title': 'بدون ترجمة (مصحف شريف نقي 100%)',
        'sub': 'القراءة العربية الأصيلة المعتمدة دون أي ترجمة',
        'badge': 'الأصل الإلهي',
      },
      {
        'code': 'en',
        'title': 'English (Saheeh International)',
        'sub': 'King Fahd Complex verified translation',
        'badge': 'Verified',
      },
      {
        'code': 'fr',
        'title': 'Français (Dr. Muhammad Hamidullah)',
        'sub': 'Traduction autorisée du Complexe du Roi Fahd',
        'badge': 'Vérifié',
      },
      {
        'code': 'id',
        'title': 'Bahasa Indonesia (Kemenag)',
        'sub': 'Terjemahan resmi Kementerian Agama RI',
        'badge': 'Resmi',
      },
      {
        'code': 'tr',
        'title': 'Türkçe (Diyanet / Saheeh Meali)',
        'sub': 'Güvenilir Türkçe Kur\'an-ı Kerim Meali',
        'badge': 'Onaylı',
      },
      {
        'code': 'ur',
        'title': 'اردو (فتح محمد جالندھری)',
        'sub': 'مستند اور معتبر اردو ترجمہ قرآن مجید',
        'badge': 'مستند',
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: theme.textColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: theme.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.g_translate_rounded, color: theme.accentColor, size: 22.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ترجمة معاني القرآن الكريم',
                          style: GoogleFonts.cairo(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.textColor,
                          ),
                        ),
                        Text(
                          'تراجم معتمدة لفهم المعاني، والعربية أصل معجز',
                          style: GoogleFonts.cairo(
                            fontSize: 11.sp,
                            color: theme.subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified_outlined, color: Colors.amber.shade700, size: 16.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'جميع التراجم معتمدة من مجمع الملك فهد لطباعة المصحف الشريف والجهات الرسمية الإسلامية الموثوقة.',
                        style: GoogleFonts.cairo(
                          fontSize: 10.5.sp,
                          color: theme.textColor.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (ctx, i) {
                    final item = options[i];
                    final isSelected = _selectedQuranTranslation == item['code'];
                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _setQuranTranslationPreference(item['code']!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: theme.accentColor,
                            content: Text(
                              item['code'] == 'none'
                                  ? 'تم تفعيل المصحف الشريف بالنص العربي الأصيل 📖'
                                  : 'تم تفعيل: ${item['title']} 🌍',
                              style: GoogleFonts.cairo(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.accentColor.withValues(alpha: 0.16)
                              : theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: isSelected
                                ? theme.accentColor
                                : theme.accentColor.withValues(alpha: 0.15),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: isSelected ? theme.accentColor : theme.subtitleColor,
                              size: 20.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['title']!,
                                          style: GoogleFonts.cairo(
                                            fontSize: 13.sp,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            color: isSelected
                                                ? theme.accentColor
                                                : theme.textColor,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? theme.accentColor.withValues(alpha: 0.2)
                                              : Colors.grey.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          item['badge']!,
                                          style: GoogleFonts.cairo(
                                            fontSize: 9.sp,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? theme.accentColor
                                                : theme.subtitleColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    item['sub']!,
                                    style: GoogleFonts.cairo(
                                      fontSize: 10.5.sp,
                                      color: theme.subtitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Future<void> _autoSavePosition(int surahNum, int verseNum) async {
    if (_lastSavedSurah == surahNum && _lastSavedVerse == verseNum) return;
    _lastSavedSurah = surahNum;
    _lastSavedVerse = verseNum;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_surah', surahNum);
    await prefs.setString('last_read_surah_name', quran.getSurahNameArabic(surahNum));
    await prefs.setInt('last_read_verse', verseNum);
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioSession();
    _scrollController = ScrollController();

    _loadedSurahNumbers = [widget.surahNumber];
    _activeSurahNumber = widget.surahNumber;
    _activeSurahName = widget.surahName;
    _surahKeys[widget.surahNumber] = GlobalKey();

    final startVerse = widget.initialVerse ?? 1;
    _currentJuz = quran.getJuzNumber(widget.surahNumber, startVerse);
    _currentPage = quran.getPageNumber(widget.surahNumber, startVerse);

    final versesCount = quran.getVerseCount(widget.surahNumber);
    for (int i = 1; i <= versesCount; i++) {
      _verseKeys['${widget.surahNumber}_$i'] = GlobalKey();
    }

    _scrollController.addListener(_onScroll);
    _loadSavedReciter();
    _loadBookmark();
    _checkDownloadedStatus();
    _loadQuranTranslationPreference();

    _audioPlayer.playingStream.listen((playing) {
      if (!mounted) return;
      setState(() {
        _isPlaying = playing;
      });
    });

    _audioPlayer.currentIndexStream.listen((index) {
      if (!mounted || index == null) return;
      final newVerse = index + 1;
      if (_activePlayingSurah != null && _activePlayingVerse != newVerse) {
        setState(() {
          _activePlayingVerse = newVerse;
        });
        _scrollToVerse(_activePlayingSurah!, newVerse);
        _autoSavePosition(_activePlayingSurah!, newVerse);
      }
    });

    _audioPlayer.processingStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isLoading = state == ProcessingState.loading ||
            state == ProcessingState.buffering;
      });

      if (state == ProcessingState.completed) {
        _playNextVerse();
      }
    });

    if (widget.initialVerse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollToVerse(widget.surahNumber, widget.initialVerse!);
        });
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _scrollToVerse(int surahNumber, int verseNumber) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _verseKeys['${surahNumber}_$verseNumber'];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          alignment: 0.5,
        );
      } else {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (key != null && key.currentContext != null) {
            Scrollable.ensureVisible(
              key.currentContext!,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              alignment: 0.5,
            );
          }
        });
      }
    });
  }

  void _onScroll() {
    if (!mounted) return;

    // 1. Detect active Surah based on viewport position of Surah headers
    int activeSurah = _activeSurahNumber;
    for (int surahNum in _loadedSurahNumbers) {
      final key = _surahKeys[surahNum];
      if (key == null || key.currentContext == null) continue;
      
      final box = key.currentContext!.findRenderObject() as RenderBox?;
      if (box == null) continue;
      
      final position = box.localToGlobal(Offset.zero);
      final dy = position.dy;
      final height = box.size.height;
      
      if (dy < 300 && dy + height > 100) {
        activeSurah = surahNum;
        break;
      }
    }

    if (activeSurah != _activeSurahNumber) {
      setState(() {
        _activeSurahNumber = activeSurah;
        _activeSurahName = quran.getSurahNameArabic(activeSurah);
        if (_isPlaying) {
          _audioPlayer.stop();
          _isPlaying = false;
        }
      });
      _checkDownloadedStatus();
    }

    // 2. Load next Surah when reaching near the bottom of current content
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 600) {
      if (_loadedSurahNumbers.last < 114) {
        final nextSurah = _loadedSurahNumbers.last + 1;
        if (!_loadedSurahNumbers.contains(nextSurah)) {
          setState(() {
            _loadedSurahNumbers.add(nextSurah);
            _surahKeys[nextSurah] = GlobalKey();
            
            final versesCount = quran.getVerseCount(nextSurah);
            for (int i = 1; i <= versesCount; i++) {
              _verseKeys['${nextSurah}_$i'] = GlobalKey();
            }
          });
        }
      }
    }

    // 3. Update active Juz and Page numbers based on the visible verse in active Surah
    final versesCount = quran.getVerseCount(_activeSurahNumber);
    int low = 1;
    int high = versesCount;
    int visibleVerse = 1;
    const double threshold = 180.0;

    while (low <= high) {
      int mid = (low + high) ~/ 2;
      final key = _verseKeys['${_activeSurahNumber}_$mid'];
      if (key == null || key.currentContext == null) {
        low = mid + 1;
        continue;
      }
      final box = key.currentContext!.findRenderObject() as RenderBox?;
      if (box == null) {
        low = mid + 1;
        continue;
      }

      final position = box.localToGlobal(Offset.zero);
      final dy = position.dy;

      if (dy < threshold) {
        visibleVerse = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    final newJuz = quran.getJuzNumber(_activeSurahNumber, visibleVerse);
    final newPage = quran.getPageNumber(_activeSurahNumber, visibleVerse);

    if (newJuz != _currentJuz || newPage != _currentPage) {
      setState(() {
        _currentJuz = newJuz;
        _currentPage = newPage;
      });
    }

    _autoSavePosition(_activeSurahNumber, visibleVerse);
  }

  Future<void> _loadSavedReciter() async {
    final prefs = await SharedPreferences.getInstance();
    final reciterName = prefs.getString('preferred_reciter_name') ?? 'الشيخ مشاري العفاسي';
    if (!mounted) return;
    setState(() {
      _selectedReciterName = reciterName;
    });
  }

  Future<void> _loadBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSurah = prefs.getInt('last_read_surah');
    if (savedSurah != null) {
      setState(() {
        _bookmarkedSurahNumber = savedSurah;
        _bookmarkedVerse = prefs.getInt('last_read_verse');
      });
    }
  }

  Reciter _getSelectedReciter() {
    return reciters.firstWhere(
      (r) => r.name == _selectedReciterName,
      orElse: () => reciters.first,
    );
  }

  String _getReciterFolder(Reciter reciter) {
    if (reciter.name.contains('الحصري')) return 'Husary_128kbps';
    if (reciter.name.contains('عبد الباسط')) return 'Abdul_Basit_Murattal_64kbps';
    if (reciter.name.contains('المنشاوي')) return 'Minshawy_Murattal_128kbps';
    if (reciter.name.contains('البنا')) return 'Banna_32kbps';
    if (reciter.name.contains('مصطفى إسماعيل')) return 'Mustafa_Ismail_128kbps';
    if (reciter.name.contains('العفاسي')) return 'Alafasy_128kbps';
    if (reciter.name.contains('المعيقلي')) return 'MaherAlMuaiqly128kbps';
    if (reciter.name.contains('الغامدي')) return 'Ghamadi_40kbps';
    if (reciter.name.contains('السديس')) return 'Abdurrahmaan_As-Sudais_192kbps';
    if (reciter.name.contains('الشريم')) return 'Saood_ash-Shuraym_128kbps';
    if (reciter.name.contains('القطامي')) return 'Nasser_Alqatami_128kbps';
    if (reciter.name.contains('الدوسري')) return 'Yasser_Ad-Dussary_128kbps';
    return 'Alafasy_128kbps';
  }

  String _getVerseAudioUrl(int surahNum, int verseNum) {
    final reciter = _getSelectedReciter();
    final reciterFolder = _getReciterFolder(reciter);
    final surahStr = surahNum.toString().padLeft(3, '0');
    final verseStr = verseNum.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/$reciterFolder/$surahStr$verseStr.mp3';
  }

  Future<void> _playVerse(int surahNum, int verseNum) async {
    await AudioService.stop();
    final reciter = _getSelectedReciter();
    final reciterFolder = _getReciterFolder(reciter);

    setState(() {
      _activePlayingSurah = surahNum;
      _activePlayingVerse = verseNum;
      _isLoading = true;
    });

    try {
      if (_currentPlaylist == null ||
          _playlistSurahNumber != surahNum ||
          _playlistReciterFolder != reciterFolder) {
        final totalVerses = quran.getVerseCount(surahNum);
        final sources = <AudioSource>[];
        for (int i = 1; i <= totalVerses; i++) {
          final localPath = await _getLocalAudioPath(surahNum, i);
          final file = File(localPath);
          if (await file.exists()) {
            sources.add(AudioSource.file(localPath));
          } else {
            final url = _getVerseAudioUrl(surahNum, i);
            sources.add(AudioSource.uri(Uri.parse(url)));
          }
        }
        _currentPlaylist = ConcatenatingAudioSource(children: sources);
        _playlistSurahNumber = surahNum;
        _playlistReciterFolder = reciterFolder;
        await _audioPlayer.setAudioSource(_currentPlaylist!, initialIndex: verseNum - 1);
      } else {
        await _audioPlayer.seek(Duration.zero, index: verseNum - 1);
      }

      _scrollToVerse(surahNum, verseNum);
      _autoSavePosition(surahNum, verseNum);
      await _audioPlayer.play();

      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error playing verse: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          content: Text(
            'تعذر تشغيل الآية $verseNum من سورة ${quran.getSurahNameArabic(surahNum)}',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
        ),
      );
      
      setState(() {
        _isLoading = false;
        _isPlaying = false;
      });
    }
  }

  void _playNextVerse() {
    if (_activePlayingVerse == null || _activePlayingSurah == null) return;
    
    final currentVerseCount = quran.getVerseCount(_activePlayingSurah!);
    if (_activePlayingVerse! < currentVerseCount) {
      _playVerse(_activePlayingSurah!, _activePlayingVerse! + 1);
    } else {
      if (_activePlayingSurah! < 114) {
        final nextSurah = _activePlayingSurah! + 1;
        if (!_loadedSurahNumbers.contains(nextSurah)) {
          setState(() {
            _loadedSurahNumbers.add(nextSurah);
            _surahKeys[nextSurah] = GlobalKey();
            final versesCount = quran.getVerseCount(nextSurah);
            for (int i = 1; i <= versesCount; i++) {
              _verseKeys['${nextSurah}_$i'] = GlobalKey();
            }
          });
        }
        _playVerse(nextSurah, 1);
      } else {
        setState(() {
          _isPlaying = false;
          _activePlayingSurah = null;
          _activePlayingVerse = null;
        });
      }
    }
  }

  Future<void> _toggleAudio() async {
    if (_isLoading) return;
    HapticFeedback.lightImpact();

    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
      return;
    }

    if (_activePlayingSurah != null && _activePlayingVerse != null) {
      await _audioPlayer.play();
      setState(() {
        _isPlaying = true;
      });
      return;
    }

    _activePlayingSurah = _activeSurahNumber;
    _activePlayingVerse = 1;
    _playVerse(_activePlayingSurah!, _activePlayingVerse!);
  }

  void _changeFontSize(bool increase) {
    HapticFeedback.lightImpact();
    setState(() {
      if (increase && _fontSize < 38.sp) {
        _fontSize += 2.sp;
      }
      if (!increase && _fontSize > 18.sp) {
        _fontSize -= 2.sp;
      }
    });
  }

  void _copyVerse(int surahNum, String sName, int verseNumber, String verseText) {
    String textToCopy = '﴿ $verseText ﴾\n[$sName - الآية $verseNumber]';
    if (_selectedQuranTranslation != 'none') {
      final trans = _getVerseTranslationText(surahNum, verseNumber);
      if (trans.isNotEmpty) {
        textToCopy += '\n\n📖 [${_getQuranTranslationTitle(_selectedQuranTranslation)}]:\n$trans';
      }
    }
    Clipboard.setData(
      ClipboardData(
        text: textToCopy,
      ),
    );
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'تم نسخ الآية',
          style: GoogleFonts.cairo(),
        ),
      ),
    );
  }

  Future<void> _saveBookmark(int surahNum, int verseNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_surah', surahNum);
    await prefs.setInt('last_surah', surahNum);
    await prefs.setString('last_read_surah_name', quran.getSurahNameArabic(surahNum));
    await prefs.setInt('last_read_verse', verseNumber);
    await prefs.setInt('last_verse', verseNumber);
    await prefs.setInt('last_page', quran.getPageNumber(surahNum, verseNumber));
    
    setState(() {
      _bookmarkedSurahNumber = surahNum;
      _bookmarkedVerse = verseNumber;
    });

    // مزامنة سحابية لحظية ومباشرة لحفظ موقف القراءة في Firestore
    CloudSyncService.autoSyncOnDataChange();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          content: Text(
            'تم حفظ علامة الوقوف عند سورة ${quran.getSurahNameArabic(surahNum)} - الآية $verseNumber',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  void _showVerseOptions(int surahNum, int verseNumber, String verseText) {
    final theme = Provider.of<AppThemeManager>(context, listen: false).currentTheme;
    final sName = quran.getSurahNameArabic(surahNum);
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
              side: BorderSide(color: theme.accentColor.withValues(alpha: 0.3)),
            ),
            title: Text(
              'خيارات الآية $verseNumber - سورة $sName',
              style: GoogleFonts.cairo(
                color: theme.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              '﴿ $verseText ﴾',
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 18.sp,
                color: theme.textColor,
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _playVerse(surahNum, verseNumber);
                },
                icon: Icon(Icons.play_circle_fill, color: theme.accentColor),
                label: Text(
                  'تشغيل من هذه الآية',
                  style: GoogleFonts.cairo(color: theme.textColor),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _copyVerse(surahNum, sName, verseNumber, verseText);
                },
                icon: Icon(Icons.copy, color: theme.accentColor),
                label: Text(
                  'نسخ الآية',
                  style: GoogleFonts.cairo(color: theme.textColor),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await _saveBookmark(surahNum, verseNumber);
                },
                icon: Icon(Icons.bookmark_add, color: theme.accentColor),
                label: Text(
                  'حفظ كعلامة وقوف',
                  style: GoogleFonts.cairo(color: theme.textColor),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showTafsirDialog(surahNum, sName, verseNumber, verseText, theme);
                },
                icon: Icon(Icons.menu_book_rounded, color: theme.accentColor),
                label: Text(
                  'عرض التفسير الميسر 📖',
                  style: GoogleFonts.cairo(color: theme.textColor),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _shareAsQuoteCard(surahNum, sName, verseNumber, verseText, theme);
                },
                icon: Icon(Icons.share_rounded, color: theme.accentColor),
                label: Text(
                  'مشاركة نصية سريعة 📋',
                  style: GoogleFonts.cairo(color: theme.textColor),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CardStudioScreen(
                        initialText: '﴿ $verseText ﴾',
                        initialSource: 'سورة $sName - الآية $verseNumber',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt_rounded, color: Color(0xFF25D366)),
                label: Text(
                  'صمم وشارك كحالة ستوري (9:16) 📲',
                  style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareAsQuoteCard(int surahNum, String sName, int verseNumber, String verseText, dynamic theme) async {
    final tafsirText = await TafsirService.getTafsir(
      surahNumber: surahNum,
      verseNumber: verseNumber,
      verseText: verseText,
    );

    String translationSection = '';
    if (_selectedQuranTranslation != 'none') {
      final trans = _getVerseTranslationText(surahNum, verseNumber);
      if (trans.isNotEmpty) {
        translationSection = '\n------------------------\n🌍 ${_getQuranTranslationTitle(_selectedQuranTranslation)}:\n$trans\n';
      }
    }

    final formattedCardText = '''
✨ ﴿ $verseText ﴾ ✨
------------------------
📖 سورة $sName - الآية $verseNumber$translationSection------------------------
💡 التفسير الميسر:
$tafsirText

-- تم المشاركة عبر تطبيق سكن الروح 🕌
''';

    await Clipboard.setData(ClipboardData(text: formattedCardText));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: theme.accentColor,
          content: Text(
            'تم تجهيز ونسخ البطاقة الدعوية للآية والتفسير بنجاح! 🎨',
            style: GoogleFonts.cairo(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  static String getCleanVerseText(int surahNum, int verseNumber) {
    String text = quran.getVerse(surahNum, verseNumber);
    if (surahNum != 1 && verseNumber == 1) {
      const basmalaPrefix = 'بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ';
      if (text.startsWith(basmalaPrefix)) {
        text = text.substring(basmalaPrefix.length).trim();
      }
    }
    return text;
  }

  // 1. علامة بداية الجزء: شارة ملكية مذهبة بإطار هندسي مذهب متوهج
  Widget _buildJuzSymbol(dynamic theme) {
    return Container(
      margin: EdgeInsets.only(left: 6.w, right: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.gold,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.3),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        '۞',
        style: GoogleFonts.amiri(
          fontSize: 18.sp,
          fontWeight: FontWeight.w900,
          color: AppColors.gold,
          height: 1.0,
        ),
      ),
    );
  }

  // 2. علامة بداية الحزب: وردة قرآنية دائرية عنبرية ناعمة مفرغة
  Widget _buildHizbSymbol(dynamic theme) {
    return Container(
      margin: EdgeInsets.only(left: 6.w, right: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.amber.shade700,
          width: 1.1,
        ),
      ),
      child: Text(
        '۞',
        style: GoogleFonts.amiri(
          fontSize: 13.5.sp,
          color: Colors.amber.shade700,
          fontWeight: FontWeight.bold,
          height: 1.0,
        ),
      ),
    );
  }

  // 3. علامة السجدة: رمز المحراب الإسلامي الشريف ۩ بإطار زمردي أنيق
  Widget _buildSajdahSymbol(dynamic theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFF047857).withValues(alpha: 0.22),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.r),
          topRight: Radius.circular(8.r),
          bottomLeft: Radius.circular(3.r),
          bottomRight: Radius.circular(3.r),
        ),
        border: Border.all(
          color: const Color(0xFF10B981),
          width: 1.2,
        ),
      ),
      child: Text(
        '۩',
        style: GoogleFonts.amiri(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF10B981),
          height: 1.0,
        ),
      ),
    );
  }

  void _showTafsirDialog(int surahNum, String sName, int verseNumber, String verseText, dynamic theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book_rounded, color: theme.accentColor),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'التفسير الميسر (سورة $sName - آية $verseNumber)',
                          style: GoogleFonts.cairo(
                            color: theme.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: theme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      '﴿ $verseText ﴾',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 17.sp,
                        color: theme.textColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'التفسير الميسر:',
                    style: GoogleFonts.cairo(
                      color: theme.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  FutureBuilder<String>(
                    future: TafsirService.getTafsir(
                      surahNumber: surahNum,
                      verseNumber: verseNumber,
                      verseText: verseText,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: theme.accentColor,
                            ),
                          ),
                        );
                      }
                      final tafsirText = snapshot.data ??
                          'تعذر جلب التفسير، يرجى التأكد من الاتصال بالإنترنت والمحاولة مجدداً.';
                      return Text(
                        tafsirText,
                        style: GoogleFonts.cairo(
                          color: theme.textColor,
                          fontSize: 14.sp,
                          height: 1.6,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showReciterSelection() {
    final egyptianReciters = reciters.where((r) =>
      r.name.contains('الحصري') ||
      r.name.contains('عبد الباسط') ||
      r.name.contains('المنشاوي') ||
      r.name.contains('البنا') ||
      r.name.contains('مصطفى إسماعيل')
    ).toList();

    final arabReciters = reciters.where((r) => !egyptianReciters.contains(r)).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Provider.of<AppThemeManager>(context, listen: false).currentTheme;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.65,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Text(
                    'اختر القارئ المفضل',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.accentColor,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TabBar(
                    indicatorColor: theme.accentColor,
                    labelColor: theme.accentColor,
                    unselectedLabelColor: theme.subtitleColor,
                    labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13.sp),
                    unselectedLabelStyle: GoogleFonts.cairo(fontSize: 12.sp),
                    tabs: const [
                      Tab(text: '🇪🇬 القراء المصريون'),
                      Tab(text: '🇸🇦 القراء العرب والخليج'),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildReciterList(egyptianReciters, theme),
                        _buildReciterList(arabReciters, theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReciterList(List<Reciter> list, AppTheme theme) {
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white10),
      itemBuilder: (context, index) {
        final r = list[index];
        final isSelected = r.name == _selectedReciterName;
        return ListTile(
          title: Text(
            r.name,
            style: GoogleFonts.cairo(
              color: isSelected ? theme.accentColor : theme.textColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: isSelected
              ? Icon(Icons.check_circle_rounded, color: theme.accentColor)
              : null,
          onTap: () async {
            Navigator.pop(context);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('preferred_reciter_name', r.name);

            setState(() {
              _selectedReciterName = r.name;
            });

            if (_isPlaying && _activePlayingSurah != null && _activePlayingVerse != null) {
              await _audioPlayer.stop();
              _playVerse(_activePlayingSurah!, _activePlayingVerse!);
            }
          },
        );
      },
    );
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
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _changeFontSize(false),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.remove, size: 20.sp, color: Colors.white),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                _activeSurahName,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              InkWell(
                onTap: () => _changeFontSize(true),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, size: 20.sp, color: Colors.white),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.g_translate_rounded,
                    color: _selectedQuranTranslation != 'none' ? Colors.amberAccent : Colors.white,
                    size: 22.sp,
                  ),
                  if (_selectedQuranTranslation != 'none')
                    Positioned(
                      top: -1,
                      right: -1,
                      child: Container(
                        width: 7.r,
                        height: 7.r,
                        decoration: const BoxDecoration(
                          color: Colors.amberAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              tooltip: 'ترجمة معاني القرآن',
              onPressed: _showQuranTranslationSelectionSheet,
            ),
            IconButton(
              icon: Icon(Icons.font_download_outlined, color: Colors.white, size: 22.sp),
              tooltip: 'تغيير خط المصحف',
              onPressed: _showFontSelectionSheet,
            ),
            InkWell(
              onTap: _showReciterSelection,
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: theme.accentColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.record_voice_over_rounded, color: Colors.amber, size: 18.sp),
                    SizedBox(width: 4.w),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 90.w),
                      child: AutoScrollText(
                        _selectedReciterName,
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.white, size: 18.sp),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Container(
          width: double.infinity,
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
                // Premium Info Bar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: theme.cardColor.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: theme.accentColor.withValues(alpha: 0.2),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Surah Name
                      Row(
                        children: [
                          Icon(Icons.menu_book_rounded, color: theme.accentColor, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'سورة $_activeSurahName',
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.textColor,
                            ),
                          ),
                        ],
                      ),
                      // Vertical divider
                      Container(height: 16.h, width: 1.w, color: theme.accentColor.withValues(alpha: 0.3)),
                      // Juz
                      Row(
                        children: [
                          Icon(Icons.grid_3x3_rounded, color: theme.accentColor, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'الجزء $_currentJuz',
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.textColor,
                            ),
                          ),
                        ],
                      ),
                      // Vertical divider
                      Container(height: 16.h, width: 1.w, color: theme.accentColor.withValues(alpha: 0.3)),
                      // Page
                      Row(
                        children: [
                          Icon(Icons.pages_rounded, color: theme.accentColor, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'الصفحة $_currentPage',
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    itemCount: _loadedSurahNumbers.length,
                    itemBuilder: (context, index) {
                      final surahNum = _loadedSurahNumbers[index];
                      final sName = quran.getSurahNameArabic(surahNum);
                      final versesCount = quran.getVerseCount(surahNum);
                      final showBasmala = surahNum != 1 && surahNum != 9;

                      return Container(
                        key: _surahKeys[surahNum],
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 24.h),
                        padding: EdgeInsets.all(22.w),
                        decoration: BoxDecoration(
                          color: theme.cardColor.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(28.r),
                          border: Border.all(
                            color: theme.accentColor.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Surah Separator / Header Banner
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    'سورة $sName',
                                    style: GoogleFonts.cairo(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: theme.accentColor,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    'نزولها: ${quran.getPlaceOfRevelation(surahNum) == 'Makkah' ? 'مكية' : 'مدنية'} | آياتها: $versesCount',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.sp,
                                      color: theme.subtitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              height: 30.h,
                              color: theme.accentColor.withValues(alpha: 0.2),
                              thickness: 1.2,
                            ),
                            if (showBasmala) ...[
                              Text(
                                quran.basmala,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.amiri(
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.bold,
                                  color: theme.accentColor,
                                  height: 1.8,
                                ),
                              ),
                              AppSpacing.h30,
                            ],
                            if (_selectedQuranTranslation == 'none')
                              Wrap(
                                alignment: WrapAlignment.center,
                                runSpacing: 14.h,
                                children: List.generate(
                                  versesCount,
                                  (idx) {
                                    final verseNumber = idx + 1;
                                    final verseText = getCleanVerseText(
                                      surahNum,
                                      verseNumber,
                                    );
                                    final isBookmarked = _bookmarkedSurahNumber == surahNum &&
                                        _bookmarkedVerse == verseNumber;
                                    final isPlaying = _activePlayingSurah == surahNum &&
                                        _activePlayingVerse == verseNumber;
                                    final isJuz = QuranDivisions.isJuzStart(surahNum, verseNumber);
                                    final isHizb = QuranDivisions.isHizbStart(surahNum, verseNumber);
                                    final isSajdah = QuranDivisions.isSajdah(surahNum, verseNumber);

                                    return GestureDetector(
                                      key: _verseKeys['${surahNum}_$verseNumber'],
                                      onLongPress: () {
                                        _showVerseOptions(surahNum, verseNumber, verseText);
                                      },
                                      onTap: () {
                                        _showVerseOptions(surahNum, verseNumber, verseText);
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isPlaying
                                              ? theme.accentColor.withValues(alpha: 0.15)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(12.r),
                                          border: Border.all(
                                            color: isPlaying
                                                ? theme.accentColor.withValues(alpha: 0.35)
                                                : Colors.transparent,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              if (isJuz)
                                                WidgetSpan(
                                                  alignment: PlaceholderAlignment.middle,
                                                  child: _buildJuzSymbol(theme),
                                                )
                                              else if (isHizb)
                                                WidgetSpan(
                                                  alignment: PlaceholderAlignment.middle,
                                                  child: _buildHizbSymbol(theme),
                                                ),
                                              TextSpan(
                                                text: '$verseText ',
                                                style: GoogleFonts.getFont(
                                                  _selectedFontFamily,
                                                  fontSize: _fontSize,
                                                  fontWeight: FontWeight.w500,
                                                  color: isPlaying
                                                      ? theme.accentColor
                                                      : (isBookmarked
                                                          ? theme.accentColor
                                                          : theme.textColor),
                                                  height: 2.2,
                                                ),
                                              ),
                                              if (isSajdah)
                                                WidgetSpan(
                                                  alignment: PlaceholderAlignment.middle,
                                                  child: _buildSajdahSymbol(theme),
                                                ),
                                              WidgetSpan(
                                                alignment: PlaceholderAlignment.middle,
                                                child: Container(
                                                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                                                  padding: EdgeInsets.all(5.w),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: isPlaying
                                                          ? theme.accentColor
                                                          : (isBookmarked
                                                              ? Colors.redAccent
                                                              : theme.accentColor),
                                                      width: isPlaying || isBookmarked ? 1.8 : 1.0,
                                                    ),
                                                    color: isPlaying
                                                        ? theme.accentColor.withValues(alpha: 0.25)
                                                        : (isBookmarked
                                                            ? Colors.redAccent.withOpacity(0.2)
                                                            : theme.scaffoldBackgroundColor),
                                                   ),
                                                   child: Text(
                                                    '$verseNumber',
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 10.sp,
                                                      fontWeight: FontWeight.bold,
                                                      color: isPlaying
                                                          ? theme.accentColor
                                                          : (isBookmarked
                                                              ? Colors.redAccent
                                                              : theme.accentColor),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: List.generate(
                                  versesCount,
                                  (idx) {
                                    final verseNumber = idx + 1;
                                    final verseText = getCleanVerseText(
                                      surahNum,
                                      verseNumber,
                                    );
                                    final isBookmarked = _bookmarkedSurahNumber == surahNum &&
                                        _bookmarkedVerse == verseNumber;
                                    final isPlaying = _activePlayingSurah == surahNum &&
                                        _activePlayingVerse == verseNumber;
                                    final isJuz = QuranDivisions.isJuzStart(surahNum, verseNumber);
                                    final isHizb = QuranDivisions.isHizbStart(surahNum, verseNumber);
                                    final isSajdah = QuranDivisions.isSajdah(surahNum, verseNumber);
                                    final translationText = _getVerseTranslationText(surahNum, verseNumber);
                                    final isUrdu = _selectedQuranTranslation == 'ur';

                                    return Container(
                                      key: _verseKeys['${surahNum}_$verseNumber'],
                                      margin: EdgeInsets.only(bottom: 14.h),
                                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                                      decoration: BoxDecoration(
                                        color: isPlaying
                                            ? theme.accentColor.withValues(alpha: 0.14)
                                            : theme.cardColor.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(16.r),
                                        border: Border.all(
                                          color: isPlaying
                                              ? theme.accentColor
                                              : (isBookmarked
                                                  ? Colors.redAccent.withValues(alpha: 0.5)
                                                  : theme.accentColor.withValues(alpha: 0.18)),
                                          width: isPlaying ? 1.5 : 1.0,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          // Top Verse Header Row: Verse badge, markers, controls
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                                                decoration: BoxDecoration(
                                                  color: isPlaying
                                                      ? theme.accentColor
                                                      : theme.accentColor.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(12.r),
                                                  border: Border.all(
                                                    color: theme.accentColor.withValues(alpha: 0.35),
                                                  ),
                                                ),
                                                child: Text(
                                                  'آية $verseNumber',
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 11.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: isPlaying ? Colors.black : theme.accentColor,
                                                  ),
                                                ),
                                              ),
                                              if (isJuz) _buildJuzSymbol(theme),
                                              if (isHizb) _buildHizbSymbol(theme),
                                              if (isSajdah) _buildSajdahSymbol(theme),
                                              const Spacer(),
                                              // Actions
                                              InkWell(
                                                onTap: () => _playVerse(surahNum, verseNumber),
                                                borderRadius: BorderRadius.circular(20.r),
                                                child: Padding(
                                                  padding: EdgeInsets.all(6.w),
                                                  child: Icon(
                                                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                                    color: theme.accentColor,
                                                    size: 22.sp,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () => _saveBookmark(surahNum, verseNumber),
                                                borderRadius: BorderRadius.circular(20.r),
                                                child: Padding(
                                                  padding: EdgeInsets.all(6.w),
                                                  child: Icon(
                                                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                                    color: isBookmarked ? Colors.redAccent : theme.subtitleColor,
                                                    size: 20.sp,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () => _showTafsirDialog(surahNum, sName, verseNumber, verseText, theme),
                                                borderRadius: BorderRadius.circular(20.r),
                                                child: Padding(
                                                  padding: EdgeInsets.all(6.w),
                                                  child: Icon(
                                                    Icons.menu_book_rounded,
                                                    color: theme.subtitleColor,
                                                    size: 20.sp,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () => _showVerseOptions(surahNum, verseNumber, verseText),
                                                borderRadius: BorderRadius.circular(20.r),
                                                child: Padding(
                                                  padding: EdgeInsets.all(6.w),
                                                  child: Icon(
                                                    Icons.more_horiz_rounded,
                                                    color: theme.subtitleColor,
                                                    size: 20.sp,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10.h),
                                          // Pure Arabic Verse Text
                                          Text(
                                            verseText,
                                            textAlign: TextAlign.right,
                                            style: GoogleFonts.getFont(
                                              _selectedFontFamily,
                                              fontSize: _fontSize,
                                              fontWeight: FontWeight.w500,
                                              color: isPlaying
                                                  ? theme.accentColor
                                                  : (isBookmarked ? theme.accentColor : theme.textColor),
                                              height: 2.1,
                                            ),
                                          ),
                                          // Authorized Translation Container
                                          if (translationText.isNotEmpty) ...[
                                            SizedBox(height: 10.h),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                              decoration: BoxDecoration(
                                                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.65),
                                                borderRadius: BorderRadius.circular(12.r),
                                                border: Border.all(
                                                  color: theme.accentColor.withValues(alpha: 0.15),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    isUrdu ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.translate_rounded,
                                                        size: 13.sp,
                                                        color: theme.accentColor,
                                                      ),
                                                      SizedBox(width: 5.w),
                                                      Text(
                                                        _getQuranTranslationTitle(_selectedQuranTranslation),
                                                        style: GoogleFonts.cairo(
                                                          fontSize: 10.5.sp,
                                                          fontWeight: FontWeight.bold,
                                                          color: theme.accentColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 6.h),
                                                  Directionality(
                                                    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                                                    child: Text(
                                                      translationText,
                                                      textAlign: isUrdu ? TextAlign.right : TextAlign.left,
                                                      style: isUrdu
                                                          ? GoogleFonts.cairo(
                                                              fontSize: 13.5.sp,
                                                              color: theme.textColor.withValues(alpha: 0.95),
                                                              height: 1.8,
                                                            )
                                                          : GoogleFonts.cairo(
                                                              fontSize: 13.sp,
                                                              color: theme.textColor.withValues(alpha: 0.9),
                                                              height: 1.6,
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    border: Border(
                      top: BorderSide(
                        color: theme.accentColor.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _isDownloading
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'جاري تحميل التلاوة...',
                                      style: GoogleFonts.cairo(
                                        fontSize: 11.sp,
                                        color: theme.accentColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.r),
                                      child: LinearProgressIndicator(
                                        value: _downloadProgress,
                                        backgroundColor: Colors.white10,
                                        color: theme.accentColor,
                                        minHeight: 6.h,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'تم تحميل $_downloadedCount من $_totalToDownload آية (${(_downloadProgress * 100).toInt()}%)',
                                      style: GoogleFonts.cairo(
                                        fontSize: 9.sp,
                                        color: theme.subtitleColor,
                                      ),
                                    ),
                                  ],
                                )
                              : InkWell(
                                  onTap: _showReciterSelection,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'القارئ الحالي',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11.sp,
                                          color: theme.subtitleColor,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: AutoScrollText(
                                              _selectedReciterName,
                                              style: GoogleFonts.cairo(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                                color: theme.accentColor,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            color: theme.accentColor,
                                            size: 20.sp,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        if (!_isDownloading) ...[
                          SizedBox(width: 8.w),
                          IconButton(
                            onPressed: () => _seekRelative(-10),
                            icon: Icon(
                              Icons.replay_10_rounded,
                              color: theme.accentColor,
                              size: 24.sp,
                            ),
                            tooltip: 'تأخير 10 ثوانٍ',
                          ),
                          IconButton(
                            onPressed: _downloadCurrentSurah,
                            icon: Icon(
                              _currentSurahDownloaded
                                  ? Icons.cloud_done_rounded
                                  : Icons.cloud_download_rounded,
                              color: _currentSurahDownloaded
                                  ? Colors.greenAccent
                                  : theme.accentColor,
                              size: 24.sp,
                            ),
                            tooltip: _currentSurahDownloaded
                                ? 'السورة محملة بالكامل'
                                : 'تحميل السورة للاستماع دون اتصال',
                          ),
                        ],
                        SizedBox(width: 10.w),
                        InkWell(
                          onTap: _toggleAudio,
                          borderRadius: BorderRadius.circular(40.r),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 54.w,
                            height: 54.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.accentColor,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.accentColor.withValues(alpha: 0.28),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? SizedBox(
                                      width: 22.w,
                                      height: 22.w,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: theme.scaffoldBackgroundColor,
                                      ),
                                    )
                                  : Icon(
                                      _isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: theme.scaffoldBackgroundColor,
                                      size: 30.sp,
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        IconButton(
                          onPressed: () => _seekRelative(10),
                          icon: Icon(
                            Icons.forward_10_rounded,
                            color: theme.accentColor,
                            size: 24.sp,
                          ),
                          tooltip: 'تقديم 10 ثوانٍ',
                        ),
                        SizedBox(width: 8.w),
                        InkWell(
                          onTap: _showSpeedDialog,
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: theme.accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: theme.accentColor.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              '${_playbackSpeed}x',
                              style: GoogleFonts.cairo(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.accentColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: _isPlaying
                                ? Colors.green.withValues(alpha: 0.18)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Text(
                            _isPlaying ? 'جارٍ التشغيل' : 'متوقف',
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              color: _isPlaying
                                  ? Colors.greenAccent
                                  : theme.subtitleColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      debugPrint('Error initializing audio session: $e');
    }
  }

  Future<String> _getLocalAudioPath(int surahNum, int verseNum) async {
    final reciter = _getSelectedReciter();
    final reciterFolder = _getReciterFolder(reciter);
    final surahStr = surahNum.toString().padLeft(3, '0');
    final verseStr = verseNum.toString().padLeft(3, '0');
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/audio/$reciterFolder/$surahStr$verseStr.mp3';
  }

  Future<void> _downloadCurrentSurah() async {
    if (_isDownloading) return;
    HapticFeedback.lightImpact();

    final surahNum = _activeSurahNumber;
    final versesCount = quran.getVerseCount(surahNum);
    
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadedCount = 0;
      _totalToDownload = versesCount;
    });

    final client = HttpClient();
    
    try {
      for (int v = 1; v <= versesCount; v++) {
        if (!_isDownloading) break;
        
        final localPath = await _getLocalAudioPath(surahNum, v);
        final file = File(localPath);
        await file.parent.create(recursive: true);
        
        if (!await file.exists()) {
          final url = _getVerseAudioUrl(surahNum, v);
          final request = await client.getUrl(Uri.parse(url));
          final response = await request.close();
          
          if (response.statusCode == 200) {
            final bytes = await response.fold<List<int>>([], (p, e) => p..addAll(e));
            await file.writeAsBytes(bytes);
          }
        }
        
        if (mounted) {
          setState(() {
            _downloadedCount++;
            _downloadProgress = _downloadedCount / _totalToDownload;
          });
        }
      }
      
      await _checkDownloadedStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            content: Text(
              'تم تحميل سورة ${quran.getSurahNameArabic(surahNum)} بنجاح للاستماع بدون إنترنت',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Download error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            content: Text(
              'حدث خطأ أثناء تحميل السورة. تأكد من اتصالك بالإنترنت.',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    } finally {
      client.close();
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future<bool> _isSurahDownloaded(int surahNum) async {
    final versesCount = quran.getVerseCount(surahNum);
    for (int v = 1; v <= versesCount; v++) {
      final localPath = await _getLocalAudioPath(surahNum, v);
      final file = File(localPath);
      if (!await file.exists()) {
        return false;
      }
    }
    return true;
  }

  Future<void> _checkDownloadedStatus() async {
    final downloaded = await _isSurahDownloaded(_activeSurahNumber);
    if (!mounted) return;
    setState(() {
      _currentSurahDownloaded = downloaded;
    });
  }
}

