import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  try {
    return AuthRepository(client: Supabase.instance.client);
  } catch (_) {
    return AuthRepository(client: null);
  }
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String displayName;
  final String? errorMessage;

  const AuthState({
    required this.isAuthenticated,
    this.isLoading = false,
    this.displayName = 'Staff',
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? displayName,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      displayName: displayName ?? this.displayName,
      errorMessage: errorMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository)
      : super(AuthState(
          isAuthenticated: _repository.currentUser != null,
        )) {
    _init();
  }

  void _init() async {
    if (_repository.currentUser != null) {
      final name = await _repository.fetchDisplayName();
      state = state.copyWith(
        isAuthenticated: true,
        displayName: name,
      );
    }

    _repository.authStateChanges?.listen((data) async {
      final user = data.session?.user;
      if (user != null) {
        final name = await _repository.fetchDisplayName();
        state = state.copyWith(
          isAuthenticated: true,
          displayName: name,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          displayName: 'Staff',
        );
      }
    });
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.signIn(email: email, password: password);
      final name = await _repository.fetchDisplayName();
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        displayName: name,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState(isAuthenticated: false, displayName: 'Staff');
  }

  /// Demo quick login for testing without typing
  Future<void> demoLogin(String name) async {
    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      displayName: name,
    );
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

