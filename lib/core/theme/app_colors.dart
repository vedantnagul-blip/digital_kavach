import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // === BRAND ===
  static const Color primary = Color(0xFFE85D04);
  static const Color primaryContainer = Color(0xFFFFDBC7);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF3B1600);

  // === SEMANTIC — SEVERITY ===
  static const Color danger = Color(0xFFC1121F);
  static const Color dangerContainer = Color(0xFFFFE3E3);
  static const Color onDanger = Color(0xFFFFFFFF);
  static const Color onDangerContainer = Color(0xFF410007);

  static const Color warning = Color(0xFFB57700);
  static const Color warningContainer = Color(0xFFFFF3D6);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color onWarningContainer = Color(0xFF2A1D00);

  static const Color safe = Color(0xFF1B7334);
  static const Color safeContainer = Color(0xFFDDF3E1);
  static const Color onSafe = Color(0xFFFFFFFF);
  static const Color onSafeContainer = Color(0xFF002110);

  // === MODERN SOFT UI NEUTRALS ===
  // Backgrounds are slightly tinted so pure white cards with shadows pop out
  static const Color lightBg = Color(0xFFF4F6F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEEF0F3);
  static const Color lightText = Color(0xFF1A1D21);
  static const Color lightTextMuted = Color(0xFF6B7280);
  static const Color lightOutlineVariant = Color(0xFFE5E7EB);
  static const Color softShadow = Color(0x14000000); // 8% black for ultra-soft shadow

  // === DARK MODE (Adjusted for soft UI) ===
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkSurface = Color(0xFF1C1F24);
  static const Color darkSurfaceVariant = Color(0xFF272B31);
  static const Color darkText = Color(0xFFF3F4F6);
  static const Color darkTextMuted = Color(0xFF9CA3AF);
  static const Color darkOutlineVariant = Color(0xFF374151);
  static const Color darkShadow = Color(0x33000000); // Darker shadow for dark mode

  // === DASHBOARD CARD ACCENTS (From your images) ===
  // We use these specifically for the home screen grid
  static const Color cardPurple = Color(0xFF8B5CF6);
  static const Color cardTeal = Color(0xFF14B8A6);
  static const Color cardOrange = Color(0xFFF97316);
  static const Color cardPink = Color(0xFFEC4899);
  static const Color cardBlue = Color(0xFF3B82F6);
}