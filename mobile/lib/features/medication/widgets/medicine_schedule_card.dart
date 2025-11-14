import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import '../../../core/models/medicine_model.dart';
import '../../../core/providers/medication_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/modern_surface_theme.dart';
import 'medicine_item_tile.dart';

enum MedicineTimeOfDay { morning, afternoon, evening }

class MedicineScheduleCard extends StatefulWidget {
  final MedicineTimeOfDay timeOfDay;
  final List<MedicineModel> medicines;
  final DateTime selectedDate;
  final VoidCallback? onStatusChanged;

  const MedicineScheduleCard({
    super.key,
    required this.timeOfDay,
    required this.medicines,
    required this.selectedDate,
    this.onStatusChanged,
  });

  @override
  State<MedicineScheduleCard> createState() => _MedicineScheduleCardState();
}

class _MedicineScheduleCardState extends State<MedicineScheduleCard> {
  bool _isExpanded = false;
  Map<String, IntakeStatus> _medicineStatuses = {};

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  @override
  void didUpdateWidget(MedicineScheduleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.medicines != widget.medicines ||
        oldWidget.selectedDate != widget.selectedDate) {
      _loadStatuses();
    }
  }

  Future<void> _loadStatuses() async {
    final medicationProvider = context.read<MedicationProvider>();
    final statuses = <String, IntakeStatus>{};

    for (final medicine in widget.medicines) {
      for (final reminderTime in medicine.reminderTimes) {
        final key = '${medicine.id}_$reminderTime';
        final status = await medicationProvider.getMedicineStatus(
          medicine,
          reminderTime,
          widget.selectedDate,
        );
        statuses[key] = status;
      }
    }

    if (mounted) {
      setState(() {
        _medicineStatuses = statuses;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.medicines.isEmpty) return const SizedBox.shrink();

    final timeInfo = _getTimeInfo(context);
    final chipForeground =
        ModernSurfaceTheme.chipForegroundColor(timeInfo.color);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onSurface = colorScheme.onSurface;
    final muted = colorScheme.onSurfaceVariant;
    final onPrimary = colorScheme.onPrimary;

    return Container(
      decoration: ModernSurfaceTheme.glassCard(context, accent: timeInfo.color),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: ModernSurfaceTheme.iconBadge(context, timeInfo.color),
                    child: Icon(
                      timeInfo.icon,
                      color: onPrimary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timeInfo.label,
                          style: textTheme.titleMedium?.copyWith(
                                color: onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _getStatusText(context),
                          style: textTheme.bodySmall?.copyWith(
                                color: muted,
                              ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusIcon(context),
                  SizedBox(width: 12.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: ModernSurfaceTheme.frostedChip(
                      context,
                      baseColor: timeInfo.color,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.medicines.length.toString(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: chipForeground,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          _isExpanded ? FIcons.chevronUp : FIcons.chevronDown,
                          size: 14,
                      color: chipForeground,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            Divider(
              height: 24.h,
              color: onSurface.withValues(alpha: 0.08),
            ),
            Column(
              children: widget.medicines
                  .map((medicine) {
                    final relevantTimes = medicine.reminderTimes
                        .where((time) => _isRelevantTimeOfDay(time))
                        .toList();

                    return relevantTimes.map((time) {
                      final key = '${medicine.id}_$time';
                      final status =
                          _medicineStatuses[key] ?? IntakeStatus.pending;

                      return MedicineItemTile(
                        medicine: medicine,
                        reminderTime: time,
                        status: status,
                        selectedDate: widget.selectedDate,
                        onStatusChanged: () {
                          _loadStatuses();
                          widget.onStatusChanged?.call();
                        },
                      );
                    }).toList();
                  })
                  .expand((x) => x)
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  bool _isRelevantTimeOfDay(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) return false;

    final hour = int.tryParse(parts[0]);
    if (hour == null) return false;

    switch (widget.timeOfDay) {
      case MedicineTimeOfDay.morning:
        return hour < 12;
      case MedicineTimeOfDay.afternoon:
        return hour >= 12 && hour < 17;
      case MedicineTimeOfDay.evening:
        return hour >= 17;
    }
  }

  Widget _buildStatusIcon(BuildContext context) {
    final statuses = _medicineStatuses.values.toSet();

    if (statuses.contains(IntakeStatus.missed)) {
        return _StatusBadge(
          color: AppTheme.getErrorColor(context),
          icon: FIcons.x,
        );
    } else if (statuses.contains(IntakeStatus.pending)) {
      return _StatusBadge(
        color: context.theme.colors.primary,
        icon: FIcons.clock,
      );
    } else if (statuses.contains(IntakeStatus.taken)) {
      return _StatusBadge(
        color: AppTheme.getSuccessColor(context),
        icon: FIcons.check,
      );
    }

    return const SizedBox.shrink();
  }

  String _getStatusText(BuildContext context) {
    final statuses = _medicineStatuses.values.toSet();

    if (statuses.contains(IntakeStatus.missed)) {
      return 'Missed';
    } else if (statuses.contains(IntakeStatus.pending)) {
      return 'Upcoming';
    } else if (statuses.contains(IntakeStatus.taken)) {
      return 'Taken';
    }

    return 'No medicines';
  }

  ({String label, IconData icon, Color color}) _getTimeInfo(
    BuildContext context,
  ) {
    switch (widget.timeOfDay) {
      case MedicineTimeOfDay.morning:
        return (label: 'Morning', icon: FIcons.sunrise, color: ModernSurfaceTheme.accentYellow);
      case MedicineTimeOfDay.afternoon:
        return (label: 'Afternoon', icon: FIcons.sun, color: ModernSurfaceTheme.primaryTeal);
      case MedicineTimeOfDay.evening:
        return (label: 'Evening', icon: FIcons.moon, color: ModernSurfaceTheme.accentBlue);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _StatusBadge({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}
