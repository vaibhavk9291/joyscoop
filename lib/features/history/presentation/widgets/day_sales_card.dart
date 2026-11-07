import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/history_day_item.dart';
import 'summary_bottom_sheet.dart';

/// Single day sales summary card in History list
class DaySalesCard extends StatelessWidget {
  final HistoryDayItem dayItem;

  const DaySalesCard({
    super.key,
    required this.dayItem,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = AppDateUtils.isToday(dayItem.businessDate);
    final dateDisplay = isToday
        ? 'Today'
        : AppDateUtils.formatDisplayDate(dayItem.businessDate);

    return GestureDetector(
      onTap: () {
        SummaryBottomSheet.show(context, dayItem);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDimensions.borderCard,
          boxShadow: AppShadows.cardShadow,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space20,
          vertical: AppDimensions.space16,
        ),
        child: Row(
          children: [
            // Left calendar badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isToday ? AppColors.primary : AppColors.primaryTint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: isToday ? Colors.white : AppColors.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.space16),

            // Middle: Date and total items
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        dateDisplay,
                        style: AppTextStyles.cardTitle,
                      ),
                      if (isToday) ...[
                        const SizedBox(width: AppDimensions.space8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Active',
                            style: AppTextStyles.captionBold.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dayItem.totalUnits} items sold',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            // Right: Revenue & chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  CurrencyFormatter.formatInt(dayItem.totalRevenue),
                  style: AppTextStyles.cardTitle.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Details',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

