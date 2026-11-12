import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/privacy/privacy_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../core/widgets/blush_shimmer.dart';
import '../../../core/widgets/confirm_delete_dialog.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../services/printing/models/bill.dart';
import '../../../services/printing/printer_service.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../settings/presentation/printer_settings_screen.dart';
import '../domain/product_sales_state.dart';
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
    final printerState = ref.watch(printerServiceProvider);
    final isMasked = ref.watch(privacyProvider);
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

      // Auto-print bill when a sale is incremented/saved if enabled
      if (previous != null &&
          next.totalUnits > previous.totalUnits &&
          printerState.config.autoPrint) {
        final bill = Bill.fromSalesUiState(next);
        ref.read(printerServiceProvider.notifier).printBill(bill);
      }
    });

    // Listen for printer notifications/errors
    ref.listen<PrinterState>(printerServiceProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppSnackBar.show(
          context,
          message: next.errorMessage!,
          isError: true,
        );
      }
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        AppSnackBar.show(context, message: next.successMessage!);
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
                    onPrinterTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PrinterSettingsScreen(),
                        ),
                      );
                    },
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
                      isMasked: isMasked,
                      onTogglePrivacy: () =>
                          ref.read(privacyProvider.notifier).togglePrivacy(),
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
                        isMasked: isMasked,
                        onIncrement: () =>
                            salesNotifier.increment(item.product.id),
                        onDecrement: () async {
                          if (item.unitsSold <= 0) return;
                          final confirmed = await showDeleteConfirmDialog(
                            context: context,
                            title: 'Reduce Quantity?',
                            message:
                                'Are you sure you want to remove 1 unit of ${item.product.name}?\n\nThis will reduce today\'s sales by ₹${item.product.price}.',
                            confirmLabel: 'Yes, Remove',
                            icon: Icons.remove_circle_outline_rounded,
                          );
                          if (confirmed == true && context.mounted) {
                            salesNotifier.decrement(item.product.id);
                          }
                        },
                      ),
                      const SizedBox(height: AppDimensions.space12),
                    ],
                  ],

                  const SizedBox(height: AppDimensions.space16),

                  // 5. Action Buttons (Undo & Print Bill)
                  if (salesState.canUndo || salesState.totalUnits > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (salesState.canUndo) ...[
                          SecondaryButton(
                            text: 'Undo last tap',
                            icon: Icons.undo_rounded,
                            onPressed: () async {
                              final prod = salesState.items
                                  .cast<ProductSalesState?>()
                                  .firstWhere(
                                    (it) =>
                                        it?.product.id ==
                                        salesState.lastTappedProductId,
                                    orElse: () => null,
                                  );
                              final prodName = prod != null
                                  ? prod.product.name
                                  : 'the last item';
                              final price =
                                  prod != null ? ' (₹${prod.product.price})' : '';

                              final confirmed = await showDeleteConfirmDialog(
                                context: context,
                                title: 'Undo Last Sale?',
                                message:
                                    'Are you sure you want to undo $prodName$price?\n\nThis will remove the recorded sale and adjust today\'s total amount.',
                                confirmLabel: 'Yes, Undo',
                                icon: Icons.undo_rounded,
                              );
                              if (confirmed == true && context.mounted) {
                                salesNotifier.undoLastTap();
                              }
                            },
                          ),
                          if (salesState.totalUnits > 0)
                            const SizedBox(width: AppDimensions.space12),
                        ],
                        if (salesState.totalUnits > 0)
                          SecondaryButton(
                            text: 'Print Bill',
                            icon: Icons.receipt_long_rounded,
                            onPressed: () {
                              final bill = Bill.fromSalesUiState(salesState);
                              ref
                                  .read(printerServiceProvider.notifier)
                                  .printBill(bill);
                            },
                          ),
                      ],
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

