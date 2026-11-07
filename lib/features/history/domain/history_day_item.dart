class HistoryProductBreakdown {
  final String productName;
  final int units;
  final int revenue;

  const HistoryProductBreakdown({
    required this.productName,
    required this.units,
    required this.revenue,
  });

  factory HistoryProductBreakdown.fromJson(Map<String, dynamic> json) {
    return HistoryProductBreakdown(
      productName: json['product_name'] as String? ?? 'Item',
      units: (json['units_sold'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toInt() ?? 0,
    );
  }
}

class HistoryDayItem {
  final String businessDate;
  final int totalUnits;
  final int totalRevenue;
  final List<HistoryProductBreakdown> breakdown;

  const HistoryDayItem({
    required this.businessDate,
    required this.totalUnits,
    required this.totalRevenue,
    this.breakdown = const [],
  });

  factory HistoryDayItem.fromDailyTotal(
    Map<String, dynamic> json,
    List<HistoryProductBreakdown> breakdown,
  ) {
    return HistoryDayItem(
      businessDate: json['business_date'] as String,
      totalUnits: (json['total_units'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toInt() ?? 0,
      breakdown: breakdown,
    );
  }
}

