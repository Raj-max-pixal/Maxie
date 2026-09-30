import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_elevation.dart';
import 'package:maxie_mobile/theme/app_radius.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      secondary: AppColors.calmTeal,
      tertiary: AppColors.warmCoral,
      surface: Colors.white,
      error: AppColors.danger,
    );

    return _base(colorScheme).copyWith(
      scaffoldBackgroundColor: AppColors.lightScaffold,
      dividerColor: Colors.transparent,
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.dark,
      secondary: AppColors.calmTeal,
      tertiary: AppColors.warmCoral,
      surface: AppColors.darkSurface,
      error: AppColors.danger,
    );

    return _base(colorScheme).copyWith(
      scaffoldBackgroundColor: AppColors.darkScaffold,
      dividerColor: Colors.transparent,
    );
  }

  static ThemeData _base(ColorScheme colorScheme) {
    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      dividerColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: AppElevation.none,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.brightness == Brightness.dark
            ? AppColors.darkSurface
            : colorScheme.surface,
        elevation: AppElevation.none,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          elevation: AppElevation.none,
          foregroundColor: Colors.white,
          backgroundColor: AppColors.seed,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
          backgroundColor: Colors.white.withValues(alpha: 0.04),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white,
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.72),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.42),
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.55),
            width: 1.4,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.brightness == Brightness.dark
            ? AppColors.darkSurface.withValues(alpha: 0.94)
            : colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.06),
        selectedColor: colorScheme.primary.withValues(alpha: 0.22),
        disabledColor: Colors.white.withValues(alpha: 0.03),
        deleteIconColor: colorScheme.onSurface,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.primary,
        selectionColor: colorScheme.primary.withValues(alpha: 0.22),
        selectionHandleColor: colorScheme.primary,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          hoverColor: Colors.white.withValues(alpha: 0.08),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
        ),
      ),
    );
  }
}
