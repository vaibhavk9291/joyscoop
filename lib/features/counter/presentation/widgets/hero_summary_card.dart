import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'animated_count_text.dart';

/// Hero summary card (full-width card, radius 28, pink gradient, white text, decorative circle)
class HeroSummaryCard extends StatelessWidget {
  final int totalRevenue;
  final int totalUnits;

  const HeroSummaryCard({
    super.key,
    required this.totalRevenue,
    required this.totalUnits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        boxShadow: AppShadows.primaryButtonGlow,
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          // Subtle decorative circle (white at 12% opacity) in the top-right corner
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 50,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space24,
              vertical: AppDimensions.space20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // "Today's Sales" caption
                Text(
                  "Today's Sales",
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppDimensions.space8),

                // Revenue in displayPrice (animated count-up 300ms)
                AnimatedRevenueText(
                  targetValue: totalRevenue,
                  style: AppTextStyles.displayPrice,
                ),
                const SizedBox(height: AppDimensions.space4),

                // Second line: "N items sold"
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    '$totalUnits ${totalUnits == 1 ? "item" : "items"} sold',
                    key: ValueKey<int>(totalUnits),
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

