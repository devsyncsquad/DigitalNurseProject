import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/medication_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../widgets/medicine_calendar_header.dart';
import '../widgets/medicine_schedule_card.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  DateTime _selectedDate = DateTime.now();

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
    final userId = authProvider.currentUser?.id;

    if (userId != null) {
      await medicationProvider.loadMedicines(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicationProvider = context.watch<MedicationProvider>();
    final medicines = medicationProvider.medicines;

    return FScaffold(
      header: FHeader(
        title: const Text('My Medicine'),
        suffixes: [
          FHeaderAction(
            icon: const Icon(FIcons.plus),
            onPress: () => context.push('/medicine/add'),
          ),
        ],
      ),
      child: medicationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Calendar Header - always show
                MedicineCalendarHeader(
                  selectedDate: _selectedDate,
                  onDateChanged: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),

                // Medicine Schedule Cards or empty state
                Expanded(
                  child: medicines.isEmpty
                      ? _buildEmptyState(context)
                      : _buildMedicineSchedule(context, medicationProvider),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            'Tap + to add your first medicine',
            style: context.theme.typography.sm,
          ),
          const SizedBox(height: 24),
          FButton(
            onPress: () => context.push('/medicine/add'),
            child: const Text('Add Medicine'),
          ),
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
}
