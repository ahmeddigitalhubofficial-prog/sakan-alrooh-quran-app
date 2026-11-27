import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class AppGradients {
  static const LinearGradient primaryBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.background,
      AppColors.emeraldDark,
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.cardDark,
      AppColors.emerald,
    ],
  );
}
