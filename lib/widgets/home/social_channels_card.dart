// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../models/theme_manager.dart';
import '../../services/social_service.dart';

/// بطاقة قنوات سكن الروح الرسمية في الشاشة الرئيسية والإعدادات
class SocialChannelsCard extends StatelessWidget {
  final AppTheme theme;
  final bool isCompact;

  const SocialChannelsCard({
    super.key,
    required this.theme,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 14.w : 16.w),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gold,
                      AppColors.gold.withValues(alpha: 0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.public_rounded,
                  color: Colors.black87,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'قنوات سكن الروح الرسمية 🌙',
                          style: GoogleFonts.cairo(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.textColor,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: const Color(0xFF2ECC71).withValues(alpha: 0.5),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            'مباشر',
                            style: GoogleFonts.cairo(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2ECC71),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'شاهد التلاوات اليومية والتصاميم الإيمانية وشارك الأجر',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5.sp,
                        color: theme.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Platform Buttons Grid / Row
          Row(
            children: [
              // TikTok
              Expanded(
                child: _buildPlatformButton(
                  context: context,
                  label: 'تيك توك',
                  iconWidget: const Icon(
                    Icons.music_note_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  backgroundColor: const Color(0xFF010101),
                  borderColor: const Color(0xFFFE2C55).withValues(alpha: 0.6),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    SocialService.openTikTok();
                  },
                ),
              ),
              SizedBox(width: 8.w),

              // Instagram
              Expanded(
                child: _buildPlatformButton(
                  context: context,
                  label: 'إنستغرام',
                  iconWidget: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  backgroundColor: const Color(0xFF833AB4),
                  borderColor: const Color(0xFFFD1D1D).withValues(alpha: 0.6),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF833AB4),
                      Color(0xFFFD1D1D),
                      Color(0xFFFCB045),
                    ],
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    SocialService.openInstagram();
                  },
                ),
              ),
              SizedBox(width: 8.w),

              // Facebook
              Expanded(
                child: _buildPlatformButton(
                  context: context,
                  label: 'فيسبوك',
                  iconWidget: const Icon(
                    Icons.facebook_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  backgroundColor: const Color(0xFF1877F2),
                  borderColor: const Color(0xFF1877F2).withValues(alpha: 0.6),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    SocialService.openFacebook();
                  },
                ),
              ),
              SizedBox(width: 8.w),

              // Linktree (All Links)
              Expanded(
                child: _buildPlatformButton(
                  context: context,
                  label: 'كل الروابط',
                  iconWidget: const Icon(
                    Icons.link_rounded,
                    color: Colors.black87,
                    size: 18,
                  ),
                  backgroundColor: AppColors.gold,
                  borderColor: AppColors.gold,
                  textColor: Colors.black87,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    SocialService.openUniversalBio();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformButton({
    required BuildContext context,
    required String label,
    required Widget iconWidget,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback onTap,
    Gradient? gradient,
    Color textColor = Colors.white,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: gradient == null ? backgroundColor : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              SizedBox(height: 3.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
