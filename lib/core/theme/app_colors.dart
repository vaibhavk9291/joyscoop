import 'package:flutter/material.dart';

/// Joyscoop Design System Color Tokens (Strictly from DESIGN.md)
class AppColors {
  AppColors._();

  // Background gradient tokens
  static const Color bgTop = Color(0xFFFFE3EA);
  static const Color bgMid = Color(0xFFFFF1F4);
  static const Color bgBottom = Color(0xFFFFFFFF);

  // Surface tokens
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF4F4F6);

  // Primary brand tokens
  static const Color primary = Color(0xFFF2476A);
  static const Color primaryLight = Color(0xFFFF7A93);
  static const Color primaryTint = Color(0xFFFFD9E2);

  // Typography tokens
  static const Color textPrimary = Color(0xFF1F1F24);
  static const Color textSecondary = Color(0xFF8A8A93);

  // Status tokens
  static const Color danger = Color(0xFFE5486B);
  static const Color ratingStar = Color(0xFFFFB020);
  static const Color liveGreen = Color(0xFF27AE60);

  // Hairline divider token
  static const Color dividerHairline = Color(0xFFF0E4E8);

  // Product Accent Tints (for thumbnail background & + button halo)
  static const Color softyTint = Color(0xFFFFD9E2);
  static const Color softyChocoDipTint = Color(0xFFF3D9D2);
  static const Color coldCoffeeTint = Color(0xFFF3E1D0);
  static const Color coldCoffeeCrushTint = Color(0xFFFFD0DA);
  static const Color coldCoffeeVanillaTint = Color(0xFFFFF1CC);

  /// Helper to get product tint by product name
  static Color getProductTint(String productName) {
    final lower = productName.toLowerCase();
    if (lower.contains('choco') || lower.contains('dip')) {
      return softyChocoDipTint;
    } else if (lower.contains('vanilla')) {
      return coldCoffeeVanillaTint;
    } else if (lower.contains('crush')) {
      return coldCoffeeCrushTint;
    } else if (lower.contains('coffee')) {
      return coldCoffeeTint;
    } else {
      return softyTint;
    }
  }
}

