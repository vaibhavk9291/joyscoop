import 'package:flutter/material.dart';

/// Joyscoop Shape, Radii, and Spacing Tokens (Strictly from DESIGN.md)
class AppDimensions {
  AppDimensions._();

  // Spacing scale
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // Screen horizontal padding
  static const double screenPadding = 20.0;

  // Radii
  static const double radiusCard = 24.0;
  static const double radiusPill = 28.0;
  static const double radiusThumbnail = 20.0;
  static const double radiusCircleIcon = 22.0;
  static const double radiusBottomSheet = 32.0;
  static const double radiusNav = 36.0;
  static const double radiusChip = 16.0;

  // Border Radii objects
  static const BorderRadius borderCard = BorderRadius.all(Radius.circular(radiusCard));
  static const BorderRadius borderPill = BorderRadius.all(Radius.circular(radiusPill));
  static const BorderRadius borderThumbnail = BorderRadius.all(Radius.circular(radiusThumbnail));
  static const BorderRadius borderBottomSheet = BorderRadius.only(
    topLeft: Radius.circular(radiusBottomSheet),
    topRight: Radius.circular(radiusBottomSheet),
  );
  static const BorderRadius borderNav = BorderRadius.all(Radius.circular(radiusNav));

  // Component Sizes
  static const double buttonHeight = 56.0;
  static const double searchBarHeight = 48.0;
  static const double circleButtonSize = 44.0;
  static const double thumbnailSize = 72.0;
  static const double stepperButtonSize = 36.0;
  static const double minTapTargetSize = 48.0;
  static const double avatarSize = 40.0;
  static const double liveDotSize = 8.0;
  static const double navItemSize = 48.0;
}

