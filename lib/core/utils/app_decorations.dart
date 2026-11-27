import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppDecorations {
  static BoxDecoration card = BoxDecoration(
    color: AppColors.cardDark,
    borderRadius: BorderRadius.circular(
      22,
    ),
    border: Border.all(
      color: AppColors.gold.withValues(alpha: 0.08),
    ),
  );
}
