import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'models/printer_config.dart';
import 'printer_connection.dart';

/// Concrete connection implementation for USB thermal printers
class UsbPrinterConnection implements PrinterConnection {
  final FlutterThermalPrinter _thermalPlugin = FlutterThermalPrinter.instance;
  Printer? _activePrinter;
  bool _isConnected = false;

  @override
  PrinterConnectionType get connectionType => PrinterConnectionType.usb;

  @override
  Future<bool> isEnabled() async => true;

  @override
  bool get isConnected => _isConnected && _activePrinter != null;

  @override
  Future<List<DiscoveredPrinter>> scan() async {
    try {
      final List<Printer> usbPrinters = [];
      final completer = Completer<List<DiscoveredPrinter>>();

      // Listen to the discovered devices stream for USB devices
      final subscription = _thermalPlugin.devicesStream.listen((printers) {
        for (final p in printers) {
          if (p.connectionType == ConnectionType.USB) {
            if (!usbPrinters.any((existing) =>
                (existing.vendorId == p.vendorId &&
                    existing.productId == p.productId) ||
                (existing.address == p.address && p.address != null))) {
              usbPrinters.add(p);
            }
          }
        }
      });

      // Request USB scan
      await _thermalPlugin.getPrinters(
        connectionTypes: [ConnectionType.USB],
        refreshDuration: const Duration(seconds: 1),
      );

      // Wait a short duration to gather broadcasted USB devices
      await Future.delayed(const Duration(milliseconds: 1500));
      await subscription.cancel();

      final results = usbPrinters.map((p) {
        final address = (p.vendorId != null && p.productId != null)
            ? '${p.vendorId}:${p.productId}'
            : (p.address ?? p.name ?? 'USB_PRINTER');
        return DiscoveredPrinter(
          name: p.name ?? 'USB Thermal Printer',
          address: address,
          type: PrinterConnectionType.usb,
          originalDevice: p,
        );
      }).toList();

      if (!completer.isCompleted) {
        completer.complete(results);
      }

      return await completer.future;
    } catch (e) {
      debugPrint('UsbPrinterConnection: scan failed: $e');
      return [];
    }
  }

  @override
  Future<bool> connect(DiscoveredPrinter printer) async {
    try {
      Printer? targetDevice;
      if (printer.originalDevice is Printer) {
        targetDevice = printer.originalDevice as Printer;
      } else {
        // Parse vendorId and productId from address if possible
        String? vId;
        String? pId;
        if (printer.address.contains(':')) {
          final parts = printer.address.split(':');
          vId = parts[0];
          pId = parts[1];
        }
        targetDevice = Printer(
          name: printer.name,
          address: printer.address,
          vendorId: vId,
          productId: pId,
          connectionType: ConnectionType.USB,
        );
      }

      final success = await _thermalPlugin.connect(targetDevice);
      if (success) {
        _activePrinter = targetDevice;
        _isConnected = true;
      }
      return success;
    } catch (e) {
      debugPrint('UsbPrinterConnection: connect failed: $e');
      _isConnected = false;
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    if (_activePrinter != null) {
      try {
        await _thermalPlugin.disconnect(_activePrinter!);
      } catch (e) {
        debugPrint('UsbPrinterConnection: disconnect error: $e');
      }
    }
    _activePrinter = null;
    _isConnected = false;
  }

  @override
  Future<bool> printBytes(List<int> bytes) async {
    if (_activePrinter == null) {
      debugPrint('UsbPrinterConnection: Cannot print, no active printer');
      return false;
    }

    try {
      await _thermalPlugin.printData(_activePrinter!, bytes);
      return true;
    } catch (e) {
      debugPrint('UsbPrinterConnection: printBytes error: $e');
      return false;
    }
  }
}

