import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'animated_count_text.dart';

/// Hero summary card (full-width card, radius 28, pink gradient, white text, decorative circle)
/// Includes bank-style privacy toggle ("i" / eye icon) to hide/unhide sales and quantities.
class HeroSummaryCard extends StatelessWidget {
  final int totalRevenue;
  final int totalUnits;
  final bool isMasked;
  final VoidCallback? onTogglePrivacy;

  const HeroSummaryCard({
    super.key,
    required this.totalRevenue,
    required this.totalUnits,
    this.isMasked = false,
    this.onTogglePrivacy,
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
                // Top Row: "Today's Sales" caption and Bank-style Privacy "i" / Eye Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Sales",
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (onTogglePrivacy != null)
                      InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onTogglePrivacy!();
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isMasked
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isMasked ? 'Hidden' : 'Visible',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space8),

                // Revenue in displayPrice (masked if private, else animated count-up)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isMasked
                      ? Text(
                          '₹ • • • • • •',
                          key: const ValueKey('masked_revenue'),
                          style: AppTextStyles.displayPrice,
                        )
                      : AnimatedRevenueText(
                          key: ValueKey<int>(totalRevenue),
                          targetValue: totalRevenue,
                          style: AppTextStyles.displayPrice,
                        ),
                ),
                const SizedBox(height: AppDimensions.space4),

                // Second line: "N items sold" (masked if private)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    isMasked
                        ? '•••• items sold'
                        : '$totalUnits ${totalUnits == 1 ? "item" : "items"} sold',
                    key: ValueKey<String>(
                      isMasked ? 'masked_units' : '$totalUnits',
                    ),
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
