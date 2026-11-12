// spiritual_badges_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/theme_manager.dart';
import '../models/task_manager.dart';

enum BadgeRank { none, bronze, silver, gold, diamond }

class TierTarget {
  final BadgeRank rank;
  final String title; // "برونزي", "فضي", "ذهبي", "ماسي"
  final String iconSymbol; // 🥉, 🥈, 🥇, 💎
  final int requiredCount;
  final Color color;

  const TierTarget({
    required this.rank,
    required this.title,
    required this.iconSymbol,
    required this.requiredCount,
    required this.color,
  });
}

class MultiTierBadgeItem {
  final String id;
  final String title;
  final String baseDescription;
  final IconData icon;
  final List<TierTarget> targets;

  const MultiTierBadgeItem({
    required this.id,
    required this.title,
    required this.baseDescription,
    required this.icon,
    required this.targets,
  });
}

class SpiritualBadgesScreen extends StatelessWidget {
  const SpiritualBadgesScreen({super.key});

  static const List<MultiTierBadgeItem> allBadges = [
    MultiTierBadgeItem(
      id: 'fajr_knight',
      title: 'وسام فارس الفجر 🌅',
      baseDescription: 'المحافظة على صلاة الفجر في وقتها بدون انقطاع.',
      icon: Icons.brightness_5_rounded,
      targets: [
        TierTarget(
            rank: BadgeRank.bronze,
            title: 'برونزي 🥉',
            iconSymbol: '🥉',
            requiredCount: 7,
            color: Color(0xFFCD7F32)),
        TierTarget(
            rank: BadgeRank.silver,
            title: 'فضي 🥈',
            iconSymbol: '🥈',
            requiredCount: 30,
            color: Color(0xFFC0C0C0)),
        TierTarget(
            rank: BadgeRank.gold,
            title: 'ذهبي 🥇',
            iconSymbol: '🥇',
            requiredCount: 90,
            color: Color(0xFFFFD700)),
        TierTarget(
            rank: BadgeRank.diamond,
            title: 'ماسي 💎',
            iconSymbol: '💎',
            requiredCount: 365,
            color: Color(0xFF00E5FF)),
      ],
    ),
    MultiTierBadgeItem(
      id: 'fasting_sunnah',
      title: 'وسام صائم النوافل 🌙',
      baseDescription: 'إتمام صيام سنة الإثنين والخميس والأيام البيض.',
      icon: Icons.nights_stay_rounded,
      targets: [
        TierTarget(
            rank: BadgeRank.bronze,
            title: 'برونزي 🥉',
            iconSymbol: '🥉',
            requiredCount: 3,
            color: Color(0xFFCD7F32)),
        TierTarget(
            rank: BadgeRank.silver,
            title: 'فضي 🥈',
            iconSymbol: '🥈',
            requiredCount: 12,
            color: Color(0xFFC0C0C0)),
        TierTarget(
            rank: BadgeRank.gold,
            title: 'ذهبي 🥇',
            iconSymbol: '🥇',
            requiredCount: 36,
            color: Color(0xFFFFD700)),
        TierTarget(
            rank: BadgeRank.diamond,
            title: 'ماسي 💎',
            iconSymbol: '💎',
            requiredCount: 100,
            color: Color(0xFF00E5FF)),
      ],
    ),
    MultiTierBadgeItem(
      id: 'dhikrimaster',
      title: 'وسام الذاكرين والذاكرات 📿',
      baseDescription: 'المواظبة المستمرة على أذكار الصباح والمساء والاستغفار.',
      icon: Icons.auto_awesome_rounded,
      targets: [
        TierTarget(
            rank: BadgeRank.bronze,
            title: 'برونزي 🥉',
            iconSymbol: '🥉',
            requiredCount: 7,
            color: Color(0xFFCD7F32)),
        TierTarget(
            rank: BadgeRank.silver,
            title: 'فضي 🥈',
            iconSymbol: '🥈',
            requiredCount: 30,
            color: Color(0xFFC0C0C0)),
        TierTarget(
            rank: BadgeRank.gold,
            title: 'ذهبي 🥇',
            iconSymbol: '🥇',
            requiredCount: 100,
            color: Color(0xFFFFD700)),
        TierTarget(
            rank: BadgeRank.diamond,
            title: 'ماسي 💎',
            iconSymbol: '💎',
            requiredCount: 365,
            color: Color(0xFF00E5FF)),
      ],
    ),
    MultiTierBadgeItem(
      id: 'quran_companion',
      title: 'وسام خادِم القرآن والتدبر 📖',
      baseDescription: 'المواظبة على قراءة الورد القرآني والتفسير الميسر.',
      icon: Icons.menu_book_rounded,
      targets: [
        TierTarget(
            rank: BadgeRank.bronze,
            title: 'برونزي 🥉',
            iconSymbol: '🥉',
            requiredCount: 7,
            color: Color(0xFFCD7F32)),
        TierTarget(
            rank: BadgeRank.silver,
            title: 'فضي 🥈',
            iconSymbol: '🥈',
            requiredCount: 30,
            color: Color(0xFFC0C0C0)),
        TierTarget(
            rank: BadgeRank.gold,
            title: 'ذهبي 🥇',
            iconSymbol: '🥇',
            requiredCount: 90,
            color: Color(0xFFFFD700)),
        TierTarget(
            rank: BadgeRank.diamond,
            title: 'ماسي 💎',
            iconSymbol: '💎',
            requiredCount: 365,
            color: Color(0xFF00E5FF)),
      ],
    ),
    MultiTierBadgeItem(
      id: 'streak_master',
      title: 'وسام صاحب الهمة العالية 🌟',
      baseDescription: 'تحقيق نسبة التزام عالية في الورد اليومي بدون انقطاع.',
      icon: Icons.local_fire_department_rounded,
      targets: [
        TierTarget(
            rank: BadgeRank.bronze,
            title: 'برونزي 🥉',
            iconSymbol: '🥉',
            requiredCount: 7,
            color: Color(0xFFCD7F32)),
        TierTarget(
            rank: BadgeRank.silver,
            title: 'فضي 🥈',
            iconSymbol: '🥈',
            requiredCount: 30,
            color: Color(0xFFC0C0C0)),
        TierTarget(
            rank: BadgeRank.gold,
            title: 'ذهبي 🥇',
            iconSymbol: '🥇',
            requiredCount: 90,
            color: Color(0xFFFFD700)),
        TierTarget(
            rank: BadgeRank.diamond,
            title: 'ماسي 💎',
            iconSymbol: '💎',
            requiredCount: 180,
            color: Color(0xFF00E5FF)),
      ],
    ),
    MultiTierBadgeItem(
      id: 'night_prayer',
      title: 'وسام قائم الليل والوتر 🤲',
      baseDescription: 'المحافظة على صلاة الوتر وقيام الليل.',
      icon: Icons.bedtime_rounded,
      targets: [
        TierTarget(
            rank: BadgeRank.bronze,
            title: 'برونزي 🥉',
            iconSymbol: '🥉',
            requiredCount: 5,
            color: Color(0xFFCD7F32)),
        TierTarget(
            rank: BadgeRank.silver,
            title: 'فضي 🥈',
            iconSymbol: '🥈',
            requiredCount: 20,
            color: Color(0xFFC0C0C0)),
        TierTarget(
            rank: BadgeRank.gold,
            title: 'ذهبي 🥇',
            iconSymbol: '🥇',
            requiredCount: 60,
            color: Color(0xFFFFD700)),
        TierTarget(
            rank: BadgeRank.diamond,
            title: 'ماسي 💎',
            iconSymbol: '💎',
            requiredCount: 180,
            color: Color(0xFF00E5FF)),
      ],
    ),
    MultiTierBadgeItem(
      id: 'salawat_lover',
      title: 'وسام المُصلي على النبي ﷺ 🌺',
      baseDescription: 'إكثار الصلاة على الحبيب النبي ﷺ وتجميع الأعداد.',
      icon: Icons.favorite_rounded,
      targets: [
        TierTarget(
            rank: BadgeRank.bronze,
            title: 'برونزي 🥉',
            iconSymbol: '🥉',
            requiredCount: 500,
            color: Color(0xFFCD7F32)),
        TierTarget(
            rank: BadgeRank.silver,
            title: 'فضي 🥈',
            iconSymbol: '🥈',
            requiredCount: 2500,
            color: Color(0xFFC0C0C0)),
        TierTarget(
            rank: BadgeRank.gold,
            title: 'ذهبي 🥇',
            iconSymbol: '🥇',
            requiredCount: 10000,
            color: Color(0xFFFFD700)),
        TierTarget(
            rank: BadgeRank.diamond,
            title: 'ماسي 💎',
            iconSymbol: '💎',
            requiredCount: 50000,
            color: Color(0xFF00E5FF)),
      ],
    ),
    MultiTierBadgeItem(
      id: 'friday_hour',
      title: 'وسام تحرّي ساعة الإجابة 🕋',
      baseDescription: 'تحري ساعة الإجابة والدعاء قبل مغرب يوم الجمعة.',
      icon: Icons.mosque_rounded,
      targets: [
        TierTarget(
            rank: BadgeRank.bronze,
            title: 'برونزي 🥉',
            iconSymbol: '🥉',
            requiredCount: 3,
            color: Color(0xFFCD7F32)),
        TierTarget(
            rank: BadgeRank.silver,
            title: 'فضي 🥈',
            iconSymbol: '🥈',
            requiredCount: 10,
            color: Color(0xFFC0C0C0)),
        TierTarget(
            rank: BadgeRank.gold,
            title: 'ذهبي 🥇',
            iconSymbol: '🥇',
            requiredCount: 25,
            color: Color(0xFFFFD700)),
        TierTarget(
            rank: BadgeRank.diamond,
            title: 'ماسي 💎',
            iconSymbol: '💎',
            requiredCount: 52,
            color: Color(0xFF00E5FF)),
      ],
    ),
    MultiTierBadgeItem(
      id: 'after_prayer_azkar',
      title: 'وسام عَقِب الصلوات 💧',
      baseDescription: 'استكمال التسبيح والأذكار عقب الصلوات المكتوبة.',
      icon: Icons.opacity_rounded,
      targets: [
        TierTarget(
            rank: BadgeRank.bronze,
            title: 'برونزي 🥉',
            iconSymbol: '🥉',
            requiredCount: 10,
            color: Color(0xFFCD7F32)),
        TierTarget(
            rank: BadgeRank.silver,
            title: 'فضي 🥈',
            iconSymbol: '🥈',
            requiredCount: 50,
            color: Color(0xFFC0C0C0)),
        TierTarget(
            rank: BadgeRank.gold,
            title: 'ذهبي 🥇',
            iconSymbol: '🥇',
            requiredCount: 150,
            color: Color(0xFFFFD700)),
        TierTarget(
            rank: BadgeRank.diamond,
            title: 'ماسي 💎',
            iconSymbol: '💎',
            requiredCount: 500,
            color: Color(0xFF00E5FF)),
      ],
    ),
    MultiTierBadgeItem(
      id: 'sadaqah_giver',
      title: 'وسام المُنفق والباذل 🤝',
      baseDescription: 'إخراج الصدقات وفعل الخيرات في مواسم الطاعات.',
      icon: Icons.handshake_rounded,
      targets: [
        TierTarget(
            rank: BadgeRank.bronze,
            title: 'برونزي 🥉',
            iconSymbol: '🥉',
            requiredCount: 3,
            color: Color(0xFFCD7F32)),
        TierTarget(
            rank: BadgeRank.silver,
            title: 'فضي 🥈',
            iconSymbol: '🥈',
            requiredCount: 10,
            color: Color(0xFFC0C0C0)),
        TierTarget(
            rank: BadgeRank.gold,
            title: 'ذهبي 🥇',
            iconSymbol: '🥇',
            requiredCount: 30,
            color: Color(0xFFFFD700)),
        TierTarget(
            rank: BadgeRank.diamond,
            title: 'ماسي 💎',
            iconSymbol: '💎',
            requiredCount: 100,
            color: Color(0xFF00E5FF)),
      ],
    ),
  ];

