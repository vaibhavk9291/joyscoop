import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/live_indicator_chip.dart';
import '../data/offline_queue_service.dart';
import '../data/sales_repository.dart';
import '../domain/product.dart';
import '../domain/product_sales_state.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  try {
    return SalesRepository(client: Supabase.instance.client);
  } catch (_) {
    return SalesRepository(client: null);
  }
});

final offlineQueueServiceProvider = Provider<OfflineQueueService>((ref) {
  return OfflineQueueService();
});

class SalesUiState {
  final List<ProductSalesState> items;
  final bool isLoading;
  final String businessDate;
  final LiveStatus liveStatus;
  final int pendingCount;
  final String? lastTappedProductId;
  final int? lastTappedDelta;
  final String? errorMessage;

  const SalesUiState({
    this.items = const [],
    this.isLoading = true,
    required this.businessDate,
    this.liveStatus = LiveStatus.live,
    this.pendingCount = 0,
    this.lastTappedProductId,
    this.lastTappedDelta,
    this.errorMessage,
  });

  int get totalRevenue =>
      items.fold(0, (sum, item) => sum + item.revenue);

  int get totalUnits =>
      items.fold(0, (sum, item) => sum + item.unitsSold);

  bool get canUndo => lastTappedProductId != null && lastTappedDelta != null;

  SalesUiState copyWith({
    List<ProductSalesState>? items,
    bool? isLoading,
    String? businessDate,
    LiveStatus? liveStatus,
    int? pendingCount,
    String? lastTappedProductId,
    int? lastTappedDelta,
    String? errorMessage,
    bool clearUndo = false,
  }) {
    return SalesUiState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      businessDate: businessDate ?? this.businessDate,
      liveStatus: liveStatus ?? this.liveStatus,
      pendingCount: pendingCount ?? this.pendingCount,
      lastTappedProductId:
          clearUndo ? null : (lastTappedProductId ?? this.lastTappedProductId),
      lastTappedDelta:
          clearUndo ? null : (lastTappedDelta ?? this.lastTappedDelta),
      errorMessage: errorMessage,
    );
  }
}

class SalesController extends StateNotifier<SalesUiState> {
  final SalesRepository _repository;
  final OfflineQueueService _queueService;
  RealtimeChannel? _realtimeChannel;
  StreamSubscription? _connectivitySub;
  Timer? _dateRolloverTimer;

  SalesController(this._repository, this._queueService)
      : super(SalesUiState(
          businessDate: AppDateUtils.currentBusinessDateString(),
        )) {
    _init();
  }

  void _init() async {
    await loadTodayData();
    _subscribeRealtime();
    _listenConnectivity();
    _startDateRolloverMonitor();
    _syncOfflineQueue();
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    _connectivitySub?.cancel();
    _dateRolloverTimer?.cancel();
    super.dispose();
  }

  /// Load catalog products and today's initial counts from daily_summary
  Future<void> loadTodayData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final products = await _repository.fetchProducts();
      final todayDate = AppDateUtils.currentBusinessDateString();
      final unitsMap = await _repository.fetchDailyUnitsSold(todayDate);

      final items = products.map((prod) {
        final sold = unitsMap[prod.id] ?? 0;
        return ProductSalesState(product: prod, unitsSold: sold);
      }).toList();

      final queue = await _queueService.getQueue();

