import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryOrange,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryOrange,
        secondary: AppColors.accentBlue,
        surface: AppColors.cardLight,
        error: AppColors.accentRed,
      ),
      dividerColor: AppColors.divider,
      cardTheme: const CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display.copyWith(color: AppColors.textPrimary),
        displayMedium: AppTextStyles.display.copyWith(color: AppColors.textPrimary),
        displaySmall: AppTextStyles.display.copyWith(color: AppColors.textPrimary),
        headlineMedium: AppTextStyles.heading.copyWith(color: AppColors.textPrimary),
        titleLarge: AppTextStyles.heading.copyWith(color: AppColors.textPrimary),
        titleMedium: AppTextStyles.subHead.copyWith(color: AppColors.textPrimary),
        bodyLarge: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        bodyMedium: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        bodySmall: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        labelLarge: AppTextStyles.button.copyWith(color: Colors.white),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cardLight,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.heading.copyWith(color: AppColors.primaryOrange),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardLight,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryOrange,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryOrange,
        secondary: AppColors.accentBlue,
        surface: AppColors.cardDark,
        error: AppColors.accentRed,
      ),
      dividerColor: AppColors.divider.withOpacity(0.2),
      cardTheme: const CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display.copyWith(color: Colors.white),
        displayMedium: AppTextStyles.display.copyWith(color: Colors.white),
        displaySmall: AppTextStyles.display.copyWith(color: Colors.white),
        headlineMedium: AppTextStyles.heading.copyWith(color: Colors.white),
        titleLarge: AppTextStyles.heading.copyWith(color: Colors.white),
        titleMedium: AppTextStyles.subHead.copyWith(color: Colors.white),
        bodyLarge: AppTextStyles.body.copyWith(color: Colors.white),
        bodyMedium: AppTextStyles.body.copyWith(color: Colors.white),
        bodySmall: AppTextStyles.caption.copyWith(color: Colors.white70),
        labelLarge: AppTextStyles.button.copyWith(color: Colors.white),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cardDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.heading.copyWith(color: AppColors.primaryOrangeLight),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        selectedItemColor: AppColors.primaryOrangeLight,
        unselectedItemColor: Colors.white60,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      offset: const Offset(0, 2),
      blurRadius: 8,
    )
  ];

  static List<BoxShadow> get floatShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.16),
      offset: const Offset(0, 4),
      blurRadius: 16,
    )
  ];
}
