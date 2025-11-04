import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/providers/health_provider.dart';
import '../../../core/models/vital_measurement_model.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/vitals_calendar_header.dart';
import '../widgets/vital_status_badge.dart';

class VitalsListScreen extends StatefulWidget {
  const VitalsListScreen({super.key});

  @override
  State<VitalsListScreen> createState() => _VitalsListScreenState();
}

class _VitalsListScreenState extends State<VitalsListScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final healthProvider = context.watch<HealthProvider>();
    final vitals = healthProvider.getVitalsForDate(_selectedDate);

    return FScaffold(
      header: FHeader(
        title: const Text('Health Vitals'),
        suffixes: [
          FHeaderAction(
            icon: const Icon(FIcons.plus),
            onPress: () => context.push('/vitals/add'),
          ),
        ],
      ),
      child: Column(
        children: [
          // Calendar Header
          VitalsCalendarHeader(
            selectedDate: _selectedDate,
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),

          // Quick stats
          Container(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: FButton(
                    onPress: () => context.push('/health/trends'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(FIcons.trendingUp),
                        const SizedBox(width: 8),
                        const Text('View Trends'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Vitals list or empty state
          Expanded(
            child: vitals.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vitals.length,
                    itemBuilder: (context, index) {
                      final vital = vitals[index];
                      final healthStatus = vital.getHealthStatus();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FCard(
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _getStatusBackgroundColor(
                                      healthStatus,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    FIcons.activity,
                                    color: _getStatusColor(healthStatus),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vital.type.displayName,
                                        style: context.theme.typography.base
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        DateFormat(
                                          'MMM d, yyyy - h:mm a',
                                        ).format(vital.timestamp),
                                        style: context.theme.typography.sm,
                                      ),
                                      if (vital.notes != null) ...[
                                        SizedBox(height: 4),
                                        Text(
                                          vital.notes!,
                                          style: context.theme.typography.xs
                                              .copyWith(
                                                color: context
                                                    .theme
                                                    .colors
                                                    .mutedForeground,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      vital.value,
                                      style: context.theme.typography.lg
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: _getStatusColor(
                                              healthStatus,
                                            ),
                                          ),
                                    ),
                                    Text(
                                      vital.type.unit,
                                      style: context.theme.typography.xs,
                                    ),
                                    const SizedBox(height: 4),
                                    VitalStatusBadge(status: healthStatus),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final healthProvider = context.watch<HealthProvider>();
    final allVitals = healthProvider.vitals;

    if (allVitals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FIcons.activity,
              size: 64.r,
              color: context.theme.colors.mutedForeground,
            ),
            SizedBox(height: 16.h),
            Text('No vitals logged yet', style: context.theme.typography.lg),
            SizedBox(height: 8.h),
            Text(
              'Start tracking your health vitals',
              style: context.theme.typography.sm,
            ),
            SizedBox(height: 24.h),
            FButton(
              onPress: () => context.push('/vitals/add'),
              child: const Text('Log Vitals'),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FIcons.calendar,
              size: 64.r,
              color: context.theme.colors.mutedForeground,
            ),
            SizedBox(height: 16.h),
            Text(
              'No vitals for ${_getFormattedDate(_selectedDate)}',
              style: context.theme.typography.lg,
            ),
            SizedBox(height: 8.h),
            Text(
              'Select another date or add vitals',
              style: context.theme.typography.sm.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      );
    }
  }

  String _getFormattedDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _getStatusColor(VitalHealthStatus status) {
    switch (status) {
      case VitalHealthStatus.normal:
        return AppTheme.getSuccessColor(context);
      case VitalHealthStatus.warning:
        return AppTheme.getWarningColor(context);
      case VitalHealthStatus.danger:
        return AppTheme.getErrorColor(context);
    }
  }

  Color _getStatusBackgroundColor(VitalHealthStatus status) {
    switch (status) {
      case VitalHealthStatus.normal:
        return AppTheme.getSuccessColor(context).withOpacity(0.1);
      case VitalHealthStatus.warning:
        return AppTheme.getWarningColor(context).withOpacity(0.1);
      case VitalHealthStatus.danger:
        return AppTheme.getErrorColor(context).withOpacity(0.1);
    }
  }
}
