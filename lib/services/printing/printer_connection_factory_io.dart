import 'bluetooth_printer_connection.dart';
import 'network_printer_connection.dart';
import 'printer_connection.dart';
import 'usb_printer_connection.dart';

PrinterConnection createUsbPrinterConnection() => UsbPrinterConnection();
PrinterConnection createBluetoothPrinterConnection() =>
    BluetoothPrinterConnection();
PrinterConnection createNetworkPrinterConnection() =>
    NetworkPrinterConnection();

