import 'package:digital_nurse/core/extensions/vital_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/vital_measurement_model.dart';
import '../../../../core/providers/health_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../dashboard_theme.dart';

class PatientVitalsCard extends StatelessWidget {
  const PatientVitalsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final healthProvider = context.watch<HealthProvider>();
    final recentVitals = healthProvider.vitals.take(5).toList();
    final abnormalVitals = healthProvider.vitals
        .where((vital) => vital.isAbnormal())
        .take(5)
        .toList();

    return Container(
      padding: CaregiverDashboardTheme.cardPadding(),
      decoration: CaregiverDashboardTheme.glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: CaregiverDashboardTheme.iconBadge(
                  CaregiverDashboardTheme.accentCoral,
                ),
                child: const Icon(
                  Icons.monitor_heart_outlined,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent vitals',
                      style: CaregiverDashboardTheme.sectionTitleStyle(
                        context,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      abnormalVitals.isNotEmpty
                          ? 'Track readings that fall outside normal ranges.'
                          : 'Your latest health measurements.',
                      style: CaregiverDashboardTheme.sectionSubtitleStyle(
                        context,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          if (recentVitals.isEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 18.h,
              ),
              decoration: CaregiverDashboardTheme.tintedCard(
                CaregiverDashboardTheme.primaryTeal,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: CaregiverDashboardTheme.iconBadge(
                      CaregiverDashboardTheme.primaryTeal,
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'No vitals recorded yet.',
                      style: context.theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: CaregiverDashboardTheme.deepTeal,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...recentVitals.asMap().entries.map((entry) {
              final index = entry.key;
              final vital = entry.value;
              final isAbnormal = vital.isAbnormal();
              final status = vital.getHealthStatus();
              final statusColor = switch (status) {
                VitalHealthStatus.danger =>
                  AppTheme.getErrorColor(context),
                VitalHealthStatus.warning =>
                  AppTheme.getWarningColor(context),
                _ => CaregiverDashboardTheme.primaryTeal,
              };
              final isLast = index == recentVitals.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
                child: _VitalRow(
                  vital: vital,
                  accent: isAbnormal ? statusColor : CaregiverDashboardTheme.primaryTeal,
                  onTap: () => context.push('/health'),
                ),
              );
            }).toList(),
          if (recentVitals.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => context.push('/health'),
                style: TextButton.styleFrom(
                  foregroundColor: CaregiverDashboardTheme.accentCoral,
                  textStyle: context.theme.typography.xs.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('View all vitals'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VitalRow extends StatelessWidget {
  final VitalMeasurementModel vital;
  final Color accent;
  final VoidCallback onTap;

  const _VitalRow({
    required this.vital,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: CaregiverDashboardTheme.tintedCard(accent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: CaregiverDashboardTheme.iconBadge(accent),
                child: const Icon(
                  Icons.monitor_heart,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vital.type.displayName,
                      style: context.theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: CaregiverDashboardTheme.deepTeal,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${vital.value} ${vital.type.unit}',
                      style: context.theme.typography.xs.copyWith(
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  foregroundColor: accent,
                  textStyle: context.theme.typography.xs.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Review'),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            DateFormat('MMM d, h:mm a').format(vital.timestamp),
            style: context.theme.typography.xs.copyWith(
              color: CaregiverDashboardTheme.deepTeal.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

