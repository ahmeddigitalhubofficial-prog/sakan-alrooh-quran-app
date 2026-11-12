// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/theme_manager.dart';
import '../models/task_manager.dart';
import '../services/cloud_sync_service.dart';
import '../widgets/common/auto_scroll_text.dart';

class TasbihScreen extends StatefulWidget {
  final String? initialDhikr;
  final int? targetCount;
  final String? linkedTaskId;

  const TasbihScreen({
    super.key,
    this.initialDhikr,
    this.targetCount,
    this.linkedTaskId,
  });

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with SingleTickerProviderStateMixin {
  int _counter = 0;

  int get _displayCount {
    if (_targetCount > 0) {
      if (_counter == 0) return 0;
      final mod = _counter % _targetCount;
      return mod == 0 ? _targetCount : mod;
    }
    return _counter;
  }

  int _totalAllTime = 0;

  int _dailyCount = 0;

  int _weeklyCount = 0;

  int _monthlyCount = 0;

  int _streakDays = 1;

  String _lastClickDate = '';

  int _targetCount = 33;

  double _progress = 0;

  String _selectedDhikr = 'سُبْحَانَ اللهِ';

  final List<String> _defaultAzkar = [
    'سُبْحَانَ اللهِ',
    'الحَمْدُ للهِ',
    'لا إِلهَ إِلاَّ اللهُ',
    'اللهُ أَكْبَرُ',
    'أَسْتَغْفِرُ اللهَ',
  ];

  String _selectedTheme = 'ذهبي';

  bool _soundEnabled = true;

  bool _vibrationEnabled = true;

  bool _is3DMode = false;
  double _angleOffset = 0.0;
  int _lastSnap = 0;

  late final AnimationController _animationController;

  late final Animation<double> _scaleAnimation;

  List<int> _achievements = [];

  List<String> _customAzkar = [];

  final TextEditingController _customDhikrController = TextEditingController();

  final List<String> _floatingQuotes = [
    'ما شاء الله ✨',
    'استمر 🤍',
    'جزاك الله خيرًا 🌙',
    'ذكر الله يطمئن القلب 🕌',
    'بارك الله فيك 💛',
  ];

  String _currentQuote = 'استمر 🤍';

  final Map<String, List<Color>> _tasbihThemes = {
    'ذهبي': [
      const Color(
        0xFFD4AF37,
      ),
      const Color(
        0xFFB8922E,
      ),
    ],
    'زمردي': [
      const Color(
        0xFF2ECC71,
      ),
      const Color(
        0xFF145A32,
      ),
    ],
    'ليلي': [
      const Color(
        0xFF5B2C6F,
      ),
      const Color(
        0xFF1B2631,
      ),
    ],
    'خشبي': [
      const Color(
        0xFF8E5A3C,
      ),
      const Color(
        0xFF5D4037,
      ),
    ],
  };

  List<Color> get _activeThemeColors {
    if (_tasbihThemes.containsKey(_selectedTheme)) {
      return _tasbihThemes[_selectedTheme]!;
    }
    if (_selectedTheme == 'emerald') return _tasbihThemes['زمردي']!;
    if (_selectedTheme == 'gold') return _tasbihThemes['ذهبي']!;
    if (_selectedTheme == 'midnight') return _tasbihThemes['ليلي']!;
    if (_selectedTheme == 'wood') return _tasbihThemes['خشبي']!;
    return _tasbihThemes['ذهبي']!;
  }

  @override
  void initState() {
    super.initState();

    _loadData();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 120,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.93,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();

    _customDhikrController.dispose();

    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _counter = prefs.getInt(
            'tasbih_counter',
          ) ??
          0;

      _dailyCount = prefs.getInt(
            'tasbih_daily',
          ) ??
          0;

      _weeklyCount = prefs.getInt(
            'weekly_count',
          ) ??
          0;

      _monthlyCount = prefs.getInt(
            'monthly_count',
          ) ??
          0;

      _totalAllTime = prefs.getInt(
            'tasbih_total',
          ) ??
          0;

      _streakDays = prefs.getInt(
            'tasbih_streak',
          ) ??
          1;

      _lastClickDate = prefs.getString('tasbih_last_click_date') ?? '';

      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (_lastClickDate != todayStr) {
        if (_lastClickDate.isNotEmpty) {
          try {
            final today = DateTime.now();
            final todayDateOnly = DateTime(today.year, today.month, today.day);
            final lastDate = DateFormat('yyyy-MM-dd').parse(_lastClickDate);
            final lastDateOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
            final differenceInDays = todayDateOnly.difference(lastDateOnly).inDays;
            if (differenceInDays > 1) {
              _streakDays = 1;
            }
          } catch (e) {
            _streakDays = 1;
          }
        } else {
          _streakDays = 1;
        }
        _dailyCount = 0;
        _counter = 0;
        _lastClickDate = todayStr;
      } else {
        // إذا كان نفس اليوم ومهمة التسبيح اليومي غير مكتملة، نبدأ العداد من تسبيحات اليوم الفعلية
        if (widget.linkedTaskId == 'daily_tasbih') {
          _counter = _dailyCount < 33 ? _dailyCount : 0;
        }
      }

      final savedTarget = prefs.getInt(
            'tasbih_target',
          ) ??
          33;
      _targetCount = savedTarget <= 0 ? 33 : savedTarget;

      final savedTheme = prefs.getString(
            'tasbih_theme',
          ) ??
          'ذهبي';
      if (_tasbihThemes.containsKey(savedTheme)) {
        _selectedTheme = savedTheme;
      } else if (savedTheme == 'emerald') {
        _selectedTheme = 'زمردي';
      } else if (savedTheme == 'gold') {
        _selectedTheme = 'ذهبي';
      } else if (savedTheme == 'midnight') {
        _selectedTheme = 'ليلي';
      } else if (savedTheme == 'wood') {
        _selectedTheme = 'خشبي';
      } else {
        _selectedTheme = 'ذهبي';
      }

      _customAzkar = prefs.getStringList(
            'custom_azkar',
          ) ??
          [];

      _selectedDhikr = widget.initialDhikr ?? prefs.getString('tasbih_dhikr') ?? 'سُبْحَانَ اللهِ';
      if (widget.targetCount != null) {
        _targetCount = widget.targetCount!;
      }

      _achievements = prefs
              .getStringList(
                'achievements',
              )
              ?.map(
                (e) => int.parse(e),
              )
              .toList() ??
          [];

      if (_targetCount > 0) {
        final currentInCycle = _counter % _targetCount;
        _progress = (currentInCycle == 0 && _counter > 0) ? 1.0 : currentInCycle / _targetCount;
      } else {
        _progress = 1.0;
      }

      _soundEnabled = prefs.getBool('tasbih_sound') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _is3DMode = prefs.getBool('tasbih_is_3d') ?? false;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      'tasbih_counter',
      _counter,
    );

    await prefs.setInt(
      'tasbih_daily',
      _dailyCount,
    );

    await prefs.setInt(
      'weekly_count',
      _weeklyCount,
    );

    await prefs.setInt(
      'monthly_count',
      _monthlyCount,
    );

    await prefs.setInt(
      'tasbih_total',
      _totalAllTime,
    );

    await prefs.setInt(
      'tasbih_streak',
      _streakDays,
    );

    await prefs.setString(
      'tasbih_last_click_date',
      _lastClickDate,
    );

    if (widget.targetCount == null) {
      await prefs.setInt(
        'tasbih_target',
        _targetCount,
      );
    }

    await prefs.setString(
      'tasbih_theme',
      _selectedTheme,
    );

    await prefs.setStringList(
      'custom_azkar',
      _customAzkar,
    );

    await prefs.setString(
      'tasbih_dhikr',
      _selectedDhikr,
    );

    await prefs.setStringList(
      'achievements',
      _achievements
          .map(
            (e) => e.toString(),
          )
          .toList(),
    );

    await prefs.setBool(
      'tasbih_is_3d',
      _is3DMode,
    );

    // مزامنة سحابية هادئة وتلقائية لحفظ أعداد التسبيح في Firestore فوراً
    CloudSyncService.autoSyncOnDataChange();
  }

