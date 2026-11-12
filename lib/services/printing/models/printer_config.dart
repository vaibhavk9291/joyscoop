import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum PrinterConnectionType { usb, bluetooth, network }

enum ReceiptPaperSize {
  mm58(charsPerLine: 32, label: '58mm'),
  mm80(charsPerLine: 48, label: '80mm');

  final int charsPerLine;
  final String label;
  const ReceiptPaperSize({required this.charsPerLine, required this.label});
}

class PrinterConfig {
  static const String _storageKey = 'joyscoop_printer_config';

  final String shopName;
  final String address;
  final String phone;
  final String gstin;
  final String footerMessage;
  final String upiId;
  final bool autoPrint;
  final bool useRasterHeading;
  final PrinterConnectionType connectionType;
  final ReceiptPaperSize paperSize;
  final String? selectedPrinterName;
  final String? selectedPrinterAddress; // MAC for BT, "vendorId:productId" for USB, IP for network

  const PrinterConfig({
    this.shopName = 'Joyscoop',
    this.address = 'Ice Cream & Cold Coffee Bar',
    this.phone = '+91 98765 43210',
    this.gstin = '',
    this.footerMessage = 'Thank you! Visit again 🍦',
    this.upiId = '',
    this.autoPrint = false,
    this.useRasterHeading = false,
    this.connectionType = PrinterConnectionType.bluetooth,
    this.paperSize = ReceiptPaperSize.mm58,
    this.selectedPrinterName,
    this.selectedPrinterAddress,
  });

  PrinterConfig copyWith({
    String? shopName,
    String? address,
    String? phone,
    String? gstin,
    String? footerMessage,
    String? upiId,
    bool? autoPrint,
    bool? useRasterHeading,
    PrinterConnectionType? connectionType,
    ReceiptPaperSize? paperSize,
    String? selectedPrinterName,
    String? selectedPrinterAddress,
    bool clearSelectedPrinter = false,
  }) {
    return PrinterConfig(
      shopName: shopName ?? this.shopName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      gstin: gstin ?? this.gstin,
      footerMessage: footerMessage ?? this.footerMessage,
      upiId: upiId ?? this.upiId,
      autoPrint: autoPrint ?? this.autoPrint,
      useRasterHeading: useRasterHeading ?? this.useRasterHeading,
      connectionType: connectionType ?? this.connectionType,
      paperSize: paperSize ?? this.paperSize,
      selectedPrinterName: clearSelectedPrinter
          ? null
          : (selectedPrinterName ?? this.selectedPrinterName),
      selectedPrinterAddress: clearSelectedPrinter
          ? null
          : (selectedPrinterAddress ?? this.selectedPrinterAddress),
    );
  }

  Map<String, dynamic> toJson() => {
        'shopName': shopName,
        'address': address,
        'phone': phone,
        'gstin': gstin,
        'footerMessage': footerMessage,
        'upiId': upiId,
        'autoPrint': autoPrint,
        'useRasterHeading': useRasterHeading,
        'connectionType': connectionType.name,
        'paperSize': paperSize.name,
        'selectedPrinterName': selectedPrinterName,
        'selectedPrinterAddress': selectedPrinterAddress,
      };

  factory PrinterConfig.fromJson(Map<String, dynamic> json) {
    final connTypeStr = json['connectionType'] as String? ?? 'bluetooth';
    final paperSizeStr = json['paperSize'] as String? ?? 'mm58';

    return PrinterConfig(
      shopName: json['shopName'] as String? ?? 'Joyscoop',
      address: json['address'] as String? ?? 'Ice Cream & Cold Coffee Bar',
      phone: json['phone'] as String? ?? '+91 98765 43210',
      gstin: json['gstin'] as String? ?? '',
      footerMessage:
          json['footerMessage'] as String? ?? 'Thank you! Visit again 🍦',
      upiId: json['upiId'] as String? ?? '',
      autoPrint: json['autoPrint'] as bool? ?? false,
      useRasterHeading: json['useRasterHeading'] as bool? ?? false,
      connectionType: PrinterConnectionType.values.firstWhere(
        (e) => e.name == connTypeStr,
        orElse: () => PrinterConnectionType.bluetooth,
      ),
      paperSize: ReceiptPaperSize.values.firstWhere(
        (e) => e.name == paperSizeStr,
        orElse: () => ReceiptPaperSize.mm58,
      ),
      selectedPrinterName: json['selectedPrinterName'] as String?,
      selectedPrinterAddress: json['selectedPrinterAddress'] as String?,
    );
  }

  static Future<PrinterConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const PrinterConfig();
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return PrinterConfig.fromJson(map);
    } catch (_) {
      return const PrinterConfig();
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(toJson()));
  }
}

