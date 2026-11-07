import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/navigation/main_nav_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.anonKey,
      );
      SupabaseConfig.printStatus();
    } catch (e) {
      debugPrint('Failed to initialize Supabase: $e');
    }
  } else {
    SupabaseConfig.printStatus();
  }

  runApp(
    const ProviderScope(
      child: JoyScoopApp(),
    ),
  );
}

class JoyScoopApp extends ConsumerWidget {
  const JoyScoopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return MaterialApp(
      title: 'Joyscoop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.04),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: authState.isAuthenticated
            ? const MainNavShell(key: ValueKey('main_shell'))
            : const LoginScreen(key: ValueKey('login_screen')),
      ),
    );
  }
}
