import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeHeader extends StatelessWidget {
  final String greeting;

  const HomeHeader({
    super.key,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: GoogleFonts.cairo(
            fontSize: 16.sp,
            color: Colors.white70,
          ),
        ),
        SizedBox(
          height: 6.h,
        ),
        Text(
          'نور الهدى',
          style: GoogleFonts.cairo(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(
          height: 8.h,
        ),
        Text(
          'رحلة إيمانية يومية 🤍',
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
}
