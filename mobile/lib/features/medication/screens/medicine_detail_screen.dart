import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/models/medicine_model.dart';
import '../../../core/providers/medication_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

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

    return FScaffold(
      header: FHeader.nested(
        title: Text(medicine.name),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        suffixes: [
          FHeaderAction(
            icon: Icon(FIcons.trash, color: context.theme.colors.destructive),
            onPress: _handleDelete,
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Medicine info card
            FCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          FIcons.pill,
                          size: 48,
                          color: context.theme.colors.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medicine.name,
                                style: context.theme.typography.xl.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                medicine.dosage,
                                style: context.theme.typography.base,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _InfoRow(
                      label: 'Frequency',
                      value: _getFrequencyName(medicine.frequency),
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'Start Date',
                      value: DateFormat(
                        'MMM d, yyyy',
                      ).format(medicine.startDate),
                    ),
                    if (medicine.endDate != null) ...[
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: 'End Date',
                        value: DateFormat(
                          'MMM d, yyyy',
                        ).format(medicine.endDate!),
                      ),
                    ],
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'Reminder Times',
                      value: medicine.reminderTimes.join(', '),
                    ),
                    if (medicine.notes != null) ...[
                      const SizedBox(height: 8),
                      _InfoRow(label: 'Notes', value: medicine.notes!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick actions
            Row(
              children: [
                Expanded(
                  child: FButton(
                    onPress: () => _handleLogIntake(IntakeStatus.taken),
                    child: const Text('Mark as Taken'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleLogIntake(IntakeStatus.missed),
                    child: const Text('Mark as Missed'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Intake history
            Text(
              'Intake History',
              style: context.theme.typography.lg.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (_intakeHistory == null)
              const Center(child: CircularProgressIndicator())
            else if (_intakeHistory!.isEmpty)
              FCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No intake history yet',
                      style: context.theme.typography.sm,
                    ),
                  ),
                ),
              )
            else
              ..._intakeHistory!.map((intake) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FCard(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
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
                                : context.theme.colors.mutedForeground,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getStatusName(intake.status),
                                  style: context.theme.typography.sm.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  DateFormat(
                                    'MMM d, yyyy - h:mm a',
                                  ).format(intake.scheduledTime),
                                  style: context.theme.typography.xs,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _getFrequencyName(MedicineFrequency freq) {
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
    }
  }

  String _getStatusName(IntakeStatus status) {
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
          width: 120,
          child: Text(
            label,
            style: context.theme.typography.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: context.theme.typography.sm.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
