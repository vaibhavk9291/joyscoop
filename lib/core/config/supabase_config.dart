import 'package:flutter/foundation.dart';

/// Configuration for Supabase Backend Connection
class SupabaseConfig {
  SupabaseConfig._();

  /// Loaded from `--dart-define=SUPABASE_URL=...` or defaults to provided shop project
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: String.fromEnvironment(
      'NEXT_PUBLIC_SUPABASE_URL',
      defaultValue: 'https://jkigjwlgwidtuotfvkyp.supabase.co',
    ),
  );

  /// Loaded from `--dart-define=SUPABASE_ANON_KEY=...` or defaults to provided publishable key
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: String.fromEnvironment(
      'NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY',
      defaultValue: 'sb_publishable_VhOu70jxG7OwFdxxNtv7pw_hvQo2aL9',
    ),
  );

  /// Helper to check if credentials are provided
  static bool get isConfigured =>
      url.isNotEmpty &&
      !url.contains('placeholder') &&
      anonKey.isNotEmpty &&
      !anonKey.contains('placeholder');

  static void printStatus() {
    if (kDebugMode) {
      if (isConfigured) {
        debugPrint('Supabase initialized with URL: $url');
      } else {
        debugPrint('WARNING: Supabase URL or Anon Key not provided');
      }
    }
  }
}
