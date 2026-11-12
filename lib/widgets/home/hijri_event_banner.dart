// hijri_event_banner.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/theme_manager.dart';

class HijriEventBanner extends StatefulWidget {
  final AppTheme theme;

  const HijriEventBanner({
    super.key,
    required this.theme,
  });

  @override
  State<HijriEventBanner> createState() => _HijriEventBannerState();
}

class _HijriEventBannerState extends State<HijriEventBanner> {
  String? _eventText;
  IconData _eventIcon = Icons.auto_awesome_rounded;
  Color _eventColor = const Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    _calculateUpcomingEvent();
  }

  Future<void> _calculateUpcomingEvent() async {
    final prefs = await SharedPreferences.getInstance();
    final hijriOffset = prefs.getInt('hijri_offset') ?? 0;

    final now = DateTime.now();
    final targetDate = now.add(Duration(days: hijriOffset));
    final hijri = HijriCalendar.fromDate(targetDate);

    final hDay = hijri.hDay;
    final hMonth = hijri.hMonth;

    String title = '';
    IconData icon = Icons.star_rounded;
    Color color = widget.theme.accentColor;

    // 1. الجمعة
    if (now.weekday == DateTime.friday) {
      title = 'اليوم الجمعة المباركة 🕌: لا تنس قراءة سورة الكهف والصلاة على النبي ﷺ وتحري ساعة الإجابة!';
      icon = Icons.mosque_rounded;
      color = const Color(0xFF00B0FF);
    }
    // 2. الإثنين والخميس
    else if (now.weekday == DateTime.monday || now.weekday == DateTime.thursday) {
      final dayName = now.weekday == DateTime.monday ? 'الإثنين' : 'الخميس';
      title = 'اليوم $dayName 🌙: تذَكّر صيام السنة وتجديد النية!';
      icon = Icons.nights_stay_rounded;
      color = const Color(0xFFFFB74D);
    }
    // 3. الأيام البيض
    else if ((hDay >= 12 && hDay <= 15) && hMonth != 12) {
      if (hDay == 12) {
        title = 'غداً تبدأ الأيام البيض (13، 14، 15 هـ) 🌕: جهز نفسك لصيام النوافل والمغفرة!';
      } else {
        title = 'اليوم من الأيام البيض المباركة (يوم $hDay هـ) 🌕: هنيئاً للصائمين والذاكرين!';
      }
      icon = Icons.wb_sunny_rounded;
      color = const Color(0xFFFFD54F);
    }
    // 4. رمضان
    else if (hMonth == 9) {
      title = 'شهر رمضان المبارك (يوم $hDay) 🌙: تقبل الله صيامكم وقيامكم وطاعاتكم!';
      icon = Icons.nightlight_round;
      color = const Color(0xFF81C784);
    }
    // 5. العشر الأوائل من ذي الحجة
    else if (hMonth == 12 && hDay <= 9) {
      if (hDay == 9) {
        title = 'اليوم يوم عرفة المبارك 🤲: أفضل أيام السنة والدعاء فيه مستجاب، كفّارة سنة ماضية وباقية!';
        icon = Icons.favorite_rounded;
        color = const Color(0xFFE57373);
      } else {
        title = 'أيام العشر من ذي الحجة 🕋: أكثروا من التكبير والتحميد والتهليل وصيام النوافل!';
        icon = Icons.auto_awesome_rounded;
        color = const Color(0xFFBA68C8);
      }
    }
    // 6. عاشوراء وتاسوعاء
    else if (hMonth == 1 && (hDay == 8 || hDay == 9 || hDay == 10)) {
      title = 'أيام تاسوعاء وعاشوراء 🌙: صيام يوم عاشوراء يكفر السنة الماضية!';
      icon = Icons.star_rounded;
      color = const Color(0xFF4DD0E1);
    }
    // 7. الافتراضي الجميل
    else {
      title = 'حافظ على أذكارك ووردك اليومي لتكون في معية الله وحفظه طوال اليوم 🌿';
      icon = Icons.auto_awesome_rounded;
      color = widget.theme.accentColor;
    }

    if (mounted) {
      setState(() {
        _eventText = title;
        _eventIcon = icon;
        _eventColor = color;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_eventText == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: widget.theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: _eventColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: _eventColor.withValues(alpha: 0.08),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: _eventColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _eventIcon,
              color: _eventColor,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              _eventText!,
              style: GoogleFonts.cairo(
                color: widget.theme.textColor,
                fontSize: 12.5.sp,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
