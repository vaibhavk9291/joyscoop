class SalesEvent {
  final String id;
  final String productId;
  final int delta;
  final int unitPrice;
  final String businessDate;
  final String? createdBy;
  final DateTime createdAt;

  const SalesEvent({
    required this.id,
    required this.productId,
    required this.delta,
    required this.unitPrice,
    required this.businessDate,
    this.createdBy,
    required this.createdAt,
  });

  factory SalesEvent.fromJson(Map<String, dynamic> json) {
    return SalesEvent(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      delta: (json['delta'] as num).toInt(),
      unitPrice: (json['unit_price'] as num?)?.toInt() ?? 0,
      businessDate: json['business_date'] as String,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'delta': delta,
        'unit_price': unitPrice,
        'business_date': businessDate,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
      };
}

