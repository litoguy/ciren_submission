import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Brand constants — same in both themes
// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  // Maroon brand — unchanged across themes
  static const primary      = Color(0xFF8B1A2B);
  static const primaryDark  = Color(0xFF5E0F1A);
  static const primaryLight = Color(0xFFB02438);

  // Gold accent — unchanged across themes
  static const gold         = Color(0xFFC9922A);
  static const goldLight    = Color(0xFFE8B455);
  static const goldPale     = Color(0xFFFDF3E3);

  // Error
  static const error        = Color(0xFFE53935);

  // ── Dark theme surfaces ───────────────────────────────────────────────────
  static const darkBackground  = Color(0xFF0F0205);
  static const darkSurface     = Color(0xFF120508);
  static const darkCardIcon    = Color(0xFF1E0A0C);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecond  = Color(0x99FFFFFF);
  static const darkTextMuted   = Color(0x4DFFFFFF);

  // ── Light theme surfaces ──────────────────────────────────────────────────
  static const lightBackground  = Color(0xFFFAF6F2); // warm parchment — CU cream
  static const lightSurface     = Color(0xFFFFFFFF); // pure white cards
  static const lightCardIcon    = Color(0xFFF5EDE5); // warm tinted icon bg
  static const lightBorder      = Color(0xFFE8DDD5); // warm border
  static const lightTextPrimary = Color(0xFF1A0A0C); // near-black warm tint
  static const lightTextSecond  = Color(0xFF6B4045); // muted maroon
  static const lightTextMuted   = Color(0xFF9E8080); // placeholder warm grey

  // ── Light theme glow layers ───────────────────────────────────────────────
  // Soft mist effect: low opacity, wide radius, multi-stop fade
  // Transitions from pale burgundy/peach → translucent cream → transparent
  static const lightGlowPrimary = Color(0x338B1A2B); // maroon at 20% — very soft
  static const lightGlowGold    = Color(0x18C9922A); // gold at 9% — barely-there warmth
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme extension — access semantic tokens anywhere via context
// ─────────────────────────────────────────────────────────────────────────────
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  final Color background;
  final Color surface;
  final Color cardIcon;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color glowColor;       // primary radial glow
  final Color glowColorTwo;    // secondary glow (gold halo in light, transparent in dark)

  const AppColorScheme({
    required this.background,
    required this.surface,
    required this.cardIcon,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.glowColor,
    this.glowColorTwo = Colors.transparent,
  });

  static const dark = AppColorScheme(
    background:    AppColors.darkBackground,
    surface:       AppColors.darkSurface,
    cardIcon:      AppColors.darkCardIcon,
    border:        Color(0xFF2A0A0E),
    textPrimary:   AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecond,
    textMuted:     AppColors.darkTextMuted,
    glowColor:     Color(0x668B1A2B),   // maroon at 40%
    glowColorTwo:  Colors.transparent,
  );

  static const light = AppColorScheme(
    background:    AppColors.lightBackground,
    surface:       AppColors.lightSurface,
    cardIcon:      AppColors.lightCardIcon,
    border:        AppColors.lightBorder,
    textPrimary:   AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecond,
    textMuted:     AppColors.lightTextMuted,
    glowColor:     AppColors.lightGlowPrimary, // maroon at 80%
    glowColorTwo:  AppColors.lightGlowGold,    // gold halo at 27%
  );

  @override
  AppColorScheme copyWith({
    Color? background, Color? surface, Color? cardIcon, Color? border,
    Color? textPrimary, Color? textSecondary, Color? textMuted,
    Color? glowColor, Color? glowColorTwo,
  }) => AppColorScheme(
    background:    background    ?? this.background,
    surface:       surface       ?? this.surface,
    cardIcon:      cardIcon      ?? this.cardIcon,
    border:        border        ?? this.border,
    textPrimary:   textPrimary   ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textMuted:     textMuted     ?? this.textMuted,
    glowColor:     glowColor     ?? this.glowColor,
    glowColorTwo:  glowColorTwo  ?? this.glowColorTwo,
  );

  @override
  AppColorScheme lerp(AppColorScheme? other, double t) {
    if (other == null) return this;
    return AppColorScheme(
      background:    Color.lerp(background,    other.background,    t)!,
      surface:       Color.lerp(surface,       other.surface,       t)!,
      cardIcon:      Color.lerp(cardIcon,      other.cardIcon,      t)!,
      border:        Color.lerp(border,        other.border,        t)!,
      textPrimary:   Color.lerp(textPrimary,   other.textPrimary,   t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted:     Color.lerp(textMuted,     other.textMuted,     t)!,
      glowColor:     Color.lerp(glowColor,     other.glowColor,     t)!,
      glowColorTwo:  Color.lerp(glowColorTwo,  other.glowColorTwo,  t)!,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Convenience extension — Theme.of(context).app
// ─────────────────────────────────────────────────────────────────────────────
extension AppThemeContext on BuildContext {
  AppColorScheme get app =>
      Theme.of(this).extension<AppColorScheme>() ?? AppColorScheme.dark;
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTheme — produces ThemeData for light and dark modes
// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  static TextTheme _textTheme(Color primary, Color secondary, Color muted) =>
      TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 36, fontWeight: FontWeight.w700, color: primary),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 28, fontWeight: FontWeight.w700, color: primary),
        titleLarge: GoogleFonts.dmSans(
          fontSize: 18, fontWeight: FontWeight.w500, color: primary),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w400, color: primary),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14, fontWeight: FontWeight.w400, color: secondary),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 12, fontWeight: FontWeight.w400, color: muted),
      );

  // ── Dark ──────────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary:   AppColors.primary,
      secondary: AppColors.gold,
      surface:   AppColors.darkSurface,
      error:     AppColors.error,
    ),
    textTheme: _textTheme(
      AppColors.darkTextPrimary,
      AppColors.darkTextSecond,
      AppColors.darkTextMuted,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor:  AppColors.darkSurface,
      indicatorColor:   AppColors.primary.withValues(alpha: 0.25),
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected)
          ? GoogleFonts.dmSans(color: AppColors.gold,          fontSize: 11, fontWeight: FontWeight.w500)
          : GoogleFonts.dmSans(color: AppColors.darkTextMuted, fontSize: 11)),
      iconTheme: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected)
          ? const IconThemeData(color: AppColors.gold,          size: 22)
          : const IconThemeData(color: AppColors.darkTextMuted, size: 22)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor:  AppColors.darkSurface,
      foregroundColor:  AppColors.darkTextPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    dividerColor: AppColors.darkCardIcon,
    extensions: const [AppColorScheme.dark],
    useMaterial3: true,
  );

  // ── Light ─────────────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      primary:   AppColors.primary,
      secondary: AppColors.gold,
      surface:   AppColors.lightSurface,
      error:     AppColors.error,
    ),
    textTheme: _textTheme(
      AppColors.lightTextPrimary,
      AppColors.lightTextSecond,
      AppColors.lightTextMuted,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor:  AppColors.lightSurface,
      indicatorColor:   AppColors.primary.withValues(alpha: 0.12),
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected)
          ? GoogleFonts.dmSans(color: AppColors.gold,           fontSize: 11, fontWeight: FontWeight.w500)
          : GoogleFonts.dmSans(color: AppColors.lightTextMuted, fontSize: 11)),
      iconTheme: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected)
          ? const IconThemeData(color: AppColors.gold,           size: 22)
          : const IconThemeData(color: AppColors.lightTextMuted, size: 22)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor:  AppColors.lightSurface,
      foregroundColor:  AppColors.lightTextPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    dividerColor: AppColors.lightBorder,
    extensions: const [AppColorScheme.light],
    useMaterial3: true,
  );
}
