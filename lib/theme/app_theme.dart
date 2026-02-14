import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// THEME ENUM
// ─────────────────────────────────────────────────────────────
enum AppThemeType {
  darkOcean,
  cyberpunk,
  nord,
  dracula,
  solarized,
  monokai,
  midnight,
  forest,
}

extension AppThemeTypeExt on AppThemeType {
  String get displayName {
    switch (this) {
      case AppThemeType.darkOcean: return 'Dark Ocean';
      case AppThemeType.cyberpunk: return 'Cyberpunk';
      case AppThemeType.nord:      return 'Nord';
      case AppThemeType.dracula:   return 'Dracula';
      case AppThemeType.solarized: return 'Solarized';
      case AppThemeType.monokai:   return 'Monokai';
      case AppThemeType.midnight:  return 'Midnight';
      case AppThemeType.forest:    return 'Forest';
    }
  }
}

// ─────────────────────────────────────────────────────────────
// THEME COLOR PALETTE
// ─────────────────────────────────────────────────────────────
class AppThemeColors {
  final Color bg, surface, glass, glassBorder;
  final Color accent1, accent2, green, yellow, orange;
  final Color textPrimary, textSecondary, divider;

  const AppThemeColors({
    required this.bg,
    required this.surface,
    required this.glass,
    required this.glassBorder,
    required this.accent1,
    required this.accent2,
    required this.green,
    required this.yellow,
    required this.orange,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
  });

  // ── Factory ────────────────────────────────────────────────
  static AppThemeColors fromType(AppThemeType type) {
    switch (type) {
      case AppThemeType.darkOcean:
        return const AppThemeColors(
          bg: Color(0xFF070B1A),         surface: Color(0xFF0D1529),
          glass: Color(0x1AFFFFFF),       glassBorder: Color(0x26FFFFFF),
          accent1: Color(0xFF00E5FF),     accent2: Color(0xFF8B5CF6),
          green: Color(0xFF10B981),       yellow: Color(0xFFF59E0B),
          orange: Color(0xFFEF4444),      textPrimary: Color(0xFFF0F4FF),
          textSecondary: Color(0xFF8B9CC8), divider: Color(0x1AFFFFFF),
        );
      case AppThemeType.cyberpunk:
        return const AppThemeColors(
          bg: Color(0xFF0A0A0F),         surface: Color(0xFF141420),
          glass: Color(0x1AFF00FF),       glassBorder: Color(0x33FF00FF),
          accent1: Color(0xFFFF00FF),     accent2: Color(0xFF00FFFF),
          green: Color(0xFF39FF14),       yellow: Color(0xFFFFFF00),
          orange: Color(0xFFFF4444),      textPrimary: Color(0xFFFFFFFF),
          textSecondary: Color(0xFFB0B0D0), divider: Color(0x1AFF00FF),
        );
      case AppThemeType.nord:
        return const AppThemeColors(
          bg: Color(0xFF2E3440),         surface: Color(0xFF3B4252),
          glass: Color(0x1AD8DEE9),       glassBorder: Color(0x26D8DEE9),
          accent1: Color(0xFF88C0D0),     accent2: Color(0xFF81A1C1),
          green: Color(0xFFA3BE8C),       yellow: Color(0xFFEBCB8B),
          orange: Color(0xFFBF616A),      textPrimary: Color(0xFFECEFF4),
          textSecondary: Color(0xFF9DA8BE), divider: Color(0x1AD8DEE9),
        );
      case AppThemeType.dracula:
        return const AppThemeColors(
          bg: Color(0xFF282A36),         surface: Color(0xFF343746),
          glass: Color(0x1AF8F8F2),       glassBorder: Color(0x26F8F8F2),
          accent1: Color(0xFFBD93F9),     accent2: Color(0xFFFF79C6),
          green: Color(0xFF50FA7B),       yellow: Color(0xFFF1FA8C),
          orange: Color(0xFFFF5555),      textPrimary: Color(0xFFF8F8F2),
          textSecondary: Color(0xFF9B9FAD), divider: Color(0x1AF8F8F2),
        );
      case AppThemeType.solarized:
        return const AppThemeColors(
          bg: Color(0xFF002B36),         surface: Color(0xFF073642),
          glass: Color(0x1A93A1A1),       glassBorder: Color(0x2693A1A1),
          accent1: Color(0xFF268BD2),     accent2: Color(0xFF2AA198),
          green: Color(0xFF859900),       yellow: Color(0xFFB58900),
          orange: Color(0xFFDC322F),      textPrimary: Color(0xFFFDF6E3),
          textSecondary: Color(0xFF839496), divider: Color(0x1A93A1A1),
        );
      case AppThemeType.monokai:
        return const AppThemeColors(
          bg: Color(0xFF272822),         surface: Color(0xFF3E3D32),
          glass: Color(0x1AF8F8F2),       glassBorder: Color(0x26F8F8F2),
          accent1: Color(0xFFA6E22E),     accent2: Color(0xFFAE81FF),
          green: Color(0xFFA6E22E),       yellow: Color(0xFFE6DB74),
          orange: Color(0xFFF92672),      textPrimary: Color(0xFFF8F8F2),
          textSecondary: Color(0xFF90908A), divider: Color(0x1AF8F8F2),
        );
      case AppThemeType.midnight:
        return const AppThemeColors(
          bg: Color(0xFF0D1117),         surface: Color(0xFF161B22),
          glass: Color(0x1AC9D1D9),       glassBorder: Color(0x26C9D1D9),
          accent1: Color(0xFF58A6FF),     accent2: Color(0xFFBC8CFF),
          green: Color(0xFF3FB950),       yellow: Color(0xFFD29922),
          orange: Color(0xFFF85149),      textPrimary: Color(0xFFC9D1D9),
          textSecondary: Color(0xFF8B949E), divider: Color(0x1AC9D1D9),
        );
      case AppThemeType.forest:
        return const AppThemeColors(
          bg: Color(0xFF0B1A0B),         surface: Color(0xFF132913),
          glass: Color(0x1A90EE90),       glassBorder: Color(0x2690EE90),
          accent1: Color(0xFF4ADE80),     accent2: Color(0xFF86EFAC),
          green: Color(0xFF22C55E),       yellow: Color(0xFFFBBF24),
          orange: Color(0xFFEF4444),      textPrimary: Color(0xFFE8F5E9),
          textSecondary: Color(0xFF81C784), divider: Color(0x1A90EE90),
        );
    }
  }
}