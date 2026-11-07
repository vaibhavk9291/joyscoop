import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/history_day_item.dart';

/// 7-Day Revenue Bar Chart strictly per DESIGN.md
class RevenueBarChart extends StatelessWidget {
  final List<HistoryDayItem> last7Days;

  const RevenueBarChart({
    super.key,
    required this.last7Days,
  });

  @override
  Widget build(BuildContext context) {
    if (last7Days.isEmpty) return const SizedBox.shrink();

    // Chronological order for chart (oldest to newest)
    final items = last7Days.reversed.toList();
    final double maxRevenue = items.fold<double>(
      1000.0,
      (max, it) => it.totalRevenue > max ? it.totalRevenue.toDouble() : max,
    );

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.borderCard,
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7-Day Revenue Trend',
                style: AppTextStyles.cardTitle,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space8,
                  vertical: AppDimensions.space4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusChip),
                ),
                child: Text(
                  'Last 7 Days',
                  style: AppTextStyles.captionBold.copyWith(
                    color: AppColors.primary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxRevenue * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.textPrimary,
                    tooltipRoundedRadius: 12,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final item = items[group.x.toInt()];
                      return BarTooltipItem(
                        '${AppDateUtils.formatDisplayDate(item.businessDate)}\n',
                        AppTextStyles.caption.copyWith(color: Colors.white70),
                        children: [
                          TextSpan(
                            text: CurrencyFormatter.formatInt(item.totalRevenue),
                            style: AppTextStyles.cardTitle.copyWith(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= items.length) {
                          return const SizedBox.shrink();
                        }
                        final item = items[index];
                        final isToday = AppDateUtils.isToday(item.businessDate);
                        final date = DateTime.tryParse(item.businessDate);
                        final label = isToday
                            ? 'Today'
                            : (date != null ? _shortWeekday(date.weekday) : '');

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            label,
                            style: AppTextStyles.caption.copyWith(
                              color: isToday
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isToday = AppDateUtils.isToday(item.businessDate);

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: item.totalRevenue.toDouble(),
                        width: 22,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isToday
                              ? [AppColors.primary, AppColors.primaryLight]
                              : [
                                  AppColors.primaryLight.withValues(alpha: 0.8),
                                  AppColors.primary.withValues(alpha: 0.6),
                                ],
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxRevenue * 1.2,
                          color: AppColors.surfaceMuted,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }
}

