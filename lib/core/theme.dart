import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Colour palette ────────────────────────────────────────
  static const Color _primaryDark    = Color(0xFF1A1F2E);
  static const Color _surfaceDark    = Color(0xFF242938);
  static const Color _cardDark       = Color(0xFF2D3447);
  static const Color _accentRed      = Color(0xFFE53935);
  static const Color _accentBlue     = Color(0xFF1E88E5);
  static const Color _textPrimary    = Color(0xFFECEFF1);
  static const Color _textSecondary  = Color(0xFF90A4AE);
  static const Color _divider        = Color(0xFF37474F);

  static const Color _primaryLight   = Color(0xFFF5F7FA);
  static const Color _surfaceLight   = Color(0xFFFFFFFF);
  static const Color _cardLight      = Color(0xFFFFFFFF);
  static const Color _textPrimaryL   = Color(0xFF1A1F2E);
  static const Color _textSecondaryL = Color(0xFF607D8B);

  // ── Dark theme ────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _primaryDark,
    colorScheme: const ColorScheme.dark(
      primary:    _accentRed,
      secondary:  _accentBlue,
      surface:    _surfaceDark,
      onPrimary:  Colors.white,
      onSecondary: Colors.white,
      onSurface:  _textPrimary,
    ),
    cardTheme: CardThemeData(
      color:       _cardDark,
      elevation:   0,
      shape:       RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin:      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor:  _primaryDark,
      foregroundColor:  _textPrimary,
      elevation:        0,
      centerTitle:      false,
      titleTextStyle: TextStyle(
        color:      _textPrimary,
        fontSize:   20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor:  _surfaceDark,
      indicatorColor:   _accentRed.withValues(alpha: 0.2),
      labelTextStyle:   WidgetStateProperty.all(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor:  _cardDark,
      selectedColor:    _accentRed.withValues(alpha: 0.25),
      labelStyle: const TextStyle(fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: const DividerThemeData(color: _divider, thickness: 0.5),
    textTheme: _buildTextTheme(_textPrimary, _textSecondary),
    extensions: const [AppColors.dark],
  );

  // ── Light theme ───────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _primaryLight,
    colorScheme: const ColorScheme.light(
      primary:    _accentRed,
      secondary:  _accentBlue,
      surface:    _surfaceLight,
      onPrimary:  Colors.white,
      onSecondary: Colors.white,
      onSurface:  _textPrimaryL,
    ),
    cardTheme: CardThemeData(
      color:     _cardLight,
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _surfaceLight,
      foregroundColor: _textPrimaryL,
      elevation:       0,
      centerTitle:     false,
      titleTextStyle: TextStyle(
        color:      _textPrimaryL,
        fontSize:   20,
        fontWeight: FontWeight.w700,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _surfaceLight,
      indicatorColor:  _accentRed.withValues(alpha: 0.15),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE0E0E0), thickness: 0.5),
    textTheme: _buildTextTheme(_textPrimaryL, _textSecondaryL),
    extensions: const [AppColors.light],
  );

  static TextTheme _buildTextTheme(Color primary, Color secondary) => TextTheme(
    headlineLarge:  TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: primary),
    headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: primary),
    headlineSmall:  TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
    titleLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
    titleMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primary),
    bodyLarge:      TextStyle(fontSize: 14, color: primary),
    bodyMedium:     TextStyle(fontSize: 13, color: secondary),
    bodySmall:      TextStyle(fontSize: 12, color: secondary),
    labelLarge:     TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primary),
    labelSmall:     TextStyle(fontSize: 10, color: secondary),
  );
}

// ── Custom colours extension ──────────────────────────────
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.cardBackground,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.mapBackground,
  });

  final Color cardBackground;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color mapBackground;

  static const dark = AppColors(
    cardBackground:  Color(0xFF2D3447),
    shimmerBase:     Color(0xFF2D3447),
    shimmerHighlight:Color(0xFF3A4060),
    mapBackground:   Color(0xFF1A1F2E),
  );

  static const light = AppColors(
    cardBackground:  Color(0xFFFFFFFF),
    shimmerBase:     Color(0xFFE0E0E0),
    shimmerHighlight:Color(0xFFF5F5F5),
    mapBackground:   Color(0xFFEEEEEE),
  );

  @override
  AppColors copyWith({
    Color? cardBackground,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? mapBackground,
  }) => AppColors(
    cardBackground:   cardBackground   ?? this.cardBackground,
    shimmerBase:      shimmerBase      ?? this.shimmerBase,
    shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    mapBackground:    mapBackground    ?? this.mapBackground,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      cardBackground:   Color.lerp(cardBackground,   other.cardBackground,   t)!,
      shimmerBase:      Color.lerp(shimmerBase,      other.shimmerBase,      t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      mapBackground:    Color.lerp(mapBackground,    other.mapBackground,    t)!,
    );
  }
}