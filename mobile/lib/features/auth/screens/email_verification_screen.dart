import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class EmailVerificationScreen extends StatelessWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  Future<void> _handleContinue(BuildContext context) async {
    // In real app, would check if email is verified
    // For mock, just continue to profile setup
    context.go('/profile-setup');
  }

  Future<void> _handleResend(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.verifyEmail(email);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Verification email sent!'),
          backgroundColor: AppTheme.getSuccessColor(context),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Success icon
                Icon(
                  FIcons.mailCheck,
                  size: 100.r,
                  color: context.theme.colors.primary,
                ),
                SizedBox(height: 32.h),

                // Title
                Text(
                  'Verify Your Email',
                  style: context.theme.typography.xl4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),

                // Message
                Text(
                  'We\'ve sent a verification link to:',
                  style: context.theme.typography.base,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  email,
                  style: context.theme.typography.base.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.theme.colors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Please check your inbox and click the verification link to continue.',
                  style: context.theme.typography.sm,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48.h),

                // Continue button (for mock flow)
                FButton(
                  onPress: () => _handleContinue(context),
                  child: const Text('Continue'),
                ),
                SizedBox(height: 16.h),

                // Resend button
                TextButton(
                  onPressed: () => _handleResend(context),
                  child: const Text('Resend Email'),
                ),
                SizedBox(height: 24.h),

                // Back to login
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Back to Login',
                    style: context.theme.typography.sm.copyWith(
                      color: context.theme.colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
