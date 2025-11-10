import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/providers/caregiver_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class AddCaregiverScreen extends StatefulWidget {
  const AddCaregiverScreen({super.key});

  @override
  State<AddCaregiverScreen> createState() => _AddCaregiverScreenState();
}

class _AddCaregiverScreenState extends State<AddCaregiverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _relationshipController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter a valid email address'),
          backgroundColor: AppTheme.getErrorColor(context),
        ),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Phone number is required'),
          backgroundColor: AppTheme.getErrorColor(context),
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final patientId = authProvider.currentUser!.id;

    final invitation = await context.read<CaregiverProvider>().inviteCaregiver(
      patientId: patientId,
      email: email,
      phone: phone,
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      relationship: _relationshipController.text.trim().isEmpty
          ? null
          : _relationshipController.text.trim(),
    );

    if (!mounted) return;

    if (invitation != null) {
      _showInvitationSentDialog(invitation);
    } else {
      final error = context.read<CaregiverProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to send invitation'),
          backgroundColor: AppTheme.getErrorColor(context),
        ),
      );
    }
  }

  void _showInvitationSentDialog(Map<String, dynamic> invitation) {
    final inviteCode =
        invitation['inviteCode']?.toString() ?? invitation['code']?.toString();
    final inviteLink = inviteCode != null && inviteCode.isNotEmpty
        ? 'https://digitalnurse.app/invite/$inviteCode'
        : null;
    final expiresAtRaw = invitation['expiresAt'] ?? invitation['expires_at'];
    DateTime? expiresAt;
    if (expiresAtRaw != null) {
      try {
        expiresAt = DateTime.parse(expiresAtRaw.toString());
      } catch (_) {
        expiresAt = null;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invitation Sent!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'An invitation has been sent to the caregiver. Share the link below so they can join and accept.',
            ),
            const SizedBox(height: 16),
            if (inviteLink != null) ...[
              const Text('Shareable Link:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.theme.colors.muted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  inviteLink,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
            if (expiresAt != null) ...[
              const SizedBox(height: 12),
              Text(
                'Expires: ${expiresAt.toLocal()}',
                style: context.theme.typography.xs.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: const Text('Add Caregiver'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Invite someone to help manage your care',
                  style: context.theme.typography.base,
                ),
                SizedBox(height: 24.h),

                FTextField(
                  controller: _emailController,
                  label: const Text('Email'),
                  hint: 'caregiver@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16.h),

                FTextField(
                  controller: _phoneController,
                  label: const Text('Phone Number'),
                  hint: '+1234567890',
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16.h),

                FTextField(
                  controller: _nameController,
                  label: const Text('Name (Optional)'),
                  hint: 'Caregiver name',
                ),
                SizedBox(height: 16.h),

                FTextField(
                  controller: _relationshipController,
                  label: const Text('Relationship (Optional)'),
                  hint: 'e.g., Daughter, Son, Friend',
                ),
                SizedBox(height: 24.h),

                FButton(
                  onPress: _handleAdd,
                  child: const Text('Send Invitation'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
