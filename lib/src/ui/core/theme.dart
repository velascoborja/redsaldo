import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class EdenredColors {
  static const navyDark = Color(0xFF0F172A);
  static const navyMedium = Color(0xFF1E293B);
  static const redAlert = Color(0xFFF72717);
  static const redDark = Color(0xFFCF2E2E);
  static const cyanBrand = Color(0xFF0E8AFF);
  static const white = Color(0xFFFFFFFF);
  static const lightSlate = Color(0xFFF8FAFC);
  static const grayLight = Color(0xFFF6F6F6);
  static const borderGray = Color(0xFFCBD5E1);
  static const grayMedium = Color(0xFFB3B3B3);
  static const grayDark = Color(0xFF747474);
  static const slateMuted = Color(0xFF334155);
  static const slateLight = Color(0xFF94A3B8);
  static const brandLightBg = Color(0xFFF1F7FF);
  static const warning = Color(0xFFFCB900);
}

abstract final class EdenredTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: EdenredColors.redAlert,
      onPrimary: EdenredColors.white,
      primaryContainer: Color(0xFF131B2E),
      onPrimaryContainer: Color(0xFF7C839B),
      secondary: EdenredColors.navyDark,
      onSecondary: EdenredColors.white,
      secondaryContainer: EdenredColors.brandLightBg,
      onSecondaryContainer: EdenredColors.navyDark,
      tertiary: EdenredColors.cyanBrand,
      onTertiary: EdenredColors.white,
      tertiaryContainer: Color(0xFF001B3C),
      onTertiaryContainer: EdenredColors.cyanBrand,
      error: EdenredColors.redDark,
      onError: EdenredColors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),
      surface: EdenredColors.white,
      onSurface: EdenredColors.navyDark,
      surfaceContainerHighest: EdenredColors.grayLight,
      surfaceContainerHigh: Color(0xFFEAE7E9),
      surfaceContainer: Color(0xFFF0EDEF),
      surfaceContainerLow: Color(0xFFF6F3F5),
      surfaceContainerLowest: EdenredColors.white,
      onSurfaceVariant: EdenredColors.slateMuted,
      outline: EdenredColors.borderGray,
      outlineVariant: Color(0xFFC6C6CD),
      inverseSurface: Color(0xFF303032),
      onInverseSurface: Color(0xFFF3F0F2),
      inversePrimary: Color(0xFFBEC6E0),
    );

    final textTheme = TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: EdenredColors.navyDark,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: EdenredColors.navyDark,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: EdenredColors.navyDark,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: EdenredColors.navyDark,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: EdenredColors.navyDark,
      ),
      titleSmall: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: EdenredColors.navyDark,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: EdenredColors.navyDark,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: EdenredColors.navyDark,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: EdenredColors.grayDark,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: EdenredColors.white,
      ),
      labelMedium: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.28,
        color: EdenredColors.navyDark,
      ),
      labelSmall: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: EdenredColors.grayDark,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: EdenredColors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: EdenredColors.navyDark,
        foregroundColor: EdenredColors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: EdenredColors.white,
        ),
        iconTheme: const IconThemeData(color: EdenredColors.white),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: EdenredColors.redAlert,
          foregroundColor: EdenredColors.white,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const StadiumBorder(),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: EdenredColors.navyDark,
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: EdenredColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadowColor: const Color(0x1A000000),
      ),
      dividerTheme: const DividerThemeData(
        color: EdenredColors.borderGray,
        thickness: 1,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: EdenredColors.navyDark,
        textColor: EdenredColors.navyDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: EdenredColors.borderGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: EdenredColors.borderGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: EdenredColors.navyDark, width: 2),
        ),
      ),
    );
  }
}
