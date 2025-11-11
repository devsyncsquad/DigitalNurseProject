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
    final cardSpacing = 16.h;
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
        SizedBox(height: cardSpacing),
        const CaregiverOverviewCard(),
        SizedBox(height: cardSpacing),
        const CaregiverActionShortcuts(),
        SizedBox(height: cardSpacing),
        const CaregiverAdherenceAndVitalsRow(),
        SizedBox(height: cardSpacing),
        const CaregiverUpcomingMedicationsCard(),
        SizedBox(height: cardSpacing),
        const CaregiverVitalsWatchlistCard(),
        SizedBox(height: cardSpacing),
        const CaregiverAlertsFeed(),
        SizedBox(height: 24.h),
      ],
    );
  }
}