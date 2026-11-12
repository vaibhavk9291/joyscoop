import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'models/printer_config.dart';
import 'printer_connection.dart';

/// Concrete connection implementation for Network/Wi-Fi thermal printers (Raw TCP Port 9100)
class NetworkPrinterConnection implements PrinterConnection {
  Socket? _socket;
  DiscoveredPrinter? _activePrinter;
  static const int defaultPort = 9100;

  @override
  PrinterConnectionType get connectionType => PrinterConnectionType.network;

  @override
  Future<bool> isEnabled() async => true;

  @override
  bool get isConnected => _socket != null && _activePrinter != null;

  @override
  Future<List<DiscoveredPrinter>> scan() async {
    // Network printer scanning typically takes an IP subnet or manual IP input.
    // Return empty list by default; user enters IP:PORT in settings if needed.
    return [];
  }

  @override
  Future<bool> connect(DiscoveredPrinter printer) async {
    try {
      await disconnect();

      String host = printer.address;
      int port = defaultPort;

      if (host.contains(':')) {
        final parts = host.split(':');
        host = parts[0];
        port = int.tryParse(parts[1]) ?? defaultPort;
      }

      _socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 4),
      );

      _activePrinter = printer;
      return true;
    } catch (e) {
      debugPrint('NetworkPrinterConnection: connect failed: $e');
      _socket = null;
      _activePrinter = null;
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _socket?.close();
      _socket?.destroy();
    } catch (_) {}
    _socket = null;
    _activePrinter = null;
  }

  @override
  Future<bool> printBytes(List<int> bytes) async {
    if (_socket == null) return false;
    try {
      _socket!.add(bytes);
      await _socket!.flush();
      return true;
    } catch (e) {
      debugPrint('NetworkPrinterConnection: printBytes error: $e');
      return false;
    }
  }
}

