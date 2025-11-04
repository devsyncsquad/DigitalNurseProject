import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        title: const Text('Registration Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
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
                      'Create Account',
                      style: context.theme.typography.xl4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Sign up to get started',
                      style: context.theme.typography.base,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 48.h),

                    // Name field
                    FTextField(
                      controller: _nameController,
                      label: const Text('Full Name'),
                      hint: 'Enter your name',
                    ),
                    SizedBox(height: 16.h),

                    // Email field
                    FTextField(
                      controller: _emailController,
                      label: const Text('Email'),
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16.h),

                    // Password field
                    FTextField(
                      controller: _passwordController,
                      label: const Text('Password'),
                      hint: 'Enter your password',
                      obscureText: _obscurePassword,
                    ),
                    SizedBox(height: 16.h),

                    // Confirm Password field
                    FTextField(
                      controller: _confirmPasswordController,
                      label: const Text('Confirm Password'),
                      hint: 'Confirm your password',
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
                          : const Text('Create Account'),
                    ),
                    SizedBox(height: 16.h),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: context.theme.typography.sm,
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Login'),
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
