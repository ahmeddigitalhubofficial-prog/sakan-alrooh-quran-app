import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCard extends StatelessWidget {
  final Widget child;

  final EdgeInsetsGeometry? padding;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: padding ??
          EdgeInsets.all(
            18.w,
          ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(
          22.r,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: child,
    );
  }
}
