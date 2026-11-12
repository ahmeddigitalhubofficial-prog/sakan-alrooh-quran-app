// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/sunan_manager.dart';
import '../models/theme_manager.dart';

class QasrAlJannahCard extends StatelessWidget {
  final bool isCompact;

  const QasrAlJannahCard({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<AppThemeManager>(context);
    final theme = themeManager.currentTheme;

    return Consumer<SunanManager>(
      builder: (context, sunanManager, _) {
        final total = sunanManager.totalCompletedRakats;
        final isComplete = sunanManager.isPalaceCompleted;

        if (isCompact) {
          return _buildCompactCard(context, sunanManager, total, isComplete, theme);
        }
        return _buildFullCard(context, sunanManager, total, isComplete, theme);
      },
    );
  }

  // الكارت المضغوط للشاشة الرئيسية
  Widget _buildCompactCard(
    BuildContext context,
    SunanManager sunanManager,
    int total,
    bool isComplete,
    AppTheme theme,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: () => showSunanBottomSheet(context),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isComplete
                  ? [const Color(0xFFD4AF37), const Color(0xFF8C6D1F)]
                  : [theme.cardColor, theme.cardColor.withValues(alpha: 0.85)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isComplete
                  ? const Color(0xFFFFD700)
                  : theme.accentColor.withValues(alpha: 0.3),
              width: isComplete ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isComplete ? const Color(0xFFD4AF37) : theme.primaryColor)
                    .withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: isComplete ? Colors.black26 : theme.accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text('🏰', style: TextStyle(fontSize: 22.sp)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'قصرك في الجنة اليوم',
                          style: GoogleFonts.cairo(
                            color: isComplete ? Colors.white : theme.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          isComplete ? '✨ اكتمل!' : '($total / 12 ركعة)',
                          style: GoogleFonts.cairo(
                            color: isComplete ? const Color(0xFFFFE082) : theme.accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      isComplete
                          ? 'بُني لك بيت في الجنة اليوم بحمد الله 🤲'
                          : 'المواظبة على السنن الرواتب الـ 12 ركعة',
                      style: GoogleFonts.cairo(
                        color: isComplete ? Colors.white.withValues(alpha: 0.9) : theme.subtitleColor,
                        fontSize: 10.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isComplete ? Colors.white : theme.accentColor,
                size: 14.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // الكارت التفاعلي الكامل لشاشة الورد
  Widget _buildFullCard(
    BuildContext context,
    SunanManager sunanManager,
    int total,
    bool isComplete,
    AppTheme theme,
  ) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isComplete
              ? const Color(0xFFFFD700)
              : theme.accentColor.withValues(alpha: 0.25),
          width: isComplete ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('🏰', style: TextStyle(fontSize: 24.sp)),
                  SizedBox(width: 8.w),
                  Text(
                    'قصر الجنة (السنن الرواتب)',
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
                  color: isComplete
                      ? const Color(0xFF00E676).withValues(alpha: 0.2)
                      : theme.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$total / 12 ركعة',
                  style: GoogleFonts.cairo(
                    color: isComplete ? const Color(0xFF69F0AE) : theme.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          // 5 Sunan Pillars Grid
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: SunanManager.allSunan.map((s) {
              final isDone = sunanManager.isSunnahCompleted(s.key);
              final isEntered = sunanManager.isSunnahTimeEntered(s.key);
              return InkWell(
                borderRadius: BorderRadius.circular(14.r),
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (!isEntered && !isDone) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          'لا يمكن تسجيل سنة ${s.prayerName} قبل دخول وقتها ⏳',
                          style: GoogleFonts.cairo(),
                        ),
                      ),
                    );
                    return;
                  }
                  sunanManager.toggleSunnah(s.key);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFFD4AF37).withValues(alpha: 0.25)
                        : (!isEntered ? Colors.white.withValues(alpha: 0.02) : Colors.white.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isDone
                          ? const Color(0xFFFFD700)
                          : (!isEntered ? Colors.white.withValues(alpha: 0.05) : Colors.white12),
                      width: isDone ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDone
                            ? Icons.check_circle_rounded
                            : (!isEntered ? Icons.lock_clock_outlined : Icons.circle_outlined),
                        color: isDone
                            ? const Color(0xFFFFD700)
                            : (!isEntered ? theme.subtitleColor.withValues(alpha: 0.4) : theme.subtitleColor),
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '${s.prayerName} (${s.rakats} ركعة)',
                        style: GoogleFonts.cairo(
                          color: isDone
                              ? Colors.white
                              : (!isEntered ? theme.textColor.withValues(alpha: 0.4) : theme.textColor),
                          fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11.5.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (isComplete) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFF0F5A3E).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'هنيئاً لك! أتممت الـ 12 ركعة وبُني لك بيت في الجنة 🏰',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFF69F0AE),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
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
  }

  // نافذة التأكيد السريعة المنبثقة من الأسفل
  static void showSunanBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final themeManager = Provider.of<AppThemeManager>(ctx);
        final theme = themeManager.currentTheme;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              border: Border.all(color: theme.accentColor.withValues(alpha: 0.3)),
            ),
            child: Consumer<SunanManager>(
              builder: (context, sunanManager, _) {
                final total = sunanManager.totalCompletedRakats;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44.w,
                        height: 4.h,
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('🏰', style: TextStyle(fontSize: 24.sp)),
                            SizedBox(width: 8.w),
                            Text(
                              'متتبع السنن الرواتب اليومي',
                              style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 16.sp),
                            ),
                          ],
                        ),
                        Text(
                          '$total / 12 ركعة',
                          style: GoogleFonts.cairo(color: theme.accentColor, fontWeight: FontWeight.bold, fontSize: 14.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '«مَا مِنْ عَبْدٍ مُسْلِمٍ يُصَلِّي لِلَّهِ كُلَّ يَوْمٍ ثِنْتَيْ عَشْرَةَ رَكْعَةً تَطَوُّعًا، إِلَّا بَنَى اللَّهُ لَهُ بَيْتًا فِي الْجَنَّةِ»',
                      style: GoogleFonts.amiri(color: theme.subtitleColor, fontSize: 13.sp, height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ...SunanManager.allSunan.map((s) {
                      final isDone = sunanManager.isSunnahCompleted(s.key);
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: CheckboxListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          tileColor: isDone ? theme.accentColor.withValues(alpha: 0.12) : theme.cardColor,
                          activeColor: theme.accentColor,
                          title: Text(s.title, style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 13.sp)),
                          subtitle: Text('${s.rakats} ركعات ${s.isPre ? 'قبل الفريضة' : 'بعد الفريضة'}', style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 11.sp)),
                          value: isDone,
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            final isEntered = sunanManager.isSunnahTimeEntered(s.key);
                            if (!isEntered && !isDone) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                    'لا يمكن تسجيل سنة ${s.prayerName} قبل دخول وقتها ⏳',
                                    style: GoogleFonts.cairo(),
                                  ),
                                ),
                              );
                              return;
                            }
                            sunanManager.toggleSunnah(s.key);
                          },
                        ),
                      );
                    }),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.accentColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        minimumSize: Size(double.infinity, 44.h),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('تم بحمد الله', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
