import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_share_service.dart';
import 'platform_service_hub.dart';

class AppReviewService {
  static final InAppReview _inAppReview = InAppReview.instance;
  static const String _reviewPromptCountKey = 'app_review_prompt_count';
  static const String _hasReviewedKey = 'app_has_reviewed';

  /// Show interactive in-app rating dialog (5 stars)
  static Future<void> showRatingDialog(BuildContext context) async {
    int selectedRating = 5;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF102C3B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              title: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 38.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'تقييم تطبيق سكن الروح | Sakan Al-Rooh ⭐️',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color: const Color(0xFFD4AF37),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'رأيك يهمنا جداً لتطوير التطبيق وتقديم أفضل خدمة إسلامية بدون إعلانات.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color: Colors.white70,
                      fontSize: 13.sp,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            selectedRating = starIndex;
                          });
                        },
                        icon: Icon(
                          starIndex <= selectedRating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 34.sp,
                        ),
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'إلغاء',
                    style: GoogleFonts.cairo(color: Colors.white54),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    AppShareService.showInviteBottomSheet(context, fromRating: true);
                  },
                  icon: const Icon(Icons.share_rounded, size: 16, color: Color(0xFF64D2FF)),
                  label: Text(
                    'مشاركة التطبيق 🎁',
                    style: GoogleFonts.cairo(color: const Color(0xFF64D2FF), fontSize: 12.sp),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    if (selectedRating >= 4) {
                      await requestReview();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'شكراً جزيلاً لتقييمك الرائع! 🤍',
                              style: GoogleFonts.cairo(),
                            ),
                            backgroundColor: const Color(0xFF102C3B),
                          ),
                        );
                        Future.delayed(const Duration(milliseconds: 600), () {
                          if (context.mounted) {
                            AppShareService.showInviteBottomSheet(context, fromRating: true);
                          }
                        });
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'شكراً لملاحظاتك! نعمل دائماً على تحسين التطبيق.',
                              style: GoogleFonts.cairo(),
                            ),
                            backgroundColor: Colors.orange.shade800,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    'إرسال التقييم',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Request in-app review dialog or open store listing if unavailable
  static Future<void> requestReview() async {
    try {
      final isAvailable = await _inAppReview.isAvailable();
      if (isAvailable) {
        await _inAppReview.requestReview();
      } else {
        await openStoreListing();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasReviewedKey, true);
    } catch (e) {
      debugPrint('AppReviewService Error: $e');
      await openStoreListing();
    }
  }

  /// Open Google Play / Huawei AppGallery / Apple App Store page directly with URL fallback
  static Future<void> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasReviewedKey, true);
    } catch (e) {
      debugPrint('AppReviewService openStoreListing Error: $e');
      await PlatformServiceHub.openCurrentStoreListing();
    }
  }

  /// Auto-prompt for review after user completes milestones
  static Future<void> checkAndPromptAutoReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasReviewed = prefs.getBool(_hasReviewedKey) ?? false;
      if (hasReviewed) return;

      int count = prefs.getInt(_reviewPromptCountKey) ?? 0;
      count++;
      await prefs.setInt(_reviewPromptCountKey, count);

      if (count == 3 || count == 10 || count == 25 || count == 50) {
        if (await _inAppReview.isAvailable()) {
          await _inAppReview.requestReview();
        }
      }
    } catch (e) {
      debugPrint('AppReviewService checkAndPromptAutoReview Error: $e');
    }
  }
}
