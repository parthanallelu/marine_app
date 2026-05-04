import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────
// Maritime Elite Design System — Color Tokens
// ─────────────────────────────────────────────────

class AppColors {
  // ── Primary Brand ──
  static const Color primaryLight = Color(0xFF2563EB);   // Vibrant blue (light mode)
  static const Color primaryDark = Color(0xFF60A5FA);     // Bright blue (dark mode)
  static const Color primaryContainer = Color(0xFFDBEAFE); // Soft blue tint
  static const Color primaryContainerDark = Color(0xFF1E3A5F);

  // ── Legacy primary aliases (backwards compatibility) ──
  static const Color navyBlueBase = Color(0xFF0A2A66);
  static const Color navyBlueDark = Color(0xFF071C47);
  static const Color navyBlueLight = Color(0xFF1A3D80);
  static const Color navyBlueSurface = Color(0xFFE8EDF5);
  static const Color oceanBlue = Color(0xFF0066CC);
  static const Color oceanBlueSurface = Color(0xFFE6F0FF);

  // ── Accent ──
  static const Color gold = Color(0xFFD4A017);
  static const Color goldLight = Color(0xFFF5D77A);
  static const Color goldSurface = Color(0xFFFFF8E1);
  static const Color teal = Color(0xFF14B8A6);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color orange = Color(0xFFF97316);

  // ── Semantic ──
  static const Color success = Color(0xFF16A34A);
  static const Color successDark = Color(0xFF22C55E);
  static const Color successSurface = Color(0xFFDCFCE7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorDark = Color(0xFFEF4444);
  static const Color errorSurface = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color warningSurface = Color(0xFFFEF3C7);

  // ── Surfaces (Light Mode) ──
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLight = Color(0xFFF1F5F9);

  // ── Surfaces (Dark Mode) ──
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF161F30);
  static const Color surfaceContainerDark = Color(0xFF253448);

  // ── Text (Light Mode) ──
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textHintLight = Color(0xFF94A3B8);

  // ── Text (Dark Mode) ──
  static const Color textPrimaryDark = Color(0xFFE2E8F0);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textHintDark = Color(0xFF64748B);

  // ── Borders ──
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);
  static const Color borderCardDark = Color(0xFF2E3B4E);

  // ── Legacy aliases (backwards compatibility) ──
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFCBD5E1);
  static const Color textHint = Color(0xFF64748B);
  static const Color divider = Color(0xFF334155);
  static const Color border = Color(0xFF334155);

  // ── Semantic Status (backwards compatibility) ──
  static const Color present = Color(0xFF16A34A);
  static const Color absent = Color(0xFFDC2626);
  static const Color halfDay = Color(0xFFF59E0B);
  static const Color course11th = Color(0xFF1565C0);
  static const Color course12th = Color(0xFF6A1B9A);
  static const Color courseCrash = Color(0xFFBF360C);
  static const Color testPassed = Color(0xFF16A34A);
  static const Color testFailed = Color(0xFFDC2626);

  // ── Badge Backgrounds ──
  static const Color badgeHighBg = Color(0xFFFEE2E2);
  static const Color badgeMediumBg = Color(0xFFFEF3C7);
  static const Color badgeLowBg = Color(0xFFDCFCE7);
  static const Color badgeHighText = Color(0xFFDC2626);
  static const Color badgeMediumText = Color(0xFFD97706);
  static const Color badgeLowText = Color(0xFF16A34A);
}

// ─────────────────────────────────────────────────
// Maritime Elite Design System — Typography
// ─────────────────────────────────────────────────

class AppTextStyles {
  static TextStyle get _base => GoogleFonts.inter();

  // ── Display ──
  static TextStyle displayLarge = _base.copyWith(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5);
  static TextStyle displayMedium = _base.copyWith(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.3);

  // ── Headings ──
  static TextStyle headingLarge = _base.copyWith(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.2);
  static TextStyle headingMedium = _base.copyWith(fontSize: 18, fontWeight: FontWeight.w600);
  static TextStyle headingSmall = _base.copyWith(fontSize: 16, fontWeight: FontWeight.w600);

