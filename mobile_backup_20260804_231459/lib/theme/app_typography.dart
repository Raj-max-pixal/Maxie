import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme textTheme = GoogleFonts.interTextTheme();

  static final TextStyle displayLarge = textTheme.displayLarge!.copyWith(
    fontWeight: FontWeight.bold,
  );
  static final TextStyle displayMedium = textTheme.displayMedium!.copyWith(
    fontWeight: FontWeight.bold,
  );
  static final TextStyle displaySmall = textTheme.displaySmall!.copyWith(
    fontWeight: FontWeight.bold,
  );

  static final TextStyle headlineLarge = textTheme.headlineLarge!.copyWith(
    fontWeight: FontWeight.bold,
  );
  static final TextStyle headlineMedium = textTheme.headlineMedium!.copyWith(
    fontWeight: FontWeight.bold,
  );
  static final TextStyle headlineSmall = textTheme.headlineSmall!.copyWith(
    fontWeight: FontWeight.bold,
  );

  static final TextStyle titleLarge = textTheme.titleLarge!.copyWith(
    fontWeight: FontWeight.bold,
  );
  static final TextStyle titleMedium = textTheme.titleMedium;
  static final TextStyle titleSmall = textTheme.titleSmall;

  static final TextStyle bodyLarge = textTheme.bodyLarge;
  static final TextStyle bodyMedium = textTheme.bodyMedium;
  static final TextStyle bodySmall = textTheme.bodySmall;

  static final TextStyle labelLarge = textTheme.labelLarge;
  static final TextStyle labelMedium = textTheme.labelMedium;
  static final TextStyle labelSmall = textTheme.labelSmall;
}