      state = state.copyWith(
        items: items,
        isLoading: false,
        businessDate: todayDate,
        pendingCount: queue.length,
      );
    } catch (e) {
      debugPrint('Error loading sales data: $e');
      final fallbackItems = Product.defaultProducts()
          .map((prod) => ProductSalesState(product: prod, unitsSold: 0))
          .toList();
      state = state.copyWith(
        items: fallbackItems,
        isLoading: false,
        errorMessage: 'Loaded cached menu',
      );
    }
  }

  /// Optimistic Increment (+1)
  Future<void> increment(String productId) async {
    await _recordDelta(productId: productId, delta: 1);
  }

  /// Optimistic Decrement (-1)
  Future<void> decrement(String productId) async {
    final itemIndex = state.items.indexWhere((it) => it.product.id == productId);
    if (itemIndex == -1 || state.items[itemIndex].unitsSold <= 0) {
      return;
    }
    await _recordDelta(productId: productId, delta: -1);
  }

  /// Undo the last tap performed on this device
  Future<void> undoLastTap() async {
    if (!state.canUndo) return;

    final productId = state.lastTappedProductId!;
    final lastDelta = state.lastTappedDelta!;
    final compensatingDelta = -lastDelta;

    // Check if decrementing would go below 0
    if (compensatingDelta == -1) {
      final item = state.items.firstWhere(
        (it) => it.product.id == productId,
        orElse: () => state.items.first,
      );
      if (item.unitsSold <= 0) return;
    }

    state = state.copyWith(clearUndo: true);
    await _recordDelta(
      productId: productId,
      delta: compensatingDelta,
      isUndo: true,
    );
  }

  Future<void> _recordDelta({
    required String productId,
    required int delta,
    bool isUndo = false,
  }) async {
    // 1. Optimistic local update
    final updatedItems = state.items.map((item) {
      if (item.product.id == productId) {
        final newUnits = (item.unitsSold + delta).clamp(0, 99999);
        return item.copyWith(unitsSold: newUnits);
      }
      return item;
    }).toList();

    state = state.copyWith(
      items: updatedItems,
      lastTappedProductId: isUndo ? null : productId,
      lastTappedDelta: isUndo ? null : delta,
      clearUndo: isUndo,
    );

    final todayDate = state.businessDate;

    // 2. Transmit to server or queue if offline
    try {
      if (state.liveStatus == LiveStatus.offline) {
        await _enqueueOffline(productId, delta, todayDate);
        return;
      }

      await _repository.insertSalesEvent(
        productId: productId,
        delta: delta,
        businessDate: todayDate,
      );
    } catch (e) {
      debugPrint('Failed to send sales event: $e. Enqueueing offline.');
      // Enqueue to offline storage for later auto-sync
      await _enqueueOffline(productId, delta, todayDate);
      state = state.copyWith(
        liveStatus: LiveStatus.offline,
        errorMessage: 'Connection lost. Tap saved locally to sync.',
      );
    }
  }

  Future<void> _enqueueOffline(String productId, int delta, String date) async {
    final event = QueuedSaleEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: productId,
      delta: delta,
      businessDate: date,
      createdAt: DateTime.now(),
    );
    await _queueService.enqueue(event);
    final count = (await _queueService.getQueue()).length;
    state = state.copyWith(
      pendingCount: count,
      liveStatus: LiveStatus.offline,
    );
  }

  /// Sync pending offline taps in FIFO order
  Future<void> _syncOfflineQueue() async {
    final queue = await _queueService.getQueue();
    if (queue.isEmpty) {
      state = state.copyWith(
        pendingCount: 0,
        liveStatus: LiveStatus.live,
      );
      return;
    }

    state = state.copyWith(
      liveStatus: LiveStatus.syncing,
      pendingCount: queue.length,
    );

    for (final event in queue) {
      try {
        await _repository.insertSalesEvent(
          productId: event.productId,
          delta: event.delta,
          businessDate: event.businessDate,
        );
        await _queueService.removeFirst();
      } catch (e) {
        debugPrint('Sync pending event failed: $e');
        state = state.copyWith(liveStatus: LiveStatus.offline);
        return;
      }
    }

    final remaining = (await _queueService.getQueue()).length;
    state = state.copyWith(
      pendingCount: remaining,
      liveStatus: remaining == 0 ? LiveStatus.live : LiveStatus.offline,
    );

    // Reconcile totals from server after drain
    await loadTodayData();
  }

  void _subscribeRealtime() {
    _realtimeChannel = _repository.subscribeToSalesEvents((payload) async {
      try {
        final record = payload.newRecord as Map<String, dynamic>?;
        if (record != null) {
          final eventDate = record['business_date'] as String?;
          if (eventDate == state.businessDate) {
            // Instant reconciliation from daily_summary
            final unitsMap =
                await _repository.fetchDailyUnitsSold(state.businessDate);
            final updatedItems = state.items.map((item) {
              final sold = unitsMap[item.product.id] ?? item.unitsSold;
              return item.copyWith(unitsSold: sold);
            }).toList();

            state = state.copyWith(items: updatedItems);
          }
        }
      } catch (e) {
        debugPrint('Error reconciling realtime event: $e');
      }
    });
  }

  void _listenConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final isConnected = results.any((r) => r != ConnectivityResult.none);
      if (isConnected) {
        if (state.liveStatus == LiveStatus.offline) {
          _syncOfflineQueue();
        }
      } else {
        state = state.copyWith(liveStatus: LiveStatus.offline);
      }
    });
  }

  /// Midnight IST rollover detector
  void _startDateRolloverMonitor() {
    _dateRolloverTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final currentToday = AppDateUtils.currentBusinessDateString();
      if (currentToday != state.businessDate) {
        debugPrint('Business date changed past midnight IST to: $currentToday');
        state = state.copyWith(
          businessDate: currentToday,
          clearUndo: true,
        );
        loadTodayData();
      }
    });
  }

  /// Force retry sync manually
  void retrySync() {
    _syncOfflineQueue();
  }
}

final salesControllerProvider =
    StateNotifierProvider<SalesController, SalesUiState>((ref) {
  final repository = ref.watch(salesRepositoryProvider);
  final queueService = ref.watch(offlineQueueServiceProvider);
  return SalesController(repository, queueService);
});

