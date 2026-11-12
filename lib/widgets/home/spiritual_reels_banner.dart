import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../models/spiritual_reel_model.dart';
import '../../models/theme_manager.dart';
import '../../screens/spiritual_reels_screen.dart';
import '../../services/spiritual_reels_service.dart';

/// بطاقة مدخل مقاطع الريلز الإيمانية (سكينة مرئية) في الشاشة الرئيسية
class SpiritualReelsBanner extends StatefulWidget {
  final AppTheme theme;

  const SpiritualReelsBanner({
    super.key,
    required this.theme,
  });

  @override
  State<SpiritualReelsBanner> createState() => _SpiritualReelsBannerState();
}

class _SpiritualReelsBannerState extends State<SpiritualReelsBanner> {
  SpiritualReelModel? _latestReel;
  int _totalReleased = 0;
  List<SpiritualReelModel> _reels = [];

  static final SpiritualReelModel _defaultReel = SpiritualReelModel(
    id: 1,
    title: 'سكينة القلب: ألا بذكر الله تطمئن القلوب',
    surah: 13,
    ayah: 28,
    screenKey: 'quran',
    featureBadge: '📖 المصحف المرتل بالرسم العثماني أوفلاين',
    hookText: 'أوعى تقلب.. لو في ضيق في صدرك الآية دي مكتوبة ليك 🤍',
    ayahText: '﴿أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ﴾',
    videoUrl: 'https://res.cloudinary.com/bmp3hs5g/video/upload/v1793505018/sakan_1793505014_reel_day_1.mp4',
    releaseDate: DateTime(2026, 1, 1),
    youtubeUrl: 'https://www.youtube.com/@SakanAl-Rooh',
    instagramUrl: 'https://www.instagram.com/sakan.alrooh.app',
    tiktokUrl: 'https://www.tiktok.com/@sakan.alrooh.app',
    facebookUrl: 'https://www.facebook.com/profile.php?id=61595603427400',
  );

  @override
  void initState() {
    super.initState();
    _loadReelsData();
  }

  Future<void> _loadReelsData() async {
    var released = await SpiritualReelsService.getReleasedReels(newestFirst: true);
    if (released.isEmpty) {
      released = await SpiritualReelsService.getAllReels();
    }
    if (!mounted) return;
    setState(() {
      _reels = released;
      _totalReleased = released.isNotEmpty ? released.length : 60;
      _latestReel = released.isNotEmpty ? released.first : _defaultReel;
    });
  }

  void _openReelsScreen([int index = 0]) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SpiritualReelsScreen(
          initialIndex: index,
          initialReels: _reels.isNotEmpty ? _reels : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reel = _latestReel ?? _defaultReel;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.theme.cardColor.withValues(alpha: 0.95),
            AppColors.emeraldDark.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22.r),
          onTap: () => _openReelsScreen(0),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Badge + Count Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.gold, AppColors.darkGold],
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 12.sp,
                                color: Colors.black,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'سكينة مرئية',
                                style: GoogleFonts.cairo(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            'ريلز قرآنية يومية',
                            style: GoogleFonts.cairo(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_totalReleased > 0)
                      Text(
                        '$_totalReleased مقطع متاح',
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Latest Reel Information
                Row(
                  children: [
                    // Video Reel Icon Thumbnail
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            AppColors.gold.withValues(alpha: 0.3),
                            AppColors.emeraldDark,
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.gold,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: AppColors.gold,
                          size: 28.sp,
                        ),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    // Title & Surah Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reel.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'سورة ${reel.surahName} • آية ${reel.ayah}',
                            style: GoogleFonts.cairo(
                              fontSize: 11.5.sp,
                              color: AppColors.gold.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Forward Arrow
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16.sp,
                      color: AppColors.gold,
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Bottom Callout Row
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        size: 14.sp,
                        color: AppColors.gold,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'اضغط للمشاهدة بملء الشاشة والتقليب بين جميع المقاطع المنشورة 🎬',
                          style: GoogleFonts.cairo(
                            fontSize: 10.5.sp,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

