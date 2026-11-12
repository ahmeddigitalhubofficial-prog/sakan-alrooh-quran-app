// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import '../models/theme_manager.dart';
import '../models/task_manager.dart';
import '../services/cloud_sync_service.dart';
import '../services/prayer_service.dart';
import '../services/world_location_service.dart';
import '../core/helpers/app_lifecycle_helper.dart';
import '../widgets/common/quick_language_button.dart';
import '../core/localization/locale_manager.dart';
import '../core/localization/app_translations.dart';

class FastingTrackerScreen extends StatefulWidget {
  const FastingTrackerScreen({super.key});

  @override
  State<FastingTrackerScreen> createState() => _FastingTrackerScreenState();
}

class _FastingTrackerScreenState extends State<FastingTrackerScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  int _qadaDaysRemaining = 0;
  int _completedQadaDays = 0;
  final Set<String> _fastedDaysHistory = {};
  bool _isFastingToday = false;
  bool _fastingReminderEnabled = true;
  Coordinates? _coordinates;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadFastingData();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (AppLifecycleHelper.isBackground) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      if (AppLifecycleHelper.isBackground) {
        _timer?.cancel();
        _timer = null;
        return;
      }
      safeSetState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      safeSetState(() {});
      _startTimer();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  Future<void> _loadFastingData() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final coords = await WorldLocationService.getSavedCoordinates();
    
    if (mounted) {
      setState(() {
        _coordinates = coords;
        _qadaDaysRemaining = prefs.getInt('fasting_qada_remaining') ?? 0;
        _completedQadaDays = prefs.getInt('fasting_qada_completed') ?? 0;
        _fastingReminderEnabled = prefs.getBool('fasting_reminder_enabled') ?? true;
        final history = prefs.getStringList('fasting_history_days') ?? [];
        _fastedDaysHistory.clear();
        _fastedDaysHistory.addAll(history);
        _isFastingToday = _fastedDaysHistory.contains(todayStr);
      });
    }
  }

  Future<void> _pickAndAddPastFastingDate() async {
    final now = DateTime.now();
    final theme = Provider.of<AppThemeManager>(context, listen: false).currentTheme;
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      helpText: 'اختر يوم الصيام',
      cancelText: 'إلغاء',
      confirmText: 'تسجيل الصيام',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: theme.accentColor,
              onPrimary: Colors.black,
              surface: theme.cardColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final pickedStr = DateFormat('yyyy-MM-dd').format(picked);
      if (_fastedDaysHistory.contains(pickedStr)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'هذا اليوم مسجل بالفعل في سجل الصيام!',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.orangeAccent,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final taskManager = Provider.of<SpiritualTaskManager>(context, listen: false);
      final themeManager = Provider.of<AppThemeManager>(context, listen: false);
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      setState(() {
        _fastedDaysHistory.add(pickedStr);
        if (pickedStr == todayStr) {
          _isFastingToday = true;
        }
      });
      themeManager.addHasanatPoints(100);

      await prefs.setStringList('fasting_history_days', _fastedDaysHistory.toList());
      taskManager.updateFastingHistory(_fastedDaysHistory.toList());
      CloudSyncService.autoSyncOnDataChange();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم توثيق صيام يوم ${DateFormat('d MMMM y', 'ar').format(picked)} بنجاح 🌙 (+100 حسنة)',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF0F5A3E),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _confirmDeleteFastingDate(String dateStr, String formattedDate) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF102C3B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'حذف يوم الصيام',
          style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل تريد حذف صيام يوم ($formattedDate) من سجلك؟',
          style: GoogleFonts.cairo(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('حذف', style: GoogleFonts.cairo(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final taskManager = Provider.of<SpiritualTaskManager>(context, listen: false);
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      setState(() {
        _fastedDaysHistory.remove(dateStr);
        if (dateStr == todayStr) {
          _isFastingToday = false;
        }
      });

      await prefs.setStringList('fasting_history_days', _fastedDaysHistory.toList());
      taskManager.updateFastingHistory(_fastedDaysHistory.toList());
      CloudSyncService.autoSyncOnDataChange();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف اليوم من سجل الصيام بنجاح', style: GoogleFonts.cairo()),
          backgroundColor: Colors.black87,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleTodayFasting() async {
    HapticFeedback.mediumImpact();
    final taskManager = Provider.of<SpiritualTaskManager>(context, listen: false);
    final themeManager = Provider.of<AppThemeManager>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    setState(() {
      _isFastingToday = !_isFastingToday;
      if (_isFastingToday) {
        _fastedDaysHistory.add(todayStr);
        themeManager.addHasanatPoints(100); // 100 حسنة لصيام اليوم
      } else {
        _fastedDaysHistory.remove(todayStr);
      }
    });

    await prefs.setStringList('fasting_history_days', _fastedDaysHistory.toList());

    // تحديث مهمة الصيام في الورد اليومي إذا كانت موجودة
    for (var task in taskManager.tasks) {
      if (task.category == 'fasting' || task.id.startsWith('fasting')) {
        taskManager.setTaskCompleted(task.id, _isFastingToday);
      }
    }
    taskManager.updateFastingHistory(_fastedDaysHistory.toList());

    CloudSyncService.autoSyncOnDataChange();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFastingToday ? 'تقبل الله صيامك وطاعتك 🌙 (+100 حسنة)' : 'تم إلغاء تسجيل صيام اليوم',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          backgroundColor: _isFastingToday ? const Color(0xFF0F5A3E) : Colors.black87,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _updateQadaDays(int delta) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _qadaDaysRemaining = (_qadaDaysRemaining + delta).clamp(0, 365);
      if (delta < 0 && _qadaDaysRemaining >= 0) {
        _completedQadaDays += delta.abs();
      }
    });
    await prefs.setInt('fasting_qada_remaining', _qadaDaysRemaining);
    await prefs.setInt('fasting_qada_completed', _completedQadaDays);
    if (mounted) {
      final taskManager = Provider.of<SpiritualTaskManager>(context, listen: false);
      taskManager.updateFastingHistory(_fastedDaysHistory.toList(), qadaCompleted: _completedQadaDays);
    }
    CloudSyncService.autoSyncOnDataChange();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<AppThemeManager>(context);
    final theme = themeManager.currentTheme;
    final now = DateTime.now();
    final hijri = HijriCalendar.now();

    // Coordinates from WorldLocationService with fallback Cairo
    final coordinates = _coordinates ?? Coordinates(30.0444, 31.2357);
    final prayerTimes = PrayerService.getPrayerTimes(coordinates, now);

    final fajr = prayerTimes.fajr;
    final maghrib = prayerTimes.maghrib;

    bool isDaytime = now.isAfter(fajr) && now.isBefore(maghrib);
    Duration diff = isDaytime ? maghrib.difference(now) : (now.isBefore(fajr) ? fajr.difference(now) : fajr.add(const Duration(days: 1)).difference(now));

    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('service_fasting'),
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17.sp),
        ),
        actions: const [
          QuickLanguageButton(isCompact: true),
          SizedBox(width: 8),
        ],
      ),
      body: Directionality(
        textDirection: Provider.of<LocaleManager>(context).textDirection,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Iftar / Imsak Live Countdown Hero Card
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.cardColor,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: theme.accentColor.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isDaytime ? 'الوقت المتبقي حتى الإفطار 🍲' : 'الوقت المتبقي حتى الإمساك (الفجر) ⏳',
                          style: GoogleFonts.cairo(
                            color: theme.accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}هـ',
                            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      '$hours:$minutes:$seconds',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 38.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTimeBadge('الفجر (الإمساك)', DateFormat('hh:mm a', 'ar').format(fajr), theme),
                        _buildTimeBadge('المغرب (الإفطار)', DateFormat('hh:mm a', 'ar').format(maghrib), theme),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    ElevatedButton.icon(
                      onPressed: _toggleTodayFasting,
                      icon: Icon(_isFastingToday ? Icons.check_circle_rounded : Icons.add_task_rounded, color: Colors.black),
                      label: Text(
                        _isFastingToday ? 'أنا صائم اليوم بحمد الله 🤍' : 'تسجيل أنني صائم اليوم 🌙',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFastingToday ? const Color(0xFF69F0AE) : theme.accentColor,
                        foregroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 44.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // 2. Fasting Reminders Switch Card
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: theme.accentColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: theme.accentColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.notifications_active_rounded, color: theme.accentColor, size: 22.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تذكير صيام النوافل 🔔',
                            style: GoogleFonts.cairo(
                              color: theme.textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            'تنبيه مساء الأحد والأربعاء وقبل الأيام البيض',
                            style: GoogleFonts.cairo(
                              color: theme.subtitleColor,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _fastingReminderEnabled,
                      activeColor: theme.accentColor,
                      onChanged: (val) async {
                        final messenger = ScaffoldMessenger.of(context);
                        final prefs = await SharedPreferences.getInstance();
                        if (!mounted) return;
                        setState(() => _fastingReminderEnabled = val);
                        await prefs.setBool('fasting_reminder_enabled', val);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              val ? 'تم تفعيل تذكير صيام النوافل بنجاح 🔔' : 'تم إيقاف تذكير الصيام',
                              style: GoogleFonts.cairo(),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // 3. Qada' Tracker (سجل أيام القضاء والكفارات)
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_month_rounded, color: theme.accentColor, size: 22.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'سجل أيام القضاء والكفارات',
                          style: GoogleFonts.cairo(
                            color: theme.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الأيام المتبقية عليك:',
                              style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 12.sp),
                            ),
                            Text(
                              '$_qadaDaysRemaining يوم',
                              style: GoogleFonts.cairo(
                                color: _qadaDaysRemaining > 0 ? Colors.orangeAccent : Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 22.sp,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton.filled(
                              onPressed: () => _updateQadaDays(-1),
                              icon: const Icon(Icons.remove, color: Colors.white),
                              style: IconButton.styleFrom(backgroundColor: Colors.redAccent.shade400),
                            ),
                            SizedBox(width: 8.w),
                            IconButton.filled(
                              onPressed: () => _updateQadaDays(1),
                              icon: const Icon(Icons.add, color: Colors.black),
                              style: IconButton.styleFrom(backgroundColor: theme.accentColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // 4. Detailed Fasting Log (سجل الصيام التفصيلي الموثق)
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: theme.accentColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.history_edu_rounded, color: theme.accentColor, size: 22.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'سجل أيامي المصومة 📜',
                              style: GoogleFonts.cairo(
                                color: theme.textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: theme.accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '${_fastedDaysHistory.length} يوم صيام',
                            style: GoogleFonts.cairo(
                              color: theme.accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    OutlinedButton.icon(
                      onPressed: _pickAndAddPastFastingDate,
                      icon: Icon(Icons.add_circle_outline_rounded, size: 16.sp, color: theme.accentColor),
                      label: Text(
                        'تسجيل يوم صيام سابق ➕',
                        style: GoogleFonts.cairo(
                          color: theme.accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5.sp,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.accentColor.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        minimumSize: Size(double.infinity, 38.h),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    if (_fastedDaysHistory.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.nights_stay_outlined, color: theme.subtitleColor, size: 36.sp),
                              SizedBox(height: 8.h),
                              Text(
                                'لم تسجل أي أيام صيام بعد.\nاضغط على "أنا صائم اليوم" لتوثيق صيامك وحصد الأوسمة!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 12.sp),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _fastedDaysHistory.length > 15 ? 15 : _fastedDaysHistory.length,
                        separatorBuilder: (_, __) => Divider(color: theme.dividerColor.withValues(alpha: 0.2)),
                        itemBuilder: (context, index) {
                          final sortedList = _fastedDaysHistory.toList()..sort((a, b) => b.compareTo(a));
                          final dateStr = sortedList[index];
                          final parsedDate = DateTime.tryParse(dateStr) ?? DateTime.now();
                          final hijriDate = HijriCalendar.fromDate(parsedDate);
                          final type = _getFastingType(parsedDate, hijriDate);

                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF64B5F6).withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.check_rounded, color: const Color(0xFF64B5F6), size: 16.sp),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        type,
                                        style: GoogleFonts.cairo(
                                          color: theme.textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                      Text(
                                        '${DateFormat('EEEE، d MMMM y', 'ar').format(parsedDate)} (${hijriDate.hDay} ${hijriDate.longMonthName})',
                                        style: GoogleFonts.cairo(
                                          color: theme.subtitleColor,
                                          fontSize: 10.5.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.redAccent.withValues(alpha: 0.7),
                                    size: 18.sp,
                                  ),
                                  onPressed: () => _confirmDeleteFastingDate(
                                    dateStr,
                                    DateFormat('EEEE، d MMMM y', 'ar').format(parsedDate),
                                  ),
                                  tooltip: 'حذف من السجل',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // 5. Sunnah Fasting Occasions (سنن الصيام المستحبة)
              Text(
                'سنن الصيام المباركة',
                style: GoogleFonts.cairo(
                  color: theme.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 10.h),
              _buildSunnahCard('صيام الإثنين والخميس', 'تُعرض فيهما الأعمال على الله تعالى', Icons.wb_sunny_outlined, theme),
              SizedBox(height: 8.h),
              _buildSunnahCard('صيام الأيام البيض (13 و 14 و 15)', 'صيام ثلاثة أيام من كل شهر يعدل صيام الدهر', Icons.brightness_2_outlined, theme),
              SizedBox(height: 8.h),
              _buildSunnahCard('صيام الست من شوال', 'من صام رمضان ثم أتبعه بست من شوال كان كصيام الدهر', Icons.star_border_rounded, theme),
              SizedBox(height: 8.h),
              _buildSunnahCard('صيام يوم عرفة وعاشوراء', 'يكفر سنة ماضية وباقية (عرفة) وسنة ماضية (عاشوراء)', Icons.mosque_outlined, theme),

              SizedBox(height: 20.h),

              // 6. Dua for Fasting and Breaking Fast
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: theme.accentColor.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'دعاء الإفطار المأثور 🤲',
                          style: GoogleFonts.cairo(color: theme.accentColor, fontWeight: FontWeight.bold, fontSize: 14.sp),
                        ),
                        IconButton(
                          icon: Icon(Icons.share_rounded, color: theme.accentColor, size: 18.sp),
                          onPressed: () {
                            Share.share('دعاء الإفطار: "ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ، وَثَبَتَ الأَجْرُ إِنْ شَاءَ اللَّهُ"\n\nمن تطبيق نور الهدى 🌙');
                          },
                        ),
                      ],
                    ),
                    Text(
                      '« ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ، وَثَبَتَ الأَجْرُ إِنْ شَاءَ اللَّهُ »',
                      style: GoogleFonts.amiri(
                        color: theme.textColor,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  String _getFastingType(DateTime date, HijriCalendar hijri) {
    if (hijri.hMonth == 9) return 'صيام شهر رمضان المبارك 🌙';
    if (hijri.hMonth == 12 && hijri.hDay == 9) return 'صيام يوم عرفة 🕋';
    if (hijri.hMonth == 1 && (hijri.hDay == 9 || hijri.hDay == 10)) return 'صيام تاسوعاء وعاشوراء 🤲';
    if (hijri.hMonth == 10 && hijri.hDay >= 2 && hijri.hDay <= 30) return 'صيام الست من شوال 🌟';
    if (hijri.hDay == 13 || hijri.hDay == 14 || hijri.hDay == 15) return 'صيام الأيام البيض (${hijri.hDay} ${hijri.longMonthName}) 🌕';
    if (date.weekday == DateTime.monday) return 'صيام سنة يوم الإثنين 🌙';
    if (date.weekday == DateTime.thursday) return 'صيام سنة يوم الخميس 🌙';
    return 'صيام تطوع وقضاء لله تعالى 🤍';
  }

  Widget _buildTimeBadge(String title, String time, AppTheme theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11.sp)),
          SizedBox(height: 2.h),
          Text(time, style: GoogleFonts.cairo(color: theme.accentColor, fontWeight: FontWeight.bold, fontSize: 13.sp)),
        ],
      ),
    );
  }

  Widget _buildSunnahCard(String title, String subtitle, IconData icon, AppTheme theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: theme.accentColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 13.sp)),
                Text(subtitle, style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 11.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
