import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Joyscoop Elevation & Shadows (Strictly from DESIGN.md)
class AppShadows {
  AppShadows._();

  /// Cards shadow: color #F2476A at 12% opacity, blur 24, offset (0, 8)
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// Circular buttons shadow: color #000 at 6% opacity, blur 12, offset (0, 4)
  static final List<BoxShadow> circularButtonShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Stepper minus button shadow
  static final List<BoxShadow> stepperMinusShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 3),
    ),
  ];

  /// Primary button glow: color #F2476A at 35% opacity, blur 20, offset (0, 8)
  static final List<BoxShadow> primaryButtonGlow = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.35),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// Floating nav bar soft shadow
  static final List<BoxShadow> floatingNavShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  /// Input fields soft shadow
  static final List<BoxShadow> inputFieldShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 14,
      offset: const Offset(0, 4),
    ),
  ];
}

