import 'package:flutter/material.dart';

class JewelleryTheme {
  // Brand Colors
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFFFD700);
  static const Color cream = Color(0xFFF9F6F0);
  static const Color softBeige = Color(0xFFEFE9D9);
  static const Color charcoal = Color(0xFF333333);
  static const Color slate = Color(0xFF666666);
  static const Color white = Colors.white;

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF242424);
  static const Color darkOutline = Color(0xFF333333);
  static const Color offWhite = Color(0xFFE0E0E0);
  static const Color darkSlate = Color(0xFF9E9E9E);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);

  static ThemeData lightTheme(BuildContext context) {
    return _buildTheme(Brightness.light);
  }

  static ThemeData darkTheme(BuildContext context) {
    return _buildTheme(Brightness.dark);
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final Color background = isDark ? darkBackground : cream;
    final Color surface = isDark ? darkSurface : white;
    final Color card = isDark ? darkCard : white;
    final Color textColor = isDark ? offWhite : charcoal;
    final Color secondaryTextColor = isDark ? darkSlate : slate;
    final Color outline = isDark ? darkOutline : softBeige;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: gold,
      scaffoldBackgroundColor: background,
      fontFamily: 'Inter',
      canvasColor:
          background, // Added this for consistency in widgets using canvas
      colorScheme: ColorScheme.fromSeed(
        seedColor: gold,
        brightness: brightness,
        primary: gold,
        onPrimary: isDark ? charcoal : white,
        secondary: isDark ? gold : charcoal,
        onSecondary: isDark ? charcoal : white,
        surface: surface,
        onSurface: textColor,
        outline: outline,
        surfaceContainerLow: background,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: outline, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: textColor,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          fontFamily: 'Inter',
        ),
        titleLarge: TextStyle(
          color: textColor,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
        bodyLarge: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: 'Inter',
        ),
        bodyMedium: TextStyle(
          color: secondaryTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: 'Inter',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: isDark ? charcoal : white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: secondaryTextColor),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1),
      iconTheme: IconThemeData(color: textColor),
    );
  }
}
