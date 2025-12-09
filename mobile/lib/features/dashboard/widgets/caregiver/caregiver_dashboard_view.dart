import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/providers/care_context_provider.dart';
import '../dashboard_theme.dart';
import 'patient_cards_grid.dart';
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
    return SafeArea(
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
            PatientCardsGrid(
              careContext: careContext,
              onPatientSelected: onRecipientSelected,
            ),
            SizedBox(height: cardSpacing),
            const CaregiverOverviewCard(),
            SizedBox(height: cardSpacing),
            const CaregiverActionShortcuts(),
          ],
        ),
      ),
    );
  }
}


