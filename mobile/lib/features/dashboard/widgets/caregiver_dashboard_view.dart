import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/providers/care_context_provider.dart';
import 'care_recipient_selector.dart';
import 'caregiver_action_shortcuts.dart';
import 'caregiver_alerts_feed.dart';
import 'caregiver_overview_card.dart';
import 'caregiver_trends_section.dart';
import 'caregiver_upcoming_medications_card.dart';
import 'caregiver_vitals_watchlist_card.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CareRecipientSelector(
          isLoading: careContext.isLoading,
          recipients: careContext.careRecipients,
          selectedRecipient: careContext.selectedRecipient,
          error: careContext.error,
          onSelect: onRecipientSelected,
        ),
        SizedBox(height: 16.h),
        const CaregiverOverviewCard(),
        SizedBox(height: 16.h),
        const CaregiverActionShortcuts(),
        SizedBox(height: 16.h),
        const CaregiverAdherenceAndVitalsRow(),
        SizedBox(height: 16.h),
        const CaregiverUpcomingMedicationsCard(),
        SizedBox(height: 16.h),
        const CaregiverVitalsWatchlistCard(),
        SizedBox(height: 16.h),
        const CaregiverAlertsFeed(),
        SizedBox(height: 24.h),
      ],
    );
  }
}