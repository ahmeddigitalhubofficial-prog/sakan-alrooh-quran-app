import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;

  final String hint;

  final IconData? icon;

  const CustomTextField({
    super.key,
    this.controller,
    required this.hint,
    this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white70,
          fontSize: 14.sp,
        ),
        prefixIcon: icon != null
            ? Icon(
                icon,
                color: Colors.white70,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withValues(
          alpha: 0.05,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            18.r,
          ),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
