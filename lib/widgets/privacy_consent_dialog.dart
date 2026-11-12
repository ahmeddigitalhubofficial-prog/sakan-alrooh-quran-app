// privacy_consent_dialog.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_colors.dart';
import '../screens/privacy_policy_screen.dart';

class PrivacyConsentDialog extends StatefulWidget {
  final VoidCallback onAccepted;

  const PrivacyConsentDialog({
    super.key,
    required this.onAccepted,
  });

  static Future<bool> isAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_accepted_privacy_policy') ?? false;
  }

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onAccepted,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PrivacyConsentDialog(
        onAccepted: () {
          Navigator.of(ctx).pop();
          onAccepted();
        },
      ),
    );
  }

  @override
  State<PrivacyConsentDialog> createState() => _PrivacyConsentDialogState();
}

class _PrivacyConsentDialogState extends State<PrivacyConsentDialog> {
  bool _isEnglish = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: const Color(0xFF0D1B2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
          side: BorderSide(
            color: AppColors.gold.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Directionality(
              textDirection: _isEnglish ? TextDirection.ltr : TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // شريط تبديل اللغة (عربي / English) لتسهيل الفحص على مراجعي هواوي
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          _isEnglish ? 'Huawei Verified' : 'معتمد رسمياً',
                          style: GoogleFonts.cairo(
                            fontSize: 10.sp,
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isEnglish = !_isEnglish;
                          });
                        },
                        borderRadius: BorderRadius.circular(16.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.language_rounded,
                                color: Colors.white,
                                size: 14.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                _isEnglish ? 'العربية 🇸🇦' : 'English 🌐',
                                style: GoogleFonts.cairo(
                                  fontSize: 11.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // الشعار والأيقونة
                  Container(
                    width: 54.w,
                    height: 54.w,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.gold,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // عنوان سياسة الخصوصية
                  Text(
                    _isEnglish
                        ? 'Privacy Policy & Terms of Service'
                        : 'سياسة الخصوصية وحماية البيانات',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // اسم التطبيق واسم المطور بوضوح وفق اشتراطات هواوي
                  Text(
                    _isEnglish
                        ? 'App: Sakan Al-Rooh (سكن الروح)'
                        : 'تطبيق: سكن الروح (Sakan Al-Rooh)',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _isEnglish
                        ? 'Developer: Ahmed Digitalhub (Ahmed Ibrahem Mohamed)'
                        : 'المطور: Ahmed Digitalhub (Ahmed Ibrahem Mohamed)',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 10.5.sp,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // صندوق البنود التوضيحية
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPoint(
                          icon: Icons.location_on_rounded,
                          text: _isEnglish
                              ? 'Location (GPS): Used strictly on-device to calculate astronomical prayer times & Qibla. Never uploaded or shared.'
                              : 'الموقع الجغرافي (GPS): يُستخدم محلياً فقط لحساب مواقيت الصلاة واتجاه القبلة، ولا يتم حفظه على خوادم خارجية.',
                        ),
                        SizedBox(height: 8.h),
                        _buildPoint(
                          icon: Icons.mic_rounded,
                          text: _isEnglish
                              ? 'Microphone (Voice): Used solely for optional Quran recitation self-training. Recordings remain local on device.'
                              : 'الميكروفون والتسجيل: يُطلب فقط في ميزة تسميع وتدريب تلاوة القرآن وتبقى التسجيلات مؤقتة محلياً.',
                        ),
                        SizedBox(height: 8.h),
                        _buildPoint(
                          icon: Icons.storage_rounded,
                          text: _isEnglish
                              ? 'Storage & Media: Used to cache audio recitations for offline use and save generated cards to gallery.'
                              : 'التخزين والوسائط: لحفظ تلاوات المصحف للاستماع بدون إنترنت وتخزين بطاقات الآيات في المعرض.',
                        ),
                        SizedBox(height: 8.h),
                        _buildPoint(
                          icon: Icons.cloud_sync_rounded,
                          text: _isEnglish
                              ? 'Huawei ID / Cloud Sync: Optional service to safely synchronize your reading bookmarks and worship counters.'
                              : 'حساب هواوي والمزامنة: خدمة اختيارية لمزامنة علامات المصحف وأذكارك سحابياً بأمان.',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // زر قراءة السياسة الكاملة
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.gold,
                      size: 15.sp,
                    ),
                    label: Text(
                      _isEnglish
                          ? 'Read Full Privacy Policy & User Agreement ↗'
                          : 'قراءة سياسة الخصوصية واتفاقية الاستخدام بالتفصيل ↗',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5.sp,
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // أزرار الموافقة والرفض
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: () {
                            SystemNavigator.pop();
                          },
                          child: Text(
                            _isEnglish ? 'Disagree & Exit' : 'رفض والخروج',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('has_accepted_privacy_policy', true);
                            widget.onAccepted();
                          },
                          child: Text(
                            _isEnglish ? 'Agree & Continue ✓' : 'موافق والمتابعة ✓',
                            style: GoogleFonts.cairo(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
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
      ),
    );
  }

  Widget _buildPoint({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.gold, size: 16.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
