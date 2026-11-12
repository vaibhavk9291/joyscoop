import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'models/printer_config.dart';
import 'printer_connection.dart';

/// Concrete connection implementation for Bluetooth thermal printers
/// Supports both Bluetooth Classic (SPP) and Bluetooth Low Energy (BLE)
class BluetoothPrinterConnection implements PrinterConnection {
  final FlutterThermalPrinter _thermalPlugin = FlutterThermalPrinter.instance;
  DiscoveredPrinter? _activePrinter;
  bool _isConnected = false;
  bool _isClassic = false;

  @override
  PrinterConnectionType get connectionType => PrinterConnectionType.bluetooth;

  @override
  Future<bool> isEnabled() => isBluetoothEnabled();

  @override
  bool get isConnected => _isConnected && _activePrinter != null;

  /// Check if Bluetooth is enabled on the device
  Future<bool> isBluetoothEnabled() async {
    try {
      return await PrintBluetoothThermal.bluetoothEnabled;
    } catch (_) {
      return false;
    }
  }

  /// Request runtime Bluetooth and Location permissions (needed for scanning on Android)
  Future<bool> requestPermissions() async {
    try {
      // Modern Android (API 31+) permissions
      final bluetoothScan = await Permission.bluetoothScan.request();
      final bluetoothConnect = await Permission.bluetoothConnect.request();
      final bluetooth = await Permission.bluetooth.request();

      // Older Android devices require location permission for bluetooth discovery
      final location = await Permission.locationWhenInUse.request();

      final granted = (bluetoothConnect.isGranted || bluetooth.isGranted) &&
          (bluetoothScan.isGranted || location.isGranted);

      return granted;
    } catch (e) {
      debugPrint('BluetoothPrinterConnection: permission request error: $e');
      return true; // Let the underlying plugin handle fallback
    }
  }

  @override
  Future<List<DiscoveredPrinter>> scan() async {
    await requestPermissions();

    final List<DiscoveredPrinter> results = [];
    final Set<String> seenAddresses = {};

    // 1. Scan Bluetooth Classic paired devices (Primary for Android POS printers)
    try {
      final List<BluetoothInfo> paired =
          await PrintBluetoothThermal.pairedBluetooths;
      for (final device in paired) {
        if (!seenAddresses.contains(device.macAdress)) {
          seenAddresses.add(device.macAdress);
          results.add(
            DiscoveredPrinter(
              name: device.name.isNotEmpty
                  ? device.name
                  : 'BT Printer (${device.macAdress})',
              address: device.macAdress,
              type: PrinterConnectionType.bluetooth,
              originalDevice: device,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('BluetoothPrinterConnection: Classic BT scan error: $e');
    }

    // 2. Scan BLE devices (for BLE printers and iOS support)
    try {
      final List<Printer> blePrinters = [];
      final subscription = _thermalPlugin.devicesStream.listen((printers) {
        for (final p in printers) {
          if (p.connectionType == ConnectionType.BLE && p.address != null) {
            if (!seenAddresses.contains(p.address)) {
              seenAddresses.add(p.address!);
              blePrinters.add(p);
            }
          }
        }
      });

      await _thermalPlugin.getPrinters(
        connectionTypes: [ConnectionType.BLE],
        refreshDuration: const Duration(seconds: 1),
      );

      await Future.delayed(const Duration(milliseconds: 1500));
      await subscription.cancel();

      for (final p in blePrinters) {
        results.add(
          DiscoveredPrinter(
            name: p.name?.isNotEmpty == true
                ? p.name!
                : 'BLE Printer (${p.address})',
            address: p.address ?? '',
            type: PrinterConnectionType.bluetooth,
            originalDevice: p,
          ),
        );
      }
    } catch (e) {
      debugPrint('BluetoothPrinterConnection: BLE scan error: $e');
    }

    return results;
  }

  @override
  Future<bool> connect(DiscoveredPrinter printer) async {
    try {
      // Determine if printer is Classic or BLE
      final isMacFormat = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$')
          .hasMatch(printer.address);

      if (printer.originalDevice is BluetoothInfo || isMacFormat) {
        // Connect via Bluetooth Classic SPP socket
        final success = await PrintBluetoothThermal.connect(
          macPrinterAddress: printer.address,
        );
        if (success) {
          _activePrinter = printer;
          _isConnected = true;
          _isClassic = true;
          return true;
        }
      }

      // Fallback or explicit BLE connection
      if (printer.originalDevice is Printer) {
        final success = await _thermalPlugin.connect(
          printer.originalDevice as Printer,
        );
        if (success) {
          _activePrinter = printer;
          _isConnected = true;
          _isClassic = false;
          return true;
        }
      } else {
        // Try BLE connect with constructed Printer
        final blePrinter = Printer(
          name: printer.name,
          address: printer.address,
          connectionType: ConnectionType.BLE,
        );
        final success = await _thermalPlugin.connect(blePrinter);
        if (success) {
          _activePrinter = printer;
          _isConnected = true;
          _isClassic = false;
          return true;
        }
      }

      _isConnected = false;
      return false;
    } catch (e) {
      debugPrint('BluetoothPrinterConnection: connect failed: $e');
      _isConnected = false;
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      if (_isClassic) {
        await PrintBluetoothThermal.disconnect;
      } else if (_activePrinter?.originalDevice is Printer) {
        await _thermalPlugin.disconnect(_activePrinter!.originalDevice as Printer);
      }
    } catch (e) {
      debugPrint('BluetoothPrinterConnection: disconnect error: $e');
    } finally {
      _activePrinter = null;
      _isConnected = false;
      _isClassic = false;
    }
  }

  @override
  Future<bool> printBytes(List<int> bytes) async {
    if (_activePrinter == null) {
      debugPrint('BluetoothPrinterConnection: No active printer');
      return false;
    }

    try {
      if (_isClassic) {
        return await PrintBluetoothThermal.writeBytes(bytes);
      } else if (_activePrinter?.originalDevice is Printer) {
        await _thermalPlugin.printData(
          _activePrinter!.originalDevice as Printer,
          bytes,
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('BluetoothPrinterConnection: printBytes error: $e');
      return false;
    }
  }
}

