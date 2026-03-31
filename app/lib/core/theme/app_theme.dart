import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background    = Color(0xFF0F0205);
  static const surface       = Color(0xFF120508);
  static const cardIcon      = Color(0xFF1E0A0C);
  static const primary       = Color(0xFF8B1A2B);
  static const primaryDark   = Color(0xFF5E0F1A);
  static const primaryLight  = Color(0xFFB02438);
  static const gold          = Color(0xFFC9922A);
  static const goldLight     = Color(0xFFE8B455);
  static const textPrimary   = Color(0xFFFFFFFF);
  static const textSecondary = Color(0x99FFFFFF);
  static const textMuted     = Color(0x4DFFFFFF);
  static const error         = Color(0xFFE53935);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.gold,
      surface: AppColors.surface,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.dmSans(
        fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted,
      ),
    ),
    useMaterial3: true,
  );
}
