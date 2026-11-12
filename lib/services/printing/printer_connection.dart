import 'models/printer_config.dart';

/// Representation of a printer discovered through scan
class DiscoveredPrinter {
  final String name;
  final String address; // MAC address for BT, "vendorId:productId" for USB, or IP
  final PrinterConnectionType type;
  final dynamic originalDevice; // Underlying platform device object (Printer, BluetoothInfo, etc.)

  const DiscoveredPrinter({
    required this.name,
    required this.address,
    required this.type,
    this.originalDevice,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveredPrinter &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          type == other.type;

  @override
  int get hashCode => address.hashCode ^ type.hashCode;
}

/// Abstract interface for printer connections
abstract class PrinterConnection {
  /// Scan for available printers of this connection type
  Future<List<DiscoveredPrinter>> scan();

  /// Connect to the given discovered printer
  Future<bool> connect(DiscoveredPrinter printer);

  /// Disconnect current printer connection
  Future<void> disconnect();

  /// Check whether the printer is actively connected
  bool get isConnected;

  /// Send raw ESC/POS bytes to the connected printer
  Future<bool> printBytes(List<int> bytes);

  /// Checks whether hardware/adapter is enabled (e.g. Bluetooth is on)
  Future<bool> isEnabled() async => true;

  /// Returns the type of connection this implements
  PrinterConnectionType get connectionType;
}