  int _calculateBadgeProgress(
      MultiTierBadgeItem badge, SpiritualTaskManager taskManager) {
    int count = 0;
    final cached = taskManager.cachedTasks;

    switch (badge.id) {
      case 'fajr_knight':
        for (var dateTasks in cached.values) {
          if (dateTasks.any((t) => t.id == 'fajr' && t.isCompleted)) {
            count++;
          }
        }
        break;
      case 'fasting_sunnah':
        count = taskManager.totalFastingDays;
        break;
      case 'dhikrimaster':
        for (var dateTasks in cached.values) {
          if (dateTasks.any((t) =>
              (t.id == 'azkar_sabah' || t.id == 'azkar_masaa') &&
              t.isCompleted)) {
            count++;
          }
        }
        break;
      case 'quran_companion':
        for (var dateTasks in cached.values) {
          if (dateTasks.any((t) => t.id == 'quran_ward' && t.isCompleted)) {
            count++;
          }
        }
        break;
      case 'streak_master':
        for (var percent in taskManager.history.values) {
          if (percent >= 80.0) {
            count++;
          }
        }
        break;
      case 'night_prayer':
        for (var dateTasks in cached.values) {
          if (dateTasks.any((t) => (t.id == 'witr_sunan' || t.id == 'qiyam_witr' || t.id.contains('witr') || t.id.contains('qiyam')) && t.isCompleted)) {
            count++;
          }
        }
        break;
      case 'salawat_lover':
        for (var dateTasks in cached.values) {
          if (dateTasks.any((t) =>
              (t.id == 'friday_salawat' || t.id == 'daily_tasbih') &&
              t.isCompleted)) {
            count += 100;
          }
        }
        break;
      case 'friday_hour':
        for (var dateTasks in cached.values) {
          if (dateTasks.any((t) => t.id == 'friday_duaa' && t.isCompleted)) {
            count++;
          }
        }
        break;
      case 'after_prayer_azkar':
        for (var dateTasks in cached.values) {
          if (dateTasks.any((t) =>
              (t.category == 'prayer' || t.category == 'azkar') &&
              t.isCompleted)) {
            count++;
          }
        }
        break;
      case 'sadaqah_giver':
        for (var dateTasks in cached.values) {
          if (dateTasks
              .any((t) => (t.id.contains('sadaqah') || t.id.contains('charity')) && t.isCompleted)) {
            count++;
          }
        }
        break;
    }
    return count;
  }

