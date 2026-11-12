import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/theme_manager.dart';
import '../models/task_manager.dart';
import '../core/helpers/app_lifecycle_helper.dart';

class PrayerTimerScreen extends StatefulWidget {
  final String prayerId;
  final DateTime? targetDate;

  const PrayerTimerScreen({
    super.key,
    required this.prayerId,
    this.targetDate,
  });

  @override
  State<PrayerTimerScreen> createState() => _PrayerTimerScreenState();
}

class _PrayerTimerScreenState extends State<PrayerTimerScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isRunning = false;
  bool _isSuccess = false;
  int? _timerStartEpochMs;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final Map<String, String> _prayerNames = {
    'fajr': 'صلاة الفجر',
    'dhuhr': 'صلاة الظهر',
    'asr': 'صلاة العصر',
    'maghrib': 'صلاة المغرب',
    'isha': 'صلاة العشاء',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _restoreActiveTimerState();
  }

  Future<void> _restoreActiveTimerState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isActive = prefs.getBool('prayer_timer_active') ?? false;
      final savedPrayerId = prefs.getString('prayer_timer_id');
      final startMs = prefs.getInt('prayer_timer_start_ms');

      if (isActive && savedPrayerId == widget.prayerId && startMs != null) {
        final elapsed = (DateTime.now().millisecondsSinceEpoch - startMs) ~/ 1000;
        if (elapsed > 0 && elapsed < 7200) {
          _timerStartEpochMs = startMs;
          _secondsElapsed = elapsed;
          _isRunning = true;
          if (AppLifecycleHelper.isForeground) {
            _pulseController.repeat(reverse: true);
          }
          _startTimerTicks();
          safeSetState(() {});
        } else if (elapsed >= 7200) {
          // Timer was forgotten (> 2 hours), clear it
          await _clearActiveTimerPrefs();
        }
      }
    } catch (_) {}
  }

  Future<void> _clearActiveTimerPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('prayer_timer_active', false);
      await prefs.remove('prayer_timer_start_ms');
      await prefs.remove('prayer_timer_id');
      await prefs.remove('prayer_timer_target_date');
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timer = null;
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_isRunning && _timerStartEpochMs != null) {
        final currentElapsed =
            (DateTime.now().millisecondsSinceEpoch - _timerStartEpochMs!) ~/ 1000;
        if (currentElapsed > _secondsElapsed) {
          _secondsElapsed = currentElapsed;
        }
        _pulseController.repeat(reverse: true);
        _startTimerTicks();
        safeSetState(() {});
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _pulseController.stop();
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> _startTimer() async {
    HapticFeedback.mediumImpact();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    _timerStartEpochMs = nowMs - (_secondsElapsed * 1000);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('prayer_timer_active', true);
      await prefs.setString('prayer_timer_id', widget.prayerId);
      await prefs.setInt('prayer_timer_start_ms', _timerStartEpochMs!);
      await prefs.setString(
        'prayer_timer_target_date',
        (widget.targetDate ?? DateTime.now()).toIso8601String(),
      );
    } catch (_) {}

    safeSetState(() {
      _isRunning = true;
    });

    if (AppLifecycleHelper.isForeground) {
      _pulseController.repeat(reverse: true);
    }
    _startTimerTicks();
  }

  void _startTimerTicks() {
    _timer?.cancel();
    if (AppLifecycleHelper.isBackground) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      if (AppLifecycleHelper.isBackground) {
        _timer?.cancel();
        _timer = null;
        return;
      }
      safeSetState(() {
        if (_timerStartEpochMs != null) {
          _secondsElapsed =
              (DateTime.now().millisecondsSinceEpoch - _timerStartEpochMs!) ~/ 1000;
        } else {
          _secondsElapsed++;
        }
      });
    });
  }

  Future<void> _pauseTimer() async {
    HapticFeedback.lightImpact();
    safeSetState(() {
      _isRunning = false;
    });
    _pulseController.stop();
    _timer?.cancel();
    _timer = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('prayer_timer_active', false);
      await prefs.remove('prayer_timer_start_ms');
    } catch (_) {}
  }

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _recordInstantlyWithoutTimer() async {
    HapticFeedback.mediumImpact();
    // Use average peaceful prayer duration (e.g. 5 minutes)
    if (_secondsElapsed == 0) {
      _secondsElapsed = 300;
    }
    await _finishPrayer();
  }

  Future<void> _finishPrayer() async {
    final taskManager = Provider.of<SpiritualTaskManager>(context, listen: false);
    _timer?.cancel();
    _pulseController.stop();
    await _clearActiveTimerPrefs();
    HapticFeedback.mediumImpact();

    final targetDate = widget.targetDate ?? DateTime.now();
    final prayerTime = taskManager.getPrayerTime(widget.prayerId, targetDate);

    bool isLate = false;
    if (prayerTime != null) {
      final diff = DateTime.now().difference(prayerTime);
      if (diff.inHours >= 6) {
        isLate = true;
      }
    }

    // Mark task complete and save duration in seconds for the targeted date
    await taskManager.markPrayerAsCompletedForDate(
      widget.prayerId,
      targetDate,
      isLate: isLate,
      duration: _secondsElapsed > 0 ? _secondsElapsed : 300,
    );

    setState(() {
      _isSuccess = true;
    });

    // Wait 2 seconds to show the beautiful confirmation message, then pop
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppThemeManager>(context).currentTheme;
    final prayerName = _prayerNames[widget.prayerId] ?? widget.prayerId;

    final taskManager = Provider.of<SpiritualTaskManager>(context, listen: false);
    final targetDate = widget.targetDate ?? DateTime.now();
    final prayerTime = taskManager.getPrayerTime(widget.prayerId, targetDate);
    bool isLate = false;
    if (prayerTime != null) {
      final diff = DateTime.now().difference(prayerTime);
      if (diff.inHours >= 6) {
        isLate = true;
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
            child: _isSuccess 
                ? _buildSuccessView(theme, prayerName)
                : _buildTimerView(theme, prayerName, isLate),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerView(AppTheme theme, String prayerName, bool isLate) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // AppBar Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close_rounded),
                color: Colors.white,
                iconSize: 28.sp,
              ),
              Text(
                'عدّاد خشوع الصلاة',
                style: GoogleFonts.cairo(
                  color: theme.textColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 48.w), // Spacer
            ],
          ),
          SizedBox(height: 30.h),
          
          // Header Text
          Center(
            child: Column(
              children: [
                Text(
                  prayerName,
                  style: GoogleFonts.cairo(
                    color: theme.accentColor,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'أقم صلاتك لوقتها بكل خشوع وطمأنينة',
                  style: GoogleFonts.cairo(
                    color: theme.subtitleColor,
                    fontSize: 14.sp,
                  ),
                ),
                if (isLate) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'تنبيه: سيتم تسجيل الصلاة كـ صلاة متأخرة بأثر رجعي',
                      style: GoogleFonts.cairo(
                        color: Colors.orangeAccent,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const Spacer(),

          // Stopwatch display in circular layout
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isRunning ? _pulseAnimation.value : 1.0,
                  child: child,
                );
              },
              child: Container(
                width: 250.w,
                height: 250.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.02),
                  border: Border.all(
                    color: _isRunning ? theme.accentColor : theme.subtitleColor.withValues(alpha: 0.2),
                    width: 3.w,
                  ),
                  boxShadow: _isRunning 
                      ? [
                          BoxShadow(
                            color: theme.accentColor.withValues(alpha: 0.25),
                            blurRadius: 40,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 32.sp,
                        color: _isRunning ? theme.accentColor : theme.subtitleColor.withValues(alpha: 0.5),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        _formatDuration(_secondsElapsed),
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 48.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _isRunning ? 'جاري حساب وقت الصلاة...' : 'اضغط بدء الصلاة للبدء',
                        style: GoogleFonts.cairo(
                          color: theme.subtitleColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          // Buttons & Background Assurance
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isRunning) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: theme.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: theme.accentColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: theme.accentColor,
                        size: 18.sp,
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          'يعمل في الخلفية: يمكنك قفل الهاتف أو الخروج بحرية.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (!_isRunning && _secondsElapsed == 0) ...[
                ElevatedButton.icon(
                  onPressed: _startTimer,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('بدء عدّاد الخشوع للصلاة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accentColor,
                    foregroundColor: theme.scaffoldBackgroundColor,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    textStyle: GoogleFonts.cairo(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 5,
                  ),
                ),
                SizedBox(height: 12.h),
                OutlinedButton.icon(
                  onPressed: _recordInstantlyWithoutTimer,
                  icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent),
                  label: const Text('صلّيت بالفعل (تسجيل فوري بدون مؤقت)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    side: BorderSide(
                      color: Colors.greenAccent.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    textStyle: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isRunning ? _pauseTimer : _startTimer,
                        icon: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                        label: Text(_isRunning ? 'إيقاف مؤقت' : 'استئناف'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          textStyle: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: _secondsElapsed > 0 ? _finishPrayer : null,
                        icon: const Icon(Icons.done_all_rounded),
                        label: const Text('إنهاء وتسجيل الصلاة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.accentColor,
                          foregroundColor: theme.scaffoldBackgroundColor,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          textStyle: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Text(
                  'رجوع',
                  style: GoogleFonts.cairo(
                    color: theme.subtitleColor,
                    fontSize: 15.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildSuccessView(AppTheme theme, String prayerName) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing check circle
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.accentColor.withValues(alpha: 0.12),
                border: Border.all(color: theme.accentColor.withValues(alpha: 0.4), width: 2.w),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: theme.accentColor,
                size: 96.sp,
              ),
            ),
            SizedBox(height: 32.h),
            
            // Acceptance text
            Text(
              'تقبل الله صلاتكم وطاعتكم',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'تم تسجيل $prayerName بنجاح وجعله الله في ميزان حسناتكم.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: theme.textColor.withValues(alpha: 0.7),
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 20.h),
            
            // Time recorded summary
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined, color: theme.accentColor, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'مدة الصلاة المسجلة: ${_formatDuration(_secondsElapsed)} دقيقة',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
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
}
