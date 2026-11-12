import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/locale_manager.dart';
import '../../core/localization/app_translations.dart';

class QuickLanguageButton extends StatelessWidget {
  final bool isCompact;

  const QuickLanguageButton({
    super.key,
    this.isCompact = false,
  });

  static void showLanguageSelectionSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    final localeManager = Provider.of<LocaleManager>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final currentCode = Provider.of<LocaleManager>(ctx).currentLocaleCode;

        return Directionality(
          textDirection: localeManager.isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            decoration: BoxDecoration(
              color: const Color(0xFF0F2634),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              border: Border(
                top: BorderSide(
                  color: AppColors.gold.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.language_rounded,
                          color: AppColors.gold,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ctx.tr('select_language'),
                              style: GoogleFonts.cairo(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              ctx.tr('language_desc'),
                              style: GoogleFonts.cairo(
                                fontSize: 12.sp,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, color: Colors.white54),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  ...LocaleManager.supportedLanguages.map((lang) {
                    final isSelected = lang.code == currentCode;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: InkWell(
                        onTap: () async {
                          HapticFeedback.mediumImpact();
                          await localeManager.setLocale(lang.code);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        borderRadius: BorderRadius.circular(16.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.gold.withValues(alpha: 0.18)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.gold
                                  : Colors.white.withValues(alpha: 0.1),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                lang.flag,
                                style: TextStyle(fontSize: 24.sp),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang.nativeName,
                                      style: GoogleFonts.cairo(
                                        fontSize: 15.sp,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        color: isSelected ? AppColors.gold : Colors.white,
                                      ),
                                    ),
                                    Text(
                                      lang.name,
                                      style: GoogleFonts.cairo(
                                        fontSize: 11.sp,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: const BoxDecoration(
                                    color: AppColors.gold,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.black,
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeManager = Provider.of<LocaleManager>(context);
    final currentLang = localeManager.currentLanguageInfo;

    return GestureDetector(
      onTap: () => showLanguageSelectionSheet(context),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8.w : 10.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentLang.flag,
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(width: 6.w),
            Text(
              currentLang.code.toUpperCase(),
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
            SizedBox(width: 2.w),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: AppColors.gold,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}
