// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../services/prayer_service.dart';
import '../services/world_location_service.dart';
import '../services/audio_service.dart';
import '../services/notification_service.dart';
import '../services/background_service.dart';
import '../services/home_widget_service.dart';
import '../core/helpers/app_lifecycle_helper.dart';
import '../widgets/common/quick_language_button.dart';
import '../widgets/location_picker_sheet.dart';
import '../widgets/common/auto_scroll_text.dart';
import '../core/localization/app_translations.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({
    super.key,
  });

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with WidgetsBindingObserver {
  Timer? _timer;

  final Map<String, String> _prayerTimes = {
    'الفجر': '--:--',
    'الشروق': '--:--',
    'الظهر': '--:--',
    'العصر': '--:--',
    'المغرب': '--:--',
    'العشاء': '--:--',
  };

  String _nextPrayerName = 'جاري الحساب...';

  String _remainingTime = '--:--:--';

  String _locationDisplayName = 'القاهرة، مصر 🇪🇬';
  Coordinates? _currentCoordinates;

  bool _isPlayingAthan = false;
  StreamSubscription? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadSavedCity();

    _startClock();

    requestPrayerCountdownUpdate();

    _playerStateSubscription = AudioService.player.playerStateStream.listen((state) {
      safeSetState(() {
        _isPlayingAthan = state.playing;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timer = null;
    _playerStateSubscription?.cancel();
    _playerStateSubscription = null;
    AudioService.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _calculatePrayerTimes();
      _startClock();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> _loadSavedCity() async {
    final displayName = await WorldLocationService.getCurrentLocationDisplayName();
    final coords = await WorldLocationService.getSavedCoordinates();

    safeSetState(() {
      _locationDisplayName = displayName;
      _currentCoordinates = coords;
    });

    _calculatePrayerTimes();
    await NotificationService().schedulePrayerNotifications();
    await HomeWidgetService.updateAllPrayerWidgets();
  }

  void _startClock() {
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

        _calculatePrayerTimes();
      },
    );
  }

  void _calculatePrayerTimes() {
    final coordinates = _currentCoordinates ?? Coordinates(30.0444, 31.2357);

    final prayerTimes = PrayerService.getPrayerTimes(
      coordinates,
      DateTime.now(),
    );

    final formatter = DateFormat('h:mm a', 'ar');

    safeSetState(() {
      _prayerTimes['الفجر'] = formatter.format(
        prayerTimes.fajr,
      );

      _prayerTimes['الشروق'] = formatter.format(
        prayerTimes.sunrise,
      );

      _prayerTimes['الظهر'] = formatter.format(
        prayerTimes.dhuhr,
      );

      _prayerTimes['العصر'] = formatter.format(
        prayerTimes.asr,
      );

      _prayerTimes['المغرب'] = formatter.format(
        prayerTimes.maghrib,
      );

      _prayerTimes['العشاء'] = formatter.format(
        prayerTimes.isha,
      );
    });

    Prayer nextPrayer = prayerTimes.nextPrayer();
    DateTime? nextPrayerTime;

    if (nextPrayer == Prayer.none) {
      final tomorrowPrayer = PrayerService.getPrayerTimes(
        coordinates,
        DateTime.now().add(const Duration(days: 1)),
      );
      nextPrayer = Prayer.fajr;
      nextPrayerTime = tomorrowPrayer.fajr;
    } else {
      nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer);
    }

    if (nextPrayerTime == null) return;

    final difference = nextPrayerTime.difference(DateTime.now());
    if (difference.isNegative) return;

    final hours = difference.inHours.toString().padLeft(2, '0');
    final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');

    safeSetState(() {
      _nextPrayerName = _getPrayerName(nextPrayer);
      _remainingTime = '$hours:$minutes:$seconds';
    });
  }

  String _getPrayerName(
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

  String _translatePrayerKey(String key) {
    switch (key) {
      case 'الفجر':
        return context.tr('prayer_fajr');
      case 'الشروق':
        return context.tr('prayer_sunrise');
      case 'الظهر':
        return context.tr('prayer_dhuhr');
      case 'العصر':
        return context.tr('prayer_asr');
      case 'المغرب':
        return context.tr('prayer_maghrib');
      case 'العشاء':
        return context.tr('prayer_isha');
      default:
        return key;
    }
  }

  Future<void> _toggleAthanPlayback() async {
    if (_isPlayingAthan) {
      await AudioService.stop();
    } else {
      try {
        await AudioService.play('https://www.islamcan.com/audio/adhan/azan1.mp3');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                'خطأ في تشغيل صوت الأذان. تأكد من اتصالك بالإنترنت.',
                style: GoogleFonts.cairo(color: Colors.white),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          context.tr('nav_prayer'),
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          const QuickLanguageButton(isCompact: true),
          IconButton(
            icon: Icon(
              _isPlayingAthan ? Icons.stop_circle_outlined : Icons.play_circle_outline_rounded,
              color: Colors.white,
              size: 26.sp,
            ),
            tooltip: 'تجربة الأذان',
            onPressed: _toggleAthanPlayback,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(
            20.w,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(
                  24.w,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    28.r,
                  ),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0F2027),
                      Color(0xFF203A43),
                      Color(0xFF2C5364),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.mosque_rounded,
                      color: Colors.white,
                      size: 52.sp,
                    ),
                    SizedBox(
                      height: 16.h,
                    ),
                    Text(
                      context.tr('next_prayer'),
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 18.sp,
                      ),
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    Text(
                      _nextPrayerName,
                      style: GoogleFonts.cairo(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 14.h,
                    ),
                    Text(
                      _remainingTime,
                      style: GoogleFonts.cairo(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 24.h,
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.r),
                  onTap: () async {
                    final selected = await LocationPickerSheet.show(context);
                    if (selected != null) {
                      await _loadSavedCity();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(
                        20.r,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: 0.08,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                            10.w,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(
                              14.r,
                            ),
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                        SizedBox(
                          width: 14.w,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الموقع وحساب المواقيت',
                                style: GoogleFonts.cairo(
                                  fontSize: 12.sp,
                                  color: Colors.white60,
                                ),
                              ),
                              AutoScrollText(
                                _locationDisplayName,
                                style: GoogleFonts.cairo(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.08,
                            ),
                            borderRadius: BorderRadius.circular(
                              12.r,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'تغيير',
                                style: GoogleFonts.cairo(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFD4AF37),
                                ),
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12.sp,
                                color: const Color(0xFFD4AF37),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30.h,
              ),
              ..._prayerTimes.entries.map(
                (entry) {
                  return Container(
                    margin: EdgeInsets.only(
                      bottom: 16.h,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 18.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(
                        22.r,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _translatePrayerKey(entry.key),
                          style: GoogleFonts.cairo(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          entry.value,
                          style: GoogleFonts.cairo(
                            fontSize: 17.sp,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
