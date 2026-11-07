import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../core/widgets/blush_shimmer.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../auth/presentation/auth_controller.dart';
import 'sales_controller.dart';
import 'widgets/hero_summary_card.dart';
import 'widgets/home_header.dart';
import 'widgets/product_row_card.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesState = ref.watch(salesControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final salesNotifier = ref.read(salesControllerProvider.notifier);
    final authNotifier = ref.read(authControllerProvider.notifier);

    // Listen for error messages to show styled snackbars
    ref.listen<SalesUiState>(salesControllerProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppSnackBar.show(
          context,
          message: next.errorMessage!,
          isError: true,
        );
      }
    });

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () => salesNotifier.loadTodayData(),
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

                  // 1. Header (Hey, {name} / Time greeting, Live Chip, Logout)
                  HomeHeader(
                    staffName: authState.displayName,
                    liveStatus: salesState.liveStatus,
                    pendingCount: salesState.pendingCount,
                    onLogout: () async {
                      await authNotifier.signOut();
                    },
                    onSyncTap: () {
                      salesNotifier.retrySync();
                    },
                  ),

                  const SizedBox(height: AppDimensions.space20),

                  // 2. Hero Summary Card (Today's Sales, ₹ displayPrice, N items sold)
                  if (salesState.isLoading && salesState.items.isEmpty)
                    const BlushShimmer(
                      width: double.infinity,
                      height: 140,
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.radiusPill),
                      ),
                    )
                  else
                    HeroSummaryCard(
                      totalRevenue: salesState.totalRevenue,
                      totalUnits: salesState.totalUnits,
                    ),

                  const SizedBox(height: AppDimensions.space24),

                  // 3. Section Title: "Products"
                  Text(
                    'Products',
                    style: AppTextStyles.sectionTitle,
                  ),

                  const SizedBox(height: AppDimensions.space12),

                  // 4. Products List
                  if (salesState.isLoading && salesState.items.isEmpty) ...[
                    for (int i = 0; i < 4; i++) ...[
                      const BlushShimmer(
                        width: double.infinity,
                        height: 96,
                        borderRadius: AppDimensions.borderCard,
                      ),
                      const SizedBox(height: AppDimensions.space12),
                    ],
                  ] else ...[
                    for (final item in salesState.items) ...[
                      ProductRowCard(
                        state: item,
                        onIncrement: () =>
                            salesNotifier.increment(item.product.id),
                        onDecrement: () =>
                            salesNotifier.decrement(item.product.id),
                      ),
                      const SizedBox(height: AppDimensions.space12),
                    ],
                  ],

                  const SizedBox(height: AppDimensions.space16),

                  // 5. "Undo last tap" Secondary Pill Button
                  if (salesState.canUndo)
                    Center(
                      child: SecondaryButton(
                        text: 'Undo last tap',
                        icon: Icons.undo_rounded,
                        onPressed: () {
                          salesNotifier.undoLastTap();
                        },
                      ),
                    ),

                  // Generous bottom whitespace so floating nav never overlaps cards
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

