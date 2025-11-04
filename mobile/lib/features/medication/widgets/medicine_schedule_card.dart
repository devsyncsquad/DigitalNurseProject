import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import '../../../core/models/medicine_model.dart';
import '../../../core/providers/medication_provider.dart';
import '../../../core/theme/app_theme.dart';
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

    final theme = context.theme;
    final timeInfo = _getTimeInfo(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: FCard(
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: timeInfo.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          timeInfo.icon,
                          color: timeInfo.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              timeInfo.label,
                              style: theme.typography.base.copyWith(
                                fontWeight: FontWeight.bold,
                                color: timeInfo.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getStatusText(context),
                              style: theme.typography.sm.copyWith(
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusIcon(context),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colors.muted,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.medicines.length.toString(),
                              style: theme.typography.sm.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _isExpanded
                                  ? FIcons.chevronUp
                                  : FIcons.chevronDown,
                              size: 16,
                              color: theme.colors.mutedForeground,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
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
              ),
            ],
          ],
        ),
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
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.getErrorColor(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(FIcons.x, color: AppTheme.getErrorColor(context), size: 20),
      );
    } else if (statuses.contains(IntakeStatus.pending)) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.theme.colors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(FIcons.clock, color: context.theme.colors.primary, size: 20),
      );
    } else if (statuses.contains(IntakeStatus.taken)) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.getSuccessColor(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(FIcons.check, color: AppTheme.getSuccessColor(context), size: 20),
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
    final primaryColor = context.theme.colors.primary;
    final secondaryColor = context.theme.colors.secondary;
    switch (widget.timeOfDay) {
      case MedicineTimeOfDay.morning:
        return (label: 'Morning', icon: FIcons.sunrise, color: primaryColor);
      case MedicineTimeOfDay.afternoon:
        return (label: 'Afternoon', icon: FIcons.sun, color: AppTheme.getSuccessColor(context));
      case MedicineTimeOfDay.evening:
        return (label: 'Evening', icon: FIcons.moon, color: secondaryColor);
    }
  }
}
