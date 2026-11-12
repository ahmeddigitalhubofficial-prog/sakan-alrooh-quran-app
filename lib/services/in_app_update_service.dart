import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'device_ecosystem_service.dart';
import 'platform_service_hub.dart';

class InAppUpdateService {
  static final InAppUpdateService _instance = InAppUpdateService._internal();
  factory InAppUpdateService() => _instance;
  InAppUpdateService._internal();

  AppUpdateInfo? _updateInfo;
  bool _isChecking = false;

  /// فحص ثابت سريع
  static Future<void> checkForUpdates(BuildContext context, {bool showNoUpdateToast = false}) =>
      _instance.checkForUpdate(context: context, showNoUpdateToast: showNoUpdateToast);

  /// فحص يدوي للمتجر مع إشعار المستخدم
  static Future<void> manualCheckForUpdate(BuildContext context) =>
      checkForUpdates(context, showNoUpdateToast: true);

  /// فحص تلقائي ذكي موجه بحسب بيئة المنصة
  Future<void> checkForUpdate({BuildContext? context, bool showNoUpdateToast = false}) async {
    final ecosystem = DeviceEcosystemService();

    // 1. للأجهزة التي لا تعمل بمتجر Google Play (Apple / Huawei):
    if (!ecosystem.isGoogle || !Platform.isAndroid) {
      if (showNoUpdateToast && context != null && context.mounted) {
        // إذا كان الفحص يدوياً بطلب المستخدم، نوجهه لصفحة التطبيق في متجر جهازه
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.storefront_rounded, color: Colors.amber),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'جاري فتح صفحة التحديث على ${PlatformServiceHub.currentStoreName}...',
                    style: GoogleFonts.cairo(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        await PlatformServiceHub.openCurrentStoreListing();
      }
      return;
    }

    if (_isChecking) return;
    _isChecking = true;
    try {
      _updateInfo = await InAppUpdate.checkForUpdate();

      if (_updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
        // إذا كان التحديث مرن ومتاح، نقوم بطلب التحديث المرن في الخلفية
        if (_updateInfo!.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
          // عند اكتمال التنزيل في الخلفية
          await InAppUpdate.completeFlexibleUpdate();
        } else if (_updateInfo!.immediateUpdateAllowed) {
          // إذا كان التحديث إجباري وفوري
          await InAppUpdate.performImmediateUpdate();
        }
      } else if (showNoUpdateToast && context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
                const SizedBox(width: 10),
                Text(
                  'أنت تستخدم أحدث إصدار رسمي من التطبيق ✨',
                  style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint('InAppUpdate check error (ignored on dev/local builds): $e');
      if (showNoUpdateToast && context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'أنت على أحدث إصدار متاح حالياً.',
              style: GoogleFonts.cairo(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _isChecking = false;
    }
  }
}
