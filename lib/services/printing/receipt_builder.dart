import 'dart:ui' as ui;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/painting.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'models/bill.dart';
import 'models/printer_config.dart';

/// Pure function to build ESC/POS byte commands for thermal receipt printing.
/// Contains no UI code and can be invoked from any service, background worker, or test.
class ReceiptBuilder {
  ReceiptBuilder._();

  /// Converts a [Bill] and [PrinterConfig] into a raw ESC/POS byte sequence.
  static Future<List<int>> buildReceipt({
    required Bill bill,
    required PrinterConfig config,
    CapabilityProfile? profile,
  }) async {
    final capProfile = profile ?? await CapabilityProfile.load();
    final paperSize = config.paperSize == ReceiptPaperSize.mm80
        ? PaperSize.mm80
        : PaperSize.mm58;

    final generator = Generator(paperSize, capProfile);
    List<int> bytes = [];

    final printableWidth = config.paperSize == ReceiptPaperSize.mm80 ? 576 : 384;

    // Reset printer state
    bytes += generator.reset();

    // 1. Header (Shop Name, Address, Phone, GSTIN)
    if (config.shopName.isNotEmpty) {
      if (config.useRasterHeading) {
        bytes += await _renderRasterTextLine(
          generator: generator,
          text: config.shopName,
          fontSize: 26,
          bold: true,
          width: printableWidth,
        );
      } else {
        bytes += generator.text(
          cleanText(config.shopName),
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
          linesAfter: 1,
        );
      }
    }

    if (config.address.isNotEmpty) {
      bytes += generator.text(
        cleanText(config.address),
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    if (config.phone.isNotEmpty) {
      bytes += generator.text(
        'Phone: ${cleanText(config.phone)}',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    if (config.gstin.isNotEmpty) {
      bytes += generator.text(
        'GSTIN: ${cleanText(config.gstin)}',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    // 2. Bill Meta Info
    bytes += generator.hr(ch: '=');
    bytes += generator.row([
      PosColumn(
        text: 'Bill No: ${cleanText(bill.billNumber)}',
        width: 6,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: DateFormat('dd/MM/yy hh:mm a').format(bill.dateTime),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    if (bill.customerName != null && bill.customerName!.isNotEmpty) {
      final custPhone = bill.customerPhone != null
          ? ' (${cleanText(bill.customerPhone!)})'
          : '';
      bytes += generator.text(
        'Customer: ${cleanText(bill.customerName!)}$custPhone',
        styles: const PosStyles(align: PosAlign.left),
      );
    }

    // 3. Item Table Header
    bytes += generator.hr(ch: '-');
    bytes += generator.row([
      PosColumn(
        text: 'Item',
        width: 6,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: 'Qty',
        width: 2,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
      PosColumn(
        text: 'Rate',
        width: 2,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
      PosColumn(
        text: 'Amount',
        width: 2,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    bytes += generator.hr(ch: '-');

    // 4. Item Rows with multi-line wrapping so columns never break
    final maxCharsForCol =
        config.paperSize == ReceiptPaperSize.mm80 ? 22 : 14;

    for (final item in bill.items) {
      final cleanName = cleanText(item.name);
      final chunks = _wrapText(cleanName, maxCharsForCol);
      final firstChunk = chunks.isNotEmpty ? chunks.first : cleanName;

      // Print first line containing Qty, Rate, Amount
      bytes += generator.row([
        PosColumn(
          text: firstChunk,
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '${item.quantity}',
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: _formatCurrency(item.rate),
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: _formatCurrency(item.amount),
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      // Print subsequent wrapped lines for item name (empty right columns)
      for (int i = 1; i < chunks.length; i++) {
        bytes += generator.row([
          PosColumn(
            text: chunks[i],
            width: 6,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(text: '', width: 2),
          PosColumn(text: '', width: 2),
          PosColumn(text: '', width: 2),
        ]);
      }
    }

    bytes += generator.hr(ch: '-');

    // 5. Financial Summary (Subtotal, Discount, Taxes)
    bytes += generator.row([
      PosColumn(
        text: 'Subtotal',
        width: 7,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: _formatCurrency(bill.subtotal),
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    if (bill.discount > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'Discount',
          width: 7,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '-${_formatCurrency(bill.discount)}',
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    if (bill.cgst != null && bill.cgst! > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'CGST',
          width: 7,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: _formatCurrency(bill.cgst!),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    if (bill.sgst != null && bill.sgst! > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'SGST',
          width: 7,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: _formatCurrency(bill.sgst!),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    if (bill.igst != null && bill.igst! > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'IGST',
          width: 7,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: _formatCurrency(bill.igst!),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    // 6. Grand Total (Large bold text or rasterized image)
    bytes += generator.hr(ch: '=');
    if (config.useRasterHeading) {
      bytes += await _renderRasterTextLine(
        generator: generator,
        text: 'TOTAL: ${_formatCurrency(bill.grandTotal)}',
        fontSize: 24,
        bold: true,
        width: printableWidth,
      );
    } else {
      bytes += generator.row([
        PosColumn(
          text: 'GRAND TOTAL',
          width: 6,
          styles: const PosStyles(
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size1,
          ),
        ),
        PosColumn(
          text: _formatCurrency(bill.grandTotal),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size1,
          ),
        ),
      ]);
    }
    bytes += generator.hr(ch: '=');

    // 7. Optional UPI Payment QR Code
    if (config.upiId.isNotEmpty && bill.grandTotal > 0) {
      final sanitizedShop =
          cleanText(config.shopName).replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '');
      final upiUrl =
          'upi://pay?pa=${config.upiId}&pn=${Uri.encodeComponent(sanitizedShop)}&am=${bill.grandTotal.toStringAsFixed(2)}&cu=INR';

      bytes += generator.text(
        'Scan to Pay via UPI',
        styles: const PosStyles(align: PosAlign.center, bold: true),
        linesAfter: 1,
      );

      bytes += generator.qrcode(
        upiUrl,
        size: QRSize.size4,
        align: PosAlign.center,
      );

      bytes += generator.text(
        'UPI ID: ${cleanText(config.upiId)}',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
      bytes += generator.hr(ch: '-');
    }

    // 8. Footer Message
    final cleanedFooter = cleanText(config.footerMessage);
    if (cleanedFooter.isNotEmpty) {
      bytes += generator.text(
        cleanedFooter,
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
    }

    // 9. Feed 3 lines & Paper Cut Command
    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }

  /// Cleans text for ESC/POS ASCII/Latin-1 printer encoding.
  /// Converts ₹ to 'Rs.' and strips characters outside ISO-8859-1 (like emojis)
  /// to prevent Latin1Codec encoding exceptions.
  static String cleanText(String input) {
    if (input.isEmpty) return '';
    final rupeeConverted = input.replaceAll('₹', 'Rs.');
    return rupeeConverted.replaceAll(RegExp(r'[^\x00-\xFF]'), '');
  }

  /// Format money without ₹ symbol as printers lack Unicode currency glyphs
  static String _formatCurrency(double amount) {
    if (amount.truncateToDouble() == amount) {
      return 'Rs. ${amount.toInt()}';
    } else {
      return 'Rs. ${amount.toStringAsFixed(2)}';
    }
  }

  /// Breaks a string into chunks of at most [maxChars] characters along word boundaries
  static List<String> _wrapText(String text, int maxChars) {
    if (text.length <= maxChars) return [text];

    final List<String> lines = [];
    final words = text.split(' ');
    String currentLine = '';

    for (final word in words) {
      if (currentLine.isEmpty) {
        if (word.length <= maxChars) {
          currentLine = word;
        } else {
          // Word longer than maxChars: split hard
          var remaining = word;
          while (remaining.length > maxChars) {
            lines.add(remaining.substring(0, maxChars));
            remaining = remaining.substring(maxChars);
          }
          currentLine = remaining;
        }
      } else if (currentLine.length + 1 + word.length <= maxChars) {
        currentLine += ' $word';
      } else {
        lines.add(currentLine);
        if (word.length <= maxChars) {
          currentLine = word;
        } else {
          var remaining = word;
          while (remaining.length > maxChars) {
            lines.add(remaining.substring(0, maxChars));
            remaining = remaining.substring(maxChars);
          }
          currentLine = remaining;
        }
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines;
  }

  /// Renders text with regional language / Unicode font onto a bitmap canvas
  /// and returns ESC/POS bitImageRaster byte commands so ₹ and Marathi/Hindi print accurately.
  static Future<List<int>> _renderRasterTextLine({
    required Generator generator,
    required String text,
    double fontSize = 24,
    bool bold = true,
    int width = 384,
  }) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final textSpan = TextSpan(
        text: text,
        style: TextStyle(
          color: const Color(0xFF000000),
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout(maxWidth: width.toDouble());

      final height = (textPainter.height + 8).ceil();
      final bgPaint = Paint()..color = const Color(0xFFFFFFFF);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        bgPaint,
      );

      final xOffset = (width - textPainter.width) / 2;
      textPainter.paint(
        canvas,
        Offset(xOffset.clamp(0, width).toDouble(), 4),
      );

      final picture = recorder.endRecording();
      final imgUi = await picture.toImage(width, height);
      final byteData = await imgUi.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return [];

      final decoded = img.decodePng(byteData.buffer.asUint8List());
      if (decoded == null) return [];

      return generator.imageRaster(decoded, align: PosAlign.center);
    } catch (_) {
      // Fallback to plain Latin text if raster rendering fails in headless environment
      return generator.text(
        cleanText(text),
        styles: PosStyles(
          align: PosAlign.center,
          bold: bold,
        ),
      );
    }
  }
}
