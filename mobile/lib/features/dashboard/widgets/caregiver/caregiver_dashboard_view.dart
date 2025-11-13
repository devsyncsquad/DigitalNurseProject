import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/providers/care_context_provider.dart';
import '../dashboard_theme.dart';
import 'care_recipient_selector.dart';
import 'caregiver_action_shortcuts.dart';
import 'caregiver_overview_card.dart';

class CaregiverDashboardView extends StatelessWidget {
  final CareContextProvider careContext;
  final ValueChanged<String> onRecipientSelected;

  const CaregiverDashboardView({
    super.key,
    required this.careContext,
    required this.onRecipientSelected,
  });

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
              _DashboardHero(
                contextProvider: careContext,
                onRecipientSelected: onRecipientSelected,
              ),
              SizedBox(height: cardSpacing),
              const CaregiverOverviewCard(),
              SizedBox(height: cardSpacing),
              const CaregiverActionShortcuts(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  final CareContextProvider contextProvider;
  final ValueChanged<String> onRecipientSelected;

  const _DashboardHero({
    required this.contextProvider,
    required this.onRecipientSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selectedRecipient = contextProvider.selectedRecipient;
    final recipients = contextProvider.careRecipients;

    final headline = selectedRecipient != null
        ? 'Caring for ${selectedRecipient.name}'
        : 'Welcome back';
    final subtitle = selectedRecipient != null
        ? 'Stay ahead with today\'s schedule and vital updates.'
        : 'Select a care recipient to see personalised insights.';

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: CaregiverDashboardTheme.heroDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headline,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.85),
                ),
          ),
          SizedBox(height: 16.h),
          CareRecipientSelector(
            isLoading: contextProvider.isLoading,
            recipients: recipients,
            selectedRecipient: selectedRecipient,
            error: contextProvider.error,
            onSelect: onRecipientSelected,
          ),
          if (recipients.isNotEmpty) ...[
            // SizedBox(height: 18.h),
            // Wrap(
            //   spacing: 8.w,
            //   runSpacing: 8.h,
            //   children: [
            //     _HeroChip(
            //       label: '${recipients.length} in care',
            //       icon: Icons.group,
            //     ),
            //     _HeroChip(
            //       label: 'Live updates on vitals',
            //       icon: Icons.monitor_heart,
            //     ),
            //     _HeroChip(
            //       label: 'Smart medication reminders',
            //       icon: Icons.medication_liquid,
            //     ),
            //   ],
            // ),
          ],
        ],
      ),
    );
  }
}


