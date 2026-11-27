import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';

class IslamicButton extends StatelessWidget {
  final String text;

  final VoidCallback onPressed;

  final IconData? icon;

  final Color? backgroundColor;

  final Color? foregroundColor;

  const IslamicButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.gold,
        foregroundColor: foregroundColor ?? Colors.black,
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            18,
          ),
        ),
      ),
      onPressed: onPressed,
      icon: icon != null ? Icon(icon) : const SizedBox(),
      label: Text(
        text,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
