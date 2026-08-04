import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_constants.dart';
import 'package:mobile/theme/app_typography.dart';

final lightThemeProvider = Provider((ref) => AppTheme.lightTheme);
final darkThemeProvider = Provider((ref) => AppTheme.darkTheme);

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColorLight,
    scaffoldBackgroundColor: AppColors.backgroundColorLight,
    cardColor: AppColors.cardColorLight,
    textTheme: AppTypography.textTheme.apply(
      bodyColor: AppColors.textColorLight,
      displayColor: AppColors.textColorLight,
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryColorLight,
      secondary: AppColors.accentColorLight,
      error: AppColors.errorColor,
    ),
    appBarTheme: AppBarTheme(
      elevation: AppConstants.elevation_0,
      backgroundColor: AppColors.backgroundColorLight,
      titleTextStyle: AppTypography.titleLarge.copyWith(color: AppColors.textColorLight),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius_12),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacing_16,
          horizontal: AppConstants.spacing_24,
        ),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColorDark,
    scaffoldBackgroundColor: AppColors.backgroundColorDark,
    cardColor: AppColors.cardColorDark,
    textTheme: AppTypography.textTheme.apply(
      bodyColor: AppColors.textColorDark,
      displayColor: AppColors.textColorDark,
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryColorDark,
      secondary: AppColors.accentColorDark,
      error: AppColors.errorColor,
    ),
    appBarTheme: AppBarTheme(
      elevation: AppConstants.elevation_0,
      backgroundColor: AppColors.backgroundColorDark,
      titleTextStyle: AppTypography.titleLarge.copyWith(color: AppColors.textColorDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius_12),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacing_16,
          horizontal: AppConstants.spacing_24,
        ),
      ),
    ),
  );
}
