import 'package:digital_nurse/core/extensions/vital_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/health_provider.dart';
import '../../../core/providers/medication_provider.dart';
import '../../../core/theme/app_theme.dart';

class CaregiverOverviewCard extends StatelessWidget {
  const CaregiverOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final medicationProvider = context.watch<MedicationProvider>();
    final healthProvider = context.watch<HealthProvider>();

    final adherencePercentage =
        medicationProvider.adherencePercentage.clamp(0, 100).toDouble();
    final adherenceStreak = medicationProvider.adherenceStreak;

    final upcomingToday = medicationProvider.upcomingReminders.where((reminder) {
      final time = reminder['reminderTime'] as DateTime;
      final now = DateTime.now();
      return time.year == now.year &&
          time.month == now.month &&
          time.day == now.day &&
          !time.isBefore(now);
    }).length;

    final abnormalVitals =
        healthProvider.vitals.where((vital) => vital.isAbnormal()).toList();
    final latestVital = healthProvider.vitals.isNotEmpty
        ? healthProvider.vitals.first
        : null;

    final cards = [
      _OverviewMetric(
        label: 'Adherence',
        value: '${adherencePercentage.toStringAsFixed(0)}%',
        icon: Icons.monitor_heart,
        color: adherencePercentage >= 90
            ? AppTheme.getSuccessColor(context)
            : adherencePercentage >= 75
                ? AppTheme.getWarningColor(context)
                : AppTheme.getErrorColor(context),
      ),
      _OverviewMetric(
        label: 'Streak',
        value: '$adherenceStreak days',
        icon: Icons.local_fire_department,
        color: context.theme.colors.primary,
      ),
      _OverviewMetric(
        label: 'Upcoming doses',
        value: '$upcomingToday today',
        icon: Icons.schedule,
        color: context.theme.colors.secondary,
      ),
      _OverviewMetric(
        label: 'Alerts',
        value: '${abnormalVitals.length}',
        icon: Icons.warning_amber_rounded,
        color: abnormalVitals.isEmpty
            ? AppTheme.getSuccessColor(context)
            : AppTheme.getErrorColor(context),
      ),
      if (latestVital != null)
        _OverviewMetric(
          label: 'Last vital',
          value:
              '${latestVital.type.displayName}: ${latestVital.value} ${latestVital.type.unit}',
          icon: Icons.favorite,
          color: context.theme.colors.mutedForeground,
          maxLines: 2,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final crossAxisCount = isWide ? 2 : 1;
        final crossAxisSpacing = 12.w;

        return FCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Care overview',
                style: context.theme.typography.sm.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: crossAxisSpacing,
                runSpacing: 12.h,
                children: cards
                    .map(
                      (metric) => SizedBox(
                        width: crossAxisCount == 1
                            ? constraints.maxWidth
                            : (constraints.maxWidth - crossAxisSpacing) /
                                crossAxisCount,
                        child: metric,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final int maxLines;

  const _OverviewMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.08),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.6),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: context.theme.typography.sm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  label,
                  style: context.theme.typography.xs.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

