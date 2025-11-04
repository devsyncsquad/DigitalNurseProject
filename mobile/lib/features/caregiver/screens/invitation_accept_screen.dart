import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/caregiver_provider.dart';
import '../../../core/theme/app_theme.dart';

class InvitationAcceptScreen extends StatefulWidget {
  final String caregiverId;

  const InvitationAcceptScreen({super.key, required this.caregiverId});

  @override
  State<InvitationAcceptScreen> createState() => _InvitationAcceptScreenState();
}

class _InvitationAcceptScreenState extends State<InvitationAcceptScreen> {
  bool _termsAccepted = false;

  Future<void> _handleAccept() async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the terms to continue'),
          backgroundColor: AppTheme.getWarningColor(context),
        ),
      );
      return;
    }

    final success = await context.read<CaregiverProvider>().acceptInvitation(
      widget.caregiverId,
    );

    if (mounted) {
      if (success) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to accept invitation'),
            backgroundColor: AppTheme.getErrorColor(context),
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Welcome!'),
        content: const Text(
          'You have successfully accepted the caregiver invitation. You can now access the patient\'s health information and help manage their care.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
            },
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.pop();
        }
      },
      child: FScaffold(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    FIcons.userPlus,
                    size: 80,
                    color: context.theme.colors.primary,
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Caregiver Invitation',
                    style: context.theme.typography.xl3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'You have been invited to become a caregiver.',
                    style: context.theme.typography.base,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  FCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'As a caregiver, you will be able to:',
                            style: context.theme.typography.sm.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _BulletPoint('View patient health information'),
                          _BulletPoint('Monitor medication adherence'),
                          _BulletPoint('Access vital measurements'),
                          _BulletPoint('View shared documents'),
                          _BulletPoint('Receive health alerts'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Terms checkbox
                  FCard(
                    child: Material(
                      child: CheckboxListTile(
                        value: _termsAccepted,
                        onChanged: (value) {
                          setState(() {
                            _termsAccepted = value ?? false;
                          });
                        },
                        title: Text(
                          'I agree to the Terms of Service and Privacy Policy',
                          style: context.theme.typography.sm,
                        ),
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  FButton(
                    onPress: _handleAccept,
                    child: const Text('Accept Invitation'),
                  ),
                  const SizedBox(height: 16),

                  OutlinedButton(
                    onPressed: () => context.go('/welcome'),
                    child: const Text('Decline'),
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

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(FIcons.check, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: context.theme.typography.sm)),
        ],
      ),
    );
  }
}