  // ── Body ──
  static TextStyle bodyLarge = _base.copyWith(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle bodyMedium = _base.copyWith(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle bodySmall = _base.copyWith(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4);

  // ── Labels ──
  static TextStyle labelLarge = _base.copyWith(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1);
  static TextStyle labelMedium = _base.copyWith(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.2);
  static TextStyle labelSmall = _base.copyWith(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.3);

  // ── Specialty ──
  static TextStyle statNumber = _base.copyWith(fontSize: 28, fontWeight: FontWeight.w700);
  static TextStyle buttonText = _base.copyWith(fontSize: 15, fontWeight: FontWeight.w600);
  static TextStyle caption = _base.copyWith(fontSize: 11, fontWeight: FontWeight.w400, letterSpacing: 0.2);
  static TextStyle gradeLarge = _base.copyWith(fontSize: 48, fontWeight: FontWeight.w700);
  static TextStyle overline = _base.copyWith(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8);
}

// ─────────────────────────────────────────────────
// Maritime Elite Design System — Spacing (8px Grid)
// ─────────────────────────────────────────────────

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
  static const double sectionGap = 32.0;
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(horizontal: 20.0);
}

// ─────────────────────────────────────────────────
// Maritime Elite Design System — Radii
// ─────────────────────────────────────────────────

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double extraLarge = 28.0;
  static const double pill = 100.0;
  static const double circle = 100.0;

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(16.0));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius badgeRadius = BorderRadius.all(Radius.circular(20.0));
}

// ─────────────────────────────────────────────────
// Maritime Elite Design System — Shadows
// Navy-tinted ambient shadows for premium depth
// ─────────────────────────────────────────────────

class AppShadows {
  // Standard card shadow — whisper-soft navy tint
  static List<BoxShadow> get card => [
        BoxShadow(
          color: const Color(0xFF0F172A).withAlpha((0.05 * 255).round()),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  // Subtle shadow for minor elevation
  static List<BoxShadow> get subtle => [
        BoxShadow(
          color: const Color(0xFF0F172A).withAlpha((0.03 * 255).round()),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  // Elevated shadow for modals, overlays
  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: const Color(0xFF0F172A).withAlpha((0.08 * 255).round()),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];

  // Gold accent glow for premium elements
  static List<BoxShadow> get goldGlow => [
        BoxShadow(
          color: AppColors.gold.withAlpha((0.15 * 255).round()),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  // No shadow (for dark mode cards using borders instead)
  static List<BoxShadow> get none => [];
}

// ─────────────────────────────────────────────────
// Maritime Elite Design System — Durations & Curves
// ─────────────────────────────────────────────────

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve springCurve = Curves.elasticOut;
}

// ─────────────────────────────────────────────────
// Maritime Elite Design System — Theme Data
// ─────────────────────────────────────────────────

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        secondary: AppColors.teal,
        tertiary: AppColors.gold,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
        onSecondary: Colors.white,
        outline: AppColors.borderLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
        margin: EdgeInsets.zero,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimaryLight),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimaryLight),
        headlineLarge: AppTextStyles.headingLarge.copyWith(color: AppColors.textPrimaryLight),
        headlineMedium: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimaryLight),
        headlineSmall: AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimaryLight),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryLight),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.textHintLight),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimaryLight),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimaryLight),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimaryLight),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          textStyle: AppTextStyles.buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.borderLight, width: 1.5),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          textStyle: AppTextStyles.buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHintLight),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLight,
        selectedColor: AppColors.primaryLight,
        labelStyle: AppTextStyles.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        height: 64,
        indicatorColor: AppColors.primaryLight.withAlpha((0.1 * 255).round()),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSmall.copyWith(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTextStyles.labelSmall.copyWith(color: AppColors.textHintLight);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryLight, size: 24);
          }
          return const IconThemeData(color: AppColors.textHintLight, size: 24);
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.teal,
        tertiary: AppColors.gold,
        surface: AppColors.surfaceDark,
        error: AppColors.errorDark,
        onPrimary: Color(0xFF002A78),
        onSurface: AppColors.textPrimaryDark,
        onSecondary: Colors.white,
        outline: AppColors.borderDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: const BorderSide(color: AppColors.borderCardDark, width: 0.8),
        ),
        margin: EdgeInsets.zero,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimaryDark),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimaryDark),
        headlineLarge: AppTextStyles.headingLarge.copyWith(color: AppColors.textPrimaryDark),
        headlineMedium: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimaryDark),
        headlineSmall: AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimaryDark),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.textHintDark),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimaryDark),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimaryDark),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimaryDark),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: const Color(0xFF002A78),
          elevation: 0,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          textStyle: AppTextStyles.buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimaryDark,
          side: const BorderSide(color: AppColors.borderCardDark, width: 1.5),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          textStyle: AppTextStyles.buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.borderCardDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.borderCardDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHintDark),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedColor: AppColors.primaryDark,
        labelStyle: AppTextStyles.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
        side: const BorderSide(color: AppColors.borderCardDark, width: 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        height: 64,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSmall.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTextStyles.labelSmall.copyWith(color: AppColors.textHintDark);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryDark, size: 24);
          }
          return const IconThemeData(color: AppColors.textHintDark, size: 24);
        }),
      ),
    );
  }
}
