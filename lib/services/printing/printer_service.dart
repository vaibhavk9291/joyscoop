import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/bill.dart';
import 'models/printer_config.dart';
import 'printer_connection.dart';
import 'printer_connection_factory.dart';
import 'receipt_builder.dart';

/// Printing status for UI feedback
enum PrinterStatus {
  idle,
  scanning,
  connecting,
  connected,
  printing,
  disconnected,
  error;
}

class PrinterState {
  final PrinterConfig config;
  final PrinterStatus status;
  final List<DiscoveredPrinter> discoveredPrinters;
  final String? errorMessage;
  final String? successMessage;
  final bool isConnected;

  const PrinterState({
    required this.config,
    this.status = PrinterStatus.idle,
    this.discoveredPrinters = const [],
    this.errorMessage,
    this.successMessage,
    this.isConnected = false,
  });

  PrinterState copyWith({
    PrinterConfig? config,
    PrinterStatus? status,
    List<DiscoveredPrinter>? discoveredPrinters,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool? isConnected,
  }) {
    return PrinterState(
      config: config ?? this.config,
      status: status ?? this.status,
      discoveredPrinters: discoveredPrinters ?? this.discoveredPrinters,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

final printerServiceProvider =
    StateNotifierProvider<PrinterService, PrinterState>((ref) {
  return PrinterService();
});

/// Central manager for thermal printing operations
class PrinterService extends StateNotifier<PrinterState> {
  final PrinterConnection _usbConnection = createUsbPrinterConnection();
  final PrinterConnection _btConnection = createBluetoothPrinterConnection();
  final PrinterConnection _networkConnection = createNetworkPrinterConnection();

  PrinterService()
      : super(const PrinterState(config: PrinterConfig())) {
    _init();
  }

  PrinterConnection _getConnectionForType(PrinterConnectionType type) {
    switch (type) {
      case PrinterConnectionType.usb:
        return _usbConnection;
      case PrinterConnectionType.bluetooth:
        return _btConnection;
      case PrinterConnectionType.network:
        return _networkConnection;
    }
  }

  Future<void> _init() async {
    final savedConfig = await PrinterConfig.load();
    state = state.copyWith(config: savedConfig);

    // Attempt auto-reconnect if printer was previously selected
    if (savedConfig.selectedPrinterAddress != null) {
      autoReconnect();
    }
  }

  /// Update and persist configuration settings
  Future<void> updateConfig(PrinterConfig newConfig) async {
    await newConfig.save();
    state = state.copyWith(config: newConfig);
  }

  /// Scan for available printers based on selected connection type
  Future<void> scan() async {
    state = state.copyWith(
      status: PrinterStatus.scanning,
      discoveredPrinters: [],
      clearError: true,
      clearSuccess: true,
    );

    try {
      final conn = _getConnectionForType(state.config.connectionType);

      if (state.config.connectionType == PrinterConnectionType.bluetooth) {
        final btEnabled = await conn.isEnabled();
        if (!btEnabled) {
          state = state.copyWith(
            status: PrinterStatus.error,
            errorMessage: 'Bluetooth is turned off. Please turn it on to search for printers.',
          );
          return;
        }
      }

      final printers = await conn.scan();

      state = state.copyWith(
        status: PrinterStatus.idle,
        discoveredPrinters: printers,
        errorMessage: printers.isEmpty
            ? 'No ${state.config.connectionType.name.toUpperCase()} printers found.'
            : null,
      );
    } catch (e) {
      state = state.copyWith(
        status: PrinterStatus.error,
        errorMessage: 'Failed to scan printers: $e',
      );
    }
  }

  /// Connect to a discovered printer and save it as default
  Future<bool> connect(DiscoveredPrinter printer) async {
    state = state.copyWith(
      status: PrinterStatus.connecting,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final conn = _getConnectionForType(printer.type);
      final success = await conn.connect(printer);

      if (success) {
        final updatedConfig = state.config.copyWith(
          selectedPrinterName: printer.name,
          selectedPrinterAddress: printer.address,
          connectionType: printer.type,
        );
        await updatedConfig.save();

        state = state.copyWith(
          config: updatedConfig,
          status: PrinterStatus.connected,
          isConnected: true,
          successMessage: 'Connected to ${printer.name}',
        );
        return true;
      } else {
        state = state.copyWith(
          status: PrinterStatus.error,
          isConnected: false,
          errorMessage: 'Could not connect to ${printer.name}. Check if printer is powered on.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: PrinterStatus.error,
        isConnected: false,
        errorMessage: 'Connection error: $e',
      );
      return false;
    }
  }

  /// Automatically reconnect to the saved printer
  Future<bool> autoReconnect() async {
    final address = state.config.selectedPrinterAddress;
    if (address == null || address.isEmpty) {
      return false;
    }

    final conn = _getConnectionForType(state.config.connectionType);
    if (conn.isConnected) {
      state = state.copyWith(isConnected: true);
      return true;
    }

    try {
      final target = DiscoveredPrinter(
        name: state.config.selectedPrinterName ?? 'Thermal Printer',
        address: address,
        type: state.config.connectionType,
      );

      final ok = await conn.connect(target);
      state = state.copyWith(isConnected: ok);
      return ok;
    } catch (e) {
      debugPrint('PrinterService: autoReconnect failed: $e');
      state = state.copyWith(isConnected: false);
      return false;
    }
  }

  /// Disconnect current printer
  Future<void> disconnect() async {
    try {
      final conn = _getConnectionForType(state.config.connectionType);
      await conn.disconnect();
    } catch (_) {}

    state = state.copyWith(
      status: PrinterStatus.disconnected,
      isConnected: false,
      clearSuccess: true,
    );
  }

  /// Print a given Bill
  Future<bool> printBill(Bill bill) async {
    if (state.config.selectedPrinterAddress == null) {
      state = state.copyWith(
        status: PrinterStatus.error,
        errorMessage: 'No printer selected. Please select a printer in Settings.',
      );
      return false;
    }

    state = state.copyWith(
      status: PrinterStatus.printing,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final conn = _getConnectionForType(state.config.connectionType);

      // Verify connection or auto-reconnect
      if (!conn.isConnected) {
        final reconnected = await autoReconnect();
        if (!reconnected) {
          state = state.copyWith(
            status: PrinterStatus.error,
            errorMessage: 'Printer unreachable. Ensure printer is on and in range.',
          );
          return false;
        }
      }

      // Generate ESC/POS receipt bytes
      final bytes = await ReceiptBuilder.buildReceipt(
        bill: bill,
        config: state.config,
      );

      final success = await conn.printBytes(bytes);

      if (success) {
        state = state.copyWith(
          status: PrinterStatus.connected,
          successMessage: 'Receipt printed successfully!',
        );
        return true;
      } else {
        state = state.copyWith(
          status: PrinterStatus.error,
          errorMessage: 'Print failed. Check printer paper and connection.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: PrinterStatus.error,
        errorMessage: 'Printing error: $e',
      );
      return false;
    }
  }

  /// Print a sample test receipt
  Future<bool> printTestPage() async {
    final sample = Bill.sampleTestBill();
    return printBill(sample);
  }

  /// Hook for auto-printing when a sale is finalized/saved
  Future<void> handleAutoPrint(Bill bill) async {
    if (state.config.autoPrint && state.config.selectedPrinterAddress != null) {
      await printBill(bill);
    }
  }
}

