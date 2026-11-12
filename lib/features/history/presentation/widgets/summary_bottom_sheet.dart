import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../services/printing/models/bill.dart';
import '../../../../services/printing/printer_service.dart';
import '../../domain/history_day_item.dart';

/// Summary bottom sheet strictly per DESIGN.md
class SummaryBottomSheet extends ConsumerWidget {
  final HistoryDayItem dayItem;
  final bool isMasked;

  const SummaryBottomSheet({
    super.key,
    required this.dayItem,
    this.isMasked = false,
  });

  static Future<void> show(
    BuildContext context,
    HistoryDayItem dayItem, {
    bool isMasked = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          SummaryBottomSheet(dayItem: dayItem, isMasked: isMasked),
    );
  }

  void _shareReport() {
    final dateDisplay = AppDateUtils.formatDisplayDate(dayItem.businessDate);
    final buffer = StringBuffer();
    buffer.writeln('🍦 Joyscoop Sales Report');
    buffer.writeln('📅 Date: $dateDisplay');
    buffer.writeln('-------------------------');
    for (final item in dayItem.breakdown) {
      buffer.writeln(
        '• ${item.productName}: ${item.units} sold - ${CurrencyFormatter.formatInt(item.revenue)}',
      );
    }
    buffer.writeln('-------------------------');
    buffer.writeln('📦 Total Items: ${dayItem.totalUnits}');
    buffer.writeln(
      '💰 Grand Total: ${CurrencyFormatter.formatInt(dayItem.totalRevenue)}',
    );

    Share.share(
      buffer.toString(),
      subject: 'Joyscoop Sales Report - $dateDisplay',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isToday = AppDateUtils.isToday(dayItem.businessDate);
    final dateTitle = isToday
        ? 'Today (${AppDateUtils.formatDisplayDate(dayItem.businessDate)})'
        : AppDateUtils.formatDisplayDate(dayItem.businessDate);

    final printerState = ref.watch(printerServiceProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.borderBottomSheet,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.space24,
        AppDimensions.space16,
        AppDimensions.space24,
        AppDimensions.space32,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle Indicator
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space20),

            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Daily Sales Breakdown', style: AppTextStyles.title),
                Text(
                  dateTitle,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space20),
            const Divider(),
            const SizedBox(height: AppDimensions.space16),

            // Rows with label left (textSecondary) and value right (textPrimary, bold)
            if (dayItem.breakdown.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.space16,
                ),
                child: Center(
                  child: Text(
                    'No individual product sales recorded',
                    style: AppTextStyles.caption,
                  ),
                ),
              )
            else
              ...dayItem.breakdown.map((item) {
                final isNegative = item.revenue < 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.space8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.getProductTint(item.productName),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space8),
                          Text(
                            item.productName,
                            style: AppTextStyles.bodySecondary,
                          ),
                          const SizedBox(width: AppDimensions.space8),
                          Text(
                            isMasked ? '× ••' : '× ${item.units}',
                            style: AppTextStyles.captionBold,
                          ),
                        ],
                      ),
                      Text(
                        isMasked
                            ? '₹ ••••'
                            : CurrencyFormatter.formatInt(item.revenue),
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isNegative
                              ? AppColors.danger
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: AppDimensions.space12),
            const Divider(),
            const SizedBox(height: AppDimensions.space16),

            // Grand Total Row in Bold
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grand Total',
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
                    ),
                    Text(
                      isMasked
                          ? '•••• items sold'
                          : '${dayItem.totalUnits} items sold',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                Text(
                  isMasked
                      ? '₹ ••••••'
                      : CurrencyFormatter.formatInt(dayItem.totalRevenue),
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.space24),

            // Action Buttons: Share report & Print / Reprint Bill
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: isToday ? "Share" : "Share report",
                    icon: Icons.share_rounded,
                    onPressed: _shareReport,
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: PrimaryButton(
                    text: 'Print Bill',
                    icon: Icons.receipt_rounded,
                    isLoading: printerState.status == PrinterStatus.printing,
                    onPressed: () {
                      final bill = Bill.fromHistoryDayItem(dayItem);
                      ref.read(printerServiceProvider.notifier).printBill(bill);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
