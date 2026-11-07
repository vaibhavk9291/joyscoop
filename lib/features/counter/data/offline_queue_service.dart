import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QueuedSaleEvent {
  final String id;
  final String productId;
  final int delta;
  final String businessDate;
  final DateTime createdAt;

  QueuedSaleEvent({
    required this.id,
    required this.productId,
    required this.delta,
    required this.businessDate,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'delta': delta,
        'business_date': businessDate,
        'created_at': createdAt.toIso8601String(),
      };

  factory QueuedSaleEvent.fromJson(Map<String, dynamic> json) =>
      QueuedSaleEvent(
        id: json['id'] as String,
        productId: json['product_id'] as String,
        delta: (json['delta'] as num).toInt(),
        businessDate: json['business_date'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class OfflineQueueService {
  static const String _storageKey = 'joyscoop_offline_sales_queue';

  Future<List<QueuedSaleEvent>> getQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    return raw
        .map((item) => QueuedSaleEvent.fromJson(
            jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> enqueue(QueuedSaleEvent event) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getQueue();
    current.add(event);
    final encoded = current.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  Future<void> removeFirst() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getQueue();
    if (current.isNotEmpty) {
      current.removeAt(0);
      final encoded = current.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_storageKey, encoded);
    }
  }

  Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

