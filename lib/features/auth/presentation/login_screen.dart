import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/background_gradient_scaffold.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/app_snack_bar.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      AppSnackBar.show(
        context,
        message: 'Please enter both email and password',
        isError: true,
      );
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .signIn(email, password);

    if (!success && mounted) {
      final error = ref.read(authControllerProvider).errorMessage ?? 'Login failed';
      AppSnackBar.show(
        context,
        message: error,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return BackgroundGradientScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPadding,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: AppDimensions.space32),
                  // Joyscoop Logo Centered at Top with transparent background
                  SizedBox(
                    height: 100,
                    child: Image.asset(
                      'assets/branding/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.icecream_rounded,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space24),
                  // Welcome Back Title
                  Text(
                    'Welcome back',
                    style: AppTextStyles.title.copyWith(fontSize: 26),
                  ),
                  const SizedBox(height: AppDimensions.space8),
                  Text(
                    'Sign in to Joyscoop daily sales counter',
                    style: AppTextStyles.caption.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: AppDimensions.space32),

                  // Email Field (White rounded, radius 28, no border, soft shadow)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppDimensions.borderPill,
                      boxShadow: AppShadows.inputFieldShadow,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space20,
                      vertical: AppDimensions.space4,
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Email address',
                        hintStyle: AppTextStyles.caption.copyWith(fontSize: 14),
                        icon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // Password Field (White rounded, radius 28, no border, soft shadow)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppDimensions.borderPill,
                      boxShadow: AppShadows.inputFieldShadow,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space20,
                      vertical: AppDimensions.space4,
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleSignIn(),
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Password',
                        hintStyle: AppTextStyles.caption.copyWith(fontSize: 14),
                        icon: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space24),

                  // Primary Pill "Sign in"
                  PrimaryButton(
                    text: 'Sign in',
                    isLoading: authState.isLoading,
                    onPressed: _handleSignIn,
                  ),

                  const SizedBox(height: AppDimensions.space24),

                  // Quick test access button for quick local evaluation without backend
                  TextButton(
                    onPressed: () {
                      ref.read(authControllerProvider.notifier).demoLogin('Aarav');
                    },
                    child: Text(
                      'Quick Staff Access (Demo Mode)',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

