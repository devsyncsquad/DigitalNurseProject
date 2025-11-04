import '../models/medicine_model.dart';
import '../models/notification_model.dart';
import 'fcm_service.dart';

class MedicationService {
  final List<MedicineModel> _medicines = [];
  final List<MedicineIntake> _intakes = [];
  final FCMService _fcmService = FCMService();

  Future<void> _mockDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Get all medicines for a user
  Future<List<MedicineModel>> getMedicines(String userId) async {
    await _mockDelay();
    return _medicines.where((m) => m.userId == userId).toList();
  }

  // Add new medicine
  Future<MedicineModel> addMedicine(MedicineModel medicine) async {
    await _mockDelay();
    _medicines.add(medicine);

    // Schedule notifications for medicine reminders (with error handling)
    try {
      await _scheduleMedicineReminders(medicine);
    } catch (e) {
      print('Warning: Failed to schedule medicine reminders: $e');
      // Don't fail the entire operation if notification scheduling fails
      // The medicine is still saved successfully
    }

    return medicine;
  }

  // Update medicine
  Future<MedicineModel> updateMedicine(MedicineModel medicine) async {
    await _mockDelay();
    final index = _medicines.indexWhere((m) => m.id == medicine.id);
    if (index == -1) {
      throw Exception('Medicine not found');
    }
    _medicines[index] = medicine;

    // Reschedule notifications for updated medicine (with error handling)
    try {
      await _scheduleMedicineReminders(medicine);
    } catch (e) {
      print('Warning: Failed to reschedule medicine reminders: $e');
      // Don't fail the entire operation if notification scheduling fails
    }

    return medicine;
  }

  // Delete medicine
  Future<void> deleteMedicine(String medicineId) async {
    await _mockDelay();
    _medicines.removeWhere((m) => m.id == medicineId);
    _intakes.removeWhere((i) => i.medicineId == medicineId);

    // Cancel scheduled notifications for deleted medicine
    await _fcmService.cancelNotification(medicineId.hashCode);
  }

  // Get medicine by ID
  Future<MedicineModel?> getMedicineById(String medicineId) async {
    await _mockDelay();
    try {
      return _medicines.firstWhere((m) => m.id == medicineId);
    } catch (e) {
      return null;
    }
  }

  // Log medicine intake
  Future<MedicineIntake> logIntake({
    required String medicineId,
    required DateTime scheduledTime,
    required IntakeStatus status,
  }) async {
    await _mockDelay();

    final intake = MedicineIntake(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicineId: medicineId,
      scheduledTime: scheduledTime,
      takenTime: status == IntakeStatus.taken ? DateTime.now() : null,
      status: status,
    );

    _intakes.add(intake);
    return intake;
  }

  // Get intake history for a medicine
  Future<List<MedicineIntake>> getIntakeHistory(String medicineId) async {
    await _mockDelay();
    return _intakes.where((i) => i.medicineId == medicineId).toList()
      ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
  }

  // Get upcoming reminders
  Future<List<Map<String, dynamic>>> getUpcomingReminders(String userId) async {
    await _mockDelay();

    final userMedicines = _medicines.where((m) => m.userId == userId).toList();
    final reminders = <Map<String, dynamic>>[];

    for (var medicine in userMedicines) {
      final now = DateTime.now();
      for (var timeStr in medicine.reminderTimes) {
        final parts = timeStr.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        var reminderTime = DateTime(now.year, now.month, now.day, hour, minute);

        // If time has passed today, schedule for tomorrow
        if (reminderTime.isBefore(now)) {
          reminderTime = reminderTime.add(const Duration(days: 1));
        }

        reminders.add({'medicine': medicine, 'reminderTime': reminderTime});
      }
    }

    reminders.sort(
      (a, b) => (a['reminderTime'] as DateTime).compareTo(
        b['reminderTime'] as DateTime,
      ),
    );

    return reminders.take(5).toList();
  }

  // Get adherence percentage
  Future<double> getAdherencePercentage(String userId, {int days = 7}) async {
    await _mockDelay();

    final userMedicines = _medicines.where((m) => m.userId == userId).toList();
    if (userMedicines.isEmpty) return 100.0;

    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentIntakes = _intakes
        .where((i) => i.scheduledTime.isAfter(cutoffDate))
        .toList();

    if (recentIntakes.isEmpty) return 100.0;

    final takenCount = recentIntakes
        .where((i) => i.status == IntakeStatus.taken)
        .length;

    return (takenCount / recentIntakes.length) * 100;
  }

  // Get adherence streak (consecutive days with 100% adherence)
  Future<int> getAdherenceStreak(String userId) async {
    await _mockDelay();

    final userMedicines = _medicines.where((m) => m.userId == userId).toList();
    if (userMedicines.isEmpty) return 0;

    int streak = 0;
    final now = DateTime.now();

    // Check each day going backwards from today
    for (int i = 0; i < 365; i++) {
      final checkDate = now.subtract(Duration(days: i));
      final startOfDay = DateTime(
        checkDate.year,
        checkDate.month,
        checkDate.day,
      );
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Get all intakes for this day
      final dayIntakes = _intakes.where((intake) {
        return intake.scheduledTime.isAfter(startOfDay) &&
            intake.scheduledTime.isBefore(endOfDay);
      }).toList();

      if (dayIntakes.isEmpty) {
        // No medicines scheduled for this day, consider it as 100% adherence
        if (i == 0 || streak > 0) {
          // Only count as streak if it's today or we're in a streak
          if (i > 0) streak++;
        } else {
          break; // Not in a streak and no intakes, stop checking
        }
        continue;
      }

      // Check if all intakes for this day were taken
      final allTaken = dayIntakes.every(
        (intake) => intake.status == IntakeStatus.taken,
      );

      if (allTaken) {
        streak++;
      } else {
        // If checking today and not perfect, don't break streak yet
        if (i > 0) break;
      }
    }

    return streak;
  }

