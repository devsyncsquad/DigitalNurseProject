import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/user_model.dart';

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
  final _phoneController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final bool _obscurePassword = true;
  final bool _obscureConfirmPassword = true;
  UserRole _selectedRole = UserRole.patient;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final inviteCode = _inviteCodeController.text.trim();
    if (_selectedRole == UserRole.caregiver && inviteCode.isEmpty) {
      _showErrorDialog('auth.register.caregiverInviteRequired'.tr());
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      role: _selectedRole,
      phone: _phoneController.text.trim(),
      caregiverInviteCode:
          _selectedRole == UserRole.caregiver ? inviteCode : null,
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

                    // Phone field (optional)
                    FTextField(
                      controller: _phoneController,
                      label: Text('auth.register.phone'.tr()),
                      hint: 'auth.register.phoneHint'.tr(),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 24.h),

                    // Role selection
                    Text(
                      'auth.register.accountType'.tr(),
                      style: context.theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.theme.colors.foreground,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      decoration: BoxDecoration(
                        color: context.theme.colors.muted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: UserRole.values.map((role) {
                          final isSelected = role == _selectedRole;
                          return RadioListTile<UserRole>(
                            value: role,
                            groupValue: _selectedRole,
                            onChanged: authProvider.isLoading
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedRole = value;
                                      });
                                    }
                                  },
                            title: Text(
                              role == UserRole.patient
                                  ? 'auth.register.rolePatient'.tr()
                                  : 'auth.register.roleCaregiver'.tr(),
                              style: context.theme.typography.base.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              role == UserRole.patient
                                  ? 'auth.register.rolePatientDesc'.tr()
                                  : 'auth.register.roleCaregiverDesc'.tr(),
                              style: context.theme.typography.sm.copyWith(
                                color: context.theme.colors.mutedForeground,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    if (_selectedRole == UserRole.caregiver) ...[
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: context.theme.colors.muted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              FIcons.info,
                              color: context.theme.colors.primary,
                              size: 20.r,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'auth.register.caregiverInfoTitle'.tr(),
                                    style: context.theme.typography.sm.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'auth.register.caregiverInfoBody'.tr(),
                                    style: context.theme.typography.sm,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      FTextField(
                        controller: _inviteCodeController,
                        label: Text('auth.register.inviteCode'.tr()),
                        hint: 'auth.register.inviteCodeHint'.tr(),
                      ),
                      SizedBox(height: 24.h),
                    ],

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
