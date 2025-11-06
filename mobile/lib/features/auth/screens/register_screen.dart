import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final bool _obscurePassword = true;
  final bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (mounted) {
      if (success) {
        context.go('/email-verification?email=${_emailController.text.trim()}');
      } else {
        _showErrorDialog(authProvider.error ?? 'Registration failed');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('auth.register.failed'.tr()),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: context.theme.colors.primary,
            ),
            child: Text('common.ok'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: FScaffold(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo/Icon
                    Icon(
                      FIcons.userPlus,
                      size: 80.r,
                      color: context.theme.colors.primary,
                    ),
                    SizedBox(height: 16.h),

                    // Title
                    Text(
                      'auth.register.title'.tr(),
                      style: context.theme.typography.xl4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'auth.register.subtitle'.tr(),
                      style: context.theme.typography.base,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 48.h),

                    // Name field
                    FTextField(
                      controller: _nameController,
                      label: Text('auth.register.fullName'.tr()),
                      hint: 'auth.register.nameHint'.tr(),
                    ),
                    SizedBox(height: 16.h),

                    // Email field
                    FTextField(
                      controller: _emailController,
                      label: Text('auth.register.email'.tr()),
                      hint: 'auth.register.emailHint'.tr(),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16.h),

                    // Password field
                    FTextField(
                      controller: _passwordController,
                      label: Text('auth.register.password'.tr()),
                      hint: 'auth.register.passwordHint'.tr(),
                      obscureText: _obscurePassword,
                    ),
                    SizedBox(height: 16.h),

                    // Confirm Password field
                    FTextField(
                      controller: _confirmPasswordController,
                      label: Text('auth.register.confirmPassword'.tr()),
                      hint: 'auth.register.confirmPasswordHint'.tr(),
                      obscureText: _obscureConfirmPassword,
                    ),
                    SizedBox(height: 24.h),

                    // Register button
                    FButton(
                      onPress: authProvider.isLoading ? null : _handleRegister,
                      child: authProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text('auth.register.createAccount'.tr()),
                    ),
                    SizedBox(height: 16.h),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'auth.register.hasAccount'.tr(),
                          style: context.theme.typography.sm.copyWith(
                            color: context.theme.colors.foreground,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          style: TextButton.styleFrom(
                            foregroundColor: context.theme.colors.primary,
                          ),
                          child: Text('auth.register.loginLink'.tr()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
