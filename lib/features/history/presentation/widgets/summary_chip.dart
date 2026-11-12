import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Soft pill summary chip for Period (e.g. This Week: ₹X)
class SummaryChip extends StatelessWidget {
  final String label;
  final int amount;
  final IconData icon;
  final bool isMasked;

  const SummaryChip({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    this.isMasked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDimensions.borderCard,
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryTint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppDimensions.space8),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              isMasked ? '₹ ••••••' : CurrencyFormatter.formatInt(amount),
              style: AppTextStyles.title.copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

