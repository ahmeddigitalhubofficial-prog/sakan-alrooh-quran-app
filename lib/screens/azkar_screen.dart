// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:noor_al_hoda/data/azkar_data.dart';
import '../models/theme_manager.dart';
import '../models/zikr_model.dart';
import '../models/task_manager.dart';

import '../services/app_review_service.dart';
import '../services/audio_service.dart';
import '../services/azkar_audio_manager.dart';
import '../core/helpers/app_lifecycle_helper.dart';
import '../widgets/common/quick_language_button.dart';
import '../widgets/common/auto_scroll_text.dart';
import '../core/localization/app_translations.dart';

class AzkarReciter {
  final String name;
  final String country;
  final Map<String, String> categoryAudioUrls;

  const AzkarReciter({
    required this.name,
    required this.country,
    required this.categoryAudioUrls,
  });
}

const List<AzkarReciter> azkarReciters = [
  AzkarReciter(
    name: 'الشيخ مشاري بن راشد العفاسي',
    country: 'الكويت 🇰🇼',
    categoryAudioUrls: {
      'morning': 'https://archive.org/download/AZKAR_MICHARY/sabah_for_mobile.mp3',
      'evening': 'https://archive.org/download/AZKAR_MICHARY/masaa_for_mobile.mp3',
      'sleep': 'https://archive.org/download/MsherrY-03_uP_bY_mUSLEm/03.mp3',
      'after_prayer': 'https://archive.org/download/Alafasy_Azkar_Sabah_Masaa/after_prayer.mp3',
      'ruqyah': 'https://archive.org/download/Alafasy_Azkar_Sabah_Masaa/ruqyah.mp3',
    },
  ),
  AzkarReciter(
    name: 'الشيخ سعد الغامدي',
    country: 'السعودية 🇸🇦',
    categoryAudioUrls: {
      'morning': 'https://archive.org/download/saad-el-ghamidiadkarasabahwalmasaa/adkar-asabah-walmasaa-pt-1.mp3',
      'evening': 'https://archive.org/download/saad-el-ghamidiadkarasabahwalmasaa/adkar-asabah-walmasaa-pt-2.mp3',
      'sleep': 'https://archive.org/download/saad-el-ghamidiadkarasabahwalmasaa/adkar-asabah-walmasaa-pt-3.mp3',
    },
  ),
  AzkarReciter(
    name: 'الشيخ إدريس أبكر',
    country: 'اليمن 🇾🇪',
    categoryAudioUrls: {
      'morning': 'https://archive.org/download/AZKARIDREESABKAR/AZKAR%20IDREES%20ABKAR.mp3',
    },
  ),
  AzkarReciter(
    name: 'الشيخ فيصل لبان',
    country: 'السعودية 🇸🇦',
    categoryAudioUrls: {
      'morning': 'https://archive.org/download/2472474272424724karAlmasaaFaisalLabban/01.mp3',
      'evening': 'https://archive.org/download/2472474272424724karAlmasaaFaisalLabban/02.mp3',
    },
  ),
  AzkarReciter(
    name: 'الشيخ فارس عباد',
    country: 'اليمن 🇾🇪',
    categoryAudioUrls: {
      'morning': 'https://archive.org/download/TvQuran.com__Athkar/TvQuran.com_athkar_02.mp3',
      'evening': 'https://archive.org/download/TvQuran.com__Athkar/TvQuran.com_athkar_03.mp3',
    },
  ),
  AzkarReciter(
    name: 'الشيخ محمد جبريل',
    country: 'مصر 🇪🇬',
    categoryAudioUrls: {
      'morning': 'https://archive.org/download/TvQuran.com__Athkar/TvQuran.com_athkar_04.mp3',
      'evening': 'https://archive.org/download/TvQuran.com__Athkar/TvQuran.com_athkar_05.mp3',
    },
  ),
];

class AzkarScreen extends StatelessWidget {
  const AzkarScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final themeManager = Provider.of<AppThemeManager>(
      context,
    );

    final theme = themeManager.currentTheme;

