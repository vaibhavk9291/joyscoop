import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/product_sales_state.dart';
import 'quantity_stepper.dart';

/// Product row card (cart-item style) strictly following DESIGN.md
class ProductRowCard extends StatelessWidget {
  final ProductSalesState state;
  final bool isMasked;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ProductRowCard({
    super.key,
    required this.state,
    this.isMasked = false,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final product = state.product;
    final Color tintColor = AppColors.getProductTint(product.name);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.borderCard,
        boxShadow: AppShadows.cardShadow,
      ),
      padding: const EdgeInsets.all(AppDimensions.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 72x72 Thumbnail with tinted background and radius 20
          Container(
            width: AppDimensions.thumbnailSize,
            height: AppDimensions.thumbnailSize,
            decoration: BoxDecoration(
              color: tintColor,
              borderRadius: AppDimensions.borderThumbnail,
            ),
            padding: const EdgeInsets.all(AppDimensions.space8),
            child: Image.asset(
              product.assetPath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(
                  Icons.icecream,
                  color: AppColors.primary.withValues(alpha: 0.6),
                  size: 32,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppDimensions.space12),

          // Middle: product name (cardTitle), price caption, and "Today: ₹X"
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  '${CurrencyFormatter.formatInt(product.price)} each',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppDimensions.space4),
                // "Today: ₹X" in danger-free textSecondary (masked when privacy active)
                Text(
                  isMasked
                      ? 'Today: ₹ ••••'
                      : 'Today: ${CurrencyFormatter.formatInt(state.revenue)}',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppDimensions.space8),

          // Right: Quantity Stepper
          QuantityStepper(
            count: state.unitsSold,
            isMasked: isMasked,
            onIncrement: onIncrement,
            onDecrement: onDecrement,
          ),
        ],
      ),
    );
  }
}

