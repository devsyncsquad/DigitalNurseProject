import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/modern_scaffold.dart';
import '../../../core/theme/modern_surface_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final bool _obscurePassword = true;
  bool _showTestCredentials = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _phoneController.text.trim(),
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

    return ModernScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: ModernSurfaceTheme.screenPadding(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40.h),
                
                // Hero section with logo/title
                Container(
                  decoration: ModernSurfaceTheme.heroDecoration(context),
                  padding: ModernSurfaceTheme.heroPadding(),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      // Logo/Icon
                      Icon(
                        FIcons.heartPulse,
                        size: 80.r,
                        color: Colors.white,
                      ),
                      SizedBox(height: ModernSurfaceTheme.heroSpacing()),

                      // Title
                      Text(
                        'app.name'.tr(),
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'auth.login.welcomeBack'.tr(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),

                // Form container with glassmorphic card
                Container(
                  decoration: ModernSurfaceTheme.glassCard(context, highlighted: true),
                  padding: ModernSurfaceTheme.cardPadding(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Phone field
                      FTextField(
                        controller: _phoneController,
                        label: Text('auth.login.phone'.tr()),
                        hint: 'auth.login.phoneHint'.tr(),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 20.h),

                      // Password field
                      FTextField(
                        controller: _passwordController,
                        label: Text('auth.login.password'.tr()),
                        hint: 'auth.login.passwordHint'.tr(),
                        obscureText: _obscurePassword,
                      ),
                      SizedBox(height: 28.h),

                      // Login button with modern pill style
                      Container(
                        decoration: ModernSurfaceTheme.pillButton(
                          context,
                          ModernSurfaceTheme.primaryTeal,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: authProvider.isLoading ? null : _handleLogin,
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              alignment: Alignment.center,
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
                                  : Text(
                                      'auth.login.loginButton'.tr(),
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Test credentials section
                Container(
                  decoration: ModernSurfaceTheme.glassCard(context),
                  padding: ModernSurfaceTheme.cardPadding(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showTestCredentials = !_showTestCredentials;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  FIcons.info,
                                  size: 20.r,
                                  color: ModernSurfaceTheme.accentBlue,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Test Credentials',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              _showTestCredentials ? Icons.expand_less : Icons.expand_more,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                      if (_showTestCredentials) ...[
                        SizedBox(height: 16.h),
                        Divider(),
                        SizedBox(height: 12.h),
                        _buildTestCredential('Patient User', '+923001234567', 'password123'),
                        SizedBox(height: 12.h),
                        _buildTestCredential('Caregiver User', '+923007654321', 'password123'),
                        SizedBox(height: 8.h),
                        TextButton(
                          onPressed: () {
                            _phoneController.text = '+923001234567';
                            _passwordController.text = 'password123';
                            setState(() {
                              _showTestCredentials = false;
                            });
                          },
                          child: Text(
                            'Use Patient Credentials',
                            style: TextStyle(
                              color: ModernSurfaceTheme.primaryTeal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'auth.login.noAccount'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      ),
                      child: Text(
                        'auth.login.registerLink'.tr(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: ModernSurfaceTheme.primaryTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestCredential(String label, String phone, String password) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Phone: $phone',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            'Password: $password',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
