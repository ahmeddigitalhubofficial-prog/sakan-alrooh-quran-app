// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_colors.dart';
import '../core/services/analytics_service.dart';
import '../models/task_manager.dart';

import '../models/theme_manager.dart';
import '../services/app_review_service.dart';
import '../services/app_share_service.dart';
import '../services/date_service.dart';
import '../services/prayer_service.dart';
import '../services/world_location_service.dart';
import '../widgets/location_picker_sheet.dart';
import '../services/in_app_update_service.dart';
import '../services/cloud_sync_service.dart';
import '../widgets/common/custom_card.dart';
import '../widgets/common/auto_scroll_text.dart';
import '../widgets/home/hijri_event_banner.dart';
import '../widgets/daily_reflection_card.dart';
import '../widgets/qasr_al_jannah_card.dart';
import 'fasting_tracker_screen.dart';
import 'feature_guide_screen.dart';
import 'islamic_quiz_screen.dart';
import 'islamic_radio_screen.dart';
import 'spiritual_moods_screen.dart';
import 'stories_screen.dart';
import 'ward_tracker_screen.dart';
import 'surah_detail_screen.dart';
import 'zakat_calculator_screen.dart';
import 'card_studio_screen.dart';
import 'global_dhikr_screen.dart';
import 'thawab_dedication_screen.dart';
import 'good_deeds_challenge_screen.dart';
import 'athar_community_screen.dart';
import 'spiritual_sleep_screen.dart';
import '../widgets/common/quick_language_button.dart';
import '../core/localization/app_translations.dart';
import '../core/helpers/app_lifecycle_helper.dart';
import '../widgets/home/social_channels_card.dart';
import '../widgets/home/spiritual_reels_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? _timer;

  String _gregorianDate = '';

  String _hijriDate = '';

  String _nextPrayerName = 'جاري الحساب...';

  String _nextPrayerTimeText = '--:--';

  String _timeRemaining = '';

  final double _defaultLat = 30.0444;

  final double _defaultLng = 31.2357;

  String _currentLocationDisplay = 'القاهرة، مصر 🇪🇬';
  Coordinates? _savedCoordinates;

  Map<String, String> _todayAyah = {};

  int? _resumeSurahNumber;
  String? _resumeSurahName;
  int? _resumeVerseNumber;

  final List<Map<String, String>> _dailyAyahs = [
    {
      'text': 'لَا تَخَفْ إِنَّنِي مَعَكُمَا أَسْمَعُ وَأَرَى',
      'surah': 'سورة طه - الآية ٤٦',
    },
    {
      'text': 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      'surah': 'سورة الرعد - الآية ٢٨',
    },
    {
      'text': 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
      'surah': 'سورة الشرح - الآية ٦',
    },
    {
      'text': 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
      'surah': 'سورة الطلاق - الآية ٣',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeHome();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateDateTime(force: true);
      _calculatePrayerTimes();
      _startTimer();
      _checkPendingPrayerTimerRecovery();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> _checkPendingPrayerTimerRecovery() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isActive = prefs.getBool('prayer_timer_active') ?? false;
      if (!isActive) return;

      final prayerId = prefs.getString('prayer_timer_id');
      final startMs = prefs.getInt('prayer_timer_start_ms');
      if (prayerId == null || startMs == null) return;

      final elapsedSeconds =
          (DateTime.now().millisecondsSinceEpoch - startMs) ~/ 1000;
      if (elapsedSeconds >= 120 && elapsedSeconds <= 5400) {
        final prayerNames = {
          'fajr': 'الفجر',
          'dhuhr': 'الظهر',
          'asr': 'العصر',
          'maghrib': 'المغرب',
          'isha': 'العشاء',
        };
        final pName = prayerNames[prayerId] ?? prayerId;
        if (!mounted) return;

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 12),
            content: Text(
              'تقبّل الله صلاتك! 🤲 هل أتممت صلاة $pName؟',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            action: SnackBarAction(
              label: 'نعم، تسجيل الصلاة ✅',
              textColor: Colors.amberAccent,
              onPressed: () async {
                final taskManager =
                    Provider.of<SpiritualTaskManager>(context, listen: false);
                await taskManager.markTodayPrayerAsCompleted(
                  prayerId,
                  duration: elapsedSeconds > 900 ? 300 : elapsedSeconds,
                );
                await prefs.setBool('prayer_timer_active', false);
                await prefs.remove('prayer_timer_start_ms');
                await prefs.remove('prayer_timer_id');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        'تم تسجيل صلاة $pName بنجاح! (+50 حسنة) 🌟',
                        style: GoogleFonts.cairo(),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      } else if (elapsedSeconds > 5400) {
        await prefs.setBool('prayer_timer_active', false);
        await prefs.remove('prayer_timer_start_ms');
        await prefs.remove('prayer_timer_id');
      }
    } catch (_) {}
  }

  Future<void> _loadResumeData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('save_last_read') ?? true) {
      safeSetState(() {
        _resumeSurahNumber = prefs.getInt('last_read_surah');
        _resumeSurahName = prefs.getString('last_read_surah_name');
        _resumeVerseNumber = prefs.getInt('last_read_verse');
      });
    } else {
      safeSetState(() {
        _resumeSurahNumber = null;
        _resumeSurahName = null;
        _resumeVerseNumber = null;
      });
    }
  }

  Future<void> _initializeHome() async {
    await _loadSavedLocation();
    await _loadResumeData();

    _setDailyAyah();

    _updateDateTime(force: true);

    _calculatePrayerTimes();

    _startTimer();

    AnalyticsService().logScreenView('home_screen');

    // فحص تلقائي ذكي للتحديثات من Google Play
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        InAppUpdateService().checkForUpdate(context: context);
        _checkPendingPrayerTimerRecovery();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    if (AppLifecycleHelper.isBackground) return;

    _timer = Timer.periodic(
      const Duration(
        seconds: 1,
      ),
      (_) {
        if (!mounted) {
          _timer?.cancel();
          return;
        }
        if (AppLifecycleHelper.isBackground) {
          _timer?.cancel();
          _timer = null;
          return;
        }

        _updateDateTime();

        _calculatePrayerTimes();
      },
    );
  }

  void _setDailyAyah() {
    final dayOfYear = DateTime.now()
        .difference(
          DateTime(
            DateTime.now().year,
            1,
            1,
          ),
        )
        .inDays;

    _todayAyah = _dailyAyahs[dayOfYear % _dailyAyahs.length];
  }

  int _hijriOffset = 0;
  int? _lastDateMinute;

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();

    _currentLocationDisplay = await WorldLocationService.getCurrentLocationDisplayName();
    _savedCoordinates = await WorldLocationService.getSavedCoordinates();
    _hijriOffset = prefs.getInt('hijri_offset') ?? 0;

    safeSetState(() {});
  }

  void _updateDateTime({bool force = false}) {
    final now = DateTime.now();
    if (!force && _lastDateMinute == now.minute && _gregorianDate.isNotEmpty) {
      return;
    }
    _lastDateMinute = now.minute;
    final hijriDate = DateService.hijri(offsetDays: _hijriOffset);

    safeSetState(() {
      _gregorianDate = DateFormat('EEEE، d MMMM y', 'ar').format(now);
      _hijriDate = hijriDate;
    });
  }

  void _calculatePrayerTimes() {
    final coordinates = _savedCoordinates ?? Coordinates(
      _defaultLat,
      _defaultLng,
    );

    final prayerTimes = PrayerService.getPrayerTimes(
      coordinates,
      DateTime.now(),
    );

    Prayer nextPrayer = prayerTimes.nextPrayer();

    DateTime? nextPrayerTime;

    if (nextPrayer == Prayer.none) {
      final tomorrowPrayer = PrayerService.getPrayerTimes(
        coordinates,
        DateTime.now().add(
          const Duration(
            days: 1,
          ),
        ),
      );

      nextPrayer = Prayer.fajr;

      nextPrayerTime = tomorrowPrayer.fajr;
    } else {
      nextPrayerTime = prayerTimes.timeForPrayer(
        nextPrayer,
      );
    }

    if (nextPrayerTime == null) {
      return;
    }

    final difference = nextPrayerTime.difference(
      DateTime.now(),
    );

    final hours = difference.inHours.toString().padLeft(2, '0');

    final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');

    final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');

    safeSetState(() {
      _nextPrayerName = _getPrayerArabicName(
        nextPrayer,
      );

      _nextPrayerTimeText = DateFormat('h:mm a', 'ar').format(
        nextPrayerTime!,
      );

      _timeRemaining = '$hours:$minutes:$seconds';
    });
  }

  String _getPrayerArabicName(
    Prayer prayer,
  ) {
    switch (prayer) {
      case Prayer.fajr:
        return context.tr('prayer_fajr');

      case Prayer.sunrise:
        return context.tr('prayer_sunrise');

      case Prayer.dhuhr:
        return context.tr('prayer_dhuhr');

      case Prayer.asr:
        return context.tr('prayer_asr');

      case Prayer.maghrib:
        return context.tr('prayer_maghrib');

      case Prayer.isha:
        return context.tr('prayer_isha');

      default:
        return context.tr('calculating');
    }
  }

  void _copyAyah() {
    Clipboard.setData(
      ClipboardData(
        text: _todayAyah['text'] ?? '',
      ),
    );

    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.gold,
        content: Text(
          'تم نسخ الآية',
          style: GoogleFonts.cairo(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


  @override
  Widget build(
    BuildContext context,
  ) {
    final themeManager = Provider.of<AppThemeManager>(
      context,
    );

    final taskManager = Provider.of<SpiritualTaskManager>(
      context,
    );

    final theme = themeManager.currentTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: theme.gradientColors,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            right: 18.w,
            left: 18.w,
            top: 12.h,
            bottom: 90.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(
                theme,
              ),
              SizedBox(
                height: 12.h,
              ),
              _buildGlobalAnnouncementBanner(
                theme,
              ),
              HijriEventBanner(
                theme: theme,
              ),
              SizedBox(
                height: 12.h,
              ),
              _buildPrayerCard(
                theme,
              ),
              SizedBox(
                height: 16.h,
              ),
              const DailyReflectionCard(),
              SizedBox(
                height: 20.h,
              ),
              _buildDateCard(
                theme,
              ),
              SizedBox(
                height: 16.h,
              ),
              const QasrAlJannahCard(isCompact: true),
              SizedBox(
                height: 20.h,
              ),
              _buildResumeReadingCard(
                theme,
              ),
              _buildWardCard(
                theme,
                taskManager,
              ),
              SizedBox(
                height: 20.h,
              ),
              SpiritualReelsBanner(
                theme: theme,
              ),
              SizedBox(
                height: 16.h,
              ),
              SocialChannelsCard(
                theme: theme,
              ),
              SizedBox(
                height: 20.h,
              ),
              _buildQuranLibraryCard(
                theme,
              ),
              SizedBox(
                height: 20.h,
              ),
              _buildAyahCard(
                theme,
              ),
              SizedBox(
                height: 20.h,
              ),
              _buildAtharCommunityBanner(
                theme,
              ),
              SizedBox(
                height: 20.h,
              ),
              _buildExclusiveServicesSection(
                theme,
              ),
              SizedBox(
                height: 20.h,
              ),
              _buildShareAppHomeCard(
                theme,
              ),
              SizedBox(
                height: 14.h,
              ),
              _buildRateAppHomeCard(
                theme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAtharCommunityBanner(AppTheme theme) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AtharCommunityScreen(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F5A3E),
              Color(0xFF102C3B),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.gold.withOpacity(0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withOpacity(0.15),
                border: Border.all(color: AppColors.gold, width: 1.5),
              ),
              child: const Icon(
                Icons.forum_rounded,
                color: AppColors.gold,
                size: 24,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        context.tr('community_banner_title'),
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          context.tr('community_new_badge'),
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    context.tr('community_banner_sub'),
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.gold.withOpacity(0.8),
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExclusiveServicesSection(AppTheme theme) {
    final services = [
      {
        'title': context.tr('service_athar'),
        'subtitle': context.tr('service_athar_sub'),
        'icon': Icons.forum_rounded,
        'color': const Color(0xFF2ECC71),
        'screen': const AtharCommunityScreen(),
      },
      {
        'title': context.tr('service_status_maker'),
        'subtitle': context.tr('service_status_sub'),
        'icon': Icons.camera_alt_rounded,
        'color': const Color(0xFFE5C07B),
        'screen': const CardStudioScreen(),
      },
      {
        'title': context.tr('service_global_dhikr'),
        'subtitle': context.tr('service_global_dhikr_sub'),
        'icon': Icons.diversity_3_rounded,
        'color': const Color(0xFF4ECCA3),
        'screen': const GlobalDhikrScreen(),
      },
      {
        'title': context.tr('service_thawab'),
        'subtitle': context.tr('service_thawab_sub'),
        'icon': Icons.volunteer_activism_rounded,
        'color': const Color(0xFFFFB74D),
        'screen': const ThawabDedicationScreen(),
      },
      {
        'title': context.tr('service_good_deeds'),
        'subtitle': context.tr('service_good_deeds_sub'),
        'icon': Icons.emoji_events_rounded,
        'color': const Color(0xFF64B5F6),
        'screen': const GoodDeedsChallengeScreen(),
      },
      {
        'title': context.tr('service_quiz'),
        'subtitle': context.tr('service_quiz_sub'),
        'icon': Icons.quiz_rounded,
        'color': const Color(0xFFBA68C8),
        'screen': const IslamicQuizScreen(),
      },
      {
        'title': context.tr('service_radio'),
        'subtitle': context.tr('service_radio_sub'),
        'icon': Icons.radio_rounded,
        'color': const Color(0xFFD4AF37),
        'screen': const IslamicRadioScreen(),
      },
      {
        'title': context.tr('service_moods'),
        'subtitle': context.tr('service_moods_sub'),
        'icon': Icons.spa_rounded,
        'color': const Color(0xFF81C784),
        'screen': const SpiritualMoodsScreen(),
      },
      {
        'title': context.tr('service_fasting'),
        'subtitle': context.tr('service_fasting_sub'),
        'icon': Icons.brightness_2_rounded,
        'color': const Color(0xFF4FC3F7),
        'screen': const FastingTrackerScreen(),
      },
      {
        'title': context.tr('service_zakat'),
        'subtitle': context.tr('service_zakat_sub'),
        'icon': Icons.calculate_rounded,
        'color': const Color(0xFFFF8A65),
        'screen': const ZakatCalculatorScreen(),
      },
      {
        'title': 'صوتيات السكينة والنوم',
        'subtitle': 'تلاوات هادئة ومطر ومؤقت نوم',
        'icon': Icons.nightlight_round,
        'color': const Color(0xFF80CBC4),
        'screen': const SpiritualSleepScreen(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: theme.accentColor, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  context.tr('quick_services'),
                  style: GoogleFonts.cairo(
                    color: theme.textColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 0.95,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final item = services[index];
            final color = item['color'] as Color;
            final icon = item['icon'] as IconData;
            final title = item['title'] as String;
            final subtitle = item['subtitle'] as String;
            final screen = item['screen'] as Widget;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18.r),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => screen),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: theme.cardColor.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: color.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 22.sp),
                      ),
                      SizedBox(height: 6.h),
                      SizedBox(
                        width: double.infinity,
                        child: AutoScrollText(
                          title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color: theme.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5.sp,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: AutoScrollText(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color: theme.subtitleColor,
                            fontSize: 9.sp,
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
      ],
    );
  }

  Widget _buildShareAppHomeCard(AppTheme theme) {
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
        side: BorderSide(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: () {
          AppShareService.showInviteBottomSheet(context);
        },
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Color(0xFFD4AF37),
                  size: 28,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('share_app_title'),
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.textColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      context.tr('share_app_sub'),
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: theme.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: theme.accentColor,
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRateAppHomeCard(AppTheme theme) {
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
        side: BorderSide(
          color: Colors.amber.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: () async {
          await AppReviewService.showRatingDialog(context);
        },
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('rate_app_title'),
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.textColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      context.tr('rate_app_sub'),
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: theme.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: theme.accentColor,
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuranLibraryCard(AppTheme theme) {
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
        side: BorderSide(
          color: theme.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const StoriesScreen(),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: theme.accentColor,
                  size: 32.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'موسوعة قصص القرآن وأسباب النزول 📚',
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.textColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'استكشف قصص الأنبياء وأسباب نزول سور وآيات القرآن والغزوات أوفلاين',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: theme.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: theme.accentColor,
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
    AppTheme theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () {
                Scaffold.maybeOf(
                  context,
                )?.openDrawer();
              },
              child: Container(
                padding: EdgeInsets.all(
                  8.w,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius: BorderRadius.circular(
                    14.r,
                  ),
                ),
                child: Icon(
                  Icons.menu_rounded,
                  color: theme.accentColor,
                  size: 28.sp,
                ),
              ),
            );
          },
        ),
        Text(
          context.tr('app_name'),
          style: GoogleFonts.cairo(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: theme.accentColor,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const QuickLanguageButton(isCompact: true),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeatureGuideScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.all(
                  8.w,
                ),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(
                    alpha: 0.15,
                  ),
                  borderRadius: BorderRadius.circular(
                    14.r,
                  ),
                  border: Border.all(
                    color: theme.accentColor.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                child: Icon(
                  Icons.help_outline_rounded,
                  color: theme.accentColor,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrayerCard(
    AppTheme theme,
  ) {
    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 300,
      ),
      padding: EdgeInsets.all(
        24.w,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          30.r,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.cardColor,
            theme.primaryColor.withValues(
              alpha: 0.85,
            ),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.accentColor.withValues(
              alpha: 0.15,
            ),
            blurRadius: 20,
            offset: const Offset(
              0,
              10,
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () async {
              final selected = await LocationPickerSheet.show(context);
              if (selected != null) {
                await _loadSavedLocation();
                _calculatePrayerTimes();
              }
            },
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: 0.22,
                ),
                borderRadius: BorderRadius.circular(
                  20.r,
                ),
                border: Border.all(
                  color: theme.accentColor.withValues(
                    alpha: 0.35,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: theme.accentColor,
                    size: 15.sp,
                  ),
                  SizedBox(
                    width: 6.w,
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 190.w),
                    child: AutoScrollText(
                      _currentLocationDisplay,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 4.w,
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: theme.accentColor,
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 14.h,
          ),
          Icon(
            Icons.mosque_rounded,
            color: theme.accentColor,
            size: 45.sp,
          ),
          SizedBox(
            height: 14.h,
          ),
          Text(
            _nextPrayerName,
            style: GoogleFonts.cairo(
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
            ),
          ),
          SizedBox(
            height: 12.h,
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
              vertical: 12.h,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(
                alpha: 0.18,
              ),
              borderRadius: BorderRadius.circular(
                18.r,
              ),
            ),
            child: Text(
              _nextPrayerTimeText,
              style: GoogleFonts.cairo(
                fontSize: 34.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Text(
            '${context.tr('time_remaining')} $_nextPrayerName',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Text(
            _timeRemaining,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 30.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(
    AppTheme theme,
  ) {
    return CustomCard(
      child: Column(
        children: [
          Text(
            _hijriDate,
            style: GoogleFonts.cairo(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Text(
            _gregorianDate,
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              color: theme.subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWardCard(
    AppTheme theme,
    SpiritualTaskManager taskManager,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const WardTrackerScreen(),
          ),
        );
      },
      child: CustomCard(
        child: Row(
          children: [
            SizedBox(
              width: 58.w,
              height: 58.w,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                value: taskManager.todayCompletionPercentage / 100,
                color: theme.accentColor,
                backgroundColor: Colors.white12,
              ),
            ),
            SizedBox(
              width: 18.w,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'متابعة الورد اليومي',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: theme.textColor,
                    ),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Text(
                    '${taskManager.todayCompletionPercentage.toStringAsFixed(0)}% مكتمل اليوم',
                    style: GoogleFonts.cairo(
                      color: theme.subtitleColor,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAyahCard(
    AppTheme theme,
  ) {
    return CustomCard(
      child: Column(
        children: [
          Text(
            _todayAyah['text'] ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              fontSize: 27.sp,
              color: theme.textColor,
              height: 2,
            ),
          ),
          SizedBox(
            height: 18.h,
          ),
          Text(
            _todayAyah['surah'] ?? '',
            style: GoogleFonts.cairo(
              color: theme.subtitleColor,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(
            height: 18.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _copyAyah,
                tooltip: 'نسخ الآية',
                icon: Icon(
                  Icons.copy_rounded,
                  color: theme.accentColor,
                ),
              ),
              SizedBox(width: 8.w),
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CardStudioScreen(
                        initialText: _todayAyah['text'] ?? '',
                        initialSource: _todayAyah['surah'] ?? '',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt_rounded, size: 16),
                label: Text(
                  'صمم كحالة ستوري (9:16) 📲',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResumeReadingCard(AppTheme theme) {
    if (_resumeSurahNumber == null || _resumeSurahName == null || _resumeVerseNumber == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            HapticFeedback.lightImpact();
            if (context.mounted) {
              Provider.of<SpiritualTaskManager>(context, listen: false).setTaskCompleted('quran_ward', true);
            }
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SurahDetailScreen(
                  surahNumber: _resumeSurahNumber!,
                  surahName: _resumeSurahName!,
                ),
              ),
            );
            _loadResumeData();
          },
          child: CustomCard(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: theme.accentColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.bookmark_added_rounded,
                    color: theme.accentColor,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('resume_reading'),
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: theme.textColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'سورة $_resumeSurahName - الآية $_resumeVerseNumber',
                        style: GoogleFonts.cairo(
                          color: theme.subtitleColor,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: theme.accentColor,
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildGlobalAnnouncementBanner(dynamic theme) {
    return StreamBuilder<String?>(
      stream: CloudSyncService.getGlobalAnnouncementStream(),
      builder: (context, snapshot) {
        final text = snapshot.data;
        if (text == null || text.trim().isEmpty) return const SizedBox.shrink();

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F5A3E), Color(0xFF1E3A8A)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('📢', style: TextStyle(fontSize: 18)),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}