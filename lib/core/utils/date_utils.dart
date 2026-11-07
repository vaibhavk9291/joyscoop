import 'package:intl/intl.dart';

/// Utilities for Business Date calculations in Asia/Kolkata (IST)
class AppDateUtils {
  AppDateUtils._();

  /// Returns current DateTime in Asia/Kolkata (IST = UTC + 5:30)
  static DateTime nowIst() {
    return DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
  }

  /// Current business date formatted as YYYY-MM-DD (IST calendar date)
  static String currentBusinessDateString() {
    final ist = nowIst();
    return DateFormat('yyyy-MM-dd').format(ist);
  }

  /// Greeting based on current IST time
  static String getGreeting() {
    final hour = nowIst().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  /// Formatted date string for display (e.g. "Sat, 7 Nov")
  static String formatDisplayDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEE, d MMM').format(date);
    } catch (_) {
      return dateString;
    }
  }

  /// Formatted date string with year (e.g. "07 Nov 2026")
  static String formatFullDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Check if date string matches today's IST date
  static bool isToday(String dateString) {
    return dateString == currentBusinessDateString();
  }
}