  // Test immediate notification (for debugging)
  Future<void> testImmediateNotification(String medicineName) async {
    try {
      print('Testing immediate notification for $medicineName');

      // Check if FCM service is initialized
      if (!_fcmService.isInitialized) {
        print('FCM service not initialized, attempting to initialize...');
        try {
          await _fcmService.initialize();
        } catch (e) {
          print('Failed to initialize FCM service: $e');
          return;
        }
      }

      await _fcmService.scheduleLocalNotification(
        id: 99999, // Use a unique ID for testing
        title: 'Test Medicine Reminder',
        body: 'Time to take $medicineName - This is a test notification',
        scheduledDate: DateTime.now().add(
          const Duration(seconds: 10),
        ), // 10 seconds from now
        payload: '{"type": "test_notification"}',
        type: NotificationType.medicineReminder,
      );
      print('Test notification scheduled for 10 seconds from now');
    } catch (e) {
      print('Failed to schedule test notification: $e');
      // Don't rethrow to prevent app crashes
    }
  }

  // Initialize mock data
  void initializeMockData(String userId) {
    final now = DateTime.now();

    _medicines.addAll([
      MedicineModel(
        id: 'mock-med-1',
        name: 'Aspirin',
        dosage: '1 tablet of 75mg',
        frequency: MedicineFrequency.daily,
        startDate: now.subtract(const Duration(days: 30)),
        reminderTimes: ['08:00', '20:00'],
        notes: 'Take with food',
        userId: userId,
        medicineForm: MedicineForm.tablet,
        strength: '75mg',
        doseAmount: '1 tablet',
      ),
      MedicineModel(
        id: 'mock-med-2',
        name: 'Metformin',
        dosage: '1 tablet of 500mg',
        frequency: MedicineFrequency.twiceDaily,
        startDate: now.subtract(const Duration(days: 15)),
        reminderTimes: ['09:00', '21:00'],
        notes: 'For blood sugar control',
        userId: userId,
        medicineForm: MedicineForm.tablet,
        strength: '500mg',
        doseAmount: '1 tablet',
      ),
      MedicineModel(
        id: 'mock-med-3',
        name: 'Vitamin D',
        dosage: '1 capsule of 1000 IU',
        frequency: MedicineFrequency.daily,
        startDate: now.subtract(const Duration(days: 60)),
        reminderTimes: ['10:00'],
        userId: userId,
        medicineForm: MedicineForm.capsule,
        strength: '1000 IU',
        doseAmount: '1 capsule',
      ),
    ]);

    // Add some mock intakes
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      _intakes.add(
        MedicineIntake(
          id: 'intake-1-$i',
          medicineId: 'mock-med-1',
          scheduledTime: DateTime(date.year, date.month, date.day, 8, 0),
          takenTime: DateTime(date.year, date.month, date.day, 8, 15),
          status: i == 1 ? IntakeStatus.missed : IntakeStatus.taken,
        ),
      );
    }
  }

  // Schedule medicine reminder notifications
  Future<void> _scheduleMedicineReminders(MedicineModel medicine) async {
    try {
      // Check if FCM service is initialized
      if (!_fcmService.isInitialized) {
        print('FCM service not initialized, attempting to initialize...');
        try {
          await _fcmService.initialize();
        } catch (e) {
          print('Failed to initialize FCM service: $e');
          return;
        }
      }

      final now = DateTime.now();

      for (int i = 0; i < 7; i++) {
        // Schedule for next 7 days
        final date = now.add(Duration(days: i));

        for (final timeStr in medicine.reminderTimes) {
          try {
            final parts = timeStr.split(':');
            if (parts.length != 2) {
              print('Warning: Invalid time format: $timeStr');
              continue;
            }

            final hour = int.parse(parts[0]);
            final minute = int.parse(parts[1]);

            final reminderTime = DateTime(
              date.year,
              date.month,
              date.day,
              hour,
              minute,
            );

            // Only schedule if the time is in the future
            if (reminderTime.isAfter(now)) {
              print(
                'Scheduling notification for ${medicine.name} at ${reminderTime.toString()}',
              );
              await _fcmService.scheduleLocalNotification(
                id: '${medicine.id}_${reminderTime.millisecondsSinceEpoch}'
                    .hashCode,
                title: 'Medicine Reminder',
                body: 'Time to take ${medicine.name} ${medicine.dosage}',
                scheduledDate: reminderTime,
                payload:
                    '{"medicineId": "${medicine.id}", "type": "medicine_reminder"}',
                type: NotificationType.medicineReminder,
              );
              print('Notification scheduled successfully for ${medicine.name}');
            } else {
              print(
                'Skipping notification for ${medicine.name} - time ${reminderTime.toString()} is in the past',
              );
            }
          } catch (e) {
            print('Warning: Failed to schedule reminder for time $timeStr: $e');
            // Continue with other times even if one fails
          }
        }
      }
    } catch (e) {
      print('Error in _scheduleMedicineReminders: $e');
      rethrow;
    }
  }
}
