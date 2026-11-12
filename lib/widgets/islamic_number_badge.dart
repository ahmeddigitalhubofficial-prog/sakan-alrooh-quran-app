import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class IslamicNumberBadge extends StatelessWidget {
  final int number;
  final Color? color;
  final double size;

  const IslamicNumberBadge({
    super.key,
    required this.number,
    this.color,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).primaryColor;
    final badgeSize = size.w;

    return SizedBox(
      width: badgeSize,
      height: badgeSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // First rotated square
          Transform.rotate(
            angle: 0.0,
            child: Container(
              width: badgeSize * 0.75,
              height: badgeSize * 0.75,
              decoration: BoxDecoration(
                border: Border.all(
                  color: themeColor.withValues(alpha: 0.8),
                  width: 1.5.w,
                ),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          // Second rotated square (45 degrees)
          Transform.rotate(
            angle: 0.785398, // 45 degrees in radians
            child: Container(
              width: badgeSize * 0.75,
              height: badgeSize * 0.75,
              decoration: BoxDecoration(
                border: Border.all(
                  color: themeColor.withValues(alpha: 0.8),
                  width: 1.5.w,
                ),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          // Inner tiny dot pattern decoration or circle
          Container(
            width: badgeSize * 0.58,
            height: badgeSize * 0.58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeColor.withValues(alpha: 0.08),
            ),
          ),
          // Number in center
          Text(
            '$number',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: (size * 0.32).sp,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
