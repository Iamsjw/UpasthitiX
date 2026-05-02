import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Brand Colors ───────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryMuted = Color(0x996C63FF);
  static const Color primaryGlow = Color(0x336C63FF);
  static const Color secondary = Color(0xFF22D3EE);
  static const Color success = Color(0xFF22C55E);
  static const Color successMuted = Color(0x3322C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningMuted = Color(0x33F59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorMuted = Color(0x33EF4444);

  // ─── Dark Surface System ────────────────────────────────────────────────────
  static const Color background = Color(0xFF080818);
  static const Color backgroundSecondary = Color(0xFF0F0F2A);
  static const Color surface = Color(0x0DFFFFFF); // white 5%
  static const Color surfaceVariant = Color(0x14FFFFFF); // white 8%
  static const Color surfaceElevated = Color(0x1AFFFFFF); // white 10%
  static const Color border = Color(0x26FFFFFF); // white 15%
  static const Color borderMuted = Color(0x14FFFFFF); // white 8%

  // ─── Text Colors ────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // white 70%
  static const Color textMuted = Color(0x66FFFFFF); // white 40%
  static const Color textDisabled = Color(0x33FFFFFF); // white 20%

  // ─── Role Colors ────────────────────────────────────────────────────────────
  static const Color adminColor = Color(0xFFFF6B6B);
  static const Color teacherColor = Color(0xFF6C63FF);
  static const Color studentColor = Color(0xFF22D3EE);

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: backgroundSecondary,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onError: Colors.white,
      outline: border,
      outlineVariant: borderMuted,
    ),
    scaffoldBackgroundColor: background,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.2,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.3,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textMuted,
          letterSpacing: 0.4,
        ),
      ),
    ),
    appBarTheme: const AppBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
      labelStyle: const TextStyle(color: textMuted, fontSize: 14),
      hintStyle: const TextStyle(color: textDisabled, fontSize: 14),
      errorStyle: const TextStyle(color: error, fontSize: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: const DividerThemeData(
      color: borderMuted,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      selectedColor: primaryMuted,
      labelStyle: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: const BorderSide(color: border, width: 1),
    ),
  );

  // lightTheme required by contract — dark-only app, mirrors dark
  static ThemeData get lightTheme => darkTheme;
}