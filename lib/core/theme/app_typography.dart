import 'package:flutter/material.dart';

/// Digital Kavach typography scale.
///
/// Uses system default sans-serif with Indic-script fallback so Hindi,
/// Marathi and other Indian scripts render correctly on all OEMs.
/// (No custom Inter font ships in Phase 01 — Phase 10 may bundle it.)
class AppTypography {
  const AppTypography._();

  /// Font-family fallback chain for Indic script glyph coverage.
  static const List<String> fontFallback = <String>[
    'Roboto',
    'Noto Sans Devanagari',
    'Noto Sans',
    'sans-serif',
  ];

  static TextTheme buildTextTheme(Color text, Color muted) {
    final TextStyle base = TextStyle(
      color: text,
      fontFamilyFallback: fontFallback,
    );

    return TextTheme(
      displayLarge: base.copyWith(fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w700),
      displayMedium: base.copyWith(fontSize: 28, height: 36 / 28, fontWeight: FontWeight.w700),
      displaySmall: base.copyWith(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w700),
      headlineLarge: base.copyWith(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w700),
      headlineMedium: base.copyWith(fontSize: 22, height: 30 / 22, fontWeight: FontWeight.w700),
      headlineSmall: base.copyWith(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600),
      titleLarge: base.copyWith(fontSize: 18, height: 26 / 18, fontWeight: FontWeight.w600),
      titleMedium: base.copyWith(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w600),
      titleSmall: base.copyWith(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600),
      bodyLarge: base.copyWith(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400),
      bodyMedium: base.copyWith(fontSize: 14, height: 22 / 14, fontWeight: FontWeight.w400, color: muted),
      bodySmall: base.copyWith(fontSize: 12, height: 18 / 12, fontWeight: FontWeight.w400, color: muted),
      labelLarge: base.copyWith(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500),
      labelMedium: base.copyWith(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: muted),
      labelSmall: base.copyWith(fontSize: 11, height: 14 / 11, fontWeight: FontWeight.w500, color: muted),
    );
  }
}