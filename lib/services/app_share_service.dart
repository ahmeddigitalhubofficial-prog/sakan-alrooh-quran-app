// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'platform_service_hub.dart';

class AppShareService {
  static String get playStoreUrl => PlatformServiceHub.googlePlayUrl;
  static String get appGalleryUrl => PlatformServiceHub.huaweiAppGalleryUrl;
  static String get appStoreUrl => PlatformServiceHub.appleAppStoreUrl;

  /// نص الدعوة والترشيح المتقن بأسلوب إيماني جذاب متوافق مع كافة المنصات
  static String getShareMessage() {
    return '''🌸 *سكن الروح | رفيقك الإيماني الشامل* 🌸

قال رسول الله ﷺ: «مَن دَلَّ على خيرٍ فله مثلُ أجرِ فاعله»

أرشح لك تطبيق *«سكن الروح»*، ليكون لك رفيقاً إيمانياً وصدقة جارية مباركة بإذن الله (تطبيق مجاني خفيف وبدون إعلانات مزعجة):

📖 *القرآن الكريم كاملاً:* بتلاوات خاشعة وتفسير ميسر بدون إنترنت.
🕋 *مواقيت الصلاة الدقيقة:* مع صوت الأذان وبوصلة دقيقة للقبلة وشريط مواقيت مستمر.
📿 *حصن المسلم والأذكار:* أذكار الصباح والمساء والسبحة الإلكترونية الذكية.
📻 *إذاعات القرآن الكريم:* بث مباشر 24 ساعة من القاهرة ومكة والمدينة.
🏰 *قصر الجنة والسنن:* متتبع الـ 12 ركعة وصيام التطوع لتعمير يومك بالطاعة.
🕊️ *رفيق المشاعر والسكينة:* لمعالجة القلق والهم بآيات الطمأنينة والأدعية النبوية.
🤲 *إهداء الثواب والصدقة الجارية:* للأحباء المتوفين والمرضى.

📲 *حمّل التطبيق الآن مجاناً:*
${PlatformServiceHub.generateStoreLinksShareText()}

جعلنا الله وإياكم من الداعين إلى الخير والمستظلين ببركته 🤍''';
  }

  /// مشاركة التطبيق فوراً عبر قائمة تطبيقات الهاتف (واتساب، تيليجرام، فيسبوك، ...)
  static Future<void> shareApp() async {
    try {
      await Share.share(
        getShareMessage(),
        subject: 'تطبيق سكن الروح | رفيقك الإيماني الشامل',
      );
    } catch (e) {
      debugPrint('Error sharing app: $e');
    }
  }

  /// نسخ نص الدعوة والرابط للحافظة بنقرة واحدة
  static Future<void> copyShareMessage(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: getShareMessage()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
              const SizedBox(width: 10),
              Text(
                'تم نسخ رسالة ورابط الدعوة بنجاح! 📋✨',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF102C3B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// عرض نافذة الدعوة والمشاركة الفاخرة
  static void showInviteBottomSheet(BuildContext context, {bool fromRating = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            decoration: BoxDecoration(
              color: const Color(0xFF0D2232),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),

                  // Header Icon
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      fromRating ? Icons.favorite_rounded : Icons.share_rounded,
                      color: const Color(0xFFD4AF37),
                      size: 32.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Title
                  Text(
                    fromRating
                        ? 'تقبل الله منك وجزاك خيراً! 🤍'
                        : 'انشر الخير ولك مثل أجر فاعله 🎁',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFFD4AF37),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6.h),

                  // Subtitle
                  Text(
                    fromRating
                        ? 'هل تحب أن تشارك أجر التطبيق مع عائلتك وأصدقائك ليكون لك صدقة جارية في كل تسبيحة وتلاوة؟'
                        : 'شارك تطبيق «سكن الروح» مع أحبابك عبر الواتساب ومواقع التواصل واكسب أجر كل من يستفيد منه.',
                    style: GoogleFonts.cairo(
                      color: Colors.white70,
                      fontSize: 13.sp,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 18.h),

                  // Preview Card
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.format_quote_rounded,
                                color: Color(0xFF64D2FF), size: 20),
                            SizedBox(width: 6.w),
                            Text(
                              'معاينة رسالة الدعوة:',
                              style: GoogleFonts.cairo(
                                color: const Color(0xFF64D2FF),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '📖 المصحف كاملاً • 🕋 مواقيت الصلاة والأذان • 📿 الأذكار والسبحة • 📻 إذاعات القرآن 24/7 • 🏰 قصر الجنة...',
                          style: GoogleFonts.cairo(
                            color: Colors.white60,
                            fontSize: 11.sp,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 22.h),

                  // Action Buttons
                  Row(
                    children: [
                      // Share button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            shareApp();
                          },
                          icon: const Icon(Icons.share_rounded, size: 20),
                          label: Text(
                            'مشاركة الآن 📲',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 13.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),

                      // Copy link button
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          copyShareMessage(context);
                        },
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: Text(
                          'نسخ الرابط',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 13.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
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
  }
}
