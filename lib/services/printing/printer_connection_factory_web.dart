import 'models/printer_config.dart';
import 'printer_connection.dart';

/// Web fallback stub connection.
/// Web browsers do not have access to USB OTG or Bluetooth Classic SPP hardware.
class WebStubPrinterConnection implements PrinterConnection {
  final PrinterConnectionType _type;
  WebStubPrinterConnection(this._type);

  @override
  PrinterConnectionType get connectionType => _type;

  @override
  bool get isConnected => false;

  @override
  Future<bool> isEnabled() async => false;

  @override
  Future<List<DiscoveredPrinter>> scan() async => [];

  @override
  Future<bool> connect(DiscoveredPrinter printer) async => false;

  @override
  Future<void> disconnect() async {}

  @override
  Future<bool> printBytes(List<int> bytes) async => false;
}

PrinterConnection createUsbPrinterConnection() =>
    WebStubPrinterConnection(PrinterConnectionType.usb);

PrinterConnection createBluetoothPrinterConnection() =>
    WebStubPrinterConnection(PrinterConnectionType.bluetooth);

PrinterConnection createNetworkPrinterConnection() =>
    WebStubPrinterConnection(PrinterConnectionType.network);

