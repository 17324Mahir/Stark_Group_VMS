import 'package:flutter/material.dart';

/// Central theme configuration for the Stark VMS frontend.
/// Implements Material 3 desktop-first styling guidelines.
class AppTheme {
  // Brand seed colors
  static const Color primarySeed = Color(0xFF1E40AF); // Enterprise Slate Blue
  static const Color secondarySeed = Color(0xFF0284C7); // Crisp Cyan Accent

  // Status Colors
  static const Color statusActive = Color(0xFF10B981); // Emerald Green
  static const Color statusMaintenance = Color(0xFFF59E0B); // Amber Warning
  static const Color statusReserved = Color(0xFF3B82F6); // Sky Blue
  static const Color statusOutOfService = Color(0xFFEF4444); // Crimson Red

  // Light Palette neutrals
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Dark Palette neutrals
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);

  /// Light Material 3 Theme
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: Brightness.light,
      surface: lightSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightBg,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: Color(0xFF0F172A),
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: lightBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: statusOutOfService),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: lightBorder),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569),
          fontSize: 13,
        ),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return const Color(0xFFF8FAFC);
          }
          return lightSurface;
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
        space: 1,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: lightSurface,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Dark Material 3 Theme
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: Brightness.dark,
      surface: darkSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBg,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: statusOutOfService),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: darkBorder),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(const Color(0xFF1E293B)),
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF94A3B8),
          fontSize: 13,
        ),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return const Color(0xFF334155);
          }
          return darkSurface;
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: darkSurface,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
