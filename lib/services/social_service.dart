import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// إدارة وروابط قنوات التواصل الرسمية لتطبيق سكن الروح
class SocialService {
  static const String universalBioUrl = 'https://linktr.ee/sakan.alrooh.app';
  static const String tiktokUrl = 'https://www.tiktok.com/@sakan.alrooh.app';
  static const String instagramUrl = 'https://www.instagram.com/sakan.alrooh.app';
  static const String facebookPageId = '61595603427400';
  static const String facebookUrl = 'https://www.facebook.com/profile.php?id=61595603427400';
  static const String youtubeUrl = 'https://www.youtube.com/@SakanAl-Rooh';

  /// فتح أي رابط خارجي بأمان داخل التطبيق المخصص له في الهاتف مع محاولات بديلة
  static Future<bool> openUrl(String urlString) async {
    try {
      final uri = Uri.parse(urlString);

      // 1. محاولة فتح الرابط في التطبيق الخارجي (تطبيق تيك توك، إنستغرام، فيسبوك أو المتصفح الافتراضي)
      final launchedExternal = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launchedExternal) return true;

      // 2. محاولة بديلة عبر الوضع الافتراضي للنظام
      final launchedDefault = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
      if (launchedDefault) return true;

      // 3. محاولة بديلة في متصفح مدمج داخل التطبيق
      return await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );
    } catch (e) {
      debugPrint('SocialService: Primary launch failed for $urlString: $e');
      try {
        final uri = Uri.parse(urlString);
        return await launchUrl(
          uri,
          mode: LaunchMode.inAppBrowserView,
        );
      } catch (fallbackError) {
        debugPrint('SocialService: All launch attempts failed for $urlString: $fallbackError');
      }
    }
    return false;
  }

  static Future<bool> openTikTok() => openUrl(tiktokUrl);

  /// فتح صفحة إنستغرام مع محاولة فتح التطبيق الأصيل أولاً
  static Future<bool> openInstagram() async {
    try {
      final nativeUri = Uri.parse('instagram://user?username=sakan.alrooh.app');
      final launchedNative = await launchUrl(
        nativeUri,
        mode: LaunchMode.externalApplication,
      );
      if (launchedNative) return true;
    } catch (_) {}

    return openUrl(instagramUrl);
  }

  /// فتح صفحة فيسبوك مع محاولة فتح تطبيق فيسبوك الأصيل أولاً
  static Future<bool> openFacebook() async {
    try {
      final nativeFbUri = Uri.parse('fb://page/$facebookPageId');
      final launchedNative = await launchUrl(
        nativeFbUri,
        mode: LaunchMode.externalApplication,
      );
      if (launchedNative) return true;
    } catch (_) {}

    return openUrl(facebookUrl);
  }

  /// فتح قناة يوتيوب الرسمية مع محاولة فتح تطبيق يوتيوب الأصيل أولاً
  static Future<bool> openYouTube() async {
    try {
      final nativeUri = Uri.parse('vnd.youtube://www.youtube.com/@SakanAl-Rooh');
      final launchedNative = await launchUrl(
        nativeUri,
        mode: LaunchMode.externalApplication,
      );
      if (launchedNative) return true;
    } catch (_) {}

    return openUrl(youtubeUrl);
  }

  static Future<bool> openUniversalBio() => openUrl(universalBioUrl);
}
