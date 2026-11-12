import '../../../features/counter/domain/product_sales_state.dart';
import '../../../features/counter/presentation/sales_controller.dart';
import '../../../features/history/domain/history_day_item.dart';

/// Single item line in a bill
class BillItem {
  final String name;
  final int quantity;
  final double rate;
  final double amount;

  const BillItem({
    required this.name,
    required this.quantity,
    required this.rate,
    required this.amount,
  });

  factory BillItem.fromProductSalesState(ProductSalesState state) {
    return BillItem(
      name: state.product.name,
      quantity: state.unitsSold,
      rate: state.product.price.toDouble(),
      amount: state.revenue.toDouble(),
    );
  }

  factory BillItem.fromBreakdown(HistoryProductBreakdown breakdown) {
    final rate = breakdown.units > 0
        ? (breakdown.revenue / breakdown.units).toDouble()
        : 0.0;
    return BillItem(
      name: breakdown.productName,
      quantity: breakdown.units,
      rate: rate,
      amount: breakdown.revenue.toDouble(),
    );
  }
}

/// Normalized Bill model used for thermal receipt printing
class Bill {
  final String billNumber;
  final DateTime dateTime;
  final List<BillItem> items;
  final double subtotal;
  final double discount;
  final double? cgst;
  final double? sgst;
  final double? igst;
  final double grandTotal;
  final String? customerName;
  final String? customerPhone;

  const Bill({
    required this.billNumber,
    required this.dateTime,
    required this.items,
    required this.subtotal,
    this.discount = 0.0,
    this.cgst,
    this.sgst,
    this.igst,
    required this.grandTotal,
    this.customerName,
    this.customerPhone,
  });

  /// Adapter: Create a Bill from active sales state (Today's live counter)
  factory Bill.fromSalesUiState(SalesUiState state, {String? billNumber}) {
    final activeItems = state.items
        .where((item) => item.unitsSold > 0)
        .map(BillItem.fromProductSalesState)
        .toList();

    final total = state.totalRevenue.toDouble();
    final now = DateTime.now();
    final number = billNumber ??
        'JS-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';

    return Bill(
      billNumber: number,
      dateTime: now,
      items: activeItems,
      subtotal: total,
      discount: 0.0,
      grandTotal: total,
    );
  }

  /// Adapter: Create a Bill from a historical day summary
  factory Bill.fromHistoryDayItem(HistoryDayItem item, {String? billNumber}) {
    final billItems = item.breakdown
        .where((b) => b.units > 0)
        .map(BillItem.fromBreakdown)
        .toList();

    final parsedDate = DateTime.tryParse(item.businessDate) ?? DateTime.now();
    final number = billNumber ?? 'JS-HIST-${item.businessDate.replaceAll('-', '')}';

    return Bill(
      billNumber: number,
      dateTime: parsedDate,
      items: billItems,
      subtotal: item.totalRevenue.toDouble(),
      discount: 0.0,
      grandTotal: item.totalRevenue.toDouble(),
    );
  }

  /// Generate sample bill for test print
  factory Bill.sampleTestBill() {
    return Bill(
      billNumber: 'JS-TEST-001',
      dateTime: DateTime.now(),
      items: const [
        BillItem(
          name: 'Softy Soft-Serve Cone',
          quantity: 2,
          rate: 25.0,
          amount: 50.0,
        ),
        BillItem(
          name: 'Softy Choco Dip Cone',
          quantity: 1,
          rate: 40.0,
          amount: 40.0,
        ),
        BillItem(
          name: 'Cold Coffee with Vanilla Ice Cream',
          quantity: 1,
          rate: 55.0,
          amount: 55.0,
        ),
      ],
      subtotal: 145.0,
      discount: 0.0,
      cgst: 3.62,
      sgst: 3.62,
      grandTotal: 145.0,
    );
  }
}

