import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color navyBlue = Color(0x0A2A66FF); // Correcting: 0xFF0A2A66
  // Wait, wait, I should use the hex provided. #0A2A66 -> 0xFF0A2A66
  
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
  static const Color background = Color(0xFFF4F6FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0D1B3E);
  static const Color textSecondary = Color(0xFF4A5578);
  static const Color textHint = Color(0xFF8F9BBF);
  static const Color divider = Color(0xFFE0E4EF);
  static const Color border = Color(0xFFCDD3E5);
  static const Color present = Color(0xFF2E7D32);
  static const Color absent = Color(0xFFC62828);
  static const Color halfDay = Color(0xFFF57F17);
  static const Color course11th = Color(0xFF1565C0);
  static const Color course12th = Color(0xFF6A1B9A);
  static const Color courseCrash = Color(0xFFBF360C);
  
  // Semantic Colors for Results
  static const Color testPassed = Color(0xFF1B5E20);
  static const Color testFailed = Color(0xFF7F0000);
}

class AppTextStyles {
  static TextStyle get _base => GoogleFonts.poppins();

  static TextStyle displayLarge = _base.copyWith(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle displayMedium = _base.copyWith(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle headingLarge = _base.copyWith(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle headingMedium = _base.copyWith(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle headingSmall = _base.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle bodyLarge = _base.copyWith(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static TextStyle bodyMedium = _base.copyWith(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle bodySmall = _base.copyWith(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textHint);
  static TextStyle labelLarge = _base.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle labelMedium = _base.copyWith(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary);
  static TextStyle labelSmall = _base.copyWith(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary);
  static TextStyle statNumber = _base.copyWith(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.navyBlueBase);
  static TextStyle buttonText = _base.copyWith(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white);
  static TextStyle caption = _base.copyWith(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textHint);
  
  // Custom variations for specific UI elements
  static TextStyle gradeLarge = _base.copyWith(fontSize: 48, fontWeight: FontWeight.w700, color: Colors.white);
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
  static const double circle = 100.0;
  
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(16.0));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(12.0));
}

class AppShadows {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: AppColors.navyBlueBase.withAlpha((0.07 * 255).round()),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get subtle => [
        BoxShadow(
          color: AppColors.navyBlueBase.withAlpha((0.05 * 255).round()),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: AppColors.navyBlueBase.withAlpha((0.12 * 255).round()),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get goldGlow => [
        BoxShadow(
          color: AppColors.gold.withAlpha((0.30 * 255).round()),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navyBlueBase,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navyBlueBase,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTextStyles.buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navyBlueBase,
          side: const BorderSide(color: AppColors.navyBlueBase, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTextStyles.buttonText.copyWith(color: AppColors.navyBlueBase),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.navyBlueBase, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.navyBlueSurface,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.navyBlueBase);
          }
          return const IconThemeData(color: AppColors.textHint);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSmall.copyWith(color: AppColors.navyBlueBase);
          }
          return AppTextStyles.labelSmall.copyWith(color: AppColors.textHint);
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.navyBlueDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
      ),
    );
  }
}
