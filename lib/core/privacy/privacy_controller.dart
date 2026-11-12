import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Privacy state notifier: controls masking/unmasking of sales revenues and quantities.
/// Defaults to `true` (hidden by default) so revenue and quantities stay confidential.
class PrivacyNotifier extends StateNotifier<bool> {
  static const String _storageKey = 'joyscoop_privacy_mode_enabled';

  PrivacyNotifier() : super(true) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedValue = prefs.getBool(_storageKey);
      if (savedValue != null) {
        state = savedValue;
      }
    } catch (_) {}
  }

  Future<void> togglePrivacy() async {
    state = !state;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_storageKey, state);
    } catch (_) {}
  }

  Future<void> setPrivacy(bool isPrivate) async {
    state = isPrivate;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_storageKey, isPrivate);
    } catch (_) {}
  }
}

final privacyProvider = StateNotifierProvider<PrivacyNotifier, bool>((ref) {
  return PrivacyNotifier();
});

