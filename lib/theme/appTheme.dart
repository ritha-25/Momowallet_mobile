import 'package:flutter/material.dart';

class AppColors {
  static const momoYellow = Color(0xFFFFCC00);
  static const dark = Color(0xFF1D1D1F);
  static const green = Color(0xFF28A745);
  static const red = Color(0xFFC0392B);
  static const bg = Color(0xFFF5F5F7);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        colorSchemeSeed: AppColors.momoYellow,
        scaffoldBackgroundColor: AppColors.bg,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.momoYellow,
          foregroundColor: AppColors.dark,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.momoYellow,
            foregroundColor: AppColors.dark,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
}