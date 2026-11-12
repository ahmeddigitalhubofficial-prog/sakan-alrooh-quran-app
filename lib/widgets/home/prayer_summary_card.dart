import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../common/glass_container.dart';

class PrayerSummaryCard extends StatelessWidget {
  final String prayerName;

  final String prayerTime;

  final String remaining;

  const PrayerSummaryCard({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        children: [
          Text(
            'الصلاة القادمة',
            style: GoogleFonts.cairo(
              color: Colors.white70,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(
            height: 8.h,
          ),
          Text(
            prayerName,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Text(
            prayerTime,
            style: GoogleFonts.cairo(
              color: Colors.amber,
              fontSize: 20.sp,
            ),
          ),
          SizedBox(
            height: 12.h,
          ),
          Text(
            'باقي $remaining',
            style: GoogleFonts.cairo(
              color: Colors.white70,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
