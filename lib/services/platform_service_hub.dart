import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'device_ecosystem_service.dart';
import 'auth_service.dart';

/// البوابة المركزية الموحدة لتوجيه وإدارة خدمات المنصات المختلفة
/// (Apple App Store / Huawei AppGallery / Google Play)
class PlatformServiceHub {
  static final PlatformServiceHub _instance = PlatformServiceHub._internal();
  factory PlatformServiceHub() => _instance;
  PlatformServiceHub._internal();

  static final DeviceEcosystemService _ecosystem = DeviceEcosystemService();

  /// ثابت تحديد المتجر وقت الترجمة عبر --dart-define=TARGET_STORE=apple (أو google أو huawei)
  /// يتيح لمحرك لغة Dart تفعيل خاصية الـ Tree-Shaking لحذف أي كود أو نصوص تخص المتاجر الأخرى
  static const String compileTimeTargetStore =
      String.fromEnvironment('TARGET_STORE', defaultValue: '');

  static bool get isCompileTimeApple => compileTimeTargetStore == 'apple';
  static bool get isCompileTimeHuawei => compileTimeTargetStore == 'huawei';
  static bool get isCompileTimeGoogle => compileTimeTargetStore == 'google';

  // --- روابط المتاجر الرسمية لتطبيق سكن الروح ---
  static const String googlePlayUrl =
      'https://play.google.com/store/apps/details?id=com.nooralhoda.official.app';

  static const String huaweiAppGalleryUrl =
      'https://appgallery.huawei.com/app/C118816285';

  static const String appleAppStoreUrl =
      'https://apps.apple.com/app/id6742398451';

  static const String huaweiAppMarketScheme =
      'appmarket://details?id=com.nooralhoda.official.app';

  /// رابط المتجر المناسب بحسب تحديد وقت البناء أو الكشف التلقائي للجهاز
  static String get currentStoreUrl {
    if (isCompileTimeApple) return appleAppStoreUrl;
    if (isCompileTimeHuawei) return huaweiAppGalleryUrl;
    if (isCompileTimeGoogle) return googlePlayUrl;

    switch (_ecosystem.currentEcosystem) {
      case DeviceEcosystem.apple:
        return appleAppStoreUrl;
      case DeviceEcosystem.huawei:
        return huaweiAppGalleryUrl;
      case DeviceEcosystem.google:
        return googlePlayUrl;
    }
  }

  /// اسم المتجر الحالي بالعربية
  static String get currentStoreName {
    if (isCompileTimeApple) return 'Apple App Store';
    if (isCompileTimeHuawei) return 'Huawei AppGallery';
    if (isCompileTimeGoogle) return 'Google Play';

    switch (_ecosystem.currentEcosystem) {
      case DeviceEcosystem.apple:
        return 'Apple App Store';
      case DeviceEcosystem.huawei:
        return 'Huawei AppGallery';
      case DeviceEcosystem.google:
        return 'Google Play';
    }
  }

  /// اسم مزود الحساب المناسب للمنصة (Apple ID / Huawei ID / Google)
  static String get currentAuthProviderName {
    switch (_ecosystem.currentEcosystem) {
      case DeviceEcosystem.apple:
        return 'Apple ID';
      case DeviceEcosystem.huawei:
        return 'Huawei ID';
      case DeviceEcosystem.google:
        return 'Google';
    }
  }

  /// فحص هل الحساب الحالي مرتبط بمزود هذه المنصة
  static bool get isCurrentPlatformLinked {
    switch (_ecosystem.currentEcosystem) {
      case DeviceEcosystem.apple:
        return AuthService.isLinkedWithApple;
      case DeviceEcosystem.huawei:
        return false;
      case DeviceEcosystem.google:
        return AuthService.isLinkedWithGoogle;
    }
  }

  /// فتح صفحة التطبيق في متجر المنصة الحالي مباشرة للتقييم أو التحديث
  static Future<bool> openCurrentStoreListing() async {
    try {
      if (_ecosystem.isHuawei) {
        // محاولة فتح تطبيق AppGallery مباشرة عبر المخطط الأصيل
        final Uri schemeUri = Uri.parse(huaweiAppMarketScheme);
        try {
          if (await launchUrl(schemeUri, mode: LaunchMode.externalApplication)) {
            return true;
          }
        } catch (_) {}
      }

      final Uri storeUri = Uri.parse(currentStoreUrl);
      return await launchUrl(storeUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('PlatformServiceHub: Failed to open store listing: $e');
    }
    return false;
  }

  /// توليد قائمة روابط المتاجر بصيغة مهيئة لرسائل المشاركة (مع العزل التام بحسب المنصة)
  static String generateStoreLinksShareText() {
    // إذا كان البناء مخصصاً لـ Apple، لا يُذكر سوى متجر أبل لتفادي رفض المراجعة
    if (isCompileTimeApple) {
      return '''• متجر Apple App Store:
$appleAppStoreUrl''';
    }

    // إذا كان البناء مخصصاً لـ Huawei
    if (isCompileTimeHuawei) {
      return '''• متجر Huawei AppGallery:
$huaweiAppGalleryUrl''';
    }

    // إذا كان البناء مخصصاً لـ Google Play
    if (isCompileTimeGoogle) {
      return '''• متجر Google Play:
$googlePlayUrl''';
    }

    // الوضع العام الحالي للمستخدمين: Google Play و Huawei AppGallery ورابط التحميل الشامل
    return '''• متجر Google Play (أندرويد):
$googlePlayUrl

• متجر Huawei AppGallery (هواوي):
$huaweiAppGalleryUrl

• رابط التحميل الشامل لكافة الأجهزة وقنواتنا:
https://linktr.ee/sakan.alrooh.app''';
  }
}
