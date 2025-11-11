import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/models/vital_measurement_model.dart';
import '../../../core/providers/health_provider.dart';
import '../../../core/theme/app_theme.dart';

class CaregiverVitalsWatchlistCard extends StatelessWidget {
  const CaregiverVitalsWatchlistCard({super.key});

  @override
  Widget build(BuildContext context) {
    final healthProvider = context.watch<HealthProvider>();
    final abnormalVitals = healthProvider.vitals
        .where((vital) => vital.isAbnormal())
        .take(5)
        .toList();

    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vitals watchlist',
            style: context.theme.typography.sm.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          if (abnormalVitals.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                'All vitals are within normal range.',
                style: context.theme.typography.xs.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            )
          else
            ...abnormalVitals.map((vital) {
              final status = vital.getHealthStatus();
              final statusColor = switch (status) {
                VitalHealthStatus.danger => AppTheme.getErrorColor(context),
                VitalHealthStatus.warning => AppTheme.getWarningColor(context),
                _ => AppTheme.getSuccessColor(context),
              };
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.monitor_heart,
                        color: statusColor,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vital.type.displayName,
                            style: context.theme.typography.sm.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${vital.value} ${vital.type.unit}',
                            style: context.theme.typography.xs.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            DateFormat('MMM d, h:mm a').format(vital.timestamp),
                            style: context.theme.typography.xs.copyWith(
                              color: context.theme.colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.push('/health'),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}

