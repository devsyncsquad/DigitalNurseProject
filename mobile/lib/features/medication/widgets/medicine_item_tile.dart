import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/models/medicine_model.dart';
import '../../../core/providers/medication_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class MedicineItemTile extends StatelessWidget {
  final MedicineModel medicine;
  final String reminderTime;
  final IntakeStatus status;
  final DateTime selectedDate;
  final VoidCallback? onStatusChanged;

  const MedicineItemTile({
    super.key,
    required this.medicine,
    required this.reminderTime,
    required this.status,
    required this.selectedDate,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final medicationProvider = context.read<MedicationProvider>();
    final timeDisplay = medicationProvider.getTimeOfDayString(reminderTime);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => context.push('/medicine/${medicine.id}'),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: context.theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${medicine.dosage} - $timeDisplay',
                      style: context.theme.typography.xs.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildStatusButton(context),
        ],
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context) {
    switch (status) {
      case IntakeStatus.taken:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.getSuccessColor(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            FIcons.check,
            color: AppTheme.getSuccessColor(context),
            size: 16,
          ),
        );
      case IntakeStatus.missed:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.getErrorColor(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            FIcons.x,
            color: AppTheme.getErrorColor(context),
            size: 16,
          ),
        );
      case IntakeStatus.pending:
        final now = DateTime.now();
        final parts = reminderTime.split(':');
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        final scheduledTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          hour,
          minute,
        );

        if (scheduledTime.isBefore(now)) {
          // Past time, show missed status
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.getWarningColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              FIcons.x,
              color: AppTheme.getWarningColor(context),
              size: 16,
            ),
          );
        } else {
          // Future time, show neutral outlined action button
          final theme = context.theme;
          final borderColor = theme.colors.border;
          return SizedBox(
            width: 36,
            height: 36,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _handleMarkTaken(context),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colors.background,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor),
                  ),
                  child: Center(
                    child: Icon(
                      FIcons.plus,
                      size: 16,
                      color: theme.colors.foreground,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      case IntakeStatus.skipped:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.theme.colors.mutedForeground.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(FIcons.minus, color: context.theme.colors.mutedForeground, size: 16),
        );
    }
  }

  Future<void> _handleMarkTaken(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final medicationProvider = context.read<MedicationProvider>();

    final parts = reminderTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    final scheduledTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      hour,
      minute,
    );

    await medicationProvider.logIntake(
      medicineId: medicine.id,
      scheduledTime: scheduledTime,
      status: IntakeStatus.taken,
      userId: authProvider.currentUser!.id,
    );

    onStatusChanged?.call();
  }
}
