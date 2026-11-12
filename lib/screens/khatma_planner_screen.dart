// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/theme_manager.dart';
import '../models/khatma_model.dart';
import '../data/quran_index_data.dart';
import '../widgets/common/auto_scroll_text.dart';
import 'surah_detail_screen.dart';

class KhatmaPlannerScreen extends StatefulWidget {
  const KhatmaPlannerScreen({super.key});

  @override
  State<KhatmaPlannerScreen> createState() => _KhatmaPlannerScreenState();
}

class _KhatmaPlannerScreenState extends State<KhatmaPlannerScreen> {
  KhatmaPlan? _activePlan;
  SharedKhatmaPlan? _activeSharedPlan;
  bool _isLoading = true;

  // Personal Plan Form controllers
  final TextEditingController _titleController = TextEditingController(text: 'ختمة القرآن الكريم');
  double _daysSliderValue = 30.0;

  // Shared Plan Form controllers
  final TextEditingController _sharedTitleController = TextEditingController(text: 'ختمة جماعية مباركة');

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sharedTitleController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    final plan = await KhatmaService.loadPlan();
    if (plan != null) {
      await KhatmaService.checkAndResetStreak(plan);
    }
    final sharedPlan = await KhatmaService.loadSharedPlan();
    setState(() {
      _activePlan = plan;
      _activeSharedPlan = sharedPlan;
      _isLoading = false;
    });
  }

  Future<void> _createPlan() async {
    HapticFeedback.mediumImpact();
    final newPlan = KhatmaPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : 'ختمة القرآن الكريم',
      totalDays: _daysSliderValue.toInt(),
      startDate: DateTime.now(),
    );
    await KhatmaService.savePlan(newPlan);
    setState(() {
      _activePlan = newPlan;
    });
  }

  Future<void> _deletePlan() async {
    HapticFeedback.mediumImpact();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Provider.of<AppThemeManager>(context, listen: false).currentTheme;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: theme.cardColor,
            title: Text('إنهاء الختمة الفردية', style: GoogleFonts.cairo(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            content: Text('هل أنت متأكد من رغبتك في حذف الختمة الفردية الحالية؟ سيتم مسح الإحصائيات وسجل التقدم.', style: GoogleFonts.cairo(color: theme.textColor)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('إلغاء', style: GoogleFonts.cairo(color: theme.subtitleColor)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () => Navigator.pop(context, true),
                child: Text('نعم، احذف', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );

    if (confirm == true) {
      await KhatmaService.clearPlan();
      setState(() {
        _activePlan = null;
      });
    }
  }

  Future<void> _logReadingProgress() async {
    final pageController = TextEditingController(
      text: _activePlan?.lastReadPage == 0 ? '' : _activePlan?.lastReadPage.toString(),
    );

    final newPage = await showDialog<int>(
      context: context,
      builder: (context) {
        final theme = Provider.of<AppThemeManager>(context, listen: false).currentTheme;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: theme.cardColor,
            title: Text(
              'تسجيل الصفحة الحالية',
              style: GoogleFonts.cairo(color: theme.accentColor, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أدخل رقم الصفحة التي وصلت إليها في القراءة (من 1 إلى 604):',
                  style: GoogleFonts.cairo(color: theme.textColor, fontSize: 13.sp),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: pageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GoogleFonts.cairo(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'مثال: 120',
                    hintStyle: GoogleFonts.cairo(color: Colors.white30),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: theme.accentColor),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء', style: GoogleFonts.cairo(color: theme.subtitleColor)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: theme.accentColor),
                onPressed: () {
                  final input = int.tryParse(pageController.text);
                  if (input != null && input >= 1 && input <= 604) {
                    Navigator.pop(context, input);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('الرجاء إدخال رقم صفحة صحيح بين 1 و 604', style: GoogleFonts.cairo())),
                    );
                  }
                },
                child: Text(
                  'حفظ',
                  style: GoogleFonts.cairo(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (newPage != null && _activePlan != null) {
      HapticFeedback.lightImpact();
      final updatedPlan = await KhatmaService.logProgress(_activePlan!, newPage);
      setState(() {
        _activePlan = updatedPlan;
      });
    }
  }

  void _shareProgress() {
    if (_activePlan == null) return;
    HapticFeedback.lightImpact();
    
    final plan = _activePlan!;
    final shareText = '🌟 الحمد لله، أنا أتابع تقدمي في قراءة القرآن الكريم عبر تطبيق "سكن الروح (Sakan Al-Rooh)"!\n\n'
        '📌 الختمة: ${plan.title}\n'
        '📊 نسبة الإنجاز: ${plan.progressPercentage.toStringAsFixed(1)}%\n'
        '📖 الصفحة الحالية: ${plan.lastReadPage} / 604\n'
        '🔥 سلسلة المتابعة متتالية: ${plan.streakDays} أيام\n'
        '📅 المتبقي التقريبي: ${plan.remainingDaysEstimate} أيام\n\n'
        'نسأل الله القبول والتوفيق. شاركني قراءة القرآن الكريم! 🚀';
        
    SharePlus.instance.share(ShareParams(text: shareText));
  }

  // --- SHARED KHATMA METHODS ---

  Future<void> _createSharedPlan() async {
    HapticFeedback.mediumImpact();
    final newPlan = SharedKhatmaPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _sharedTitleController.text.trim().isNotEmpty 
          ? _sharedTitleController.text.trim() 
          : 'ختمة مشتركة',
      startDate: DateTime.now(),
      juzList: List.generate(
        30,
        (index) => SharedKhatmaJuz(juzNumber: index + 1),
      ),
    );
    await KhatmaService.saveSharedPlan(newPlan);
    setState(() {
      _activeSharedPlan = newPlan;
    });
  }

  Future<void> _deleteSharedPlan() async {
    HapticFeedback.mediumImpact();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Provider.of<AppThemeManager>(context, listen: false).currentTheme;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: theme.cardColor,
            title: Text('إنهاء الختمة المشتركة', style: GoogleFonts.cairo(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            content: Text('هل أنت متأكد من رغبتك في حذف الختمة المشتركة الحالية؟ سيتم مسح توزيع الأجزاء وسجل القراء.', style: GoogleFonts.cairo(color: theme.textColor)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('إلغاء', style: GoogleFonts.cairo(color: theme.subtitleColor)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () => Navigator.pop(context, true),
                child: Text('نعم، احذف', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );

    if (confirm == true) {
      await KhatmaService.clearSharedPlan();
      setState(() {
        _activeSharedPlan = null;
      });
    }
  }

  void _shareSharedProgress() {
    if (_activeSharedPlan == null) return;
    HapticFeedback.lightImpact();

    final plan = _activeSharedPlan!;
    final completedCount = plan.completedJuzCount;
    final readingCount = plan.readingJuzCount;
    final freeCount = plan.freeJuzCount;

    // Build the list of free parts
    final freeJuzs = plan.juzList.where((j) => j.status == 'free').map((j) => j.juzNumber).toList();
    final freeJuzsStr = freeJuzs.isEmpty 
        ? 'لا يوجد أجزاء متبقية، الختمة مكتملة بالكامل! 🎉' 
        : freeJuzs.map((n) => 'الجزء $n').join('، ');

    final shareText = '📢 دعوة للمشاركة في الختمة العائلية المباركة: *[${plan.title}]* 👥\n\n'
        '🔑 رمز الغرفة: *${plan.id}*\n'
        '📊 نسبة الإنجاز: *${plan.progressPercentage.toStringAsFixed(1)}%*\n'
        '✅ الأجزاء المكتملة: $completedCount من 30 جزء\n'
        '⏳ أجزاء قيد القراءة: $readingCount جزء\n'
        '⚪ أجزاء متاحة ومتبقية: $freeCount جزء\n\n'
        '📌 *الأجزاء المتاحة الآن:*\n'
        '$freeJuzsStr\n\n'
        '📲 ادخل رمز الغرفة [${plan.id}] في تطبيق "سكن الروح" لاختيار جزءك والمتابعة الحية معنا!';

    SharePlus.instance.share(ShareParams(text: shareText));
  }

  Future<void> _editJuzDialog(SharedKhatmaJuz juz) async {
    final readerController = TextEditingController(text: juz.readerName);
    String selectedStatus = juz.status;

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Provider.of<AppThemeManager>(context, listen: false).currentTheme;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                backgroundColor: theme.cardColor,
                title: Text(
                  'تعديل حالة الجزء ${juz.juzNumber}',
                  style: GoogleFonts.cairo(color: theme.accentColor, fontWeight: FontWeight.bold),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اسم القارئ:',
                        style: GoogleFonts.cairo(color: theme.textColor, fontSize: 13.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: readerController,
                        style: GoogleFonts.cairo(color: Colors.white, fontSize: 14.sp),
                        decoration: InputDecoration(
                          hintText: 'مثال: أحمد، فاطمة...',
                          hintStyle: GoogleFonts.cairo(color: Colors.white30),
                          fillColor: Colors.black12,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(color: theme.accentColor.withValues(alpha: 0.3)),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'حالة القراءة:',
                        style: GoogleFonts.cairo(color: theme.textColor, fontSize: 13.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.h),
                      
                      // Status Options
                      RadioListTile<String>(
                        title: Text('غير محجوز ⚪', style: GoogleFonts.cairo(color: theme.textColor)),
                        value: 'free',
                        groupValue: selectedStatus,
                        activeColor: theme.accentColor,
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedStatus = val);
                        },
                      ),
                      RadioListTile<String>(
                        title: Text('جاري القراءة 🟡', style: GoogleFonts.cairo(color: theme.textColor)),
                        value: 'reading',
                        groupValue: selectedStatus,
                        activeColor: theme.accentColor,
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedStatus = val);
                        },
                      ),
                      RadioListTile<String>(
                        title: Text('تمت القراءة 🟢', style: GoogleFonts.cairo(color: theme.textColor)),
                        value: 'completed',
                        groupValue: selectedStatus,
                        activeColor: theme.accentColor,
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedStatus = val);
                        },
                      ),
                      const Divider(color: Colors.white12, height: 24),
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context, false);
                            
                            final juzData = quranJuzs[juz.juzNumber - 1];
                            final matchingSurah = quranSurahs.firstWhere(
                              (s) => s.name == juzData.startingSurahName,
                              orElse: () => quranSurahs.first,
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SurahDetailScreen(
                                  surahNumber: matchingSurah.id,
                                  surahName: matchingSurah.name,
                                  initialVerse: juzData.startingVerse,
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.accentColor,
                            side: BorderSide(color: theme.accentColor, width: 1.2),
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          icon: Icon(Icons.menu_book_rounded, size: 18.sp),
                          label: Text(
                            'ابدأ القراءة 📖',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('إلغاء', style: GoogleFonts.cairo(color: theme.subtitleColor)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: theme.accentColor),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text(
                      'حفظ',
                      style: GoogleFonts.cairo(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (updated == true && _activeSharedPlan != null) {
      HapticFeedback.lightImpact();
      final updatedPlan = await KhatmaService.updateSharedJuz(
        plan: _activeSharedPlan!,
        juzNumber: juz.juzNumber,
        readerName: readerController.text.trim(),
        status: selectedStatus,
      );
      setState(() {
        _activeSharedPlan = updatedPlan;
      });
    }
  }

  Future<void> _exportSharedKhatmaCode() async {
    if (_activeSharedPlan == null) return;
    HapticFeedback.lightImpact();

    try {
      final jsonStr = jsonEncode(_activeSharedPlan!.toJson());
      final bytes = utf8.encode(jsonStr);
      final base64Str = base64.encode(bytes);
      await Clipboard.setData(ClipboardData(text: base64Str));

      final webUrl = 'https://noor-al-hoda.web.app/khatma.html?id=${_activeSharedPlan!.id}';
      final shareMessage = '📖 ندعوكم للمشاركة في «${_activeSharedPlan!.title}»\n\n'
          '🔗 للمشاركة وحجز وقراءة الأجزاء مباشرة عبر الويب:\n$webUrl\n\n'
          '📱 أو افتح تطبيق «نور الهدى» واستخدم كود المزامنة:\n$base64Str';

      await Share.share(shareMessage, subject: _activeSharedPlan!.title);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade800,
            content: Text(
              '🎉 تم نسخ كود ورابط الختمة للمشاركة بنجاح!',
              style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              'حدث خطأ أثناء تصدير الكود: $e',
              style: GoogleFonts.cairo(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  Future<void> _importSharedKhatmaCode() async {
    HapticFeedback.mediumImpact();
    final codeController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Provider.of<AppThemeManager>(context, listen: false).currentTheme;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: theme.cardColor,
            title: Text(
              'استيراد ختمة مشتركة',
              style: GoogleFonts.cairo(color: theme.accentColor, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'قم بلصق كود المزامنة الذي شاركه معك أحد الأعضاء:',
                  style: GoogleFonts.cairo(color: theme.textColor, fontSize: 13.sp),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: codeController,
                  maxLines: 4,
                  style: GoogleFonts.cairo(color: Colors.white, fontSize: 13.sp),
                  decoration: InputDecoration(
                    hintText: 'ألصق الكود هنا...',
                    hintStyle: GoogleFonts.cairo(color: Colors.white30),
                    fillColor: Colors.black12,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: theme.accentColor.withValues(alpha: 0.3)),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('إلغاء', style: GoogleFonts.cairo(color: theme.subtitleColor)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: theme.accentColor),
                onPressed: () {
                  if (codeController.text.trim().isNotEmpty) {
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('الرجاء لصق كود صحيح أولاً', style: GoogleFonts.cairo())),
                    );
                  }
                },
                child: Text(
                  'استيراد',
                  style: GoogleFonts.cairo(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result == true) {
      final code = codeController.text.trim();
      try {
        // Try Cloud Firestore fetch first by Room ID
        SharedKhatmaPlan? plan;
        if (!code.startsWith('{') && code.length < 50) {
          plan = await KhatmaService.fetchSharedPlanFromCloud(code);
        }

        if (plan == null) {
          final decodedBytes = base64.decode(code);
          final jsonStr = utf8.decode(decodedBytes);
          final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
          plan = SharedKhatmaPlan.fromJson(jsonMap);
          await KhatmaService.saveSharedPlan(plan);
        }
        
        setState(() {
          _activeSharedPlan = plan;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green.shade800,
              content: Text(
                '🎉 تم الانضمام للختمة المشتركة "${plan.title}" بنجاح ومزامنتها سحابياً!',
                style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text(
                'فشل استيراد الكود. تأكد من صحة الكود المنسوخ.',
                style: GoogleFonts.cairo(color: Colors.white),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<AppThemeManager>(context);
    final theme = themeManager.currentTheme;

    return DefaultTabController(
      length: 2,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: theme.primaryColor,
            centerTitle: true,
            title: Text(
              'منظم ومتابع الختمات',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Colors.white,
              ),
            ),
            bottom: TabBar(
              indicatorColor: theme.accentColor,
              labelColor: theme.accentColor,
              unselectedLabelColor: Colors.white70,
              labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13.sp),
              unselectedLabelStyle: GoogleFonts.cairo(fontSize: 12.sp),
              tabs: const [
                Tab(text: 'ختمة فردية 👤'),
                Tab(text: 'ختمة مشتركة 👥'),
              ],
            ),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: theme.gradientColors,
              ),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                : TabBarView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.all(20.w),
                        child: _activePlan == null
                            ? _buildPlanCreationForm(theme)
                            : _buildActivePlanDashboard(theme),
                      ),
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.all(20.w),
                        child: _activeSharedPlan == null
                            ? _buildSharedPlanCreationForm(theme)
                            : _buildSharedPlanDashboard(theme),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // --- UI FOR CREATING A NEW PERSONAL PLAN ---
  Widget _buildPlanCreationForm(AppTheme theme) {
    final pagesPerDay = 604.0 / _daysSliderValue;
    final juzsPerDay = pagesPerDay / 20.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: theme.cardColor.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
            side: BorderSide(color: theme.accentColor.withValues(alpha: 0.15)),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.auto_stories_outlined, color: theme.accentColor, size: 48.sp),
                SizedBox(height: 12.h),
                Text(
                  'ابدأ ختمة جديدة',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                  ),
                ),
                Text(
                  'قم بإدخال عدد الأيام المستهدفة وسنقوم بحساب وردك اليومي ومتابعته تلقائياً.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: theme.subtitleColor,
                  ),
                ),
                SizedBox(height: 24.h),
                
                // Title Input
                Text(
                  'عنوان الختمة',
                  style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 13.sp),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _titleController,
                  style: GoogleFonts.cairo(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                    fillColor: Colors.black12,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: theme.accentColor.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: theme.accentColor, width: 1.2),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Days Selection Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'المدة المستهدفة للختمة',
                      style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 13.sp),
                    ),
                    Text(
                      '${_daysSliderValue.toInt()} يوم',
                      style: GoogleFonts.cairo(color: theme.accentColor, fontWeight: FontWeight.bold, fontSize: 15.sp),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Slider(
                  value: _daysSliderValue,
                  min: 5.0,
                  max: 120.0,
                  divisions: 23,
                  activeColor: theme.accentColor,
                  inactiveColor: Colors.white12,
                  onChanged: (val) {
                    setState(() {
                      _daysSliderValue = val;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 18.h),

        // Live Plan Stats Estimate Card
        Card(
          color: theme.accentColor.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
            side: BorderSide(color: theme.accentColor.withValues(alpha: 0.25)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('الورد اليومي', style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 12.sp)),
                    SizedBox(height: 4.h),
                    Text('${pagesPerDay.toStringAsFixed(1)} صفحة', style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 16.sp)),
                  ],
                ),
                Container(width: 1.w, height: 40.h, color: theme.accentColor.withValues(alpha: 0.2)),
                Column(
                  children: [
                    Text('ما يعادل', style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 12.sp)),
                    SizedBox(height: 4.h),
                    Text('${juzsPerDay.toStringAsFixed(2)} جزء', style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 16.sp)),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24.h),

        // Submit Button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.accentColor,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            elevation: 8,
          ),
          onPressed: _createPlan,
          child: Text(
            'ابدأ الختمة المباركة 🚀',
            style: GoogleFonts.cairo(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
        ),
      ],
    );
  }

  // --- UI FOR ACTIVE PERSONAL PLAN DASHBOARD ---
  Widget _buildActivePlanDashboard(AppTheme theme) {
    final plan = _activePlan!;
    final progressFraction = plan.progressPercentage / 100.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main Dashboard card
        Card(
          color: theme.cardColor.withValues(alpha: 0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26.r),
            side: BorderSide(color: theme.accentColor.withValues(alpha: 0.18)),
          ),
          child: Padding(
            padding: EdgeInsets.all(22.w),
            child: Column(
              children: [
                Text(
                  plan.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(fontSize: 20.sp, fontWeight: FontWeight.bold, color: theme.textColor),
                ),
                SizedBox(height: 18.h),

                // Streak Banner
                if (plan.streakDays > 0) ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🔥 سلسلة إنجاز متتالية: ', style: GoogleFonts.cairo(color: Colors.orangeAccent, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                        Text('${plan.streakDays} أيام', style: GoogleFonts.cairo(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                ] else ...[
                  Text(
                    'قم بالتسجيل اليوم لبدء سلسلة الإنجاز! 🌟',
                    style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 12.sp),
                  ),
                  SizedBox(height: 14.h),
                ],

                // Circular Progress
                SizedBox(
                  width: 140.w,
                  height: 140.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progressFraction.clamp(0.0, 1.0),
                        strokeWidth: 10.w,
                        color: theme.accentColor,
                        backgroundColor: Colors.white12,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${plan.progressPercentage.toStringAsFixed(1)}%',
                            style: GoogleFonts.cairo(
                              color: theme.textColor,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'مكتمل',
                            style: GoogleFonts.cairo(
                              color: theme.subtitleColor,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Detailed stats table/row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('الصفحة الحالية', style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 11.sp)),
                        SizedBox(height: 2.h),
                        Text('${plan.lastReadPage}', style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 15.sp)),
                      ],
                    ),
                    Container(width: 1.w, height: 28.h, color: Colors.white12),
                    Column(
                      children: [
                        Text('الورد اليومي', style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 11.sp)),
                        SizedBox(height: 2.h),
                        Text('${plan.pagesPerDay.toStringAsFixed(1)} صفحة', style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 15.sp)),
                      ],
                    ),
                    Container(width: 1.w, height: 28.h, color: Colors.white12),
                    Column(
                      children: [
                        Text('أيام متبقية', style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 11.sp)),
                        SizedBox(height: 2.h),
                        Text('${plan.remainingDaysEstimate}', style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 15.sp)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24.h),

        // Action Buttons Row
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentColor,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                onPressed: _logReadingProgress,
                icon: Icon(Icons.bookmark_add_rounded, color: Colors.black, size: 20.sp),
                label: Text(
                  'تسجيل صفحات مقروءة',
                  style: GoogleFonts.cairo(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13.sp),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: const BorderSide(color: Colors.redAccent, width: 1.2),
                  ),
                ),
                onPressed: _deletePlan,
                icon: const Icon(Icons.delete_outline, size: 20),
                label: Text(
                  'إنهاء الختمة',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13.sp),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        
        // Share progress button
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.accentColor,
            side: BorderSide(color: theme.accentColor, width: 1.2),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          onPressed: _shareProgress,
          icon: Icon(Icons.share_rounded, size: 20.sp),
          label: Text('مشاركة التقدم', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13.sp)),
        ),
      ],
    );
  }

  // --- UI FOR CREATING A NEW SHARED PLAN ---
  Widget _buildSharedPlanCreationForm(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: theme.cardColor.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
            side: BorderSide(color: theme.accentColor.withValues(alpha: 0.15)),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.people_alt_outlined, color: theme.accentColor, size: 48.sp),
                SizedBox(height: 12.h),
                Text(
                  'ابدأ ختمة مشتركة جديدة',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                  ),
                ),
                Text(
                  'يمكنك تقسيم أجزاء القرآن الثلاثين بين العائلة والأصدقاء ومتابعة إنجاز كل جزء محلياً ومشاركته معهم.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: theme.subtitleColor,
                  ),
                ),
                SizedBox(height: 24.h),
                
                // Title Input
                Text(
                  'عنوان الختمة المشتركة',
                  style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 13.sp),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _sharedTitleController,
                  style: GoogleFonts.cairo(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                    fillColor: Colors.black12,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: theme.accentColor.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: theme.accentColor, width: 1.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24.h),

        // Submit Button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.accentColor,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            elevation: 8,
          ),
          onPressed: _createSharedPlan,
          child: Text(
            'البدء في الختمة المشتركة 👥',
            style: GoogleFonts.cairo(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.accentColor,
            side: BorderSide(color: theme.accentColor, width: 1.2),
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          onPressed: _importSharedKhatmaCode,
          icon: const Icon(Icons.download_rounded, size: 20),
          label: Text(
            'استيراد ختمة مشتركة من كود 📥',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
        ),
      ],
    );
  }

  // --- UI FOR ACTIVE SHARED PLAN DASHBOARD ---
  Widget _buildSharedPlanDashboard(AppTheme theme) {
    final plan = _activeSharedPlan!;
    final progressFraction = plan.progressPercentage / 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress Card
        Card(
          color: theme.cardColor.withValues(alpha: 0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26.r),
            side: BorderSide(color: theme.accentColor.withValues(alpha: 0.18)),
          ),
          child: Padding(
            padding: EdgeInsets.all(22.w),
            child: Column(
              children: [
                Text(
                  plan.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(fontSize: 20.sp, fontWeight: FontWeight.bold, color: theme.textColor),
                ),
                SizedBox(height: 18.h),

                // Circular Progress
                SizedBox(
                  width: 140.w,
                  height: 140.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progressFraction.clamp(0.0, 1.0),
                        strokeWidth: 10.w,
                        color: theme.accentColor,
                        backgroundColor: Colors.white12,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${plan.progressPercentage.toStringAsFixed(1)}%',
                            style: GoogleFonts.cairo(
                              color: theme.textColor,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'مكتمل',
                            style: GoogleFonts.cairo(
                              color: theme.subtitleColor,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Breakdown stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('تمت القراءة', style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 11.sp)),
                        SizedBox(height: 2.h),
                        Text('${plan.completedJuzCount}', style: GoogleFonts.cairo(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 15.sp)),
                      ],
                    ),
                    Container(width: 1.w, height: 28.h, color: Colors.white12),
                    Column(
                      children: [
                        Text('جاري القراءة', style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 11.sp)),
                        SizedBox(height: 2.h),
                        Text('${plan.readingJuzCount}', style: GoogleFonts.cairo(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 15.sp)),
                      ],
                    ),
                    Container(width: 1.w, height: 28.h, color: Colors.white12),
                    Column(
                      children: [
                        Text('غير محجوز', style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 11.sp)),
                        SizedBox(height: 2.h),
                        Text('${plan.freeJuzCount}', style: GoogleFonts.cairo(color: theme.subtitleColor, fontWeight: FontWeight.bold, fontSize: 15.sp)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // Action Buttons Row
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentColor,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                onPressed: _shareSharedProgress,
                icon: const Icon(Icons.share_rounded, color: Colors.black, size: 20),
                label: Text(
                  'مشاركة التقدم',
                  style: GoogleFonts.cairo(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13.sp),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: const BorderSide(color: Colors.redAccent, width: 1.2),
                  ),
                ),
                onPressed: _deleteSharedPlan,
                icon: const Icon(Icons.delete_outline, size: 20),
                label: Text(
                  'إنهاء الختمة',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13.sp),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.accentColor,
                  side: BorderSide(color: theme.accentColor.withValues(alpha: 0.5), width: 1.2),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                onPressed: _exportSharedKhatmaCode,
                icon: const Icon(Icons.copy_all_rounded, size: 20),
                label: Text(
                  'نسخ كود المزامنة',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13.sp),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.accentColor,
                  side: BorderSide(color: theme.accentColor.withValues(alpha: 0.5), width: 1.2),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                onPressed: _importSharedKhatmaCode,
                icon: const Icon(Icons.download_rounded, size: 20),
                label: Text(
                  'استيراد كود المزامنة',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13.sp),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),

        // Grid Title
        Text(
          'توزيع الأجزاء الثلاثين',
          style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        SizedBox(height: 12.h),

        // Grid View
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 30,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final juz = plan.juzList[index];
            return _buildJuzCard(juz, theme);
          },
        ),
      ],
    );
  }

  Widget _buildJuzCard(SharedKhatmaJuz juz, AppTheme theme) {
    Color cardBg;
    Color borderCol;
    Color textCol = theme.textColor;
    Color labelCol = theme.subtitleColor;
    String statusLabel = 'غير محجوز';

    if (juz.status == 'completed') {
      cardBg = Colors.green.withValues(alpha: 0.15);
      borderCol = Colors.green.withValues(alpha: 0.6);
      statusLabel = 'تم الإنجاز';
      labelCol = Colors.greenAccent;
    } else if (juz.status == 'reading') {
      cardBg = Colors.orange.withValues(alpha: 0.15);
      borderCol = Colors.orange.withValues(alpha: 0.6);
      statusLabel = 'يقرأ حالياً';
      labelCol = Colors.orangeAccent;
    } else {
      cardBg = Colors.white.withValues(alpha: 0.05);
      borderCol = Colors.white.withValues(alpha: 0.15);
    }

    return Card(
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: borderCol, width: 1.2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => _editJuzDialog(juz),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'الجزء ${juz.juzNumber}',
                style: GoogleFonts.cairo(
                  color: textCol,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 4.h),
              juz.readerName.isNotEmpty
                  ? AutoScrollText(
                      juz.readerName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        color: theme.textColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Text(
                      statusLabel,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: GoogleFonts.cairo(
                        color: labelCol,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
              if (juz.readerName.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  statusLabel,
                  style: GoogleFonts.cairo(
                    color: labelCol,
                    fontSize: 9.sp,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
