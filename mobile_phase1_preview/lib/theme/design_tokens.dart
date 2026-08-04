import 'package:flutter/material.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/theme/app_elevation.dart';
import 'package:maxie_mobile/theme/app_radius.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';

class DesignTokens {
  const DesignTokens._();

  static const Color brandPrimary = AppColors.seed;
  static const Color brandSecondary = AppColors.calmTeal;
  static const Color brandAccent = AppColors.warmCoral;

  static const double spaceXs = AppSpacing.xs;
  static const double spaceSm = AppSpacing.sm;
  static const double spaceMd = AppSpacing.md;
  static const double spaceLg = AppSpacing.lg;
  static const double spaceXl = AppSpacing.xl;

  static const double radiusSm = AppRadius.sm;
  static const double radiusMd = AppRadius.md;
  static const double radiusLg = AppRadius.lg;

  static const double elevationNone = AppElevation.none;
  static const double elevationSm = AppElevation.sm;
  static const double elevationMd = AppElevation.md;

  static const BoxShadow softShadow = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 24,
    offset: Offset(0, 12),
  );
}
