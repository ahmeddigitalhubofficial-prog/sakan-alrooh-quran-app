import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle title = GoogleFonts.cairo(
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle subtitle = GoogleFonts.cairo(
    fontSize: 15.sp,
    color: Colors.white70,
  );

  static TextStyle body = GoogleFonts.cairo(
    fontSize: 16.sp,
    color: Colors.white,
  );
}
