import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFF8F9FA);
  static const textPrimary = Color(0xFF191C1D);
  static const textSecondary = Color(0xFF464555);
  static const textMuted = Color(0xFF777587);
  static const cardBorder = Color(0xFFC7C4D8);
  static const inputFill = Color(0xFFF3F4F5);
  static const primary = Color(0xFF4F46E5);
  static const primaryDark = Color(0xFF3525CD);
  static const mintGlow = Color(0x336CF8BB);
  static const indigoGlow = Color(0x334F46E5);
}

abstract final class AppRadii {
  static const card = 24.0;
  static const pill = 999.0;
}

class AppTheme {
  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: AppColors.textPrimary,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.lexend().fontFamily,
    );

    return base.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        hintStyle: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 16),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
      textTheme: GoogleFonts.lexendTextTheme(base.textTheme).copyWith(
        headlineMedium: GoogleFonts.lexend(

          fontSize: 42,
          height: 1.2,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.75,
        ),
        bodyLarge: GoogleFonts.lexend(
          fontSize: 16,
          height: 1.4,
          color: AppColors.textSecondary,
        ),
        titleMedium: GoogleFonts.lexend(
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
