import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../common/glass_container.dart';

class ProgressSection extends StatelessWidget {
  final int completed;

  final int total;

  const ProgressSection({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تقدمك اليومي',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 16.h,
          ),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10.h,
            borderRadius: BorderRadius.circular(
              20.r,
            ),
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation(
              Colors.amber,
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Text(
            '$completed / $total مهام مكتملة',
            style: GoogleFonts.cairo(
              color: Colors.white70,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
