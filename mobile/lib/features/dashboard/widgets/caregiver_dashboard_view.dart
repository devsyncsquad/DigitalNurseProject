import 'dart:math';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/medicine_model.dart';
import '../../../core/models/vital_measurement_model.dart';
import '../../../core/providers/care_context_provider.dart';
import '../../../core/providers/health_provider.dart';
import '../../../core/providers/medication_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'care_recipient_selector.dart';

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
        const _CaregiverOverviewCard(),
        SizedBox(height: 16.h),
        const _CaregiverActionShortcuts(),
        SizedBox(height: 16.h),
        const _AdherenceAndVitalsRow(),
        SizedBox(height: 16.h),
        const _UpcomingMedicationsCard(),
        SizedBox(height: 16.h),
        const _VitalsWatchlistCard(),
        SizedBox(height: 16.h),
        const _CareAlertsFeed(),
        SizedBox(height: 24.h),
      ],
    );
  }
}

class _CaregiverOverviewCard extends StatelessWidget {
  const _CaregiverOverviewCard();

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
            spacing: 12.w,
            runSpacing: 12.h,
            children: cards
                .map(
                  (metric) => SizedBox(
                    width: min(160.w, (ScreenUtil().screenWidth - 64.w) / 2),
                    child: metric,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CaregiverActionShortcuts extends StatelessWidget {
  const _CaregiverActionShortcuts();

  void _showComingSoon(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action coming soon'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionShortcut(
        icon: Icons.phone,
        label: 'Call patient',
        onTap: () => _showComingSoon(context, 'Calling'),
      ),
      _ActionShortcut(
        icon: Icons.notifications_active_outlined,
        label: 'Send reminder',
        onTap: () => _showComingSoon(context, 'Reminder'),
      ),
      _ActionShortcut(
        icon: Icons.note_alt,
        label: 'Log observation',
        onTap: () => context.push('/documents'),
      ),
      _ActionShortcut(
        icon: Icons.calendar_month,
        label: 'View schedule',
        onTap: () => context.push('/medications'),
      ),
    ];

    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick actions',
            style: context.theme.typography.sm.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: actions
                .map(
                  (action) => SizedBox(
                    width: (ScreenUtil().screenWidth - 64.w) / 2,
                    child: action,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _AdherenceAndVitalsRow extends StatelessWidget {
  const _AdherenceAndVitalsRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final children = const [
          _VitalsTrendCard(),
          _AdherenceSparklineCard(),
        ];
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children
                .map(
                  (child) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: child == children.last ? 0 : 12.w),
                      child: child,
                    ),
                  ),
                )
                .toList(),
          );
        }
        return Column(
          children: children
              .map(
                (child) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _VitalsTrendCard extends StatelessWidget {
  const _VitalsTrendCard();

  @override
  Widget build(BuildContext context) {
    final healthProvider = context.watch<HealthProvider>();

    final trendData = _TrendData.fromVitals(healthProvider.vitals);

    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vitals trend',
            style: context.theme.typography.sm.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          if (trendData == null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                'Not enough data to display trends yet.',
                style: context.theme.typography.xs.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            )
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trendData.label,
                  style: context.theme.typography.xs.copyWith(
                    color: context.theme.colors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${trendData.points.last.value.toStringAsFixed(1)} ${trendData.unit}',
                  style: context.theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 120.h,
              child: SparklineChart(
                values: trendData.points.map((point) => point.value).toList(),
                color: context.theme.colors.primary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Last updated: ${DateFormat('MMM d, h:mm a').format(trendData.points.last.timestamp)}',
              style: context.theme.typography.xs.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AdherenceSparklineCard extends StatelessWidget {
  const _AdherenceSparklineCard();

  Future<List<_TrendPoint>> _loadAdherenceHistory(
    BuildContext context,
    List<MedicineModel> medicines,
  ) async {
    if (medicines.isEmpty) {
      return const [];
    }

    final medicationProvider = context.read<MedicationProvider>();
    final points = <_TrendPoint>[];

    for (final medicine in medicines.take(3)) {
      final history = await medicationProvider.getIntakeHistory(medicine.id);
      for (final intake in history) {
        final status = intake.status;
        final value = status == IntakeStatus.taken
            ? 1.0
            : status == IntakeStatus.skipped
                ? 0.5
                : 0.0;
        points.add(
          _TrendPoint(
            timestamp: intake.scheduledTime,
            value: value,
          ),
        );
      }
    }

    points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return points.takeLast(14).toList();
  }

  @override
  Widget build(BuildContext context) {
    final medicationProvider = context.watch<MedicationProvider>();

    return FutureBuilder<List<_TrendPoint>>(
      future: _loadAdherenceHistory(context, medicationProvider.medicines),
      builder: (context, snapshot) {
        final points = snapshot.data ?? [];
        return FCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Medication adherence',
                style: context.theme.typography.sm.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              if (snapshot.connectionState == ConnectionState.waiting)
                SizedBox(
                  height: 120.h,
                  child: const Center(child: CircularProgressIndicator()),
                )
              else if (points.length < 2)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text(
                    'Not enough adherence history yet.',
                    style: context.theme.typography.xs.copyWith(
                      color: context.theme.colors.mutedForeground,
                    ),
                  ),
                )
              else ...[
                SizedBox(
                  height: 120.h,
                  child: SparklineChart(
                    values: points.map((point) => point.value * 100).toList(),
                    color: AppTheme.getSuccessColor(context),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Last 14 doses • ${points.last.value == 1.0 ? 'Taken' : points.last.value == 0.5 ? 'Skipped' : 'Missed'}',
                  style: context.theme.typography.xs.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _UpcomingMedicationsCard extends StatelessWidget {
  const _UpcomingMedicationsCard();

  @override
  Widget build(BuildContext context) {
    final medicationProvider = context.watch<MedicationProvider>();
    final upcoming = [...medicationProvider.upcomingReminders]
      ..sort((a, b) {
        final aTime = a['reminderTime'] as DateTime;
        final bTime = b['reminderTime'] as DateTime;
        return aTime.compareTo(bTime);
      });

    final now = DateTime.now();
    final nextReminders = upcoming.where((reminder) {
      final time = reminder['reminderTime'] as DateTime;
      return !time.isBefore(now);
    }).toList();

    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming medicines',
            style: context.theme.typography.sm.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          if (nextReminders.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                'No upcoming doses scheduled.',
                style: context.theme.typography.xs.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            )
          else
            ...nextReminders.take(4).map((reminder) {
              final medicine = reminder['medicine'] as MedicineModel;
              final time = reminder['reminderTime'] as DateTime;
              final isSoon = time.difference(now).inMinutes <= 30;
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.theme.colors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.medication,
                        color: context.theme.colors.primary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicine.name,
                            style: context.theme.typography.sm.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${medicine.dosage} • ${DateFormat('MMM d, h:mm a').format(time)}',
                            style: context.theme.typography.xs.copyWith(
                              color: context.theme.colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (isSoon) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Reminder sent for ${medicine.name}'),
                            ),
                          );
                        } else {
                          context.push('/medications');
                        }
                      },
                      child: Text(isSoon ? 'Remind now' : 'Details'),
                    ),
                  ],
                ),
              );
            }).toList(),
          if (nextReminders.length > 4)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => context.push('/medications'),
                child: const Text('View all medicines'),
              ),
            ),
        ],
      ),
    );
  }
}

class _VitalsWatchlistCard extends StatelessWidget {
  const _VitalsWatchlistCard();

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

class _CareAlertsFeed extends StatelessWidget {
  const _CareAlertsFeed();

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final notifications = notificationProvider.notifications.take(5).toList();

    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Care alerts',
                style: context.theme.typography.sm.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (notifications.isNotEmpty)
                TextButton(
                  onPressed: () => context.push('/notifications'),
                  child: const Text('View all'),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          if (notifications.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                'No new alerts.',
                style: context.theme.typography.xs.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            )
          else
            ...notifications.map((notification) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            context.theme.colors.secondary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        notification.isRead
                            ? Icons.mark_email_read_outlined
                            : Icons.mark_email_unread_outlined,
                        color: context.theme.colors.secondary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: context.theme.typography.sm.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            notification.body,
                            style: context.theme.typography.xs.copyWith(
                              color: context.theme.colors.mutedForeground,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            DateFormat('MMM d, h:mm a')
                                .format(notification.timestamp),
                            style: context.theme.typography.xs.copyWith(
                              color: context.theme.colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.push('/notifications'),
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

class _ActionShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionShortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: context.theme.colors.muted.withOpacity(0.4),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.theme.colors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: context.theme.colors.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: context.theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendData {
  final String label;
  final String unit;
  final List<_TrendPoint> points;

  const _TrendData({
    required this.label,
    required this.unit,
    required this.points,
  });

  factory _TrendData.fromType(
    VitalType type,
    List<VitalMeasurementModel> vitals,
  ) {
    final filtered = vitals
        .where((vital) => vital.type == type)
        .map((vital) {
          final value = _TrendPoint.parseVitalValue(vital);
          if (value == null) return null;
          return _TrendPoint(timestamp: vital.timestamp, value: value);
        })
        .whereType<_TrendPoint>()
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return _TrendData(
      label: type.displayName,
      unit: type.unit,
      points: filtered.takeLast(10).toList(),
    );
  }

  static _TrendData? fromVitals(List<VitalMeasurementModel> vitals) {
    if (vitals.length < 2) {
      return null;
    }

    for (final type in [
      VitalType.heartRate,
      VitalType.bloodPressure,
      VitalType.bloodSugar,
      VitalType.temperature,
    ]) {
      final data = _TrendData.fromType(type, vitals);
      if (data.points.length >= 2) {
        return data;
      }
    }

    return null;
  }
}

class _TrendPoint {
  final DateTime timestamp;
  final double value;

  const _TrendPoint({
    required this.timestamp,
    required this.value,
  });

  static double? parseVitalValue(VitalMeasurementModel vital) {
    switch (vital.type) {
      case VitalType.bloodPressure:
        final parts = vital.value.split('/');
        if (parts.isEmpty) return null;
        return double.tryParse(parts.first.trim());
      case VitalType.bloodSugar:
      case VitalType.temperature:
        return double.tryParse(vital.value);
      case VitalType.heartRate:
      case VitalType.oxygenSaturation:
      case VitalType.weight:
        return double.tryParse(vital.value);
    }
  }
}

class SparklineChart extends StatelessWidget {
  final List<double> values;
  final Color color;

  const SparklineChart({
    super.key,
    required this.values,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _SparklinePainter(values: values, color: color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;

  _SparklinePainter({
    required this.values,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      return;
    }

    final minValue = values.reduce(min);
    final maxValue = values.reduce(max);
    final range = max(maxValue - minValue, 1e-6);

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i == 0
          ? 0.0
          : (i / (values.length - 1)) * size.width;
      final normalized = (values[i] - minValue) / range;
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0.25),
          color.withOpacity(0.05),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
            ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}

extension _TakeLast<T> on List<T> {
  Iterable<T> takeLast(int count) {
    if (count <= 0) return const Iterable.empty();
    if (length <= count) return this;
    return sublist(length - count);
  }
}

