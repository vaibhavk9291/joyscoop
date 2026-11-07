import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/blush_shimmer.dart';
import 'history_controller.dart';
import 'widgets/day_sales_card.dart';
import 'widgets/revenue_bar_chart.dart';
import 'widgets/summary_chip.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  void _pickDate(BuildContext context, WidgetRef ref) async {
    final state = ref.read(historyControllerProvider);
    final now = AppDateUtils.nowIst();

    final picked = await showDatePicker(
      context: context,
      initialDate: state.selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 90)),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    ref.read(historyControllerProvider.notifier).filterByDate(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyControllerProvider);
    final historyNotifier = ref.read(historyControllerProvider.notifier);

    final selectedDateStr = historyState.selectedDate != null
        ? AppDateUtils.formatFullDate(historyState.selectedDate!)
        : 'Filter by date';

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () => historyNotifier.loadHistory(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPadding,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: AppDimensions.space16),

                  // Header with Title "History"
                  Text(
                    'History',
                    style: AppTextStyles.title.copyWith(fontSize: 26),
                  ),

                  const SizedBox(height: AppDimensions.space16),

                  // Pill Search / Date Bar (White, fully rounded, height 48, leading icon, textSecondary hint)
                  GestureDetector(
                    onTap: () => _pickDate(context, ref),
                    child: Container(
                      height: AppDimensions.searchBarHeight,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.searchBarHeight / 2,
                        ),
                        boxShadow: AppShadows.inputFieldShadow,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space16,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: AppDimensions.space12),
                          Expanded(
                            child: Text(
                              selectedDateStr,
                              style: historyState.selectedDate != null
                                  ? AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                    )
                                  : AppTextStyles.caption.copyWith(
                                      fontSize: 14,
                                    ),
                            ),
                          ),
                          if (historyState.selectedDate != null)
                            GestureDetector(
                              onTap: () => historyNotifier.filterByDate(null),
                              child: const Icon(
                                Icons.close_rounded,
                                color: AppColors.textSecondary,
                                size: 18,
                              ),
                            )
                          else
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space20),

                  // 7-Day Revenue Bar Chart
                  if (historyState.isLoading && historyState.allDays.isEmpty)
                    const BlushShimmer(
                      width: double.infinity,
                      height: 240,
                      borderRadius: AppDimensions.borderCard,
                    )
                  else
                    RevenueBarChart(last7Days: historyState.last7Days),

                  const SizedBox(height: AppDimensions.space16),

                  // Week and Month Summary Chips
                  Row(
                    children: [
                      SummaryChip(
                        label: 'This Week',
                        amount: historyState.weekTotal,
                        icon: Icons.calendar_view_week_rounded,
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      SummaryChip(
                        label: 'This Month',
                        amount: historyState.monthTotal,
                        icon: Icons.insert_chart_outlined_rounded,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.space24),

                  // Past Days Section Title
                  Text(
                    'Daily Records',
                    style: AppTextStyles.sectionTitle,
                  ),

                  const SizedBox(height: AppDimensions.space12),

                  // List of Day Cards (Last 30 Days)
                  if (historyState.isLoading && historyState.allDays.isEmpty) ...[
                    for (int i = 0; i < 5; i++) ...[
                      const BlushShimmer(
                        width: double.infinity,
                        height: 80,
                        borderRadius: AppDimensions.borderCard,
                      ),
                      const SizedBox(height: AppDimensions.space12),
                    ],
                  ] else if (historyState.filteredDays.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.space32,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: AppColors.textSecondary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: AppDimensions.space12),
                            Text(
                              historyState.selectedDate != null
                                  ? 'No sales found for the selected date'
                                  : 'No sales recorded yet',
                              style: AppTextStyles.bodySecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    for (final dayItem in historyState.filteredDays) ...[
                      DaySalesCard(dayItem: dayItem),
                      const SizedBox(height: AppDimensions.space12),
                    ],
                  ],

                  // Padding for floating bottom nav
                  const SizedBox(height: 110),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

