import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ageController.dispose();
    _phoneController.dispose();
    _medicalConditionsController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      age: _ageController.text.trim(),
      phone: _phoneController.text.trim(),
      medicalConditions: _medicalConditionsController.text.trim(),
      emergencyContact: _emergencyContactController.text.trim(),
    );

    if (mounted) {
      if (success) {
        context.go('/subscription-plans');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Failed to update profile'),
            backgroundColor: AppTheme.getErrorColor(context),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return FScaffold(
      header: FHeader(title: const Text('Complete Your Profile')),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Help us personalize your experience',
                  style: context.theme.typography.base,
                ),
                const SizedBox(height: 32),

                // Age field
                FTextField(
                  controller: _ageController,
                  label: const Text('Age'),
                  hint: 'Enter your age',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Phone field
                FTextField(
                  controller: _phoneController,
                  label: const Text('Phone Number'),
                  hint: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Medical conditions field
                FTextField(
                  controller: _medicalConditionsController,
                  label: const Text('Medical Conditions (Optional)'),
                  hint: 'e.g., Diabetes, Hypertension',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Emergency contact field
                FTextField(
                  controller: _emergencyContactController,
                  label: const Text('Emergency Contact'),
                  hint: 'Name and phone number',
                ),
                const SizedBox(height: 32),

                // Continue button
                FButton(
                  onPress: authProvider.isLoading ? null : _handleContinue,
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
                      : const Text('Continue'),
                ),
                const SizedBox(height: 16),

                // Skip button
                TextButton(
                  onPressed: () => context.go('/subscription-plans'),
                  child: Text(
                    'Skip for now',
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
