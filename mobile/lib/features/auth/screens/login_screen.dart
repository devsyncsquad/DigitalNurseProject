import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        context.go('/home');
      } else {
        _showErrorDialog(authProvider.error ?? 'Login failed');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('auth.login.failed'.tr()),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.ok'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return FScaffold(
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
                    FIcons.heartPulse,
                    size: 80.r,
                    color: context.theme.colors.primary,
                  ),
                  SizedBox(height: 16.h),

                  // Title
                  Text(
                    'app.name'.tr(),
                    style: context.theme.typography.xl4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'auth.login.welcomeBack'.tr(),
                    style: context.theme.typography.base,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 48.h),

                  // Email field
                  FTextField(
                    controller: _emailController,
                    label: Text('auth.login.email'.tr()),
                    hint: 'auth.login.emailHint'.tr(),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16.h),

                  // Password field
                  FTextField(
                    controller: _passwordController,
                    label: Text('auth.login.password'.tr()),
                    hint: 'auth.login.passwordHint'.tr(),
                    obscureText: _obscurePassword,
                  ),
                  SizedBox(height: 24.h),

                  // Login button
                  FButton(
                    onPress: authProvider.isLoading ? null : _handleLogin,
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
                        : Text('auth.login.loginButton'.tr()),
                  ),
                  SizedBox(height: 16.h),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'auth.login.noAccount'.tr(),
                        style: context.theme.typography.sm,
                      ),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: Text('auth.login.registerLink'.tr()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
