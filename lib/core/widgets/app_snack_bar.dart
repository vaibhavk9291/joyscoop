import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';

/// Styled snackbar: white floating card, rounded (radius 24), soft shadow, danger or primary accent
class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();

    final accentColor = isError ? AppColors.danger : AppColors.primary;

    scaffoldMessenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          bottom: 90,
          left: AppDimensions.space20,
          right: AppDimensions.space20,
        ),
        padding: EdgeInsets.zero,
        duration: const Duration(milliseconds: 3000),
        content: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space12,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            boxShadow: AppShadows.cardShadow,
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                  color: accentColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

