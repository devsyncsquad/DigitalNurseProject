import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/models/medicine_model.dart';
import '../../../core/providers/medication_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/modern_surface_theme.dart';
import '../../../core/widgets/modern_scaffold.dart';

class MedicineDetailScreen extends StatefulWidget {
  final String medicineId;

  const MedicineDetailScreen({super.key, required this.medicineId});

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  List<MedicineIntake>? _intakeHistory;

  @override
  void initState() {
    super.initState();
    _loadIntakeHistory();
  }

  Future<void> _loadIntakeHistory() async {
    final history = await context.read<MedicationProvider>().getIntakeHistory(
      widget.medicineId,
    );
    setState(() {
      _intakeHistory = history;
    });
  }

  Future<void> _handleLogIntake(IntakeStatus status) async {
    final authProvider = context.read<AuthProvider>();
    await context.read<MedicationProvider>().logIntake(
      medicineId: widget.medicineId,
      scheduledTime: DateTime.now(),
      status: status,
      userId: authProvider.currentUser!.id,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == IntakeStatus.taken
                ? 'Marked as taken'
                : 'Marked as missed',
          ),
          backgroundColor: status == IntakeStatus.taken
              ? AppTheme.getSuccessColor(context)
              : AppTheme.getWarningColor(context),
        ),
      );
      _loadIntakeHistory();
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: const Text('Are you sure you want to delete this medicine?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authProvider = context.read<AuthProvider>();
      final success = await context.read<MedicationProvider>().deleteMedicine(
        widget.medicineId,
        authProvider.currentUser!.id,
      );

      if (mounted) {
        if (success) {
          context.pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicationProvider = context.watch<MedicationProvider>();
    final medicine = medicationProvider.medicines.firstWhere(
      (m) => m.id == widget.medicineId,
    );

    return ModernScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          medicine.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _handleDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: ModernSurfaceTheme.screenPadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MedicineInfoCard(medicine: medicine),
            SizedBox(height: 20.h),
            _QuickActions(onLog: _handleLogIntake),
            SizedBox(height: 24.h),
            Text(
              'Intake History',
              style: ModernSurfaceTheme.sectionTitleStyle(context),
            ),
            SizedBox(height: 12.h),
            if (_intakeHistory == null)
              const Center(child: CircularProgressIndicator())
            else if (_intakeHistory!.isEmpty)
              Container(
                decoration: ModernSurfaceTheme.glassCard(),
                padding: EdgeInsets.all(24.w),
                child: Center(
                  child: Text(
                    'No intake history yet',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ModernSurfaceTheme.deepTeal.withOpacity(0.7),
                        ),
                  ),
                ),
              )
            else
              Column(
                children: _intakeHistory!
                    .map(
                      (intake) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Container(
                          decoration: ModernSurfaceTheme.glassCard(
                            accent: intake.status == IntakeStatus.taken
                                ? AppTheme.getSuccessColor(context)
                                : intake.status == IntakeStatus.missed
                                    ? AppTheme.getErrorColor(context)
                                    : ModernSurfaceTheme.accentBlue,
                          ),
                          padding: EdgeInsets.all(16.w),
                          child: Row(
                            children: [
                              Icon(
                                intake.status == IntakeStatus.taken
                                    ? FIcons.check
                                    : intake.status == IntakeStatus.missed
                                        ? FIcons.x
                                        : FIcons.circle,
                                color: intake.status == IntakeStatus.taken
                                    ? AppTheme.getSuccessColor(context)
                                    : intake.status == IntakeStatus.missed
                                        ? AppTheme.getErrorColor(context)
                                        : ModernSurfaceTheme.deepTeal,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _statusName(intake.status),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: ModernSurfaceTheme.deepTeal,
                                          ),
                                    ),
                                    Text(
                                      DateFormat('MMM d, yyyy • h:mm a')
                                          .format(intake.scheduledTime),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: ModernSurfaceTheme.deepTeal
                                                .withOpacity(0.7),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120.w,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ModernSurfaceTheme.deepTeal.withOpacity(0.6),
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ModernSurfaceTheme.deepTeal,
                ),
          ),
        ),
      ],
    );
  }
}

class _MedicineInfoCard extends StatelessWidget {
  final MedicineModel medicine;

  const _MedicineInfoCard({required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ModernSurfaceTheme.glassCard(accent: ModernSurfaceTheme.primaryTeal),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: ModernSurfaceTheme.iconBadge(
                  ModernSurfaceTheme.primaryTeal,
                ),
                child: const Icon(FIcons.pill, color: Colors.white, size: 28),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: ModernSurfaceTheme.deepTeal,
                          ),
                    ),
                    Text(
                      medicine.dosage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ModernSurfaceTheme.deepTeal.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          const Divider(),
          SizedBox(height: 20.h),
          _InfoRow(
            label: 'Frequency',
            value: _frequencyName(medicine.frequency),
          ),
          SizedBox(height: 8.h),
          _InfoRow(
            label: 'Start Date',
            value: DateFormat('MMM d, yyyy').format(medicine.startDate),
          ),
          if (medicine.endDate != null) ...[
            SizedBox(height: 8.h),
            _InfoRow(
              label: 'End Date',
              value: DateFormat('MMM d, yyyy').format(medicine.endDate!),
            ),
          ],
          SizedBox(height: 8.h),
          _InfoRow(
            label: 'Reminder Times',
            value: medicine.reminderTimes.join(', '),
          ),
          if (medicine.notes != null) ...[
            SizedBox(height: 8.h),
            _InfoRow(label: 'Notes', value: medicine.notes!),
          ],
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final Future<void> Function(IntakeStatus status) onLog;

  const _QuickActions({required this.onLog});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => onLog(IntakeStatus.taken),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              backgroundColor: ModernSurfaceTheme.primaryTeal,
            ),
            child: const Text('Mark as Taken'),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: OutlinedButton(
            onPressed: () => onLog(IntakeStatus.missed),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              side: BorderSide(color: ModernSurfaceTheme.deepTeal.withOpacity(0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text('Mark as Missed'),
          ),
        ),
      ],
    );
  }
}

String _frequencyName(MedicineFrequency freq) {
  switch (freq) {
    case MedicineFrequency.daily:
      return 'Once Daily';
    case MedicineFrequency.twiceDaily:
      return 'Twice Daily';
    case MedicineFrequency.thriceDaily:
      return 'Three Times Daily';
    case MedicineFrequency.weekly:
      return 'Weekly';
    case MedicineFrequency.asNeeded:
      return 'As Needed';
    case MedicineFrequency.periodic:
      return 'Periodic';
    case MedicineFrequency.beforeMeal:
      return 'Before Meal';
    case MedicineFrequency.afterMeal:
      return 'After Meal';
  }
}

String _statusName(IntakeStatus status) {
  switch (status) {
    case IntakeStatus.taken:
      return 'Taken';
    case IntakeStatus.missed:
      return 'Missed';
    case IntakeStatus.skipped:
      return 'Skipped';
    case IntakeStatus.pending:
      return 'Pending';
  }
}