  Future<void> _incrementCounter() async {
    _animationController.forward().then(
          (_) => _animationController.reverse(),
        );

    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    setState(() {
      if (_lastClickDate != todayStr) {
        if (_lastClickDate.isNotEmpty) {
          try {
            final today = DateTime.now();
            final todayDateOnly = DateTime(today.year, today.month, today.day);
            final lastDate = DateFormat('yyyy-MM-dd').parse(_lastClickDate);
            final lastDateOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
            final differenceInDays = todayDateOnly.difference(lastDateOnly).inDays;
            if (differenceInDays == 1) {
              _streakDays++;
            } else {
              _streakDays = 1;
            }
          } catch (e) {
            _streakDays = 1;
          }
        } else {
          _streakDays = 1;
        }
        _dailyCount = 0;
        _counter = 0;
        _lastClickDate = todayStr;
      }

      _counter++;

      _dailyCount++;

      _weeklyCount++;

      _monthlyCount++;

      _totalAllTime++;

      if (_targetCount > 0) {
        final currentInCycle = _counter % _targetCount;
        _progress = (currentInCycle == 0 && _counter > 0) ? 1.0 : currentInCycle / _targetCount;
      } else {
        _progress = 1.0;
      }

      _currentQuote = _floatingQuotes[Random().nextInt(
        _floatingQuotes.length,
      )];
    });

    if (mounted) {
      final taskId = widget.linkedTaskId ?? 'daily_tasbih';
      // مهمة daily_tasbih ترتبط بشكل صارم بعدد تسبيحات اليوم الفعلي (_dailyCount)
      // لضمان استيفاء 33 تسبيحة كاملة من اليوم الحالي دون احتساب بقايا الأيام السابقة
      final progressToSend = (widget.linkedTaskId != null && widget.linkedTaskId != 'daily_tasbih')
          ? _counter
          : _dailyCount;
      Provider.of<SpiritualTaskManager>(
        context,
        listen: false,
      ).updateTaskProgress(
        taskId,
        progressToSend,
      );
    }

    if (_vibrationEnabled) {
      HapticFeedback.lightImpact();
    }

    if (_soundEnabled) {
      SystemSound.play(
        SystemSoundType.click,
      );
    }

    _checkAchievements();

    if (_targetCount > 0 && _displayCount == _targetCount) {
      HapticFeedback.heavyImpact();

      _showAchievement();
    }

    await _saveData();
  }

