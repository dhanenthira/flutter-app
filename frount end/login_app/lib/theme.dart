import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFFF6B00);
  static const Color primaryContainer = Color(0xFFFF6B00);
  static const Color primaryFixed = Color(0xFFFFDBCC);
  static const Color primaryFixedDim = Color(0xFFFFB693);
  
  static const Color surface = Color(0xFFFBF9F8);
  static const Color background = Color(0xFFFBF9F8);
  static const Color onSurface = Color(0xFF1B1C1C);
  static const Color onSurfaceVariant = Color(0xFF5A4136);
  static const Color outlineVariant = Color(0xFFE2BFB0);
  
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: primaryContainer,
        surface: surface,
      ),
    );
  }
}
