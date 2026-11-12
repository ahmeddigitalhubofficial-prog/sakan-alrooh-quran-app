import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GlowContainer extends StatelessWidget {
  final Widget child;

  const GlowContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.04,
        ),
        borderRadius: BorderRadius.circular(
          22.r,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(
              alpha: 0.05,
            ),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}
