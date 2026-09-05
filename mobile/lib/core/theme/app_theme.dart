import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42D4);
  static const Color primaryContainer = Color(0xFFE8E6FF);

  // Secondary palette
  static const Color secondary = Color(0xFFFF6B9D);
  static const Color secondaryLight = Color(0xFFFFA0C5);
  static const Color secondaryDark = Color(0xFFE04A7C);
  static const Color secondaryContainer = Color(0xFFFFE8F0);

  // Tertiary palette
  static const Color tertiary = Color(0xFF00C9A7);
  static const Color tertiaryLight = Color(0xFF5EF0D0);
  static const Color tertiaryDark = Color(0xFF00A080);
  static const Color tertiaryContainer = Color(0xFFD4FBF2);

  // Neutral
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color backgroundDark = Color(0xFF0F0F23);

  // Gradient colors
  static const Color gradientStart = Color(0xFF6C63FF);
  static const Color gradientMid = Color(0xFFFF6B9D);
  static const Color gradientEnd = Color(0xFF00C9A7);

  // Pet mood colors
  static const Color happy = Color(0xFFFFD93D);
  static const Color sad = Color(0xFF6C63FF);
  static const Color excited = Color(0xFFFF6B9D);
  static const Color hungry = Color(0xFFFF8C42);
  static const Color sleepy = Color(0xFFA0A0B8);
  static const Color curious = Color(0xFF00C9A7);
  static const Color thinking = Color(0xFF9D97FF);
  static const Color laughing = Color(0xFFFFD93D);
  static const Color celebrating = Color(0xFFFFD93D);

  // Status
  static const Color success = Color(0xFF00C9A7);
  static const Color warning = Color(0xFFFF8C42);
  static const Color error = Color(0xFFFF4757);
  static const Color info = Color(0xFF6C63FF);

  // Glass
  static const Color glassLight = Color(0x33FFFFFF);
  static const Color glassDark = Color(0x331A1A2E);
  static const Color glassBorder = Color(0x1FFFFFFF);
  static const Color glassShadow = Color(0x296C63FF);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryContainer,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.tertiaryContainer,
      onSurface: Color(0xFF1A1A2E),
      surfaceContainerHighest: Color(0xFFF0F0FF),
      onSurfaceVariant: Color(0xFF49454F),
      error: AppColors.error,
      outline: Color(0xFFCAC4D0),
      outlineVariant: Color(0xFFE7E0EC),
    ),
    textTheme: _buildTextTheme(),
    elevatedButtonTheme: _elevatedButtonTheme(),
    outlinedButtonTheme: _outlinedButtonTheme(),
    textButtonTheme: _textButtonTheme(),
    inputDecorationTheme: _inputDecorationTheme(),
    cardTheme: _cardThemeData(),
    chipTheme: _chipTheme(),
    bottomNavigationBarTheme: _bottomNavTheme(),
    navigationBarTheme: _navBarTheme(),
    floatingActionButtonTheme: _fabTheme(),
    dialogTheme: _dialogThemeData(),
    snackBarTheme: _snackBarTheme(),
    dividerTheme: _dividerTheme(),
    appBarTheme: _appBarTheme(),
    dropdownMenuTheme: _dropdownMenuTheme(),
    menuTheme: _menuTheme(),
    popupMenuTheme: _popupMenuTheme(),
    badgeTheme: _badgeTheme(),
    progressIndicatorTheme: _progressIndicatorTheme(),
    sliderTheme: _sliderTheme(),
    switchTheme: _switchTheme(),
    checkboxTheme: _checkboxTheme(),
    radioTheme: _radioTheme(),
    tooltipTheme: _tooltipTheme(),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryLight,
      onPrimary: const Color(0xFF1A1A2E),
      primaryContainer: AppColors.primaryDark.withValues(alpha: 0.4),
      secondary: AppColors.secondaryLight,
      onSecondary: const Color(0xFF1A1A2E),
      secondaryContainer: AppColors.secondaryDark.withValues(alpha: 0.4),
      tertiary: AppColors.tertiaryLight,
      onTertiary: const Color(0xFF1A1A2E),
      tertiaryContainer: AppColors.tertiaryDark.withValues(alpha: 0.4),
      surface: AppColors.surfaceDark,
      onSurface: const Color(0xFFE6E1E5),
      surfaceContainerHighest: const Color(0xFF2D2D4A),
      onSurfaceVariant: const Color(0xFFCAC4D0),
      error: AppColors.error,
      onError: Colors.white,
      outline: const Color(0xFF938F99),
      outlineVariant: const Color(0xFF49454F),
    ),
    textTheme: _buildDarkTextTheme(),
    elevatedButtonTheme: _elevatedButtonThemeDark(),
    outlinedButtonTheme: _outlinedButtonThemeDark(),
    textButtonTheme: _textButtonThemeDark(),
    inputDecorationTheme: _inputDecorationThemeDark(),
    cardTheme: _cardThemeDataDark(),
    chipTheme: _chipThemeDark(),
    bottomNavigationBarTheme: _bottomNavThemeDark(),
    navigationBarTheme: _navBarThemeDark(),
    floatingActionButtonTheme: _fabThemeDark(),
    dialogTheme: _dialogThemeDataDark(),
    snackBarTheme: _snackBarThemeDark(),
    dividerTheme: _dividerThemeDark(),
    appBarTheme: _appBarThemeDark(),
    dropdownMenuTheme: _dropdownMenuThemeDark(),
    menuTheme: _menuThemeDark(),
    popupMenuTheme: _popupMenuThemeDark(),
    badgeTheme: _badgeThemeDark(),
    progressIndicatorTheme: _progressIndicatorThemeDark(),
    sliderTheme: _sliderThemeDark(),
    switchTheme: _switchThemeDark(),
    checkboxTheme: _checkboxThemeDark(),
    radioTheme: _radioThemeDark(),
    tooltipTheme: _tooltipThemeDark(),
  );

  static TextTheme _buildTextTheme() {
    return GoogleFonts.poppinsTextTheme(TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 57, fontWeight: FontWeight.w700, letterSpacing: -0.25,
        color: const Color(0xFF1A1A2E),
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 45, fontWeight: FontWeight.w600, letterSpacing: 0,
        color: const Color(0xFF1A1A2E),
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 36, fontWeight: FontWeight.w600, letterSpacing: 0,
        color: const Color(0xFF1A1A2E),
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: 0,
        color: const Color(0xFF1A1A2E),
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: 0,
        color: const Color(0xFF1A1A2E),
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: 0,
        color: const Color(0xFF1A1A2E),
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 0,
        color: const Color(0xFF1A1A2E),
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15,
        color: const Color(0xFF1A1A2E),
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1,
        color: const Color(0xFF1A1A2E),
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5,
        color: const Color(0xFF1A1A2E),
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25,
        color: const Color(0xFF1A1A2E),
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4,
        color: const Color(0xFF49454F),
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1,
        color: const Color(0xFF1A1A2E),
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5,
        color: const Color(0xFF49454F),
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5,
        color: const Color(0xFF49454F),
      ),
    ));
  }

  static TextTheme _buildDarkTextTheme() {
    return GoogleFonts.poppinsTextTheme(TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 57, fontWeight: FontWeight.w700, letterSpacing: -0.25,
        color: const Color(0xFFE6E1E5),
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 45, fontWeight: FontWeight.w600, letterSpacing: 0,
        color: const Color(0xFFE6E1E5),
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 36, fontWeight: FontWeight.w600, letterSpacing: 0,
        color: const Color(0xFFE6E1E5),
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: 0,
        color: const Color(0xFFE6E1E5),
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: 0,
        color: const Color(0xFFE6E1E5),
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: 0,
        color: const Color(0xFFE6E1E5),
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 0,
        color: const Color(0xFFE6E1E5),
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15,
        color: const Color(0xFFE6E1E5),
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1,
        color: const Color(0xFFE6E1E5),
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5,
        color: const Color(0xFFE6E1E5),
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25,
        color: const Color(0xFFE6E1E5),
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4,
        color: const Color(0xFFCAC4D0),
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1,
        color: const Color(0xFFE6E1E5),
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5,
        color: const Color(0xFFCAC4D0),
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5,
        color: const Color(0xFFCAC4D0),
      ),
    ));
  }

  // Light component themes
  static ElevatedButtonThemeData _elevatedButtonTheme() => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );

  static OutlinedButtonThemeData _outlinedButtonTheme() => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );

  static TextButtonThemeData _textButtonTheme() => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );

  static InputDecorationTheme _inputDecorationTheme() => InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF0F0FF),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE7E0EC)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    labelStyle: GoogleFonts.poppins(color: const Color(0xFF49454F)),
    hintStyle: GoogleFonts.poppins(color: const Color(0xFFCAC4D0)),
  );

  static CardThemeData _cardThemeData() => CardThemeData(
    elevation: 0,
    color: AppColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    margin: const EdgeInsets.all(8),
  );

  static ChipThemeData _chipTheme() => ChipThemeData(
    backgroundColor: const Color(0xFFF0F0FF),
    selectedColor: AppColors.primaryContainer,
    labelStyle: GoogleFonts.poppins(fontSize: 12),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static BottomNavigationBarThemeData _bottomNavTheme() => const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: Color(0xFFCAC4D0),
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );

  static NavigationBarThemeData _navBarTheme() => NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: AppColors.primaryContainer,
    labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
    height: 65,
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary);
      }
      return GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFFCAC4D0));
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(size: 28, color: AppColors.primary);
      }
      return const IconThemeData(size: 24, color: Color(0xFFCAC4D0));
    }),
  );

  static FloatingActionButtonThemeData _fabTheme() => FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  static DialogThemeData _dialogThemeData() => DialogThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    elevation: 0,
  );

  static SnackBarThemeData _snackBarTheme() => SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    backgroundColor: const Color(0xFF1A1A2E),
  );

  static DividerThemeData _dividerTheme() => const DividerThemeData(
    color: Color(0xFFE7E0EC),
    thickness: 1,
    space: 1,
  );

  static AppBarTheme _appBarTheme() => AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 1,
    backgroundColor: Colors.transparent,
    foregroundColor: const Color(0xFF1A1A2E),
    titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E)),
  );

  static DropdownMenuThemeData _dropdownMenuTheme() => DropdownMenuThemeData(
    inputDecorationTheme: _inputDecorationTheme(),
  );

  static MenuThemeData _menuTheme() => MenuThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStateProperty.all(Colors.white),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      elevation: WidgetStateProperty.all(8),
    ),
  );

  static PopupMenuThemeData _popupMenuTheme() => PopupMenuThemeData(
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 8,
  );

  static BadgeThemeData _badgeTheme() => const BadgeThemeData(
    backgroundColor: AppColors.secondary,
    textColor: Colors.white,
  );

  static ProgressIndicatorThemeData _progressIndicatorTheme() => const ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearTrackColor: AppColors.primaryContainer,
    circularTrackColor: AppColors.primaryContainer,
  );

  static SliderThemeData _sliderTheme() => SliderThemeData(
    activeTrackColor: AppColors.primary,
    inactiveTrackColor: AppColors.primaryContainer,
    thumbColor: AppColors.primary,
    overlayColor: AppColors.primary.withValues(alpha: 0.12),
    valueIndicatorColor: AppColors.primary,
    valueIndicatorTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
  );

  static SwitchThemeData _switchTheme() => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primary;
      return const Color(0xFFCAC4D0);
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primary.withValues(alpha: 0.5);
      return const Color(0xFFE7E0EC);
    }),
  );

  static CheckboxThemeData _checkboxTheme() => CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primary;
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  );

  static RadioThemeData _radioTheme() => RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primary;
      return const Color(0xFFCAC4D0);
    }),
  );

  static TooltipThemeData _tooltipTheme() => TooltipThemeData(
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A2E),
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  );

  // Dark component themes
  static ElevatedButtonThemeData _elevatedButtonThemeDark() => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: const Color(0xFF1A1A2E),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );

  static OutlinedButtonThemeData _outlinedButtonThemeDark() => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryLight,
      side: const BorderSide(color: AppColors.primaryLight),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );

  static TextButtonThemeData _textButtonThemeDark() => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryLight,
      textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );

  static InputDecorationTheme _inputDecorationThemeDark() => InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2D2D4A),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF49454F)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    labelStyle: GoogleFonts.poppins(color: const Color(0xFFCAC4D0)),
    hintStyle: GoogleFonts.poppins(color: const Color(0xFF938F99)),
  );

  static CardThemeData _cardThemeDataDark() => CardThemeData(
    elevation: 0,
    color: AppColors.surfaceDark,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    margin: const EdgeInsets.all(8),
  );

  static ChipThemeData _chipThemeDark() => ChipThemeData(
    backgroundColor: const Color(0xFF2D2D4A),
    selectedColor: AppColors.primaryDark.withValues(alpha: 0.4),
    labelStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFFE6E1E5)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static BottomNavigationBarThemeData _bottomNavThemeDark() => const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1A1A2E),
    selectedItemColor: AppColors.primaryLight,
    unselectedItemColor: Color(0xFF938F99),
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );

  static NavigationBarThemeData _navBarThemeDark() => NavigationBarThemeData(
    backgroundColor: const Color(0xFF1A1A2E),
    indicatorColor: AppColors.primaryDark.withValues(alpha: 0.4),
    labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
    height: 65,
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryLight);
      }
      return GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF938F99));
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(size: 28, color: AppColors.primaryLight);
      }
      return const IconThemeData(size: 24, color: Color(0xFF938F99));
    }),
  );

  static FloatingActionButtonThemeData _fabThemeDark() => FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryLight,
    foregroundColor: const Color(0xFF1A1A2E),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  static DialogThemeData _dialogThemeDataDark() => DialogThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    elevation: 0,
    backgroundColor: AppColors.surfaceDark,
  );

  static SnackBarThemeData _snackBarThemeDark() => SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    backgroundColor: const Color(0xFFE6E1E5),
  );

  static DividerThemeData _dividerThemeDark() => const DividerThemeData(
    color: Color(0xFF49454F),
    thickness: 1,
    space: 1,
  );

  static AppBarTheme _appBarThemeDark() => AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 1,
    backgroundColor: Colors.transparent,
    foregroundColor: const Color(0xFFE6E1E5),
    titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFFE6E1E5)),
  );

  static DropdownMenuThemeData _dropdownMenuThemeDark() => DropdownMenuThemeData(
    inputDecorationTheme: _inputDecorationThemeDark(),
  );

  static MenuThemeData _menuThemeDark() => MenuThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStateProperty.all(const Color(0xFF2D2D4A)),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      elevation: WidgetStateProperty.all(8),
    ),
  );

  static PopupMenuThemeData _popupMenuThemeDark() => PopupMenuThemeData(
    color: const Color(0xFF2D2D4A),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 8,
  );

  static BadgeThemeData _badgeThemeDark() => const BadgeThemeData(
    backgroundColor: AppColors.secondaryLight,
    textColor: Color(0xFF1A1A2E),
  );

  static ProgressIndicatorThemeData _progressIndicatorThemeDark() => ProgressIndicatorThemeData(
    color: AppColors.primaryLight,
    linearTrackColor: AppColors.primaryDark.withValues(alpha: 0.4),
    circularTrackColor: AppColors.primaryDark.withValues(alpha: 0.4),
  );

  static SliderThemeData _sliderThemeDark() => SliderThemeData(
    activeTrackColor: AppColors.primaryLight,
    inactiveTrackColor: AppColors.primaryDark.withValues(alpha: 0.4),
    thumbColor: AppColors.primaryLight,
    overlayColor: AppColors.primaryLight.withValues(alpha: 0.12),
    valueIndicatorColor: AppColors.primaryLight,
    valueIndicatorTextStyle: GoogleFonts.poppins(color: const Color(0xFF1A1A2E), fontSize: 12),
  );

  static SwitchThemeData _switchThemeDark() => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primaryLight;
      return const Color(0xFF938F99);
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primaryLight.withValues(alpha: 0.5);
      return const Color(0xFF49454F);
    }),
  );

  static CheckboxThemeData _checkboxThemeDark() => CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primaryLight;
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(const Color(0xFF1A1A2E)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  );

  static RadioThemeData _radioThemeDark() => RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primaryLight;
      return const Color(0xFF938F99);
    }),
  );

  static TooltipThemeData _tooltipThemeDark() => TooltipThemeData(
    decoration: BoxDecoration(
      color: const Color(0xFFE6E1E5),
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: GoogleFonts.poppins(color: const Color(0xFF1A1A2E), fontSize: 12),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  );
}