  TierTarget? _getCurrentTier(MultiTierBadgeItem badge, int currentProgress) {
    TierTarget? current;
    for (var target in badge.targets) {
      if (currentProgress >= target.requiredCount) {
        current = target;
      }
    }
    return current;
  }

  TierTarget _getNextTier(MultiTierBadgeItem badge, int currentProgress) {
    for (var target in badge.targets) {
      if (currentProgress < target.requiredCount) {
        return target;
      }
    }
    return badge.targets.last;
  }

  String _getSpiritualTitle(int totalPoints) {
    if (totalPoints >= 30) return 'السابق بالخيرات 🏆🌟';
    if (totalPoints >= 18) return 'السالك المستمسك بالعروة 🌿';
    if (totalPoints >= 8) return 'العابد المحافظ ✨';
    return 'المبتدئ المشتاق 🤲';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppThemeManager>(context).currentTheme;
    final taskManager = Provider.of<SpiritualTaskManager>(context);

    int totalTierPoints = 0;
    int totalUnlockedBadges = 0;

    for (var badge in allBadges) {
      final prog = _calculateBadgeProgress(badge, taskManager);
      final current = _getCurrentTier(badge, prog);
      if (current != null) {
        totalUnlockedBadges++;
        switch (current.rank) {
          case BadgeRank.bronze:
            totalTierPoints += 1;
            break;
          case BadgeRank.silver:
            totalTierPoints += 2;
            break;
          case BadgeRank.gold:
            totalTierPoints += 3;
            break;
          case BadgeRank.diamond:
            totalTierPoints += 4;
            break;
          case BadgeRank.none:
            break;
        }
      }
    }

    final spiritualRankTitle = _getSpiritualTitle(totalTierPoints);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        title: Text(
          'شجرة التطور والأوسمة الإيمانية',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.gradientColors,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Overall Spiritual Level Banner Card
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: theme.accentColor.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.accentColor.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.accentColor.withValues(alpha: 0.15),
                      ),
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        size: 54.sp,
                        color: theme.accentColor,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      spiritualRankTitle,
                      style: GoogleFonts.cairo(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.accentColor,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'درجة الهمة والإنجاز التراكمي في طريق العبادة',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        color: theme.subtitleColor,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHeaderStat(
                          'الأوسمة المفعلة',
                          '$totalUnlockedBadges / ${allBadges.length}',
                          Icons.emoji_events_rounded,
                          theme,
                        ),
                        Container(
                          width: 1,
                          height: 35.h,
                          color: theme.subtitleColor.withValues(alpha: 0.2),
                        ),
                        _buildHeaderStat(
                          'نقاط التطور',
                          '$totalTierPoints نقطة',
                          Icons.stars_rounded,
                          theme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تطور الأوسمة (برونزي 🥉 -> ماسي 💎)',
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.accentColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Multi-Tier Badges List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allBadges.length,
                itemBuilder: (context, index) {
                  final badge = allBadges[index];
                  final currentVal =
                      _calculateBadgeProgress(badge, taskManager);
                  final currentTier = _getCurrentTier(badge, currentVal);
                  final nextTier = _getNextTier(badge, currentVal);

                  final bool isFullyMaxed = (currentTier?.rank == BadgeRank.diamond &&
                      currentVal >= nextTier.requiredCount);

                  final activeColor = currentTier != null
                      ? currentTier.color
                      : Colors.grey;

                  final currentBadgeTitle = currentTier != null
                      ? '${badge.title} (${currentTier.title})'
                      : badge.title;

                  return Container(
                    margin: EdgeInsets.only(bottom: 14.h),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: currentTier != null
                            ? activeColor.withValues(alpha: 0.4)
                            : theme.accentColor.withValues(alpha: 0.08),
                        width: currentTier != null ? 1.5 : 1.0,
                      ),
                      boxShadow: currentTier != null
                          ? [
                              BoxShadow(
                                color: activeColor.withValues(alpha: 0.1),
                                blurRadius: 10,
                              ),
                            ]
                          : [],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 52.w,
                                height: 52.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: currentTier != null
                                      ? activeColor.withValues(alpha: 0.18)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: activeColor.withValues(
                                      alpha: currentTier != null ? 0.6 : 0.2,
                                    ),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  badge.icon,
                                  color: activeColor,
                                  size: 28.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentBadgeTitle,
                                      style: GoogleFonts.cairo(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: currentTier != null
                                            ? theme.textColor
                                            : Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      badge.baseDescription,
                                      style: GoogleFonts.cairo(
                                        fontSize: 12.sp,
                                        color: theme.subtitleColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 14.h),

                          // Tiers Badges Row (🥉 -> 🥈 -> 🥇 -> 💎)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: badge.targets.map((t) {
                              final isReached = currentVal >= t.requiredCount;
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isReached
                                      ? t.color.withValues(alpha: 0.18)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: isReached
                                        ? t.color
                                        : theme.subtitleColor.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Text(
                                  '${t.iconSymbol} ${t.requiredCount}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isReached
                                        ? t.color
                                        : theme.subtitleColor.withValues(alpha: 0.5),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          SizedBox(height: 12.h),

                          // Progress Bar to Next Tier Evolution
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5.r),
                                  child: LinearProgressIndicator(
                                    value: isFullyMaxed
                                        ? 1.0
                                        : (currentVal / nextTier.requiredCount)
                                            .clamp(0.0, 1.0),
                                    minHeight: 8.h,
                                    backgroundColor: theme.subtitleColor
                                        .withValues(alpha: 0.15),
                                    color: nextTier.color,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                isFullyMaxed
                                    ? 'ماسي مكتمل 💎✨'
                                    : '$currentVal / ${nextTier.requiredCount} (لـ ${nextTier.title})',
                                style: GoogleFonts.cairo(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: nextTier.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildHeaderStat(
    String title,
    String value,
    IconData icon,
    dynamic theme,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16.sp, color: theme.accentColor),
            SizedBox(width: 6.w),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                color: theme.subtitleColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: theme.textColor,
          ),
        ),
      ],
    );
  }
}
