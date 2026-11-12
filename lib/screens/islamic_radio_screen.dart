// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../models/theme_manager.dart';
import '../core/helpers/app_lifecycle_helper.dart';
import '../widgets/common/auto_scroll_text.dart';

class RadioStation {
  final String id;
  final String name;
  final String description;
  final String url;
  final List<String> fallbackUrls;
  final String country;
  final IconData icon;
  final Color accentColor;

  const RadioStation({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    this.fallbackUrls = const [],
    required this.country,
    required this.icon,
    required this.accentColor,
  });
}

class IslamicRadioScreen extends StatefulWidget {
  const IslamicRadioScreen({super.key});

  @override
  State<IslamicRadioScreen> createState() => _IslamicRadioScreenState();
}

class _IslamicRadioScreenState extends State<IslamicRadioScreen>
    with WidgetsBindingObserver {
  static final AudioPlayer _radioPlayer = AudioPlayer();
  StreamSubscription? _playerStateSubscription;
  static RadioStation? _currentStation;
  static bool _isPlaying = false;
  static bool _isLoading = false;

  static const List<RadioStation> stations = [
    RadioStation(
      id: 'cairo',
      name: 'إذاعة القرآن الكريم من القاهرة',
      description: 'البث المباشر الرسمي للإذاعة الأعرق في العالم الإسلامي 24/7',
      url: 'https://stream.radiojar.com/8s5u8tpdtwzuv',
      fallbackUrls: [
        'https://stream.zeno.fm/f3wvbbqmdg8uv',
        'https://n0a.radiojar.com/8s5u8tpdtwzuv',
        'https://backup.qurango.net/radio/tarateel',
      ],
      country: 'مصر 🇪🇬',
      icon: Icons.radio_rounded,
      accentColor: Color(0xFFD4AF37),
    ),
    RadioStation(
      id: 'makkah',
      name: 'إذاعة القرآن الكريم من مكة المكرمة',
      description: 'تلاوات خاشعة حية من المسجد الحرام',
      url: 'https://qurango.net/radio/makkah',
      fallbackUrls: [
        'https://backup.qurango.net/radio/makkah',
      ],
      country: 'مكة المكرمة 🕋',
      icon: Icons.mosque_rounded,
      accentColor: Color(0xFF00E676),
    ),
    RadioStation(
      id: 'medina',
      name: 'إذاعة القرآن الكريم من المدينة المنورة',
      description: 'تلاوات الحرم النبوي الشريف وأئمة المدينة',
      url: 'https://qurango.net/radio/medina',
      fallbackUrls: [
        'https://backup.qurango.net/radio/medina',
      ],
      country: 'المدينة المنورة 🕌',
      icon: Icons.location_city_rounded,
      accentColor: Color(0xFF00E5FF),
    ),
    RadioStation(
      id: 'abdulbasit',
      name: 'إذاعة الشيخ عبد الباسط عبد الصمد',
      description: 'المصحف المجود بصوت قيثارة السماء',
      url: 'https://qurango.net/radio/abdulbasit_abdulsamad_mojawwad',
      fallbackUrls: [
        'https://backup.qurango.net/radio/abdulbasit_abdulsamad_mojawwad',
      ],
      country: 'مصر 🇪🇬',
      icon: Icons.mic_external_on_rounded,
      accentColor: Color(0xFFFFD54F),
    ),
    RadioStation(
      id: 'hussary',
      name: 'إذاعة الشيخ محمود خليل الحصري',
      description: 'المصحف المرتل برواية حفص عن عاصم',
      url: 'https://qurango.net/radio/mahmoud_khalil_alhussary',
      fallbackUrls: [
        'https://backup.qurango.net/radio/mahmoud_khalil_alhussary',
      ],
      country: 'مصر 🇪🇬',
      icon: Icons.mic_rounded,
      accentColor: Color(0xFF81C784),
    ),
    RadioStation(
      id: 'minshawi',
      name: 'إذاعة الشيخ محمد صديق المنشاوي',
      description: 'التلاوات المرتلة بصوت الشجن الخاشع',
      url: 'https://qurango.net/radio/mohamed_siddiq_alminshawi',
      fallbackUrls: [
        'https://backup.qurango.net/radio/mohamed_siddiq_alminshawi',
      ],
      country: 'مصر 🇪🇬',
      icon: Icons.record_voice_over_rounded,
      accentColor: Color(0xFF64B5F6),
    ),
    RadioStation(
      id: 'afasi',
      name: 'إذاعة الشيخ مشاري بن راشد العفاسي',
      description: 'تلاوات وأدعية وأذكار بصوت الشيخ مشاري',
      url: 'https://qurango.net/radio/mishary_alafasi',
      fallbackUrls: [
        'https://backup.qurango.net/radio/mishary_alafasi',
      ],
      country: 'الكويت 🇰🇼',
      icon: Icons.music_note_rounded,
      accentColor: Color(0xFFFF8A65),
    ),
    RadioStation(
      id: 'roqiah',
      name: 'إذاعة الرقية الشرعية المباشرة',
      description: 'آيات الشفاء والحفظ والتحصين على مدار الساعة',
      url: 'https://qurango.net/radio/roqiah',
      fallbackUrls: [
        'https://backup.qurango.net/radio/roqiah',
      ],
      country: 'العالم الإسلامي 🌍',
      icon: Icons.security_rounded,
      accentColor: Color(0xFFBA68C8),
    ),
    RadioStation(
      id: 'athkar',
      name: 'إذاعة أذكار اليوم والليلة',
      description: 'أذكار الصباح والمساء والأدعية النبوية المباركة',
      url: 'https://qurango.net/radio/athkar_sabah_masa',
      fallbackUrls: [
        'https://backup.qurango.net/radio/athkar_sabah_masa',
      ],
      country: 'العالم الإسلامي 🌍',
      icon: Icons.wb_sunny_rounded,
      accentColor: Color(0xFF4DB6AC),
    ),
    RadioStation(
      id: 'shaarawi',
      name: 'إذاعة خواطر وتفسير الشيخ الشعراوي',
      description: 'خواطر إيمانية وتفسير مبسط لآيات القرآن الحكيم',
      url: 'https://qurango.net/radio/shaarawi',
      fallbackUrls: [
        'https://backup.qurango.net/radio/shaarawi',
      ],
      country: 'مصر 🇪🇬',
      icon: Icons.auto_stories_rounded,
      accentColor: Color(0xFFAED581),
    ),
    RadioStation(
      id: 'eid',
      name: 'إذاعة تكبيرات العيد وأيام الحج',
      description: 'تكبيرات الحرمين الشريفين والبهجة الإيمانية',
      url: 'https://qurango.net/radio/eid',
      fallbackUrls: [
        'https://backup.qurango.net/radio/eid',
      ],
      country: 'مكة المكرمة 🕋',
      icon: Icons.celebration_rounded,
      accentColor: Color(0xFFFFB74D),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentStation ??= stations.first;
    _playerStateSubscription = _radioPlayer.playerStateStream.listen((state) {
      safeSetState(() {
        _isPlaying = state.playing;
        _isLoading = state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
      });
    });
  }

  Future<void> _playStation(RadioStation station) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentStation = station;
      _isLoading = true;
    });

    final allUrls = [station.url, ...station.fallbackUrls];
    bool playedSuccessfully = false;

    for (final url in allUrls) {
      try {
        await _radioPlayer.stop();
        await _radioPlayer.setUrl(
          url,
          headers: {
            'User-Agent': 'NoorAlHoda/1.8.1 (Android; Flutter)',
          },
        );
        await _radioPlayer.play();
        playedSuccessfully = true;
        break;
      } catch (e) {
        debugPrint('Failed to connect to stream $url, trying next fallback: $e');
      }
    }

    if (playedSuccessfully) {
      if (mounted) {
        setState(() {
          _isPlaying = true;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPlaying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر تشغيل البث المباشر حالياً. يرجى التحقق من الاتصال بالإنترنت.',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Timer? _sleepTimer;
  int _sleepSecondsRemaining = 0;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _playerStateSubscription?.cancel();
    _playerStateSubscription = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      safeSetState(() {});
    }
  }

  void _setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    if (minutes <= 0) {
      safeSetState(() => _sleepSecondsRemaining = 0);
      return;
    }

    safeSetState(() => _sleepSecondsRemaining = minutes * 60);

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_sleepSecondsRemaining <= 1) {
        timer.cancel();
        safeSetState(() => _sleepSecondsRemaining = 0);
        await _radioPlayer.stop();
        await _radioPlayer.setVolume(1.0);
        safeSetState(() => _isPlaying = false);
      } else {
        safeSetState(() => _sleepSecondsRemaining--);
        if (_sleepSecondsRemaining <= 30) {
          final vol = (_sleepSecondsRemaining / 30.0).clamp(0.0, 1.0);
          _radioPlayer.setVolume(vol);
        }
      }
    });
  }

  void _showSleepTimerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Provider.of<AppThemeManager>(ctx).currentTheme;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              border: Border.all(color: theme.accentColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Text('🌙', style: TextStyle(fontSize: 22.sp)),
                    SizedBox(width: 8.w),
                    Text(
                      'مؤقت النوم الذكي (Sleep Timer)',
                      style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 16.sp),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'سيتم إيقاف البث تدريجياً بعد انتهاء الوقت المحدد للنوم في سكينة.',
                  style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 11.5.sp),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [15, 30, 45, 60].map((mins) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.cardColor,
                        foregroundColor: theme.accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _setSleepTimer(mins);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تم ضبط مؤقت النوم على $mins دقيقة 🌙', style: GoogleFonts.cairo()),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text('$mins دقيقة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                ),
                if (_sleepSecondsRemaining > 0) ...[
                  SizedBox(height: 12.h),
                  TextButton.icon(
                    icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent),
                    label: Text('إلغاء مؤقت النوم', style: GoogleFonts.cairo(color: Colors.redAccent)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _setSleepTimer(0);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('تم إلغاء مؤقت النوم', style: GoogleFonts.cairo())),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _togglePlayPause() async {
    if (_currentStation == null) return;
    if (_isPlaying) {
      await _radioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _playStation(_currentStation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppThemeManager>(context).currentTheme;
    final activeStation = _currentStation ?? stations.first;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'إذاعات القرآن الكريم المباشرة 📻',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16.sp),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _sleepSecondsRemaining > 0 ? Icons.bedtime_rounded : Icons.bedtime_outlined,
              color: _sleepSecondsRemaining > 0 ? const Color(0xFFFFD54F) : Colors.white,
            ),
            tooltip: 'مؤقت النوم',
            onPressed: () => _showSleepTimerDialog(context),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // 1. Now Playing Hero Banner
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.cardColor],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                border: Border.all(color: activeStation.accentColor.withValues(alpha: 0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: activeStation.accentColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeStation.accentColor.withValues(alpha: 0.2),
                          border: Border.all(color: activeStation.accentColor, width: 2),
                        ),
                        child: Icon(activeStation.icon, color: activeStation.accentColor, size: 28.sp),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isPlaying ? const Color(0xFF00E676) : Colors.grey,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  _isPlaying ? 'بث مباشر الآن (LIVE)' : 'متوقف مؤقتاً',
                                  style: GoogleFonts.cairo(
                                    color: _isPlaying ? const Color(0xFF69F0AE) : Colors.white60,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              activeStation.name,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                            Text(
                              activeStation.country,
                              style: GoogleFonts.cairo(color: activeStation.accentColor, fontSize: 11.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // Play/Pause Action Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoading)
                        SizedBox(
                          width: 54.w,
                          height: 54.w,
                          child: CircularProgressIndicator(color: activeStation.accentColor),
                        )
                      else
                        GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            width: 56.w,
                            height: 56.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: activeStation.accentColor,
                              boxShadow: [
                                BoxShadow(
                                  color: activeStation.accentColor.withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 32.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Stations List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: Row(
                children: [
                  Text(
                    'قائمة الإذاعات المتاحة (11 إذاعة عالمية):',
                    style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 13.sp),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: stations.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final station = stations[index];
                  final isCurrent = activeStation.id == station.id;

                  return Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: isCurrent ? station.accentColor : theme.dividerColor.withValues(alpha: 0.2),
                        width: isCurrent ? 1.8 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                      leading: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: station.accentColor.withValues(alpha: 0.15),
                        ),
                        child: Icon(station.icon, color: station.accentColor, size: 22.sp),
                      ),
                      title: isCurrent
                          ? AutoScrollText(
                              station.name,
                              style: GoogleFonts.cairo(
                                color: station.accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            )
                          : Text(
                              station.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                color: theme.textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                      subtitle: isCurrent
                          ? AutoScrollText(
                              station.description,
                              style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 11.sp),
                            )
                          : Text(
                              station.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 11.sp),
                            ),
                      trailing: isCurrent && _isPlaying
                          ? const Icon(Icons.graphic_eq_rounded, color: Color(0xFF00E676))
                          : IconButton(
                              icon: Icon(Icons.play_circle_fill_rounded, color: station.accentColor, size: 28.sp),
                              onPressed: () => _playStation(station),
                            ),
                      onTap: () => _playStation(station),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
