// privacy_policy_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/theme_manager.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppThemeManager>(context).currentTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'سياسة الخصوصية | Privacy Policy',
          style: GoogleFonts.cairo(
            color: theme.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.accentColor,
          labelColor: theme.accentColor,
          unselectedLabelColor: theme.subtitleColor,
          labelStyle: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
          tabs: const [
            Tab(text: 'العربية 🇸🇦'),
            Tab(text: 'English 🌐'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildArabicContent(theme),
          _buildEnglishContent(theme),
        ],
      ),
    );
  }

  Widget _buildArabicContent(dynamic theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(
            theme: theme,
            title: 'وثيقة سياسة الخصوصية وحماية البيانات',
            subtitle: 'تطبيق: سكن الروح (Sakan Al-Rooh)\nالمطور: Ahmed Digitalhub (Ahmed Ibrahem Mohamed)\nالبريد الرسمي: ahmed.digitalhub.official@gmail.com\nتاريخ آخر تحديث: سبتمبر 2026',
            icon: Icons.shield_rounded,
          ),
          SizedBox(height: 20.h),
          _buildSectionCard(
            theme: theme,
            title: '1. مقدمة والتزام الخصوصية',
            content:
                'نحن في تطبيق "سكن الروح" (Sakan Al-Rooh) المطور بواسطة Ahmed Digitalhub (Ahmed Ibrahem Mohamed) نولي خصوصية مستخدمينا الكرام أهمية قصوى. نلتزم بحماية بياناتك الشخصية وتوضيح كيفية جمع البيانات واستخدامها وفق أعلى المعايير القانونية وقواعد متاجر التطبيقات الرسمية (Google Play & Huawei AppGallery).',
          ),
          SizedBox(height: 14.h),
          _buildSectionCard(
            theme: theme,
            title: '2. البيانات التي نجمعها ولماذا نجمعها؟',
            content:
                '• بيانات الموقع الجغرافي (Location Data): يطلب التطبيق إذن الموقع بدقة (Fine/Coarse Location) فقط وفقط لحساب مواقيت الصلاة الفلكية حسب خطوط الطول والعرض وتوجيه بوصلة القبلة بالواقع المعزز. نحن لا نقوم برفع أو تتبع أو مشاركة موقعك الجغرافي مع أي خوادم خارجية.\n\n'
                '• بيانات التخزين المحلي (Local Storage): يتم حفظ تفضيلاتك (المدينة المحفوظة، آخر آية مقروءة، عدادات التسبيح، الثيم المختار) محلياً داخل جهازك عبر SharedPreferences لتوفير تجربة أوفلاين سريعة.\n\n'
                '• بيانات الأعطال والتحليلات (Crashlytics & Analytics): نستخدم خدمات Firebase Crashlytics و Analytics التابعة لشركة Google لرصد الأخطاء البرمجية والانهيارات غير المتوقعة لتحسين استقرار التطبيق. هذه البيانات مجهولة المصدر (Anonymous) وخالية من أي معرفات شخصية.\n\n'
                '• الكاميرا (Camera Permission): تُستخدم الكاميرا حصرياً وفقط لتشغيل ميزة القبلة بالواقع المعزز (AR Qibla) لعرض مجسم الكعبة. لا يتم تسجيل أو التقاط أو حفظ أي صور أو فيديوهات نهائياً.',
          ),
          SizedBox(height: 14.h),
          _buildSectionCard(
            theme: theme,
            title: '3. ما لا نفعله ببياناتك مطلقاً',
            content:
                '• لا نبيع أو نؤجر بياناتك لأي طرف ثالث نهائياً.\n'
                '• لا نعرض أي إعلانات تجارية موجهة أو غير موجهة داخل التطبيق؛ فالتطبيق صدقة جارية وخالٍ كلياً من الإعلانات.\n'
                '• لا نطلب بيانات مالية أو بنكية أو أرقام هواتف.',
          ),
          SizedBox(height: 14.h),
          _buildSectionCard(
            theme: theme,
            title: '4. الصلاحيات المطلوبة والتحكم بها',
            content:
                'يمكنك في أي وقت تفعيل أو إلغاء أي صلاحية (الموقع، الإشعارات، الكاميرا) من خلال إعدادات جهازك مباشرة. التطبيق يستمر في العمل في حال إيقاف الموقع عن طريق اختيار مدينتك يدوياً من قائمة المدن المتاحة.',
          ),
          SizedBox(height: 14.h),
          _buildSectionCard(
            theme: theme,
            title: '5. حقوق المستخدم وحذف البيانات',
            content:
                'يحق لأي مستخدم مسح كافة بياناته المحفوظة محلياً أو سحابياً من خلال الضغط على خيار "مسح كافة البيانات وإعادة التعيين" من داخل صفحة الإعدادات، أو بمراسلتنا مباشرة عبر البريد الإلكتروني.',
          ),
          SizedBox(height: 14.h),
          _buildSectionCard(
            theme: theme,
            title: '6. معلومات الاتصال بالمطور',
            content:
                'لأي استفسارات أو ملاحظات تتعلق بسياسة الخصوصية وحماية البيانات، يرجى التواصل مع المطور مباشرة عبر:\n'
                '• البريد الإلكتروني: ahmed.digitalhub.official@gmail.com\n'
                '• اسم التطبيق: سكن الروح - Sakan Al-Rooh\n'
                '• المطور: Ahmed Digitalhub (Ahmed Ibrahem Mohamed)',
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildEnglishContent(dynamic theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(
            theme: theme,
            title: 'Privacy Policy & Data Protection',
            subtitle: 'Application: Sakan Al-Rooh (سكن الروح)\nDeveloper: Ahmed Digitalhub (Ahmed Ibrahem Mohamed)\nOfficial Email: ahmed.digitalhub.official@gmail.com\nLast Updated: September 2026',
            icon: Icons.verified_user_rounded,
          ),
          SizedBox(height: 20.h),
          _buildSectionCard(
            theme: theme,
            title: '1. Introduction & Overview',
            content:
                'Sakan Al-Rooh (سكن الروح), developed by Ahmed Digitalhub (Ahmed Ibrahem Mohamed) ("we", "our", or "us"), is committed to protecting your privacy. This Privacy Policy explains how our mobile application handles user information in compliance with international data protection standards and official App Store guidelines (including Google Play and Huawei AppGallery).',
          ),
          SizedBox(height: 14.h),
          _buildSectionCard(
            theme: theme,
            title: '2. Information We Collect and Purpose',
            content:
                '• Location Information: We request device location (Fine and Coarse GPS) solely for calculating precise astronomical prayer times and pointing the Qibla compass direction. Location coordinates are processed locally and are NEVER transmitted, sold, or shared with third-party servers.\n\n'
                '• Local Storage Data: User preferences (selected theme, bookmark in Quran, tasbih counter records, saved city) are stored locally on your device using SharedPreferences to enable seamless offline experience.\n\n'
                '• Analytics and Diagnostics: We may use Google Firebase Crashlytics to monitor application crashes and ensure technical stability. This diagnostic data is completely anonymous and contains no personally identifiable information (PII).\n\n'
                '• Camera Access: The camera permission is requested exclusively for the Augmented Reality (AR) Qibla feature. No images or videos are captured, saved, or uploaded.',
          ),
          SizedBox(height: 14.h),
          _buildSectionCard(
            theme: theme,
            title: '3. Data Sharing and Third Parties',
            content:
                '• We DO NOT sell, rent, or lease any user data to third parties.\n'
                '• We DO NOT display commercial targeted advertisements.\n'
                '• We DO NOT collect personal identifiers, financial data, or phone numbers.',
          ),
          SizedBox(height: 14.h),
          _buildSectionCard(
            theme: theme,
            title: '4. Permissions & User Control',
            content:
                'Users retain full control over granted permissions (Location, Camera, Notifications) and can revoke them at any time via Android System Settings. If location is disabled, you can manually select your city from the prayer settings.',
          ),
          SizedBox(height: 14.h),
          _buildSectionCard(
            theme: theme,
            title: '5. Data Retention & Deletion Rights',
            content:
                'You have the right to request deletion of any stored data. You can erase all local data directly from the in-app Settings ("Reset App Data") or by contacting our developer support team via email.',
          ),
          SizedBox(height: 14.h),
          _buildSectionCard(
            theme: theme,
            title: '6. Developer Contact Information',
            content:
                'For any questions, concerns, or inquiries regarding this Privacy Policy, please contact us:\n'
                '• App Name: Sakan Al-Rooh (سكن الروح)\n'
                '• Developer Name: Ahmed Digitalhub (Ahmed Ibrahem Mohamed)\n'
                '• Support Email: ahmed.digitalhub.official@gmail.com',
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildHeaderCard({
    required dynamic theme,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: theme.accentColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black, size: 24.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    color: theme.accentColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    color: theme.textColor.withValues(alpha: 0.85),
                    fontSize: 12.sp,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required dynamic theme,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              color: theme.accentColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: GoogleFonts.cairo(
              color: theme.textColor.withValues(alpha: 0.8),
              fontSize: 12.5.sp,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}
