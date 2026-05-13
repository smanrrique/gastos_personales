import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  static TextTheme buildTextTheme({required bool isDark}) {
    final Color textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final Color textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    TextStyle base(double size, FontWeight weight,
        {double height = 1.3, Color? color, double letterSpacing = 0}) {
      return TextStyle(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: color ?? textPrimary,
      );
    }

    return TextTheme(
      displayLarge: base(36, FontWeight.w700, height: 1.15),
      displayMedium: base(30, FontWeight.w700, height: 1.2),
      displaySmall: base(26, FontWeight.w700, height: 1.2),
      headlineLarge: base(24, FontWeight.w700, height: 1.25),
      headlineMedium: base(22, FontWeight.w600, height: 1.25),
      headlineSmall: base(20, FontWeight.w600, height: 1.3),
      titleLarge: base(18, FontWeight.w600, height: 1.3),
      titleMedium: base(16, FontWeight.w600, height: 1.35),
      titleSmall: base(14, FontWeight.w600, height: 1.4),
      bodyLarge: base(16, FontWeight.w400, height: 1.5),
      bodyMedium: base(14, FontWeight.w400, height: 1.5, color: textSecondary),
      bodySmall: base(12, FontWeight.w400, height: 1.45, color: textSecondary),
      labelLarge: base(14, FontWeight.w600, height: 1.3, letterSpacing: 0.2),
      labelMedium: base(12, FontWeight.w600, height: 1.3, letterSpacing: 0.2),
      labelSmall: base(11, FontWeight.w500, height: 1.3,
          letterSpacing: 0.4, color: textSecondary),
    );
  }
}
