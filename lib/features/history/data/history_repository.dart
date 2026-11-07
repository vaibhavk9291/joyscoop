import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../domain/history_day_item.dart';

class HistoryRepository {
  final SupabaseClient? client;

  HistoryRepository({this.client});

  Future<List<HistoryDayItem>> fetchLast30Days() async {
    if (client == null || !SupabaseConfig.isConfigured) {
      return [];
    }

    try {
      final totalsRes = await client!
          .from('daily_totals')
          .select()
          .order('business_date', ascending: false)
          .limit(30);

      final summaryRes = await client!
          .from('daily_summary')
          .select()
          .order('business_date', ascending: false);

      final Map<String, List<HistoryProductBreakdown>> breakdownsMap = {};
      for (final row in summaryRes as List) {
        final bDate = row['business_date'] as String;
        breakdownsMap.putIfAbsent(bDate, () => []);
        breakdownsMap[bDate]!.add(HistoryProductBreakdown.fromJson(row));
      }

      final List<HistoryDayItem> items = [];
      for (final row in totalsRes as List) {
        final bDate = row['business_date'] as String;
        items.add(
          HistoryDayItem.fromDailyTotal(
            row,
            breakdownsMap[bDate] ?? [],
          ),
        );
      }

      return items;
    } catch (e) {
      debugPrint('Error fetching history: $e');
      return [];
    }
  }
}


