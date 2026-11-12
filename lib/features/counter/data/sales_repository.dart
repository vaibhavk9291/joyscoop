import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../domain/product.dart';
import '../domain/sales_event.dart';

class SalesRepository {
  final SupabaseClient? client;

  SalesRepository({this.client});

  /// Fetch all active products
  Future<List<Product>> fetchProducts() async {
    if (client == null || !SupabaseConfig.isConfigured) {
      return Product.defaultProducts();
    }

    try {
      final response = await client!
          .from('products')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      final productsList = (response as List)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();

      if (productsList.isEmpty) {
        return Product.defaultProducts();
      }

      // Ensure Softy price is updated to 25 in memory and synced to Supabase
      final updatedList = productsList.map((p) {
        if (p.name.toLowerCase() == 'softy' && p.price != 25) {
          _updateSoftyPriceInDb();
          return Product(
            id: p.id,
            name: p.name,
            price: 25,
            sortOrder: p.sortOrder,
            isActive: p.isActive,
          );
        }
        return p;
      }).toList();

      return updatedList;
    } catch (e) {
      debugPrint('Error fetching products from Supabase: $e');
      return Product.defaultProducts();
    }
  }

  /// Attempts to update the Softy price in Supabase DB to 25
  Future<void> _updateSoftyPriceInDb() async {
    try {
      await client?.from('products').update({'price': 25}).eq('name', 'Softy');
    } catch (e) {
      debugPrint('Could not update Softy price in Supabase: $e');
    }
  }

  /// Fetch today's sales per product from `daily_summary` view
  Future<Map<String, int>> fetchDailyUnitsSold(String businessDate) async {
    if (client == null || !SupabaseConfig.isConfigured) {
      return {};
    }

    try {
      final response = await client!
          .from('daily_summary')
          .select('product_id, units_sold')
          .eq('business_date', businessDate);

      final Map<String, int> unitsMap = {};
      for (final row in response as List) {
        final prodId = row['product_id'] as String;
        final units = (row['units_sold'] as num).toInt();
        unitsMap[prodId] = units;
      }
      return unitsMap;
    } catch (e) {
      debugPrint('Error fetching daily_summary: $e');
      return {};
    }
  }

  /// Insert sales event into `sales_events` (delta +1 or -1)
  Future<void> insertSalesEvent({
    required String productId,
    required int delta,
    required String businessDate,
  }) async {
    if (client == null || !SupabaseConfig.isConfigured) {
      // In mock/demo mode, complete immediately
      return;
    }

    final userId = client!.auth.currentUser?.id;

    await client!.from('sales_events').insert({
      'product_id': productId,
      'delta': delta,
      'business_date': businessDate,
      if (userId != null) 'created_by': userId,
    });
  }

  /// Fetch the current user's most recent sales event on a date (for Undo)
  Future<SalesEvent?> fetchLastEventForCurrentUser({
    required String businessDate,
  }) async {
    if (client == null || !SupabaseConfig.isConfigured) {
      return null;
    }

    final userId = client!.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await client!
          .from('sales_events')
          .select()
          .eq('business_date', businessDate)
          .eq('created_by', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return SalesEvent.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error fetching last event for user: $e');
    }
    return null;
  }

  /// Subscribe to Realtime inserts on `sales_events` table
  RealtimeChannel? subscribeToSalesEvents(void Function(dynamic payload) onEvent) {
    if (client == null || !SupabaseConfig.isConfigured) {
      return null;
    }

    try {
      final channel = client!.channel('public:sales_events');
      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'sales_events',
            callback: onEvent,
          )
          .subscribe();
      return channel;
    } catch (e) {
      debugPrint('Realtime subscription error: $e');
      return null;
    }
  }
}

