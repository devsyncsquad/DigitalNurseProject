import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/auth_provider.dart';
import '../dashboard_theme.dart';
import 'patient_action_shortcuts.dart';
import 'patient_documents_card.dart';
import 'patient_lifestyle_card.dart';
import 'patient_overview_card.dart';
import 'patient_upcoming_medications_card.dart';
import 'patient_vitals_card.dart';

class PatientDashboardView extends StatelessWidget {
  const PatientDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final cardSpacing = 18.h;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: CaregiverDashboardTheme.backgroundGradient(),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 24.h,
            bottom: 40.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PatientHero(),
              SizedBox(height: cardSpacing),
              const PatientOverviewCard(),
              SizedBox(height: cardSpacing),
              const PatientActionShortcuts(),
              SizedBox(height: cardSpacing),
              const PatientUpcomingMedicationsCard(),
              SizedBox(height: cardSpacing),
              const PatientVitalsCard(),
              SizedBox(height: cardSpacing),
              const PatientDocumentsCard(),
              SizedBox(height: cardSpacing),
              const PatientLifestyleCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final userName = user?.name ?? 'there';

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: CaregiverDashboardTheme.heroDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, $userName!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Stay on track with your health journey. Monitor medications, vitals, and wellness all in one place.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.85),
                ),
          ),
          SizedBox(height: 18.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _HeroChip(
                label: 'Medication tracking',
                icon: Icons.medication_liquid,
              ),
              _HeroChip(
                label: 'Vitals monitoring',
                icon: Icons.monitor_heart,
              ),
              _HeroChip(
                label: 'Health insights',
                icon: Icons.insights,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _HeroChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 8.h,
      ),
      decoration: CaregiverDashboardTheme.frostedChip(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

