import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class AuthRepository {
  final SupabaseClient? client;

  AuthRepository({this.client});

  /// Stream of Supabase Auth state changes
  Stream<AuthState>? get authStateChanges => client?.auth.onAuthStateChange;

  /// Current user
  User? get currentUser => client?.auth.currentUser;

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    if (client == null || !SupabaseConfig.isConfigured) {
      // Offline/Demo mock mode for testing without backend credentials
      debugPrint('Demo Mode Sign-in for $email');
      await Future.delayed(const Duration(milliseconds: 600));
      return;
    }

    await client!.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    if (client != null && SupabaseConfig.isConfigured) {
      await client!.auth.signOut();
    }
  }

  /// Fetch user profile display name from `profiles` table
  Future<String> fetchDisplayName() async {
    if (client == null || !SupabaseConfig.isConfigured) {
      return 'Diya'; // Default friendly staff name in demo mode
    }

    final userId = client!.auth.currentUser?.id;
    if (userId == null) return 'Staff';

    try {
      final response = await client!
          .from('profiles')
          .select('display_name')
          .eq('id', userId)
          .maybeSingle();

      if (response != null && response['display_name'] != null) {
        return response['display_name'] as String;
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }

    // Fallback to email username or 'Staff'
    final email = client!.auth.currentUser?.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'Staff';
  }
}

