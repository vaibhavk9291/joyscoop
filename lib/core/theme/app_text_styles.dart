import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Joyscoop Typography Tokens (Strictly from DESIGN.md)
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _font({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// 32 / 800 - Hero revenue amount
  static TextStyle get displayPrice => _font(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.surface,
      );

  /// 32 / 800 - Dark display price
  static TextStyle get displayPriceDark => _font(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      );

  /// 20 / 700 - Screen titles
  static TextStyle get title => _font(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  /// 18 / 700 - "Categories", "Products" style headers
  static TextStyle get sectionTitle => _font(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  /// 16 / 700 - Product name
  static TextStyle get cardTitle => _font(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  /// 14 / 500 - General text
  static TextStyle get body => _font(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  /// 14 / 500 - Muted secondary body
  static TextStyle get bodySecondary => _font(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  /// 12 / 500, textSecondary - Subtitles, units, labels
  static TextStyle get caption => _font(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  /// 12 / 600 - Bold caption / status
  static TextStyle get captionBold => _font(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  /// 16 / 700 - Buttons
  static TextStyle get button => _font(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  /// 16 / 700 - Secondary button text
  static TextStyle get buttonSecondary => _font(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  /// Stepper counter number (16 / 700)
  static TextStyle get stepperNumber => _font(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );
}

