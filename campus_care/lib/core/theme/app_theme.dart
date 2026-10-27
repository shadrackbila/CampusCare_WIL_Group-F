import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const navy = Color(0xFF071A38);
  static const ink = Color(0xFF0F2D5E);
  static const blue = Color(0xFF0B4AAE);
  static const skyTop = Color(0xFF2E7BD6);
  static const skyBottom = Color(0xFFDCEBFA);
  static const error = Color(0xFFB3261E);
  static const success = Color(0xFF2E7D32);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      primary: AppColors.blue,
      error: AppColors.error,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.skyBottom,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.navy),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.blue, width: 2),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    );
  }
}
