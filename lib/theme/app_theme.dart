import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const fire    = Color(0xFFFF4D00);
  static const ember   = Color(0xFFFF7A30);
  static const glow    = Color(0xFFFFB067);
  static const ink     = Color(0xFF0A0805);
  static const ink2    = Color(0xFF141008);
  static const ash     = Color(0xFF1E1810);
  static const chalk   = Color(0xFFF8F0E8);
  static const dust    = Color(0x72F8F0E8);
  static const warm    = Color(0xFFC8BAB0);
  static const glass   = Color(0x0FFFFFFF);
  static const border  = Color(0x1AFFFFFF);
  static const green   = Color(0xFF4CAF50);

  static const gradient = LinearGradient(
    colors: [fire, ember],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const bgGradient = LinearGradient(
    colors: [Color(0xFF0D0A07), ink],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.ink,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.fire,
      surface: AppColors.ink2,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.glass,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.fire),
      ),
      hintStyle: const TextStyle(color: AppColors.dust),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}

// ── Text Styles ──────────────────────────────────────────────────────────────
class AppText {
  static TextStyle h1(BuildContext ctx, {Color? color}) =>
    GoogleFonts.playfairDisplay(
      fontSize: 32, fontWeight: FontWeight.w900,
      color: color ?? AppColors.chalk, height: 1.1,
    );

  static TextStyle h1Italic(BuildContext ctx, {Color? color}) =>
    GoogleFonts.playfairDisplay(
      fontSize: 32, fontWeight: FontWeight.w900,
      fontStyle: FontStyle.italic,
      color: color ?? AppColors.fire, height: 1.1,
    );

  static TextStyle h2(BuildContext ctx, {Color? color}) =>
    GoogleFonts.playfairDisplay(
      fontSize: 24, fontWeight: FontWeight.w900,
      color: color ?? AppColors.chalk,
    );

  static TextStyle body(BuildContext ctx, {Color? color}) =>
    GoogleFonts.dmSans(
      fontSize: 15, fontWeight: FontWeight.w400,
      color: color ?? AppColors.chalk,
    );

  static TextStyle small(BuildContext ctx, {Color? color}) =>
    GoogleFonts.dmSans(
      fontSize: 12, fontWeight: FontWeight.w400,
      color: color ?? AppColors.dust,
    );

  static TextStyle label(BuildContext ctx, {Color? color}) =>
    GoogleFonts.dmSans(
      fontSize: 11, fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      color: color ?? AppColors.dust,
    );
}
