import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Joyscoop Design System Gradients (Strictly from DESIGN.md)
class AppGradients {
  AppGradients._();

  /// Screen background vertical gradient: bgTop -> bgMid -> bgBottom
  static const LinearGradient screenBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.45, 1.0],
    colors: [
      AppColors.bgTop,
      AppColors.bgMid,
      AppColors.bgBottom,
    ],
  );

  /// Primary button & Hero summary card: horizontal-diagonal primaryLight -> primary
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primaryLight,
      AppColors.primary,
    ],
  );

  /// Stepper plus button gradient: slightly angled
  static const LinearGradient plusButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.primaryLight,
      AppColors.primary,
    ],
  );

  /// Chart bar gradient: vertical primaryLight to primary
  static const LinearGradient chartBarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.primaryLight,
      AppColors.primary,
    ],
  );
}

