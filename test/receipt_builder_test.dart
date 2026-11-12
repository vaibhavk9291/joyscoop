import 'package:flutter_test/flutter_test.dart';
import 'package:joyscoop/services/printing/models/bill.dart';
import 'package:joyscoop/services/printing/models/printer_config.dart';
import 'package:joyscoop/services/printing/receipt_builder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReceiptBuilder Unit Tests', () {
    late Bill sampleBill;

    setUp(() {
      sampleBill = Bill(
        billNumber: 'JS-TEST-101',
        dateTime: DateTime(2026, 11, 11, 15, 30),
        items: const [
          BillItem(
            name: 'Softy Waffle Cone',
            quantity: 2,
            rate: 25.0,
            amount: 50.0,
          ),
          BillItem(
            name: 'Softy Choco Dip Cone with Toppings',
            quantity: 1,
            rate: 40.0,
            amount: 40.0,
          ),
          BillItem(
            name: 'Cold Coffee with Vanilla',
            quantity: 1,
            rate: 55.0,
            amount: 55.0,
          ),
        ],
        subtotal: 145.0,
        discount: 5.0,
        cgst: 3.50,
        sgst: 3.50,
        grandTotal: 147.0,
      );
    });

    test('builds valid receipt bytes for 58mm paper without throwing', () async {
      const config58 = PrinterConfig(
        shopName: 'Joyscoop',
        address: 'Main Market, Stall 4',
        phone: '+91 98765 43210',
        gstin: '27AAAAA0000A1Z5',
        footerMessage: 'Thank you! Visit again 🍦',
        paperSize: ReceiptPaperSize.mm58,
      );

      final bytes = await ReceiptBuilder.buildReceipt(
        bill: sampleBill,
        config: config58,
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(50));
    });

    test('builds valid receipt bytes for 80mm paper without throwing', () async {
      const config80 = PrinterConfig(
        shopName: 'Joyscoop',
        address: 'Main Market, Stall 4',
        phone: '+91 98765 43210',
        gstin: '27AAAAA0000A1Z5',
        footerMessage: 'Thank you! Visit again 🍦',
        paperSize: ReceiptPaperSize.mm80,
      );

      final bytes = await ReceiptBuilder.buildReceipt(
        bill: sampleBill,
        config: config80,
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(50));
    });

    test('builds receipt with UPI payment QR code', () async {
      const configWithUpi = PrinterConfig(
        shopName: 'Joyscoop',
        upiId: 'joyscoop@okhdfcbank',
        paperSize: ReceiptPaperSize.mm58,
      );

      final bytes = await ReceiptBuilder.buildReceipt(
        bill: sampleBill,
        config: configWithUpi,
      );

      expect(bytes, isNotEmpty);
    });

    test('handles long item names with wrapping across lines', () async {
      final billWithLongNames = Bill(
        billNumber: 'JS-TEST-LONG',
        dateTime: DateTime.now(),
        items: const [
          BillItem(
            name: 'Special Rich Belgian Chocolate Cold Coffee with Roasted Almond Crush',
            quantity: 3,
            rate: 80.0,
            amount: 240.0,
          ),
          BillItem(
            name: 'Classic Softy',
            quantity: 1,
            rate: 30.0,
            amount: 30.0,
          ),
          BillItem(
            name: 'Strawberry Double Swirl Sundae Cup with Sprinkles',
            quantity: 2,
            rate: 65.0,
            amount: 130.0,
          ),
        ],
        subtotal: 400.0,
        grandTotal: 400.0,
      );

      const config58 = PrinterConfig(paperSize: ReceiptPaperSize.mm58);
      final bytes58 = await ReceiptBuilder.buildReceipt(
        bill: billWithLongNames,
        config: config58,
      );
      expect(bytes58, isNotEmpty);

      const config80 = PrinterConfig(paperSize: ReceiptPaperSize.mm80);
      final bytes80 = await ReceiptBuilder.buildReceipt(
        bill: billWithLongNames,
        config: config80,
      );
      expect(bytes80, isNotEmpty);
    });

    test('cleans rupee symbol and unicode emojis cleanly', () {
      expect(ReceiptBuilder.cleanText('Price: ₹50.00 🍦'), equals('Price: Rs.50.00 '));
    });

    test('builds receipt with raster heading option enabled', () async {
      const configRaster = PrinterConfig(
        shopName: 'जॉयस्कूप Joyscoop ₹',
        useRasterHeading: true,
        paperSize: ReceiptPaperSize.mm58,
      );
      final bytes = await ReceiptBuilder.buildReceipt(
        bill: sampleBill,
        config: configRaster,
      );
      expect(bytes, isNotEmpty);
    });
  });
}

