import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class AppShadows {
  static List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: AppColors.gold
        ..withValues(
          alpha: 0.15,
        ),
      blurRadius: 20,
      spreadRadius: 1,
      offset: const Offset(
        0,
        8,
      ),
    ),
  ];
}
