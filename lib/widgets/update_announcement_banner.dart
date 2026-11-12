import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

import '../screens/changelog_screen.dart';

class UpdateAnnouncementService {
  static const String _lastNotifiedVersionKey = 'last_notified_app_version';
  static const String _lastNotifiedPatchKey = 'last_notified_patch_number';

  /// فحص تلقائي ذكي وغير مزعج عند تشغيل التطبيق
  static Future<void> checkAndShowUpdateAnnouncement(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. فحص تحديث Google Play
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final savedVersion = prefs.getString(_lastNotifiedVersionKey);

      // 2. فحص باتش Shorebird
      int? currentPatch;
      try {
        final shorebird = ShorebirdCodePush();
        currentPatch = await shorebird.currentPatchNumber();
      } catch (_) {}
      final savedPatch = prefs.getInt(_lastNotifiedPatchKey);

      bool isGooglePlayUpdate = false;
      bool isShorebirdPatch = false;

      if (savedVersion != null && savedVersion != currentVersion) {
        isGooglePlayUpdate = true;
      }

      if (currentPatch != null && savedPatch != null && currentPatch > savedPatch) {
        isShorebirdPatch = true;
      }

      // حفظ القيم الحالية فوراً حتى لا يتكرر الظهور
      await prefs.setString(_lastNotifiedVersionKey, currentVersion);
      if (currentPatch != null) {
        await prefs.setInt(_lastNotifiedPatchKey, currentPatch);
      } else if (savedPatch == null) {
        await prefs.setInt(_lastNotifiedPatchKey, 0);
      }

      // إذا كان أول تثبيت على الإطلاق، نحفظ فقط ولا نزعج المستخدم
      if (savedVersion == null && savedPatch == null) {
        return;
      }

      if (!context.mounted) return;

      if (isGooglePlayUpdate || isShorebirdPatch) {
        _showNonIntrusiveBanner(
          context,
          isPatch: isShorebirdPatch,
          versionOrPatch: isShorebirdPatch ? '#$currentPatch' : 'v$currentVersion',
        );
      }
    } catch (e) {
      debugPrint('Error checking update announcement: $e');
    }
  }

  /// إظهار البانر العائم الأنيق والسريع
  static void _showNonIntrusiveBanner(
    BuildContext context, {
    required bool isPatch,
    required String versionOrPatch,
  }) {
    final title = isPatch
        ? 'تم تطبيق تحديث فوري بنجاح ($versionOrPatch) ✨'
        : 'تم تحديث سكن الروح بنجاح ($versionOrPatch) 🎉';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 7),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        backgroundColor: const Color(0xFF0F2636),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
            width: 1.2,
          ),
        ),
        elevation: 10,
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFFD4AF37),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                '• دقة مواقيت الصلاة وشريط الإشعارات المستمر\n• إضافة وتطوير ودجات الشاشة الرئيسية\n• تحسينات الأداء واستقرار التطبيق',
                style: GoogleFonts.cairo(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12.sp,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        action: SnackBarAction(
          label: 'عرض الجديد',
          textColor: const Color(0xFF64D2FF),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangelogScreen()),
            );
          },
        ),
      ),
    );
  }
}