  Future<void> _resetCounterOnly() async {
    HapticFeedback.mediumImpact();

    setState(() {
      _counter = 0;
      _progress = 0;
    });

    // لا نقوم بتصفير مهمة الورد اليومي المنجزة عند تصفير عداد السبحة لبدء دورة جديدة

    await _saveData();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        content: Text(
          'تم تصفير العداد الحالي',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _clearAllStats() async {
    HapticFeedback.heavyImpact();

    setState(() {
      _counter = 0;
      _progress = 0;
      _totalAllTime = 0;
      _dailyCount = 0;
      _weeklyCount = 0;
      _monthlyCount = 0;
      _streakDays = 1;
      _lastClickDate = '';
      _achievements.clear();
    });

    if (mounted) {
      Provider.of<SpiritualTaskManager>(
        context,
        listen: false,
      ).updateTaskProgress(
        'daily_tasbih',
        0,
      );
    }

    await _saveData();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        content: Text(
          'تم مسح جميع الإحصائيات والسجلات بنجاح',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _showResetOptionsDialog() async {
    final activeTheme = _activeThemeColors;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: const Color(0xFF102C3B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
              side: BorderSide(color: activeTheme.first.withValues(alpha: 0.3)),
            ),
            title: Text(
              'تصفير العداد',
              style: GoogleFonts.cairo(
                color: activeTheme.first,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'يرجى اختيار نوع التصفير المطلوب:',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 16.sp,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'إلغاء',
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _resetCounterOnly();
                },
                child: Text(
                  'تصفير العداد الحالي',
                  style: GoogleFonts.cairo(
                    color: activeTheme.first,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _clearAllStats();
                },
                child: Text(
                  'مسح الكل',
                  style: GoogleFonts.cairo(
                    color: Colors.redAccent,
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

  void _checkAchievements() {
    final milestones = [
      100,
      500,
      1000,
      5000,
      10000,
    ];

    for (final value in milestones) {
      if (_totalAllTime >= value &&
          !_achievements.contains(
            value,
          )) {
        _achievements.add(
          value,
        );

        _showMilestoneDialog(
          value,
        );
      }
    }
  }

  void _showMilestoneDialog(
    int value,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(
            0xFF102C3B,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              24.r,
            ),
          ),
          title: Text(
            '🏆 إنجاز جديد',
            style: GoogleFonts.cairo(
              color: const Color(
                0xFFD4AF37,
              ),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'لقد وصلت إلى $value تسبيحة ✨',
            style: GoogleFonts.cairo(
              color: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child: Text(
                'رائع',
                style: GoogleFonts.cairo(
                  color: const Color(
                    0xFFD4AF37,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAchievement() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(
          0xFFD4AF37,
        ),
        content: Text(
          '🎉 تم إكمال الهدف بنجاح',
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

    final theme = themeManager.currentTheme;

    final activeTheme = _activeThemeColors;

    final screenWidth = MediaQuery.sizeOf(
      context,
    ).width;

    final circleSize = min(
      screenWidth * 0.58,
      240.w,
    );

    final outerCircleSize = circleSize + 70.w;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              activeTheme.first,
              theme.scaffoldBackgroundColor,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: 18.w,
              vertical: 16.h,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 6.h,
                ),
                Icon(
                  Icons.fingerprint_rounded,
                  size: 60.sp,
                  color: activeTheme.first,
                ),
                SizedBox(
                  height: 14.h,
                ),
                Text(
                  'السبحة الإلكترونية',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 300,
                  ),
                  child: Text(
                    _currentQuote,
                    key: ValueKey(
                      _currentQuote,
                    ),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color: activeTheme.first,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                SizedBox(
                  height: 14.h,
                ),
                // Mode switcher (Classic / 3D)
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _is3DMode = false;
                            });
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('tasbih_is_3d', false);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: !_is3DMode
                                  ? activeTheme.first
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'العداد التقليدي',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                color: !_is3DMode ? Colors.black : Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _is3DMode = true;
                            });
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('tasbih_is_3d', true);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: _is3DMode
                                  ? activeTheme.first
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'سبحة تفاعلية 3D',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                color: _is3DMode ? Colors.black : Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                GestureDetector(
                  onTap: _showDhikrSelectionDialog,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: activeTheme.first.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_note_rounded, color: activeTheme.first, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'تغيير الذكر: $_selectedDhikr',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 16.h,
                ),
                // صف اختيار الهدف الشرعي
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [33, 100, 1000, 0].map((t) {
                    final isSelected = _targetCount == t;
                    final label = t == 0 ? 'مفتوح' : '$t';
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: ChoiceChip(
                        label: Text(
                          t == 33 ? '$label (سُنّة)' : label,
                          style: GoogleFonts.cairo(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: activeTheme.first,
                        backgroundColor: Colors.white10,
                        onSelected: (_) async {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _targetCount = t;
                            if (_targetCount > 0) {
                              final currentInCycle = _counter % _targetCount;
                              _progress = (currentInCycle == 0 && _counter > 0)
                                  ? 1.0
                                  : currentInCycle / _targetCount;
                            } else {
                              _progress = 1.0;
                            }
                          });
                          if (widget.targetCount == null) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setInt('tasbih_target', _targetCount);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: 16.h,
                ),
                SizedBox(
                  height: 50.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _tasbihThemes.keys.map(
                      (themeName) {
                        final isSelected = _selectedTheme == themeName;

                        return Padding(
                          padding: EdgeInsets.only(
                            right: 10.w,
                          ),
                          child: ChoiceChip(
                            label: Text(
                              themeName,
                              style: GoogleFonts.cairo(
                                color: isSelected ? Colors.black : Colors.white,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: (_tasbihThemes[themeName] ?? _activeThemeColors).first,
                            backgroundColor: Colors.white10,
                            onSelected: (_) async {
                              setState(() {
                                _selectedTheme = themeName;
                              });

                              await _saveData();
                            },
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
                SizedBox(
                  height: 34.h,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _is3DMode
                      ? _build3dPlayer(activeTheme, circleSize, outerCircleSize)
                      : _buildClassicPlayer(activeTheme, circleSize, outerCircleSize),
                ),
                SizedBox(
                  height: 40.h,
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(
                    18.w,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.05,
                    ),
                    borderRadius: BorderRadius.circular(
                      24.r,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: 0.08,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildStatTile(
                        title: 'إجمالي التسبيحات',
                        value: '$_totalAllTime',
                        color: activeTheme.first,
                      ),
                      SizedBox(
                        height: 14.h,
                      ),
                      _buildStatTile(
                        title: 'تسبيحات اليوم',
                        value: '$_dailyCount',
                        color: Colors.white,
                      ),
                      SizedBox(
                        height: 14.h,
                      ),
                      _buildStatTile(
                        title: 'أيام الاستمرار',
                        value: '$_streakDays',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: EdgeInsets.symmetric(
                            vertical: 16.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              20.r,
                            ),
                          ),
                        ),
                        onPressed: _showResetOptionsDialog,
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                        label: Text(
                          'تصفير العداد',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            color: Colors.white70,
            fontSize: 15.sp,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            color: color,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showDhikrSelectionDialog() {
    final activeTheme = _activeThemeColors;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final allDhikrs = [..._defaultAzkar, ..._customAzkar];
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                backgroundColor: const Color(0xFF102C3B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  side: BorderSide(color: activeTheme.first.withValues(alpha: 0.3)),
                ),
                title: Text(
                  'اختر الذكر',
                  style: GoogleFonts.cairo(
                    color: activeTheme.first,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: allDhikrs.length,
                          itemBuilder: (context, index) {
                            final dhikr = allDhikrs[index];
                            final isDefault = index < _defaultAzkar.length;
                            final isSelected = _selectedDhikr == dhikr;

                            return ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                              title: Text(
                                dhikr,
                                style: GoogleFonts.cairo(
                                  color: isSelected ? activeTheme.first : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              leading: Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                                color: isSelected ? activeTheme.first : Colors.white54,
                              ),
                              trailing: !isDefault
                                  ? IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                      onPressed: () async {
                                        setState(() {
                                          _customAzkar.remove(dhikr);
                                          if (_selectedDhikr == dhikr) {
                                            _selectedDhikr = _defaultAzkar.first;
                                          }
                                        });
                                        setDialogState(() {});
                                        await _saveData();
                                      },
                                    )
                                  : null,
                              onTap: () async {
                                setState(() {
                                  _selectedDhikr = dhikr;
                                });
                                final navigator = Navigator.of(context);
                                await _saveData();
                                navigator.pop();
                              },
                            );
                          },
                        ),
                      ),
                      const Divider(color: Colors.white24, height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customDhikrController,
                              style: GoogleFonts.cairo(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'أضف ذكراً مخصصاً...',
                                hintStyle: GoogleFonts.cairo(color: Colors.white38),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white24),
                                ),
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline_rounded, color: activeTheme.first),
                            onPressed: () async {
                              final text = _customDhikrController.text.trim();
                              if (text.isNotEmpty && !_customAzkar.contains(text) && !_defaultAzkar.contains(text)) {
                                setState(() {
                                  _customAzkar.add(text);
                                  _selectedDhikr = text;
                                });
                                _customDhikrController.clear();
                                setDialogState(() {});
                                final navigator = Navigator.of(context);
                                await _saveData();
                                navigator.pop();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildClassicPlayer(List<Color> activeTheme, double circleSize, double outerCircleSize) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: outerCircleSize,
          height: outerCircleSize,
          child: CircularProgressIndicator(
            value: _progress,
            strokeWidth: 10.w,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation(
              activeTheme.first,
            ),
          ),
        ),
        ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTap: _incrementCounter,
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: activeTheme,
                ),
                boxShadow: [
                  BoxShadow(
                    color: activeTheme.first.withValues(
                      alpha: 0.28,
                    ),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Text(
                    '$_displayCount',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 52.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_targetCount > 0) ...[
                    Text(
                      'الهدف: $_targetCount • دورة: ${_counter == 0 ? 1 : ((_counter - 1) ~/ _targetCount) + 1}${_counter > _targetCount ? ' (الإجمالي: $_counter)' : ''}',
                      style: GoogleFonts.cairo(
                        color: Colors.white60,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                  ] else ...[
                    SizedBox(height: 6.h),
                  ],
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                    ),
                    child: Text(
                      _selectedDhikr,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _build3dPlayer(List<Color> activeTheme, double circleSize, double outerCircleSize) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Compute rotation based on drag movement
        double delta = (details.delta.dx - details.delta.dy) * 0.006;
        setState(() {
          _angleOffset += delta;
          
          double anglePerBead = 2 * pi / 33;
          int currentSnap = (_angleOffset / anglePerBead).round();
          if (currentSnap != _lastSnap) {
            int diff = (currentSnap - _lastSnap).abs();
            if (diff > 0) {
              _incrementCounter();
              _lastSnap = currentSnap;
            }
          }
        });
      },
      child: Container(
        width: outerCircleSize,
        height: outerCircleSize,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          shape: BoxShape.circle,
          border: Border.all(
            color: activeTheme.first.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(outerCircleSize, outerCircleSize),
              painter: Tasbih3dPainter(
                angleOffset: _angleOffset,
                themeColors: activeTheme,
                beadCount: 33,
                activeBeadIndex: _displayCount > 0 ? (_displayCount - 1) % 33 : 0,
              ),
            ),
            Container(
              width: circleSize * 0.72,
              height: circleSize * 0.72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF06151F).withOpacity(0.85),
                border: Border.all(
                  color: activeTheme.first.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: activeTheme.first.withValues(alpha: 0.15),
                    blurRadius: 12,
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_displayCount',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 42.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_targetCount > 0) ...[
                    Text(
                      'الهدف: $_targetCount • دورة: ${_counter == 0 ? 1 : ((_counter - 1) ~/ _targetCount) + 1}',
                      style: GoogleFonts.cairo(
                        color: Colors.white60,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  SizedBox(height: 2.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: AutoScrollText(
                      _selectedDhikr,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 10.sp,
                      ),
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

class Tasbih3dPainter extends CustomPainter {
  final double angleOffset;
  final List<Color> themeColors;
  final int beadCount;
  final int activeBeadIndex;

  Tasbih3dPainter({
    required this.angleOffset,
    required this.themeColors,
    required this.beadCount,
    required this.activeBeadIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Draw the thread connecting the beads
    final paintThread = Paint()
      ..color = themeColors.first.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, paintThread);

    // Draw a traditional Islamic tassel at the bottom (angle = pi / 2)
    final tasselCenter = Offset(center.dx, center.dy + radius);
    final paintGold = Paint()..color = themeColors.first;
    
    // Draw tassel cap/cone
    final pathCap = Path();
    pathCap.moveTo(tasselCenter.dx, tasselCenter.dy);
    pathCap.lineTo(tasselCenter.dx - 8, tasselCenter.dy + 12);
    pathCap.lineTo(tasselCenter.dx + 8, tasselCenter.dy + 12);
    pathCap.close();
    canvas.drawPath(pathCap, paintGold);
    
    // Draw tassel threads
    final paintThreads = Paint()
      ..color = themeColors.first.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (int t = -4; t <= 4; t++) {
      canvas.drawLine(
        Offset(tasselCenter.dx + t * 2, tasselCenter.dy + 12),
        Offset(tasselCenter.dx + t * 3.5, tasselCenter.dy + 32),
        paintThreads,
      );
    }

    // Draw the 33 beads
    const double beadRadius = 11.0;
    for (int i = 0; i < beadCount; i++) {
      double angle = angleOffset + i * (2 * pi / beadCount);
      double beadX = center.dx + radius * cos(angle);
      double beadY = center.dy + radius * sin(angle);
      Offset beadCenter = Offset(beadX, beadY);

      bool isActive = (i == activeBeadIndex);
      final paintBead = Paint();

      // Create a 3D effect using a RadialGradient with off-center light highlight
      final rect = Rect.fromCircle(center: beadCenter, radius: beadRadius);
      final gradient = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        colors: isActive
            ? [
                Colors.white,
                themeColors.first,
                themeColors.last,
                Colors.black,
              ]
            : [
                Colors.white70,
                themeColors.first.withOpacity(0.75),
                themeColors.last.withOpacity(0.95),
                Colors.black.withOpacity(0.9),
              ],
        stops: const [0.0, 0.25, 0.85, 1.0],
      );

      paintBead.shader = gradient.createShader(rect);
      canvas.drawCircle(beadCenter, beadRadius, paintBead);

      // Draw shiny gloss highlight
      final paintSheen = Paint()
        ..color = Colors.white.withOpacity(0.22)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(beadX - beadRadius * 0.25, beadY - beadRadius * 0.25),
        beadRadius * 0.15,
        paintSheen,
      );
    }
  }

  @override
  bool shouldRepaint(covariant Tasbih3dPainter oldDelegate) {
    return oldDelegate.angleOffset != angleOffset ||
        oldDelegate.activeBeadIndex != activeBeadIndex ||
        oldDelegate.themeColors.first != themeColors.first;
  }
}
