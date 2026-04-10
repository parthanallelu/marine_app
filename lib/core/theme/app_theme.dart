import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color navyBlueBase = Color(0xFF0A2A66);
  static const Color navyBlueDark = Color(0xFF071C47);
  static const Color navyBlueLight = Color(0xFF1A3D80);
  static const Color navyBlueSurface = Color(0xFFE8EDF5);
  static const Color oceanBlue = Color(0xFF0066CC);
  static const Color oceanBlueSurface = Color(0xFFE6F0FF);
  static const Color gold = Color(0xFFD4A017);
  static const Color goldSurface = Color(0xFFFFF8E1);
  static const Color success = Color(0xFF2E7D32);
  static const Color successSurface = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFC62828);
  static const Color errorSurface = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFF57F17);
  static const Color warningSurface = Color(0xFFFFF3E0);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  // Deprecated - will be removed after migration to theme-aware components
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFCBD5E1);
  static const Color textHint = Color(0xFF64748B);
  static const Color divider = Color(0xFF334155);
  static const Color border = Color(0xFF334155);
}

class AppTextStyles {
  static TextStyle get _base => GoogleFonts.poppins();

  static TextStyle displayLarge = _base.copyWith(fontSize: 32, fontWeight: FontWeight.w700);
  static TextStyle displayMedium = _base.copyWith(fontSize: 26, fontWeight: FontWeight.w700);
  static TextStyle headingLarge = _base.copyWith(fontSize: 22, fontWeight: FontWeight.w700);
  static TextStyle headingMedium = _base.copyWith(fontSize: 18, fontWeight: FontWeight.w600);
  static TextStyle headingSmall = _base.copyWith(fontSize: 16, fontWeight: FontWeight.w600);
  static TextStyle bodyLarge = _base.copyWith(fontSize: 15, fontWeight: FontWeight.w400);
  static TextStyle bodyMedium = _base.copyWith(fontSize: 14, fontWeight: FontWeight.w400);
  static TextStyle bodySmall = _base.copyWith(fontSize: 12, fontWeight: FontWeight.w400);
  static TextStyle labelLarge = _base.copyWith(fontSize: 14, fontWeight: FontWeight.w600);
  static TextStyle labelMedium = _base.copyWith(fontSize: 12, fontWeight: FontWeight.w500);
  static TextStyle labelSmall = _base.copyWith(fontSize: 11, fontWeight: FontWeight.w500);
  static TextStyle statNumber = _base.copyWith(fontSize: 28, fontWeight: FontWeight.w700);
  static TextStyle buttonText = _base.copyWith(fontSize: 15, fontWeight: FontWeight.w600);
  static TextStyle caption = _base.copyWith(fontSize: 11, fontWeight: FontWeight.w400);
  static TextStyle gradeLarge = _base.copyWith(fontSize: 48, fontWeight: FontWeight.w700);
}

class AppSpacing {
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double screenPadding = 20.0;
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double extraLarge = 28.0;
  static const double circle = 100.0;
  
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(16.0));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(12.0));
}

class AppShadows {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withAlpha((0.05 * 255).round()),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.navyBlueBase,
        secondary: AppColors.oceanBlue,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
        onSecondary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navyBlueBase,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      ),
       textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimaryLight),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimaryLight),
        headlineLarge: AppTextStyles.headingLarge.copyWith(color: AppColors.textPrimaryLight),
        headlineMedium: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimaryLight),
        headlineSmall: AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimaryLight),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryLight),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimaryLight),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimaryLight),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimaryLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navyBlueBase,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          textStyle: AppTextStyles.buttonText,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.navyBlueBase,
        secondary: AppColors.oceanBlue,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimaryDark,
        onSecondary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navyBlueBase,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimaryDark),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimaryDark),
        headlineLarge: AppTextStyles.headingLarge.copyWith(color: AppColors.textPrimaryDark),
        headlineMedium: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimaryDark),
        headlineSmall: AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimaryDark),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimaryDark),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimaryDark),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimaryDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navyBlueBase,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          textStyle: AppTextStyles.buttonText,
        ),
      ),
    );
  }
}
