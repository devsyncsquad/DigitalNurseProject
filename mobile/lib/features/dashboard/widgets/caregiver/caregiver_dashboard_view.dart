import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/care_context_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../dashboard_theme.dart';
import 'patient_cards_grid.dart';
// import 'caregiver_action_shortcuts.dart';
// import 'caregiver_overview_card.dart';

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
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final caregiverName = currentUser?.name ?? 'Caregiver';
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
            // Welcome Message
            _WelcomeMessage(caregiverName: caregiverName),
            SizedBox(height: 24.h),
            PatientCardsGrid(
              careContext: careContext,
              onPatientSelected: onRecipientSelected,
            ),
            SizedBox(height: cardSpacing),
            // const CaregiverOverviewCard(),
            // SizedBox(height: cardSpacing),
            // const CaregiverActionShortcuts(),
          ],
        ),
      ),
    );
  }
}

class _WelcomeMessage extends StatelessWidget {
  final String caregiverName;

  const _WelcomeMessage({
    required this.caregiverName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: CaregiverDashboardTheme.cardPadding(),
      decoration: CaregiverDashboardTheme.glassCard(
        context,
        highlighted: true,
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: CaregiverDashboardTheme.iconBadge(
              context,
              CaregiverDashboardTheme.primaryTeal,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: CaregiverDashboardTheme.sectionSubtitleStyle(context),
                ),
                SizedBox(height: 4.h),
                Text(
                  caregiverName,
                  style: CaregiverDashboardTheme.sectionTitleStyle(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


