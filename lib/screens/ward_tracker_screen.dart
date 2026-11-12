// ignore_for_file: deprecated_member_use

import 'azkar_screen.dart';
import 'quran_screen.dart';
import 'tasbih_screen.dart';
import 'prayer_times_screen.dart';
import 'prayer_timer_screen.dart';
import 'spiritual_badges_screen.dart';
import 'surah_detail_screen.dart';
import 'fasting_tracker_screen.dart';
import 'islamic_radio_screen.dart';
import 'spiritual_moods_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/theme_manager.dart';
import '../models/task_manager.dart';
import '../widgets/qasr_al_jannah_card.dart';
import '../core/helpers/haptic_helper.dart';
import '../widgets/common/auto_scroll_text.dart';
import '../widgets/common/quick_language_button.dart';
import '../core/localization/app_translations.dart';

class WardTrackerScreen extends StatefulWidget {
  final String? promptPrayerId;

  const WardTrackerScreen({
    super.key,
    this.promptPrayerId,
  });

  @override
  State<WardTrackerScreen> createState() => _WardTrackerScreenState();
}

class _WardTrackerScreenState extends State<WardTrackerScreen> {
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    if (widget.promptPrayerId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openPrayerTimer(widget.promptPrayerId!);
      });
    }
  }

  void _openPrayerTimer(String prayerId, {DateTime? targetDate}) {
    final taskManager = Provider.of<SpiritualTaskManager>(context, listen: false);
    final date = targetDate ?? taskManager.selectedDate;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrayerTimerScreen(
          prayerId: prayerId,
          targetDate: date,
        ),
      ),
    );
  }

  String _formatSeconds(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    if (minutes > 0) {
      return '$minutes د و $seconds ث';
    }
    return '$seconds ث';
  }

  bool _isDateEditable(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target.isAfter(today)) return false;
    final diff = today.difference(target).inDays;
    return diff <= 6; // last 7 days (diff 0 to 6)
  }



  @override
  Widget build(
    BuildContext context,
  ) {
    final themeManager = Provider.of<AppThemeManager>(context);
    final theme = themeManager.currentTheme;
    final taskManager = Provider.of<SpiritualTaskManager>(context);

    final filteredTasks = taskManager.tasks.where((t) {
      if (_selectedCategory == 'all') {
        return true;
      }
      if (_selectedCategory == 'custom') {
        return t.isCustom;
      }
      return t.category == _selectedCategory;
    }).toList();

    final isEditable = _isDateEditable(taskManager.selectedDate);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        title: Text(
          context.tr('ward_title'),
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: const [
          QuickLanguageButton(isCompact: true),
          SizedBox(width: 8),
        ],
      ),
      floatingActionButton: isEditable
          ? FloatingActionButton(
              backgroundColor: theme.accentColor,
              foregroundColor: theme.scaffoldBackgroundColor,
              child: const Icon(
                Icons.add,
                size: 28,
              ),
              onPressed: () {
                _showAddTaskDialog(
                  context,
                  taskManager,
                  theme,
                );
              },
            )
          : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.gradientColors,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isEditable) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Colors.amber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'تنبيه: هذا اليوم أقدم من 7 أيام، وهو متاح للعرض فقط ولا يمكن تعديل الأوراد فيه.',
                          style: GoogleFonts.cairo(
                            color: Colors.amber,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              _buildProgressHeader(
                taskManager,
                theme,
              ),
              const SizedBox(
                height: 20,
              ),
              _buildHistoryChart(
                taskManager,
                theme,
              ),
              const SizedBox(
                height: 20,
              ),
              _buildStatisticsCard(
                taskManager,
                theme,
              ),
              const SizedBox(
                height: 20,
              ),
              Card(
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  side: BorderSide(
                    color: theme.accentColor.withValues(alpha: 0.2),
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.w),
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: theme.accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: theme.accentColor,
                      size: 28.sp,
                    ),
                  ),
                  title: Text(
                    'أوسمتي الإيمانية وسجل المكافآت 🏅',
                    style: GoogleFonts.cairo(
                      color: theme.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                  subtitle: Text(
                    'تابع الأوسمة والتكريمات التي حققتها في طريق الطاعات',
                    style: GoogleFonts.cairo(
                      color: theme.subtitleColor,
                      fontSize: 12.sp,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: theme.accentColor,
                    size: 18.sp,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SpiritualBadgesScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 14.h),
              // Quick Companions Row (Fasting, Radio, Mood)
              Row(
                children: [
                  Expanded(
                    child: _buildWardCompanionChip(
                      icon: Icons.brightness_2_rounded,
                      label: 'متابع الصيام',
                      color: const Color(0xFF64B5F6),
                      theme: theme,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FastingTrackerScreen()),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildWardCompanionChip(
                      icon: Icons.radio_rounded,
                      label: 'إذاعة القرآن',
                      color: const Color(0xFFD4AF37),
                      theme: theme,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const IslamicRadioScreen()),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildWardCompanionChip(
                      icon: Icons.spa_rounded,
                      label: 'الملاذ النفسي',
                      color: const Color(0xFF81C784),
                      theme: theme,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SpiritualMoodsScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              const QasrAlJannahCard(isCompact: false),
              const SizedBox(
                height: 18,
              ),
              // Beautiful Date Picker Bar
              Card(
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide(color: theme.accentColor.withValues(alpha: 0.1)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_rounded, color: theme.accentColor, size: 20.sp),
                        onPressed: () {
                          final prevDate = taskManager.selectedDate.subtract(const Duration(days: 1));
                          taskManager.setSelectedDate(prevDate);
                        },
                      ),
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: taskManager.selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now(),
                            locale: const Locale('ar'),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.dark(
                                    primary: theme.accentColor,
                                    onPrimary: theme.scaffoldBackgroundColor,
                                    surface: theme.cardColor,
                                    onSurface: theme.textColor,
                                  ),
                                  dialogBackgroundColor: theme.scaffoldBackgroundColor,
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            taskManager.setSelectedDate(picked);
                          }
                        },
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month_rounded, color: theme.accentColor, size: 22.sp),
                            SizedBox(width: 8.w),
                            Text(
                              DateFormat('d MMMM yyyy', 'ar').format(taskManager.selectedDate),
                              style: GoogleFonts.cairo(
                                color: theme.textColor,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios_rounded, color: theme.accentColor, size: 20.sp),
                        onPressed: taskManager.selectedDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
                            ? () {
                                final nextDate = taskManager.selectedDate.add(const Duration(days: 1));
                                taskManager.setSelectedDate(nextDate);
                              }
                            : null, // disabled if today
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              _buildCategoryChips(
                theme,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                'عبادات ومتابعة الورد',
                style: GoogleFonts.cairo(
                  color: theme.accentColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              if (filteredTasks.isEmpty)
                Card(
                  color: theme.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 32.0,
                      horizontal: 16.0,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: theme.subtitleColor.withOpacity(
                            0.5,
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          'لا توجد عبادات في هذا التصنيف حالياً.',
                          style: GoogleFonts.cairo(
                            color: theme.subtitleColor,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredTasks.length,
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final task = filteredTasks[index];

                    return _buildTaskItem(
                      task,
                      taskManager,
                      theme,
                    );
                  },
                ),
              const SizedBox(
                height: 80,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader(
    SpiritualTaskManager taskManager,
    AppTheme theme,
  ) {
    int total = taskManager.tasks.length;
    int done = taskManager.tasks.where((t) => t.isCompleted).length;
    double percent = taskManager.completionPercentage;
    final isToday = taskManager.selectedDate.year == DateTime.now().year &&
        taskManager.selectedDate.month == DateTime.now().month &&
        taskManager.selectedDate.day == DateTime.now().day;

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          20,
        ),
        side: BorderSide(
          color: theme.accentColor.withOpacity(
            0.2,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          20.0,
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: percent / 100,
                    strokeWidth: 8,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.accentColor,
                    ),
                  ),
                ),
                Text(
                  '${percent.round()}%',
                  style: GoogleFonts.cairo(
                    color: theme.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حصاد التقدم',
                    style: GoogleFonts.cairo(
                      color: theme.accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    isToday 
                      ? 'تم إنجاز $done من أصل $total عبادات اليوم.'
                      : 'تم إنجاز $done من أصل $total عبادات في هذا اليوم.',
                    style: GoogleFonts.cairo(
                      color: theme.textColor.withOpacity(
                        0.8,
                      ),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    percent >= 100
                        ? 'ما شاء الله! أتممت جميع الأوراد.'
                        : 'أكمل بقية العبادات والورد لتنال الأجر كاملاً.',
                    style: GoogleFonts.cairo(
                      color: theme.subtitleColor,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
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

  Widget _buildHistoryChart(
    SpiritualTaskManager taskManager,
    AppTheme theme,
  ) {
    final List<DateTime> last7Days = List.generate(
      7,
      (i) => DateTime.now().subtract(
        Duration(
          days: 6 - i,
        ),
      ),
    );

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: theme.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      color: theme.accentColor,
                      size: 22.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'حصاد الحسنات (الـ 7 أيام الماضية)',
                      style: GoogleFonts.cairo(
                        color: theme.textColor,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'اضغط على اليوم لعرض ورده 👆',
                  style: GoogleFonts.cairo(
                    color: theme.subtitleColor,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: last7Days.map((
                date,
              ) {
                final dateStr =
                    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

                double percentage = 0.0;
                final cachedList = taskManager.cachedTasks[dateStr];
                if (cachedList != null && cachedList.isNotEmpty) {
                  final completed = cachedList.where((t) => t.isCompleted).length;
                  percentage = (completed / cachedList.length) * 100.0;
                } else {
                  percentage = taskManager.history[dateStr] ?? 0.0;
                }

                final todayStr =
                    "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

                if (dateStr == todayStr) {
                  percentage = taskManager.todayCompletionPercentage;
                }

                final selStr =
                    "${taskManager.selectedDate.year}-${taskManager.selectedDate.month.toString().padLeft(2, '0')}-${taskManager.selectedDate.day.toString().padLeft(2, '0')}";
                final isSelectedDay = selStr == dateStr;

                final arabicDayName = DateFormat.E(
                  'ar',
                ).format(date);

                return InkWell(
                  onTap: () {
                    HapticHelper.light();
                    taskManager.setSelectedDate(date);
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                    child: Column(
                      children: [
                        Text(
                          '${percentage.round()}%',
                          style: TextStyle(
                            color: isSelectedDay ? theme.accentColor : theme.subtitleColor,
                            fontSize: 10.sp,
                            fontWeight: isSelectedDay ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          height: 85.h,
                          width: 16.w,
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(10.r),
                            border: isSelectedDay
                                ? Border.all(color: theme.accentColor, width: 1.8)
                                : null,
                          ),
                          alignment: Alignment.bottomCenter,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            height: (percentage > 0)
                                ? ((percentage / 100.0) * 85.h).clamp(6.h, 85.h)
                                : 0,
                            width: 16.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  theme.accentColor,
                                  theme.accentColor.withValues(alpha: 0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          arabicDayName,
                          style: GoogleFonts.cairo(
                            color: isSelectedDay ? theme.accentColor : theme.textColor,
                            fontSize: 11.sp,
                            fontWeight: isSelectedDay ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(
    SpiritualTaskManager taskManager,
    AppTheme theme,
  ) {
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: theme.accentColor.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights_rounded,
                  color: theme.accentColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'إحصائيات الالتزام والعبادات',
                  style: GoogleFonts.cairo(
                    color: theme.textColor,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildStatItem(
                  title: 'معدل الالتزام',
                  value: '${taskManager.averageCommitment.toStringAsFixed(0)}%',
                  icon: Icons.done_all_rounded,
                  color: Colors.greenAccent,
                  theme: theme,
                ),
                _buildStatItem(
                  title: 'الـ Streak الحالي',
                  value: '${taskManager.currentStreak} يوم',
                  icon: Icons.local_fire_department_rounded,
                  color: Colors.redAccent,
                  theme: theme,
                ),
                _buildStatItem(
                  title: 'صلوات مكتملة',
                  value: '${taskManager.completedPrayersLast7Days}',
                  icon: Icons.mosque_rounded,
                  color: theme.accentColor,
                  theme: theme,
                ),
                _buildStatItem(
                  title: context.tr('total_rakahs'),
                  value: '${taskManager.totalRakahsLast7Days} ${context.tr('rakah_unit')}',
                  icon: Icons.accessibility_new_rounded,
                  color: Colors.cyanAccent,
                  theme: theme,
                ),
                _buildStatItem(
                  title: context.tr('completed_azkar'),
                  value: '${taskManager.completedAzkarLast7Days} ${context.tr('ward_unit')}',
                  icon: Icons.auto_stories_rounded,
                  color: Colors.tealAccent,
                  theme: theme,
                ),
                _buildStatItem(
                  title: context.tr('fasting_days'),
                  value: '${taskManager.totalFastingDays} ${context.tr('day_unit')}',
                  icon: Icons.nightlight_round,
                  color: Colors.amberAccent,
                  theme: theme,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FastingTrackerScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required AppTheme theme,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 16.sp, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: AutoScrollText(
                    title,
                    style: GoogleFonts.cairo(
                      color: theme.subtitleColor,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                maxLines: 1,
                style: GoogleFonts.cairo(
                  color: theme.textColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(
    AppTheme theme,
  ) {
    final categories = [
      {
        'id': 'all',
        'name': 'الكل',
      },
      {
        'id': 'prayer',
        'name': 'الصلوات',
      },
      {
        'id': 'azkar',
        'name': 'الأذكار',
      },
      {
        'id': 'tasbih',
        'name': 'التسابيح',
      },
      {
        'id': 'quran',
        'name': 'القرآن',
      },
      {
        'id': 'fasting',
        'name': 'الصيام والنوافل 🌙',
      },
      {
        'id': 'occasional',
        'name': 'سنن ومناسبات 🌟',
      },
      {
        'id': 'custom',
        'name': 'مخصصة',
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat['id'];

          return Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
            ),
            child: ChoiceChip(
              label: Text(
                cat['name']!,
                style: GoogleFonts.cairo(
                  color: isSelected
                      ? theme.scaffoldBackgroundColor
                      : theme.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              selectedColor: theme.accentColor,
              backgroundColor: theme.cardColor,
              onSelected: (
                selected,
              ) {
                setState(() {
                  _selectedCategory = cat['id']!;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskItem(
    IslamicTask task,
    SpiritualTaskManager taskManager,
    AppTheme theme,
  ) {
    bool isCompleted = task.isCompleted;
    final isEditable = _isDateEditable(taskManager.selectedDate);
    final isEnabled = taskManager.isTaskEnabled(task.id, taskManager.selectedDate);

    final Color iconColor = isCompleted 
        ? theme.accentColor 
        : (!isEditable || !isEnabled 
            ? theme.subtitleColor.withValues(alpha: 0.3) 
            : theme.subtitleColor);
            
    final Color textColor = isCompleted 
        ? theme.textColor 
        : (!isEditable || !isEnabled 
            ? theme.textColor.withValues(alpha: 0.4) 
            : theme.textColor);

    return Card(
      color: theme.cardColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
        side: BorderSide(
          color: isCompleted
              ? theme.accentColor.withOpacity(0.5)
              : theme.dividerColor.withOpacity(0.2),
          width: isCompleted ? 1.2 : 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                isCompleted 
                    ? Icons.check_circle 
                    : (task.category == 'prayer' && !isEnabled && isEditable
                        ? Icons.lock_clock_outlined 
                        : Icons.radio_button_unchecked),
                color: iconColor,
                size: 28,
              ),
              onPressed: () {
                if (!isEditable) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        'بيانات هذا اليوم للعرض فقط ولا يمكن تعديلها.',
                        style: GoogleFonts.cairo(),
                      ),
                    ),
                  );
                  return;
                }
                if (!isEnabled) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        'لا يمكن تسجيل الصلاة قبل دخول وقتها الفعلي.',
                        style: GoogleFonts.cairo(),
                      ),
                    ),
                  );
                  return;
                }
                if (task.id == 'witr_sunan') {
                  if (!isCompleted) {
                    _showQiyamRakahsDialog(taskManager);
                  } else {
                    taskManager.toggleTaskCompletion(task.id);
                  }
                  return;
                }
                if (task.category == 'prayer' && !isCompleted) {
                  final targetDate = taskManager.selectedDate;
                  final prayerTime = taskManager.getPrayerTime(task.id, targetDate);
                  bool isLate = false;
                  if (prayerTime != null) {
                    final diff = DateTime.now().difference(prayerTime);
                    if (diff.inHours >= 6) {
                      isLate = true;
                    }
                  }
                  taskManager.markPrayerAsCompletedForDate(
                    task.id,
                    targetDate,
                    isLate: isLate,
                    duration: 300,
                  );
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        'تم توثيق ${task.title} بنجاح! تقبّل الله صلاتك 🤲',
                        style: GoogleFonts.cairo(),
                      ),
                      action: SnackBarAction(
                        label: 'عدّاد الخشوع ⏱️',
                        textColor: theme.accentColor,
                        onPressed: () => _openPrayerTimer(task.id),
                      ),
                    ),
                  );
                } else {
                  taskManager.toggleTaskCompletion(task.id);
                }
              },
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(8.r),
                onTap: () {
                  if (task.id == 'witr_sunan') {
                    _showQiyamRakahsDialog(taskManager);
                  } else {
                    _openTaskScreen(task.id);
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.cairo(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (isCompleted && task.completionTime != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 12.sp, color: theme.accentColor.withValues(alpha: 0.7)),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              'تم الإنجاز في: ${DateFormat('hh:mm a', 'ar').format(DateTime.parse(task.completionTime!))}' 
                              '${task.isLateCompletion ? ' (تسجيل متأخر)' : ''}'
                              '${task.id == 'witr_sunan' ? ' • صليت: ${task.countCurrent > 0 ? task.countCurrent : 3} ركعات' : ''}'
                              '${task.prayerDuration != null && task.prayerDuration! > 0 ? ' • مدة الصلاة: ${_formatSeconds(task.prayerDuration!)}' : ''}',
                              style: GoogleFonts.cairo(
                                fontSize: 11.sp,
                                color: theme.accentColor.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (task.isCustom && isEditable)
              IconButton(
                onPressed: () {
                  taskManager.deleteTask(
                    task.id,
                  );
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 22,
                ),
              )
            else if (!task.isCustom)
              IconButton(
                onPressed: () {
                  _openTaskScreen(
                    task.id,
                  );
                },
                icon: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isEditable && isEnabled ? theme.accentColor : theme.subtitleColor.withValues(alpha: 0.3),
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddTaskDialog(
    BuildContext context,
    SpiritualTaskManager manager,
    AppTheme theme,
  ) async {
    final titleController = TextEditingController();
    int countTarget = 1;
    String selectedCategory = 'custom';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                backgroundColor: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  side: BorderSide(color: theme.accentColor.withOpacity(0.3)),
                ),
                title: Text(
                  'إضافة عبادة مخصصة',
                  style: GoogleFonts.cairo(
                    color: theme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: titleController,
                        style: GoogleFonts.cairo(color: theme.textColor),
                        decoration: InputDecoration(
                          hintText: 'اسم العبادة (مثال: قيام الليل)',
                          hintStyle: GoogleFonts.cairo(
                            color: theme.subtitleColor.withOpacity(0.5),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.textColor.withOpacity(0.2),
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: theme.accentColor),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'التصنيف',
                        style: GoogleFonts.cairo(
                          color: theme.accentColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      DropdownButton<String>(
                        dropdownColor: theme.cardColor,
                        value: selectedCategory,
                        style: GoogleFonts.cairo(color: theme.textColor),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                              value: 'prayer', child: Text('الصلوات')),
                          DropdownMenuItem(
                              value: 'azkar', child: Text('الأذكار')),
                          DropdownMenuItem(
                              value: 'tasbih', child: Text('التسابيح')),
                          DropdownMenuItem(
                              value: 'quran', child: Text('القرآن')),
                          DropdownMenuItem(
                              value: 'custom', child: Text('مخصصة')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedCategory = val;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'العدد المستهدف اليومي: $countTarget',
                        style: GoogleFonts.cairo(
                          color: theme.accentColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline,
                                color: theme.textColor),
                            onPressed: () {
                              if (countTarget > 1) {
                                setDialogState(() {
                                  countTarget--;
                                });
                              }
                            },
                          ),
                          Expanded(
                            child: Slider(
                              value: countTarget.toDouble(),
                              min: 1,
                              max: 100,
                              activeColor: theme.accentColor,
                              inactiveColor: theme.textColor.withOpacity(0.1),
                              onChanged: (val) {
                                setDialogState(() {
                                  countTarget = val.toInt();
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline,
                                color: theme.textColor),
                            onPressed: () {
                              if (countTarget < 100) {
                                setDialogState(() {
                                  countTarget++;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'إلغاء',
                      style: GoogleFonts.cairo(color: theme.subtitleColor),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.accentColor,
                      foregroundColor: theme.scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () {
                      if (titleController.text.trim().isNotEmpty) {
                        manager.addTask(
                          titleController.text.trim(),
                          selectedCategory,
                          countTarget: countTarget,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'إضافة',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    try {
      titleController.dispose();
    } catch (_) {}
  }

  void _openTaskScreen(
    String taskId,
  ) {
    final taskManager = Provider.of<SpiritualTaskManager>(context, listen: false);
    Widget? screen;

    switch (taskId) {
      case 'daily_tasbih':
        screen = const TasbihScreen(
          initialDhikr: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
          targetCount: 33,
          linkedTaskId: 'daily_tasbih',
        );
        break;

      case 'friday_salawat':
        screen = const TasbihScreen(
          initialDhikr: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
          targetCount: 100,
          linkedTaskId: 'friday_salawat',
        );
        break;

      case 'friday_kahf':
        screen = const SurahDetailScreen(
          surahNumber: 18,
          surahName: 'الكهف',
        );
        break;

      case 'quran_ward':
        screen = const QuranScreen();
        break;

      case 'azkar_sabah':
        screen = const AzkarCategoryScreen(
          category: 'morning',
          categoryTitle: 'أذكار الصباح',
        );
        break;

      case 'azkar_masaa':
        screen = const AzkarCategoryScreen(
          category: 'evening',
          categoryTitle: 'أذكار المساء',
        );
        break;

      case 'witr_sunan':
        _showQiyamRakahsDialog(taskManager);
        return;

      case 'fasting_monday':
      case 'fasting_thursday':
      case 'fasting_white_days':
      case 'ramadan_fasting':
      case 'arafah_fasting':
      case 'dhulhijjah_fasting':
      case 'ashura_fasting_9':
      case 'ashura_fasting_10':
      case 'shawwal_fasting':
        screen = const FastingTrackerScreen();
        break;
        
      case 'fajr':
      case 'dhuhr':
      case 'asr':
      case 'maghrib':
      case 'isha':
        final isToday = taskManager.selectedDate.year == DateTime.now().year &&
            taskManager.selectedDate.month == DateTime.now().month &&
            taskManager.selectedDate.day == DateTime.now().day;
        final isCompleted = taskManager.tasks.firstWhere((t) => t.id == taskId, orElse: () => IslamicTask(id: '', title: '', category: '')).isCompleted;
        if (isToday && taskManager.isTaskEnabled(taskId, DateTime.now()) && !isCompleted) {
          screen = PrayerTimerScreen(prayerId: taskId);
        } else {
          screen = const PrayerTimesScreen();
        }
        break;
    }

    if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => screen!,
        ),
      );
    }
  }

  void _showQiyamRakahsDialog(SpiritualTaskManager taskManager) {
    int selectedRakahs = 3;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌙'),
              SizedBox(width: 8.w),
              Text(
                'قيام الليل وصلاة الوتر',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'كم ركعة صليت الليلة تقبّل الله طاعتك؟',
                style: GoogleFonts.cairo(fontSize: 13.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                alignment: WrapAlignment.center,
                children: [1, 3, 5, 8, 11, 13].map((rakats) {
                  final isSelected = selectedRakahs == rakats;
                  return ChoiceChip(
                    label: Text(
                      '$rakats ركعات',
                      style: GoogleFonts.cairo(
                        color: isSelected ? Colors.black : null,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFD4AF37),
                    onSelected: (selected) {
                      if (selected) {
                        setDialogState(() => selectedRakahs = rakats);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.cairo()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                taskManager.setTaskCompleted('witr_sunan', true, customCount: selectedRakahs);
              },
              child: Text('حفظ واحتساب', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWardCompanionChip({
    required IconData icon,
    required String label,
    required Color color,
    required dynamic theme,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16.sp),
              SizedBox(width: 6.w),
              Flexible(
                child: AutoScrollText(
                  label,
                  style: GoogleFonts.cairo(
                    color: theme.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
