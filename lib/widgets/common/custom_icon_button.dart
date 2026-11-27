import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;

  final VoidCallback onTap;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(
        18.r,
      ),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(
            18.r,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}
