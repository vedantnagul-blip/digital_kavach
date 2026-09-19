import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.primary,
      onSecondary: AppColors.onPrimary,
      error: AppColors.danger,
      onError: AppColors.onDanger,
      surface: isLight ? AppColors.lightSurface : AppColors.darkSurface,
      onSurface: isLight ? AppColors.lightText : AppColors.darkText,
      surfaceContainerHighest:
      isLight ? AppColors.lightSurfaceVariant : AppColors.darkSurfaceVariant,
      onSurfaceVariant:
      isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted,
      outlineVariant:
      isLight ? AppColors.lightOutlineVariant : AppColors.darkOutlineVariant,
      shadow: isLight ? AppColors.softShadow : AppColors.darkShadow,
    );

    final TextTheme textTheme = AppTypography.buildTextTheme(
      scheme.onSurface,
      scheme.onSurfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isLight ? AppColors.lightBg : AppColors.darkBg,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      splashFactory: InkRipple.splashFactory,

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: scheme.shadow,
        backgroundColor: isLight ? AppColors.lightBg : AppColors.darkBg,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent, // Prevents tinting on scroll
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
        systemOverlayStyle: isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      ),

      // MODERN CARD: No borders, pure white/dark, soft shadow
      cardTheme: CardTheme(
        elevation: 8,
        shadowColor: scheme.shadow,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.rXl, // Soft rounded corners
        ),
      ),

      // MODERN BUTTONS: Highly rounded (pill-like)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 4,
          shadowColor: scheme.primary.withOpacity(0.4),
          minimumSize: const Size(64, 52),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.rPill),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.rPill),
          side: BorderSide(color: scheme.outlineVariant, width: 1.5),
          textStyle: textTheme.labelLarge,
        ),
      ),
    );
  }
}