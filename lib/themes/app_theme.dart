import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.emerald,
    cardColor: AppColors.cardDark,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.emerald,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      secondary: AppColors.emerald,
    ),
  );
}
