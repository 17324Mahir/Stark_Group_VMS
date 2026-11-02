import 'package:flutter/material.dart';

/// Centralized design tokens and Material 3 theme for Stark Group VMS.
///
/// Implements a restrained, accessible business administration interface
/// with clear hierarchy and generous, predictable spacing.
class AppTheme {
  // Brand Palette: Deep Navy & Blue
  static const Color navy900 = Color(0xFF0F172A); // Main brand/sidebar navy
  static const Color navy800 = Color(0xFF1E293B); // Sidebar hover/borders
  static const Color navy700 = Color(0xFF334155); // Muted navy

  static const Color primaryBlue = Color(0xFF2563EB); // Primary actions & selected
  static const Color primaryBlueHover = Color(0xFF1D4ED8); // Active/pressed blue
  static const Color primaryBlueSubtle = Color(0xFFEFF6FF); // Selected tint

  // Neutral Background & Surfaces
  static const Color neutralBg = Color(0xFFF8FAFC); // Page background
  static const Color surfaceWhite = Colors.white; // Content cards & surfaces
  static const Color borderNeutral = Color(0xFFE2E8F0); // Subtle borders
  static const Color borderSubtle = Color(0xFFF1F5F9); // Table dividers

  // Typography Neutrals
  static const Color textDark = Color(0xFF0F172A); // High-contrast primary text
  static const Color textMuted = Color(0xFF64748B); // Secondary / helper text
  static const Color textDisabled = Color(0xFF94A3B8); // Inactive / placeholder

  // Feedback Colors
  static const Color errorRed = Color(0xFFDC2626); // Destructive / validation error
  static const Color errorRedBg = Color(0xFFFEF2F2); // Error alert background
  static const Color errorRedBorder = Color(0xFFFECACA); // Error alert border

  // Status Colors (Green, Amber, Neutral)
  static const Color statusActiveText = Color(0xFF15803D);
  static const Color statusActiveBg = Color(0xFFDCFCE7);
  static const Color statusActiveBorder = Color(0xFF86EFAC);

  static const Color statusInactiveText = Color(0xFF475569);
  static const Color statusInactiveBg = Color(0xFFF1F5F9);
  static const Color statusInactiveBorder = Color(0xFFCBD5E1);

  static const Color statusMaintenanceText = Color(0xFFB45309);
  static const Color statusMaintenanceBg = Color(0xFFFEF3C7);
  static const Color statusMaintenanceBorder = Color(0xFFFCD34D);

  // Spacing Scale Tokens
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // Radius Tokens
  static const double radiusSm = 4.0;
  static const double radiusMd = 6.0;
  static const double radiusLg = 8.0;

  /// Centralized Material 3 Theme for Stark Group VMS
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        surface: surfaceWhite,
        error: errorRed,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: neutralBg,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        foregroundColor: textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textDark),
        shape: Border(
          bottom: BorderSide(color: borderNeutral, width: 1),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: borderNeutral, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space16,
          vertical: space12,
        ),
        hintStyle: const TextStyle(
          color: textDisabled,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: borderNeutral, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: borderNeutral, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: errorRed, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: space16,
            vertical: space12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textDark,
          elevation: 0,
          side: const BorderSide(color: borderNeutral, width: 1),
          padding: const EdgeInsets.symmetric(
            horizontal: space16,
            vertical: space12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderNeutral,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