    return Scaffold(
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 8.h,
                ),
                Icon(
                  Icons.auto_awesome,
                  color: theme.accentColor,
                  size: 52.sp,
                ),
                SizedBox(
                  height: 14.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 44),
                    Text(
                      context.tr('nav_azkar'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.textColor,
                      ),
                    ),
                    const QuickLanguageButton(isCompact: true),
                  ],
                ),
                SizedBox(
                  height: 12.h,
                ),
                _buildHeroCard(
                  theme,
                ),
                SizedBox(
                  height: 14.h,
                ),
                _buildAudioAndRecitersGuideCard(
                  context,
                  theme,
                ),
                SizedBox(
                  height: 24.h,
                ),
                Text(
                  'تـصـنـيـفـات الأذكـار',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.accentColor,
                  ),
                ),
                SizedBox(
                  height: 16.h,
                ),
                _buildCategoryCard(
                  context: context,
                  theme: theme,
                  title: 'أذكار الصباح',
                  subtitle: 'تُقرأ بعد صلاة الفجر إلى طلوع الشمس',
                  icon: Icons.wb_sunny_outlined,
                  iconColor: Colors.amber,
                  category: 'morning',
                ),
                SizedBox(
                  height: 14.h,
                ),
                _buildCategoryCard(
                  context: context,
                  theme: theme,
                  title: 'أذكار المساء',
                  subtitle: 'تُقرأ بعد صلاة العصر إلى غروب الشمس',
                  icon: Icons.nightlight_round,
                  iconColor: Colors.indigoAccent,
                  category: 'evening',
                ),
                SizedBox(
                  height: 14.h,
                ),
                _buildCategoryCard(
                  context: context,
                  theme: theme,
                  title: 'أذكار بعد الصلاة',
                  subtitle: 'الأدعية والاستغفار عقب الصلوات المفروضة',
                  icon: Icons.menu_book_rounded,
                  iconColor: Colors.tealAccent,
                  category: 'after_prayer',
                ),
                SizedBox(
                  height: 14.h,
                ),
                _buildCategoryCard(
                  context: context,
                  theme: theme,
                  title: 'أذكار النوم',
                  subtitle: 'حصن نفسك قبل النوم لنوم هادئ ومبارك',
                  icon: Icons.bedtime_outlined,
                  iconColor: Colors.orangeAccent,
                  category: 'sleep',
                ),
                SizedBox(
                  height: 14.h,
                ),
                _buildCategoryCard(
                  context: context,
                  theme: theme,
                  title: 'أذكار الاستيقاظ',
                  subtitle: 'أدعية النشور وحمد الله عند الاستيقاظ صباحاً',
                  icon: Icons.wb_twilight_rounded,
                  iconColor: Colors.amberAccent,
                  category: 'wakeup',
                ),
                SizedBox(
                  height: 14.h,
                ),
                _buildCategoryCard(
                  context: context,
                  theme: theme,
                  title: 'أذكار المسجد والوضوء',
                  subtitle: 'أدعية المشي للمسجد والدخول والطهور',
                  icon: Icons.mosque_rounded,
                  iconColor: Colors.cyanAccent,
                  category: 'mosque',
                ),
                SizedBox(
                  height: 14.h,
                ),
                _buildCategoryCard(
                  context: context,
                  theme: theme,
                  title: 'أدعية الكرب وتفريج الهموم',
                  subtitle: 'دعوات ذي النون والاستعاذة من الهم والحزن',
                  icon: Icons.volunteer_activism_rounded,
                  iconColor: Colors.lightGreenAccent,
                  category: 'relief',
                ),
                SizedBox(
                  height: 14.h,
                ),
                _buildCategoryCard(
                  context: context,
                  theme: theme,
                  title: 'الرقية الشرعية وتحصين النفس',
                  subtitle: 'أدعية التحصين والتعويذات المأثورة للشفاء',
                  icon: Icons.health_and_safety_rounded,
                  iconColor: Colors.purpleAccent,
                  category: 'ruqyah',
                ),
                SizedBox(
                  height: 14.h,
                ),
                _buildCategoryCard(
                  context: context,
                  theme: theme,
                  title: 'أذكار السفر والدخول والخروج',
                  subtitle: 'أدعية ركوب المركبات والسفر ودخول المنزل والخروج',
                  icon: Icons.directions_car_filled_rounded,
                  iconColor: Colors.lightBlueAccent,
                  category: 'travel',
                ),
                SizedBox(
                  height: 14.h,
                ),
                _buildCategoryCard(
                  context: context,
                  theme: theme,
                  title: 'أذكار الطعام والشراب',
                  subtitle: 'أدعية التسمية والحمد عند الطعام وحصن البركة',
                  icon: Icons.restaurant_rounded,
                  iconColor: Colors.amberAccent,
                  category: 'food',
                ),
                SizedBox(
                  height: 14.h,
                ),
                _buildCategoryCard(
                  context: context,
                  theme: theme,
                  title: 'أدعية المطر والرياح والبرق',
                  subtitle: 'دعوات الاستسقاء والغيث وسماع الرعد',
                  icon: Icons.thunderstorm_rounded,
                  iconColor: Colors.blueAccent,
                  category: 'rain',
                ),
                SizedBox(
                  height: 14.h,
                ),
                _buildCategoryCard(
                  context: context,
                  theme: theme,
                  title: 'دعاء الاستخارة وتيسير الأمور',
                  subtitle: 'النص الكامل لدعاء صلاة الاستخارة لتفويض الأمر لله',
                  icon: Icons.alt_route_rounded,
                  iconColor: Colors.deepOrangeAccent,
                  category: 'istikhara',
                ),
                SizedBox(
                  height: 14.h,
                ),
                _buildCategoryCard(
                  context: context,
                  theme: theme,
                  title: 'أدعية الحج والعمرة والتلبية',
                  subtitle: 'التلبية وأدعية الطواف والسعي ووقوف عرفة',
                  icon: Icons.mosque_outlined,
                  iconColor: Colors.amber,
                  category: 'hajj',
                ),
                SizedBox(
                  height: 14.h,
                ),
                _buildCategoryCard(
                  context: context,
                  theme: theme,
                  title: 'أدعية الاستغفار والتوبة الجامعة',
                  subtitle: 'سيد الاستغفار والأدعية النبوية الجامعة للمغفرة',
                  icon: Icons.auto_awesome_rounded,
                  iconColor: Colors.greenAccent,
                  category: 'forgiveness',
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

  Widget _buildHeroCard(
    AppTheme theme,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        28.r,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 22.w,
            vertical: 24.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.05,
            ),
            borderRadius: BorderRadius.circular(
              28.r,
            ),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.08,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.spa,
                color: theme.accentColor,
                size: 38.sp,
              ),
              SizedBox(
                height: 14.h,
              ),
              Text(
                'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.accentColor,
                  height: 1.8,
                ),
              ),
              SizedBox(
                height: 12.h,
              ),
              Text(
                'حصن نفسك بأورادك اليومية وحافظ على صلة قلبك بالله في كل وقت.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  color: theme.subtitleColor,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioAndRecitersGuideCard(BuildContext context, AppTheme theme) {
    return InkWell(
      onTap: () => _showAudioGuideModal(context, theme),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: theme.accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: theme.accentColor.withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.headphones_rounded,
                color: theme.accentColor,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'دليل القرّاء والأوراد الصوتية 🎧',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'تعرّف على الشيوخ المتاحين لكل ورد، والأوراد المخصصة للقراءة والتدبر',
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: theme.subtitleColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.accentColor,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showAudioGuideModal(BuildContext context, AppTheme theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  children: [
                    Container(
                      width: 44.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.headphones_rounded, color: theme.accentColor, size: 24.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'دليل القرّاء والأوراد الصوتية',
                              style: GoogleFonts.cairo(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.textColor,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close_rounded, color: theme.subtitleColor),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildOfflinePackDownloadSection(context, theme, setModalState),
                            SizedBox(height: 18.h),
                            Text(
                              'الأوراد الصوتية المتاحة والشيوخ 🎧',
                              style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.accentColor,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            _buildAudioCategoryGuideItem(
                              theme: theme,
                              title: 'أذكار الصباح ☀️',
                              reciters: [
                                'مشاري العفاسي (الافتراضي 🌟)',
                                'سعد الغامدي',
                                'فيصل لبان',
                                'فارس عباد',
                                'محمد جبريل',
                                'إدريس أبكر',
                              ],
                            ),
                            _buildAudioCategoryGuideItem(
                              theme: theme,
                              title: 'أذكار المساء 🌙',
                              reciters: [
                                'مشاري العفاسي (الافتراضي 🌟)',
                                'سعد الغامدي',
                                'فيصل لبان',
                                'فارس عباد',
                                'محمد جبريل',
                              ],
                            ),
                            _buildAudioCategoryGuideItem(
                              theme: theme,
                              title: 'أذكار النوم 🛏️',
                              reciters: [
                                'مشاري العفاسي (الافتراضي 🌟)',
                                'سعد الغامدي',
                              ],
                            ),
                            _buildAudioCategoryGuideItem(
                              theme: theme,
                              title: 'أذكار بعد الصلاة 🕌',
                              reciters: [
                                'مشاري العفاسي (الافتراضي 🌟)',
                              ],
                            ),
                            _buildAudioCategoryGuideItem(
                              theme: theme,
                              title: 'الرقية الشرعية 🛡️',
                              reciters: [
                                'مشاري العفاسي (الافتراضي 🌟)',
                              ],
                            ),
                            SizedBox(height: 18.h),
                            Text(
                              'أوراد القراءة والتدبر والتسبيح (بدون صوت) 📖',
                              style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.accentColor,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.all(14.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'أدعية نبوية ومواقف يومية سريعة خُصصت للقراءة التفاعلية مع عداد التسبيح الذكي والاهتزاز:',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.sp,
                                      color: theme.textColor,
                                      height: 1.5,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Wrap(
                                    spacing: 8.w,
                                    runSpacing: 8.h,
                                    children: [
                                      _buildReadBadge(theme, 'أذكار الاستيقاظ 🌅'),
                                      _buildReadBadge(theme, 'المسجد والوضوء 🕌'),
                                      _buildReadBadge(theme, 'السفر والمنزل 🚗'),
                                      _buildReadBadge(theme, 'الطعام والشراب 🍽️'),
                                      _buildReadBadge(theme, 'المطر والرعد ⛈️'),
                                      _buildReadBadge(theme, 'تفريج الكرب 🤲'),
                                      _buildReadBadge(theme, 'الاستخارة 🧭'),
                                      _buildReadBadge(theme, 'الحج والعمرة 🕋'),
                                      _buildReadBadge(theme, 'الاستغفار والتوبة 📿'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOfflinePackDownloadSection(BuildContext context, AppTheme theme, StateSetter setModalState) {
    return FutureBuilder<bool>(
      future: AzkarAudioManager.isOfflinePackDownloaded(),
      builder: (context, snapshot) {
        final isDownloaded = snapshot.data ?? false;
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.accentColor.withValues(alpha: 0.15),
                theme.cardColor,
              ],
            ),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isDownloaded ? Icons.check_circle_rounded : Icons.offline_bolt_rounded,
                    color: isDownloaded ? Colors.greenAccent : theme.accentColor,
                    size: 22.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    isDownloaded ? 'حزمة الأذكار محملة وتعمل أوفلاين ⚡' : 'تشغيل الأذكار بدون إنترنت (أوفلاين)',
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                isDownloaded
                    ? 'يمكنك الاستماع لأذكار الصباح والمساء في أي وقت بدون استهلاك باقة الإنترنت.'
                    : 'يمكنك تنزيل الصوتيات لتعمل أوفلاين دائماً دون الحاجة لشبكة الإنترنت.',
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  color: theme.subtitleColor,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12.h),
              if (!isDownloaded) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accentColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  ),
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('جارٍ تحميل الأذكار في الخلفية...', style: GoogleFonts.cairo()),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    final success = await AzkarAudioManager.downloadCorePack();
                    if (success) {
                      setModalState(() {});
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✓ تم تحميل الأذكار وتعمل الآن بدون إنترنت!', style: GoogleFonts.cairo()),
                            backgroundColor: Colors.green.shade800,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: Text(
                    'تحميل الأذكار للعمل بدون نت (~13 MB)',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12.sp),
                  ),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الحالة: جاهز أوفلاين 100%',
                      style: GoogleFonts.cairo(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        await AzkarAudioManager.deleteOfflinePack();
                        setModalState(() {});
                      },
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
                      label: Text(
                        'حذف لتوفير المساحة',
                        style: GoogleFonts.cairo(color: Colors.redAccent, fontSize: 11.sp),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAudioCategoryGuideItem({
    required AppTheme theme,
    required String title,
    required List<String> reciters,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.record_voice_over_rounded, color: theme.accentColor, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: reciters.map((r) {
              final isDefault = r.contains('🌟');
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isDefault
                      ? theme.accentColor.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isDefault ? theme.accentColor.withValues(alpha: 0.5) : Colors.white12,
                  ),
                ),
                child: Text(
                  r,
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: isDefault ? theme.accentColor : theme.textColor,
                    fontWeight: isDefault ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReadBadge(AppTheme theme, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 11.sp,
          color: theme.subtitleColor,
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required AppTheme theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String category,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(
        24.r,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (
              context,
            ) =>
                AzkarCategoryScreen(
              category: category,
              categoryTitle: title,
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 220,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 18.w,
          vertical: 18.h,
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
        child: Row(
          children: [
            Container(
              width: 58.w,
              height: 58.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  18.r,
                ),
                color: Colors.black.withValues(
                  alpha: 0.18,
                ),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28.sp,
              ),
            ),
            SizedBox(
              width: 16.w,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                  ),
                  SizedBox(
                    height: 6.h,
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: theme.subtitleColor,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 10.w,
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.accentColor,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class AzkarCategoryScreen extends StatefulWidget {
  final String category;
  final String categoryTitle;

  const AzkarCategoryScreen({
    super.key,
    required this.category,
    required this.categoryTitle,
  });

  @override
  State<AzkarCategoryScreen> createState() => _AzkarCategoryScreenState();
}

class _AzkarCategoryScreenState extends State<AzkarCategoryScreen>
    with WidgetsBindingObserver {
  late List<Zikr> _azkarList;
  int _activeZikrIndex = 0;
  bool _vibrationEnabled = true;

  bool _isPlayingAudio = false;
  bool _isAudioLoading = false;
  String? _currentPlayingZikrId;
  double _playbackSpeed = 1.0;
  String _selectedReciterName = 'الشيخ مشاري بن راشد العفاسي';
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _playSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _azkarList = AzkarData.getAzkarByCategory(widget.category)
        .map((z) => z.copy())
        .toList();
    _loadSettings();
    _initAudioListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final manager = Provider.of<SpiritualTaskManager>(context, listen: false);
        if (widget.category == 'morning') {
          manager.setTaskCompleted('azkar_sabah', true);
        } else if (widget.category == 'evening') {
          manager.setTaskCompleted('azkar_masaa', true);
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      safeSetState(() {
        _currentPosition = AudioService.player.position;
      });
    }
  }

  void _initAudioListeners() {
    _posSub = AudioService.positionStream.listen((pos) {
      safeSetState(() {
        _currentPosition = pos;
      });
    });
    _durSub = AudioService.durationStream.listen((dur) {
      if (dur != null) {
        safeSetState(() {
          _totalDuration = dur;
        });
      }
    });
    _playSub = AudioService.playingStream.listen((playing) {
      safeSetState(() {
        _isPlayingAudio = playing;
        _isAudioLoading = false;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _posSub?.cancel();
    _durSub?.cancel();
    _playSub?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _selectedReciterName = prefs.getString('azkar_preferred_reciter') ?? 'الشيخ مشاري بن راشد العفاسي';
    });
  }

  List<AzkarReciter> get _availableReciters {
    return azkarReciters.where((r) =>
      r.categoryAudioUrls.containsKey(widget.category) &&
      r.categoryAudioUrls[widget.category]!.isNotEmpty
    ).toList();
  }

  AzkarReciter _getSelectedReciter() {
    final available = _availableReciters;
    if (available.isEmpty) return azkarReciters.first;
    return available.firstWhere(
      (r) => r.name == _selectedReciterName,
      orElse: () => available.first,
    );
  }

  /// هل تتوفر تسجيلات صوتية لهذا القسم؟
  bool get _reciterHasAudio {
    return _availableReciters.isNotEmpty;
  }

  Future<String?> _getAudioUrlForCategory() async {
    if (!_reciterHasAudio) return null;
    final reciter = _getSelectedReciter();
    final url = reciter.categoryAudioUrls[widget.category];
    if (url == null || url.isEmpty) return null;
    return await AzkarAudioManager.getPlayableSource(widget.category, url);
  }

  Future<void> _toggleAudioPlayback([Zikr? zikr]) async {
    // Individual zikr audio playback
    if (zikr != null && zikr.audioUrl != null && zikr.audioUrl!.isNotEmpty) {
      if (_isPlayingAudio && _currentPlayingZikrId == zikr.id) {
        await AudioService.pause();
        if (mounted) {
          setState(() {
            _isPlayingAudio = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isAudioLoading = true;
          _currentPlayingZikrId = zikr.id;
        });
      }
      try {
        await AudioService.play(zikr.audioUrl!);
        if (mounted) {
          setState(() {
            _isAudioLoading = false;
            _isPlayingAudio = AudioService.player.playing;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isAudioLoading = false;
            _isPlayingAudio = false;
            _currentPlayingZikrId = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'عذراً، تعذر تشغيل ملف الصوت الخاص بالذكر.',
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
      return;
    }

    // Full category playback
    final url = await _getAudioUrlForCategory();
    if (url == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'هذا الورد مخصص للقراءة والتسبيح والتدبر (لا يتوفر له تسجيل صوتي).',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.teal.shade800,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    if (_isPlayingAudio) {
      await AudioService.pause();
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isAudioLoading = true;
          _currentPlayingZikrId = null;
        });
      }
      try {
        await AudioService.play(url);
        if (mounted) {
          setState(() {
            _isAudioLoading = false;
            _isPlayingAudio = AudioService.player.playing;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isAudioLoading = false;
            _isPlayingAudio = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'عذراً، تعذر تشغيل ملف الصوت. يرجى التأكد من الاتصال بالإنترنت.',
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  void _seekRelative(int seconds) {
    if (seconds > 0) {
      AudioService.seekForward(seconds: seconds);
    } else {
      AudioService.seekBackward(seconds: seconds.abs());
    }
  }

  void _changeSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    AudioService.setSpeed(speed);
  }

  void _showReciterSelectionModal() {
    final available = _availableReciters;
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'هذا الورد مخصص للقراءة والتسبيح والتدبر.',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.teal.shade800,
        ),
      );
      return;
    }

    final theme = Provider.of<AppThemeManager>(context, listen: false).currentTheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'اختر قارئ الأذكار المفضل لهذا الورد',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'يتم عرض القرّاء المتوفر لهم تسجيل حقيقي لهذا القسم فقط',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: theme.subtitleColor,
                  ),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: ListView.separated(
                    itemCount: available.length,
                    separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                    itemBuilder: (context, index) {
                      final reciter = available[index];
                      final isSelected = reciter.name == _selectedReciterName;
                      return ListTile(
                        title: Text(
                          reciter.name,
                          style: GoogleFonts.cairo(
                            color: isSelected ? theme.accentColor : theme.textColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13.sp,
                          ),
                        ),
                        subtitle: Text(
                          reciter.country,
                          style: GoogleFonts.cairo(
                            color: theme.subtitleColor,
                            fontSize: 11.sp,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: theme.accentColor)
                            : null,
                        onTap: () async {
                          final navigator = Navigator.of(context);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('azkar_preferred_reciter', reciter.name);
                          if (!mounted) return;
                          setState(() {
                            _selectedReciterName = reciter.name;
                          });
                          navigator.pop();
                          if (_isPlayingAudio) {
                            await AudioService.stop();
                            await _toggleAudioPlayback();
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQuickJumpSheet() {
    final theme = Provider.of<AppThemeManager>(context, listen: false).currentTheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'فهرس أذكار ${widget.categoryTitle} (${_azkarList.length})',
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.textColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: theme.subtitleColor),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: ListView.separated(
                    itemCount: _azkarList.length,
                    separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                    itemBuilder: (context, index) {
                      final item = _azkarList[index];
                      final isCurrent = index == _activeZikrIndex;
                      final isCompleted = item.currentCount >= item.count;
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 14.r,
                          backgroundColor: isCompleted
                              ? Colors.green.withValues(alpha: 0.2)
                              : (isCurrent ? theme.accentColor.withValues(alpha: 0.2) : Colors.white10),
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: isCompleted
                                  ? Colors.greenAccent
                                  : (isCurrent ? theme.accentColor : theme.subtitleColor),
                            ),
                          ),
                        ),
                        title: isCurrent
                            ? AutoScrollText(
                                item.text,
                                style: GoogleFonts.cairo(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: theme.accentColor,
                                ),
                              )
                            : Text(
                                item.text,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.normal,
                                  color: theme.textColor,
                                ),
                              ),
                        subtitle: item.description.isNotEmpty
                            ? Text(
                                item.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontSize: 10.sp,
                                  color: theme.subtitleColor,
                                ),
                              )
                            : null,
                        trailing: isCompleted
                            ? const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 18)
                            : Text(
                                '${item.currentCount}/${item.count}',
                                style: GoogleFonts.cairo(
                                  fontSize: 11.sp,
                                  color: theme.subtitleColor,
                                ),
                              ),
                        onTap: () {
                          setState(() {
                            _activeZikrIndex = index;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSpeedSelectionModal() {
    final theme = Provider.of<AppThemeManager>(context, listen: false).currentTheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'سرعة الصوت',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                  final isSel = _playbackSpeed == speed;
                  return InkWell(
                    onTap: () {
                      _changeSpeed(speed);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSel ? theme.accentColor : theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: theme.accentColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        '${speed}x',
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: isSel ? theme.scaffoldBackgroundColor : theme.textColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 12.h),
            ],
          ),
        );
      },
    );
  }

  void _incrementZikr() {
    if (_azkarList.isEmpty || _activeZikrIndex >= _azkarList.length) {
      return;
    }

    final zikr = _azkarList[_activeZikrIndex];

    if (zikr.currentCount < zikr.count) {
      setState(() {
        zikr.currentCount++;
      });

      if (_vibrationEnabled) {
        HapticFeedback.lightImpact();
      }

      if (zikr.currentCount == zikr.count) {
        if (_vibrationEnabled) {
          HapticFeedback.mediumImpact();
        }

        Future.delayed(
          const Duration(milliseconds: 400),
          () {
            if (mounted) {
              _moveToNextZikr();
            }
          },
        );
      }
    }
  }

  void _moveToNextZikr() {
    if (_activeZikrIndex < _azkarList.length - 1) {
      setState(() {
        _activeZikrIndex++;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _moveToPrevZikr() {
    if (_activeZikrIndex > 0) {
      setState(() {
        _activeZikrIndex--;
      });
    }
  }

  void _resetZikr() {
    setState(() {
      _azkarList = AzkarData.getAzkarByCategory(widget.category)
          .map((z) => z.copy())
          .toList();
      _activeZikrIndex = 0;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF102C3B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          title: Text(
            'تقبل الله منك 🤍',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: const Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'لقد أتممت قراءة ${widget.categoryTitle} بنجاح.',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: Colors.white,
              height: 1.7,
            ),
          ),
          actions: [
            Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    final manager = Provider.of<SpiritualTaskManager>(
                      context,
                      listen: false,
                    );

                    if (widget.category == 'morning') {
                      manager.setTaskCompleted('azkar_sabah', true);
                    }

                    if (widget.category == 'evening') {
                      manager.setTaskCompleted('azkar_masaa', true);
                    }

                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'إنهاء',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                TextButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await AppReviewService.showRatingDialog(context);
                  },
                  icon: const Icon(Icons.star_rounded, color: Colors.amber),
                  label: Text(
                    'دعماً للخير .. تقييم التطبيق ⭐️',
                    style: GoogleFonts.cairo(
                      color: Colors.amber,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<AppThemeManager>(context);
    final theme = themeManager.currentTheme;

    if (_azkarList.isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(widget.categoryTitle),
        ),
        body: Center(
          child: Text(
            'لا يوجد أذكار متوفرة حاليًا',
            style: GoogleFonts.cairo(
              color: theme.textColor,
            ),
          ),
        ),
      );
    }

    final zikr = _azkarList[_activeZikrIndex];
    final progress = zikr.count > 0 ? zikr.currentCount / zikr.count : 0.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        titleSpacing: 0,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            widget.categoryTitle,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          if (_reciterHasAudio)
            IconButton(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              constraints: const BoxConstraints(),
              onPressed: _showReciterSelectionModal,
              icon: Icon(
                Icons.record_voice_over_rounded,
                color: theme.accentColor,
                size: 21.sp,
              ),
              tooltip: 'تغيير قارئ الأذكار',
            ),
          IconButton(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            constraints: const BoxConstraints(),
            onPressed: _showQuickJumpSheet,
            icon: Icon(
              Icons.format_list_numbered_rtl_rounded,
              color: theme.accentColor,
              size: 21.sp,
            ),
            tooltip: 'فهرس الأذكار',
          ),
          IconButton(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            constraints: const BoxConstraints(),
            onPressed: _resetZikr,
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
              size: 23.sp,
            ),
            tooltip: 'إعادة ضبط العداد',
          ),
          SizedBox(width: 8.w),
        ],
      ),
      bottomNavigationBar: _reciterHasAudio
          ? Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_totalDuration > Duration.zero) ...[
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3.h,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 12.r),
                  ),
                  child: Slider(
                    value: _currentPosition.inSeconds
                        .toDouble()
                        .clamp(0.0, _totalDuration.inSeconds.toDouble()),
                    max: _totalDuration.inSeconds > 0
                        ? _totalDuration.inSeconds.toDouble()
                        : 1.0,
                    activeColor: theme.accentColor,
                    inactiveColor: Colors.white12,
                    onChanged: (val) {
                      AudioService.seek(Duration(seconds: val.toInt()));
                    },
                  ),
                ),
              ],
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _showReciterSelectionModal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AutoScrollText(
                            _selectedReciterName,
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.textColor,
                            ),
                          ),
                          Text(
                            _isPlayingAudio ? 'جارٍ الاستماع' : 'اضغط للتشغيل الصوتي',
                            style: GoogleFonts.cairo(
                              fontSize: 10.sp,
                              color: _isPlayingAudio
                                  ? Colors.greenAccent
                                  : theme.subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _seekRelative(-10),
                    icon: Icon(
                      Icons.replay_10_rounded,
                      color: theme.accentColor,
                      size: 24.sp,
                    ),
                    tooltip: 'تأخير 10 ثوانٍ',
                  ),
                  InkWell(
                    onTap: _toggleAudioPlayback,
                    borderRadius: BorderRadius.circular(30.r),
                    child: Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.accentColor,
                      ),
                      child: Center(
                        child: _isAudioLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.scaffoldBackgroundColor,
                                ),
                              )
                            : Icon(
                                _isPlayingAudio
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: theme.scaffoldBackgroundColor,
                                size: 28.sp,
                              ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _seekRelative(10),
                    icon: Icon(
                      Icons.forward_10_rounded,
                      color: theme.accentColor,
                      size: 24.sp,
                    ),
                    tooltip: 'تقديم 10 ثوانٍ',
                  ),
                  InkWell(
                    onTap: _showSpeedSelectionModal,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: theme.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: theme.accentColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        '${_playbackSpeed}x',
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.accentColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الذكر ${_activeZikrIndex + 1} من ${_azkarList.length}',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: theme.subtitleColor,
                      ),
                    ),
                    Text(
                      '${(((_activeZikrIndex + 1) / _azkarList.length) * 100).toInt()}%',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.accentColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.h,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    12.r,
                  ),
                  child: LinearProgressIndicator(
                    value: ((_activeZikrIndex + 1) / _azkarList.length).clamp(
                      0,
                      1,
                    ),
                    minHeight: 6.h,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation(
                      theme.accentColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 24.h,
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      28.r,
                    ),
                    onTap: _incrementZikr,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                        24.w,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.05,
                        ),
                        borderRadius: BorderRadius.circular(
                          28.r,
                        ),
                        boxShadow: (_isPlayingAudio && _currentPlayingZikrId == zikr.id)
                            ? [
                                BoxShadow(
                                  color: theme.accentColor.withValues(alpha: 0.35),
                                  blurRadius: 18.r,
                                  spreadRadius: 2.r,
                                ),
                              ]
                            : null,
                        border: Border.all(
                          color: (_isPlayingAudio && _currentPlayingZikrId == zikr.id)
                              ? theme.accentColor
                              : (zikr.currentCount == zikr.count
                                  ? theme.accentColor
                                  : Colors.white.withValues(
                                      alpha: 0.08,
                                    )),
                          width: (_isPlayingAudio && _currentPlayingZikrId == zikr.id) ? 2.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: InkWell(
                                  onTap: _showReciterSelectionModal,
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: theme.accentColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: theme.accentColor.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.record_voice_over_rounded, color: theme.accentColor, size: 14.sp),
                                        SizedBox(width: 4.w),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(maxWidth: 180.w),
                                          child: AutoScrollText(
                                            _selectedReciterName,
                                            style: GoogleFonts.cairo(
                                              fontSize: 10.5.sp,
                                              color: theme.accentColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.arrow_drop_down_rounded, color: theme.accentColor, size: 16.sp),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (_reciterHasAudio || (zikr.audioUrl != null && zikr.audioUrl!.isNotEmpty))
                                IconButton(
                                  onPressed: () => _toggleAudioPlayback(zikr),
                                  icon: Icon(
                                    (_isPlayingAudio && _currentPlayingZikrId == zikr.id)
                                        ? Icons.pause_circle_filled_rounded
                                        : Icons.play_circle_fill_rounded,
                                    color: theme.accentColor,
                                    size: 32.sp,
                                  ),
                                  tooltip: 'استماع صوتي لهذا الذكر منفصلاً',
                                ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    zikr.text,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.amiri(
                                      fontSize: 27.sp,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textColor,
                                      height: 1.9,
                                    ),
                                  ),
                                  if (zikr.description.isNotEmpty) ...[
                                    SizedBox(height: 14.h),
                                    Divider(
                                      color: Colors.white.withValues(alpha: 0.08),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      zikr.description,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.cairo(
                                        fontSize: 12.sp,
                                        color: theme.subtitleColor,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 80.w,
                                height: 80.w,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 5.w,
                                  backgroundColor: Colors.white10,
                                  valueColor: AlwaysStoppedAnimation(
                                    theme.accentColor,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${zikr.currentCount}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.bold,
                                      color: theme.accentColor,
                                      height: 1.1,
                                    ),
                                  ),
                                  Text(
                                    'من ${zikr.count}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 10.sp,
                                      color: theme.subtitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 6.h,
                          ),
                          Text(
                            'اضغط على البطاقة للتسبيح',
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 22.h,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white10,
                          foregroundColor: theme.accentColor,
                          padding: EdgeInsets.symmetric(
                            vertical: 14.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              16.r,
                            ),
                          ),
                        ),
                        onPressed: _moveToPrevZikr,
                        icon: Icon(
                          Icons.arrow_back_ios,
                          size: 16.sp,
                        ),
                        label: Text(
                          'السابق',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 14.w,
                    ),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.accentColor,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            vertical: 14.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              16.r,
                            ),
                          ),
                        ),
                        onPressed: _moveToNextZikr,
                        label: Text(
                          'التالي',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
