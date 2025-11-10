import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/medication_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/care_context_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/medicine_model.dart';
import '../widgets/medicine_calendar_header.dart';
import '../widgets/medicine_schedule_card.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _lastContextKey;

  @override
  void initState() {
    super.initState();
    // Defer data loading until after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMedicines();
    });
  }

  Future<void> _loadMedicines() async {
    final authProvider = context.read<AuthProvider>();
    final medicationProvider = context.read<MedicationProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return;
    }

    final isCaregiver = user.role == UserRole.caregiver;
    String? targetUserId = user.id;
    String? elderUserId;

    if (isCaregiver) {
      final careContext = context.read<CareContextProvider>();
      await careContext.ensureLoaded();
      targetUserId = careContext.selectedElderId;
      elderUserId = targetUserId;
      if (targetUserId == null) {
        return;
      }
    }

    await medicationProvider.loadMedicines(
      targetUserId,
      elderUserId: elderUserId,
    );
  }

  void _ensureContextSync({
    required bool isCaregiver,
    required String? selectedElderId,
    required String? userId,
  }) {
    final key = isCaregiver
        ? 'caregiver-${selectedElderId ?? 'none'}'
        : 'patient-${userId ?? 'unknown'}';

    if (_lastContextKey == key) {
      return;
    }

    _lastContextKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadMedicines();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final isCaregiver = currentUser?.role == UserRole.caregiver;
    final careContext = isCaregiver
        ? context.watch<CareContextProvider>()
        : null;
    final selectedElderId = careContext?.selectedElderId;
    final hasAssignments =
        !isCaregiver || (careContext?.careRecipients.isNotEmpty ?? false);
    final isCareContextLoading = careContext?.isLoading ?? false;
    final careContextError = careContext?.error;

    _ensureContextSync(
      isCaregiver: isCaregiver,
      selectedElderId: selectedElderId,
      userId: currentUser?.id,
    );

    final medicationProvider = context.watch<MedicationProvider>();
    final medicines = medicationProvider.medicines;
    final errorMessage = medicationProvider.error;

    return FScaffold(
      header: FHeader(
        title: const Text('My Medicine'),
        suffixes: [
          if (!isCaregiver)
            FHeaderAction(
              icon: const Icon(FIcons.plus),
              onPress: () => context.push('/medicine/add'),
            ),
        ],
      ),
      child: _buildBody(
        context,
        medicationProvider: medicationProvider,
        medicines: medicines,
        errorMessage: errorMessage,
        isCaregiver: isCaregiver,
        hasAssignments: hasAssignments,
        isCareContextLoading: isCareContextLoading,
        careContextError: careContextError,
        hasSelectedRecipient: selectedElderId != null,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required MedicationProvider medicationProvider,
    required List<MedicineModel> medicines,
    required String? errorMessage,
    required bool isCaregiver,
    required bool hasAssignments,
    required bool isCareContextLoading,
    required String? careContextError,
    required bool hasSelectedRecipient,
  }) {
    if (isCaregiver) {
      if (isCareContextLoading && !hasAssignments) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!hasAssignments) {
        return _buildCaregiverNotice(
          context,
          icon: FIcons.users,
          title: 'No patients assigned yet',
          message:
              'Once a patient connects you as their caregiver, their medicines will appear here.',
        );
      }

      if (careContextError != null && !hasSelectedRecipient) {
        return _buildCaregiverNotice(
          context,
          icon: FIcons.info,
          title: 'Unable to load patients',
          message: careContextError,
          onRetry: _loadMedicines,
        );
      }

      if (!hasSelectedRecipient) {
        return _buildCaregiverNotice(
          context,
          icon: FIcons.userSearch,
          title: 'Select a patient to continue',
          message:
              'Choose a patient from the dashboard to review their medication schedule.',
        );
      }
    }

    if (medicationProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _ErrorBanner(message: errorMessage, onRetry: _loadMedicines),
          ),
        MedicineCalendarHeader(
          selectedDate: _selectedDate,
          onDateChanged: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
        ),
        Expanded(
          child: medicines.isEmpty
              ? _buildEmptyState(context, isCaregiver: isCaregiver)
              : _buildMedicineSchedule(context, medicationProvider),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool isCaregiver}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FIcons.pill,
            size: 64,
            color: context.theme.colors.mutedForeground,
          ),
          const SizedBox(height: 16),
          Text('No medicines added yet', style: context.theme.typography.lg),
          const SizedBox(height: 8),
          Text(
            isCaregiver
                ? 'This patient has no medicines recorded yet.'
                : 'Tap + to add your first medicine',
            style: context.theme.typography.sm,
          ),
          if (!isCaregiver) ...[
            const SizedBox(height: 24),
            FButton(
              onPress: () => context.push('/medicine/add'),
              child: const Text('Add Medicine'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicineSchedule(
    BuildContext context,
    MedicationProvider medicationProvider,
  ) {
    final medicinesForDate = medicationProvider.getMedicinesForDate(
      _selectedDate,
    );
    final categorized = medicationProvider.categorizeMedicinesByTimeOfDay(
      medicinesForDate,
    );

    if (medicinesForDate.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FIcons.calendar,
              size: 64,
              color: context.theme.colors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              'No medicines for ${_getFormattedDate(_selectedDate)}',
              style: context.theme.typography.lg,
            ),
            const SizedBox(height: 8),
            Text(
              'Select another date or add medicines',
              style: context.theme.typography.sm.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Morning Medicines
          if (categorized['morning']!.isNotEmpty)
            MedicineScheduleCard(
              timeOfDay: MedicineTimeOfDay.morning,
              medicines: categorized['morning']!,
              selectedDate: _selectedDate,
              onStatusChanged: () {
                setState(() {});
              },
            ),

          // Afternoon Medicines
          if (categorized['afternoon']!.isNotEmpty)
            MedicineScheduleCard(
              timeOfDay: MedicineTimeOfDay.afternoon,
              medicines: categorized['afternoon']!,
              selectedDate: _selectedDate,
              onStatusChanged: () {
                setState(() {});
              },
            ),

          // Evening Medicines
          if (categorized['evening']!.isNotEmpty)
            MedicineScheduleCard(
              timeOfDay: MedicineTimeOfDay.evening,
              medicines: categorized['evening']!,
              selectedDate: _selectedDate,
              onStatusChanged: () {
                setState(() {});
              },
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
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

  Widget _buildCaregiverNotice(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: FCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: context.theme.colors.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: context.theme.typography.lg.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: context.theme.typography.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                FButton(onPress: onRetry, child: const Text('Retry')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.getErrorColor(context).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getErrorColor(context).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(FIcons.info, color: AppTheme.getErrorColor(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: context.theme.typography.sm.copyWith(
                color: AppTheme.getErrorColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              onRetry();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
