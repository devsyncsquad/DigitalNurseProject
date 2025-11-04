import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/medication_provider.dart';
import '../../../core/providers/health_provider.dart';
import '../../../core/providers/caregiver_provider.dart';
import '../../../core/providers/lifestyle_provider.dart';
import '../../../core/providers/document_provider.dart';
import '../../../core/providers/notification_provider.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  SubscriptionTier? _selectedTier;

  Future<void> _handleContinue() async {
    final authProvider = context.read<AuthProvider>();

    // Update subscription if premium selected
    if (_selectedTier == SubscriptionTier.premium) {
      await authProvider.updateSubscription(SubscriptionTier.premium);
    }

    // Initialize mock data for all providers
    final userId = authProvider.currentUser!.id;
    await Future.wait([
      context.read<MedicationProvider>().initializeMockData(userId),
      context.read<HealthProvider>().initializeMockData(userId),
      context.read<CaregiverProvider>().initializeMockData(userId),
      context.read<LifestyleProvider>().initializeMockData(userId),
      context.read<DocumentProvider>().initializeMockData(userId),
      context.read<NotificationProvider>().initializeMockData(),
    ]);

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(title: const Text('Choose Your Plan')),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select a subscription plan',
                style: context.theme.typography.xl.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You can upgrade or downgrade anytime',
                style: context.theme.typography.sm,
              ),
              const SizedBox(height: 32),

              // Free plan
              _PlanCard(
                title: 'Free',
                price: '\$0',
                period: 'forever',
                features: const [
                  'Basic medicine reminders',
                  'Vitals tracking',
                  'Up to 2 caregivers',
                  'Document storage (50MB)',
                  'Email support',
                ],
                isSelected: _selectedTier == SubscriptionTier.free,
                onTap: () {
                  setState(() {
                    _selectedTier = SubscriptionTier.free;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Premium plan
              _PlanCard(
                title: 'Premium',
                price: '\$9.99',
                period: 'per month',
                features: const [
                  'Advanced medicine reminders',
                  'Unlimited vitals tracking',
                  'Unlimited caregivers',
                  'Unlimited document storage',
                  'Diet & exercise tracking',
                  'Health trends & insights',
                  'Priority support',
                  'Export reports',
                ],
                isSelected: _selectedTier == SubscriptionTier.premium,
                isPremium: true,
                onTap: () {
                  setState(() {
                    _selectedTier = SubscriptionTier.premium;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Continue button
              FButton(
                onPress: _selectedTier != null ? _handleContinue : null,
                child: Text(
                  _selectedTier == SubscriptionTier.premium
                      ? 'Upgrade to Premium'
                      : 'Continue with Free',
                ),
              ),
              const SizedBox(height: 16),

              // Skip button (defaults to free)
              TextButton(
                onPressed: () {
                  _selectedTier = SubscriptionTier.free;
                  _handleContinue();
                },
                child: Text(
                  'Start with Free Plan',
                  style: context.theme.typography.sm.copyWith(
                    color: context.theme.colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final List<String> features;
  final bool isSelected;
  final bool isPremium;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    required this.isSelected,
    this.isPremium = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: context.theme.typography.xl2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isPremium) ...[
                          const SizedBox(width: 8),
                          FBadge(child: Text('Popular')),
                        ],
                      ],
                    ),
                    if (isSelected)
                      Icon(FIcons.check, color: context.theme.colors.primary),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: context.theme.typography.xl3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.theme.colors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(period, style: context.theme.typography.sm),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          FIcons.check,
                          size: 16,
                          color: context.theme.colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: context.theme.typography.sm,
                          ),
                        ),
                      ],
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
