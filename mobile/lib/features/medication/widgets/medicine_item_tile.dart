import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/models/medicine_model.dart';
import '../../../core/providers/medication_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/modern_surface_theme.dart';

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
      margin: EdgeInsets.symmetric(vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.6),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => context.push('/medicine/${medicine.id}'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: ModernSurfaceTheme.deepTeal,
                          ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${medicine.dosage} • $timeDisplay',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ModernSurfaceTheme.deepTeal.withOpacity(0.65),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          _buildStatusButton(context),
        ],
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context) {
    switch (status) {
      case IntakeStatus.taken:
        return _StatusChip(
          color: AppTheme.getSuccessColor(context),
          icon: FIcons.check,
        );
      case IntakeStatus.missed:
        return _StatusChip(
          color: AppTheme.getErrorColor(context),
          icon: FIcons.x,
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
          return _StatusChip(
            color: AppTheme.getWarningColor(context),
            icon: FIcons.x,
          );
        } else {
          return SizedBox(
            width: 38.w,
            height: 38.w,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _handleMarkTaken(context),
                borderRadius: BorderRadius.circular(19),
                child: Container(
                  decoration: ModernSurfaceTheme.frostedChip(
                    baseColor: ModernSurfaceTheme.primaryTeal,
                  ),
                  child: Icon(
                    FIcons.plus,
                    size: 16,
                    color: ModernSurfaceTheme.chipForegroundColor(
                      ModernSurfaceTheme.primaryTeal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      case IntakeStatus.skipped:
        return _StatusChip(
          color: context.theme.colors.mutedForeground,
          icon: FIcons.minus,
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

class _StatusChip extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _StatusChip({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}
