import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/date_utils.dart';
import '../data/history_repository.dart';
import '../domain/history_day_item.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  try {
    return HistoryRepository(client: Supabase.instance.client);
  } catch (_) {
    return HistoryRepository(client: null);
  }
});

class HistoryUiState {
  final List<HistoryDayItem> allDays;
  final List<HistoryDayItem> filteredDays;
  final bool isLoading;
  final DateTime? selectedDate;
  final String? errorMessage;

  const HistoryUiState({
    this.allDays = const [],
    this.filteredDays = const [],
    this.isLoading = true,
    this.selectedDate,
    this.errorMessage,
  });

  List<HistoryDayItem> get last7Days {
    final now = AppDateUtils.nowIst();
    final Map<String, HistoryDayItem> existingMap = {
      for (final d in allDays) d.businessDate: d,
    };

    final List<HistoryDayItem> result = [];
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr =
          "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      if (existingMap.containsKey(dateStr)) {
        result.add(existingMap[dateStr]!);
      } else {
        result.add(
          HistoryDayItem(
            businessDate: dateStr,
            totalUnits: 0,
            totalRevenue: 0,
            breakdown: const [],
          ),
        );
      }
    }
    return result;
  }

  int get weekTotal =>
      last7Days.fold(0, (sum, day) => sum + day.totalRevenue);

  int get monthTotal =>
      allDays.fold(0, (sum, day) => sum + day.totalRevenue);

  HistoryUiState copyWith({
    List<HistoryDayItem>? allDays,
    List<HistoryDayItem>? filteredDays,
    bool? isLoading,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    String? errorMessage,
  }) {
    return HistoryUiState(
      allDays: allDays ?? this.allDays,
      filteredDays: filteredDays ?? this.filteredDays,
      isLoading: isLoading ?? this.isLoading,
      selectedDate:
          clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      errorMessage: errorMessage,
    );
  }
}

class HistoryController extends StateNotifier<HistoryUiState> {
  final HistoryRepository _repository;

  HistoryController(this._repository) : super(const HistoryUiState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final days = await _repository.fetchLast30Days();
      state = state.copyWith(
        allDays: days,
        filteredDays: days,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load history records',
      );
    }
  }

  void filterByDate(DateTime? picked) {
    if (picked == null) {
      state = state.copyWith(
        filteredDays: state.allDays,
        clearSelectedDate: true,
      );
      return;
    }

    final formatted =
        "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

    final filtered =
        state.allDays.where((d) => d.businessDate == formatted).toList();

    state = state.copyWith(
      selectedDate: picked,
      filteredDays: filtered,
    );
  }
}

final historyControllerProvider =
    StateNotifierProvider<HistoryController, HistoryUiState>((ref) {
  final repo = ref.watch(historyRepositoryProvider);
  return HistoryController(repo);
});

