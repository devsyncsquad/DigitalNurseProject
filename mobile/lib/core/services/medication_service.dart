import '../models/medicine_model.dart';
import '../models/notification_model.dart';
import '../mappers/medication_mapper.dart';
import 'api_service.dart';
import 'fcm_service.dart';

class MedicationService {
  final ApiService _apiService = ApiService();
  final FCMService _fcmService = FCMService();

  void _log(String message) {
    print('🔍 [MEDICATION] $message');
  }

  // Get all medicines for a user
  Future<List<MedicineModel>> getMedicines(
    String userId, {
    String? elderUserId,
  }) async {
    _log('📋 Fetching medications for user: $userId');
    try {
      final response = await _apiService.get(
        '/medications',
        queryParameters: elderUserId != null ? {'elderUserId': elderUserId} : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        final medicines = data
            .map((json) => MedicationMapper.fromApiResponse(
                json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json)))
            .toList();
        _log('✅ Fetched ${medicines.length} medications');
        return medicines;
      } else {
        _log('❌ Failed to fetch medications: ${response.statusMessage}');
        throw Exception('Failed to fetch medications: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error fetching medications: $e');
      throw Exception(e.toString());
    }
  }

  // Add new medicine
  Future<MedicineModel> addMedicine(MedicineModel medicine) async {
    _log('➕ Adding medication: ${medicine.name}');
    try {
      final requestData = MedicationMapper.toApiRequest(
        medicine,
        elderUserId: medicine.userId,
      );
      final response = await _apiService.post(
        '/medications',
        data: requestData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final addedMedicine = MedicationMapper.fromApiResponse(response.data);
        _log('✅ Medication added successfully: ${addedMedicine.name}');

        // Schedule notifications for medicine reminders (with error handling)
        try {
          await _scheduleMedicineReminders(addedMedicine);
        } catch (e) {
          _log('⚠️ Warning: Failed to schedule medicine reminders: $e');
          // Don't fail the entire operation if notification scheduling fails
        }

        return addedMedicine;
      } else {
        _log('❌ Failed to add medication: ${response.statusMessage}');
        throw Exception('Failed to add medication: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error adding medication: $e');
      throw Exception(e.toString());
    }
  }

  // Update medicine
  Future<MedicineModel> updateMedicine(MedicineModel medicine) async {
    _log('✏️ Updating medication: ${medicine.name}');
    try {
      final requestData = MedicationMapper.toApiRequest(
        medicine,
        elderUserId: medicine.userId,
      );
      final response = await _apiService.patch(
        '/medications/${medicine.id}',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final updatedMedicine = MedicationMapper.fromApiResponse(response.data);
        _log('✅ Medication updated successfully: ${updatedMedicine.name}');

        // Reschedule notifications for updated medicine (with error handling)
        try {
          await _scheduleMedicineReminders(updatedMedicine);
        } catch (e) {
          _log('⚠️ Warning: Failed to reschedule medicine reminders: $e');
        }

        return updatedMedicine;
      } else {
        _log('❌ Failed to update medication: ${response.statusMessage}');
        throw Exception('Failed to update medication: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error updating medication: $e');
      throw Exception(e.toString());
    }
  }

  // Delete medicine
  Future<void> deleteMedicine(
    String medicineId, {
    String? elderUserId,
  }) async {
    _log('🗑️ Deleting medication: $medicineId');
    try {
      final response = await _apiService.delete(
        '/medications/$medicineId',
        queryParameters:
            elderUserId != null ? {'elderUserId': elderUserId} : null,
      );

      if (response.statusCode == 200) {
        _log('✅ Medication deleted successfully');

        // Cancel scheduled notifications for deleted medicine
        try {
          await _fcmService.cancelNotification(medicineId.hashCode);
        } catch (e) {
          _log('⚠️ Warning: Failed to cancel notifications: $e');
        }
      } else {
        _log('❌ Failed to delete medication: ${response.statusMessage}');
        throw Exception('Failed to delete medication: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error deleting medication: $e');
      throw Exception(e.toString());
    }
  }

  // Get medicine by ID
  Future<MedicineModel?> getMedicineById(
    String medicineId, {
    String? elderUserId,
  }) async {
    _log('🔍 Fetching medication by ID: $medicineId');
    try {
      final response = await _apiService.get(
        '/medications/$medicineId',
        queryParameters:
            elderUserId != null ? {'elderUserId': elderUserId} : null,
      );

      if (response.statusCode == 200) {
        final medicine = MedicationMapper.fromApiResponse(response.data);
        _log('✅ Medication fetched: ${medicine.name}');
        return medicine;
      } else {
        _log('❌ Medication not found: $medicineId');
        return null;
      }
    } catch (e) {
      _log('❌ Error fetching medication: $e');
      return null;
    }
  }

  // Log medicine intake
  Future<MedicineIntake> logIntake({
    required String medicineId,
    required DateTime scheduledTime,
    required IntakeStatus status,
    String? elderUserId,
  }) async {
    _log('📝 Logging intake for medication: $medicineId');
    try {
      final intake = MedicineIntake(
        id: '', // Will be set by backend
        medicineId: medicineId,
        scheduledTime: scheduledTime,
        takenTime: status == IntakeStatus.taken ? DateTime.now() : null,
        status: status,
      );

      final requestData = MedicationMapper.intakeToApiRequest(
        intake,
        elderUserId: elderUserId,
      );
      final response = await _apiService.post(
        '/medications/$medicineId/intakes',
        data: requestData,
        queryParameters:
            elderUserId != null ? {'elderUserId': elderUserId} : null,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final loggedIntake = MedicationMapper.intakeFromApiResponse(response.data);
        _log('✅ Intake logged successfully');
        return loggedIntake;
      } else {
        _log('❌ Failed to log intake: ${response.statusMessage}');
        throw Exception('Failed to log intake: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error logging intake: $e');
      throw Exception(e.toString());
    }
  }

  // Get intake history for a medicine
  Future<List<MedicineIntake>> getIntakeHistory(
    String medicineId, {
    String? elderUserId,
  }) async {
    _log('📜 Fetching intake history for medication: $medicineId');
    try {
      final response = await _apiService.get(
        '/medications/$medicineId/intakes',
        queryParameters:
            elderUserId != null ? {'elderUserId': elderUserId} : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        final intakes = data
            .map((json) => MedicationMapper.intakeFromApiResponse(
                json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json)))
            .toList()
          ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
        _log('✅ Fetched ${intakes.length} intake records');
        return intakes;
      } else {
        _log('❌ Failed to fetch intake history: ${response.statusMessage}');
        throw Exception('Failed to fetch intake history: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error fetching intake history: $e');
      throw Exception(e.toString());
    }
  }

  // Get upcoming reminders
  Future<List<Map<String, dynamic>>> getUpcomingReminders(
    String userId, {
    String? elderUserId,
  }) async {
    _log('⏰ Fetching upcoming reminders for user: $userId');
    try {
      final response = await _apiService.get(
        '/medications/upcoming',
        queryParameters:
            elderUserId != null ? {'elderUserId': elderUserId} : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        final reminders = data.map((item) {
          final map = item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item);
          return {
            'medicine': MedicationMapper.fromApiResponse(map['medicine'] ?? {}),
            'reminderTime': DateTime.parse(map['reminderTime']?.toString() ?? DateTime.now().toIso8601String()),
          };
        }).toList();
        _log('✅ Fetched ${reminders.length} upcoming reminders');
        return reminders;
      } else {
        _log('❌ Failed to fetch upcoming reminders: ${response.statusMessage}');
        throw Exception('Failed to fetch upcoming reminders: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error fetching upcoming reminders: $e');
      throw Exception(e.toString());
    }
  }

  // Get adherence percentage
  Future<double> getAdherencePercentage(
    String userId, {
    int days = 7,
    String? elderUserId,
  }) async {
    _log(
        '📊 Calculating adherence percentage for user: $userId (last $days days)');

    final medicines = await getMedicines(
      userId,
      elderUserId: elderUserId,
    );
    if (medicines.isEmpty) {
      _log('✅ No medications found, returning 100% adherence');
      return 100.0;
    }

    // Calculate overall adherence across all medications
    double totalPercentage = 0.0;
    int medicationCount = 0;

    for (var medicine in medicines) {
      try {
        final response = await _apiService.get(
          '/medications/${medicine.id}/adherence',
          queryParameters: {
            'days': days.toString(),
            if (elderUserId != null) 'elderUserId': elderUserId,
          },
        );

        if (response.statusCode == 200) {
          final data = response.data;
          final percentage = (data['percentage'] ?? 100.0).toDouble();
          totalPercentage += percentage;
          medicationCount++;
        }
      } catch (e) {
        _log('⚠️ Warning: Failed to get adherence for ${medicine.id}: $e');
        // Continue with other medications
      }
    }

    if (medicationCount == 0) {
      return 100.0;
    }

    final averagePercentage = totalPercentage / medicationCount;
    _log('✅ Overall adherence: ${averagePercentage.toStringAsFixed(1)}%');
    return averagePercentage;
  }

  // Get adherence streak (consecutive days with 100% adherence)
  Future<int> getAdherenceStreak(
    String userId, {
    String? elderUserId,
  }) async {
    _log('🔥 Calculating adherence streak for user: $userId');

    final medicines = await getMedicines(
      userId,
      elderUserId: elderUserId,
    );
    if (medicines.isEmpty) {
      _log('✅ No medications found, returning 0 streak');
      return 0;
    }

    // Get streak for the first medication (or calculate overall)
    // For simplicity, we'll use the first medication's streak
    // In a more sophisticated implementation, we'd calculate overall streak
    try {
      final response = await _apiService.get(
        '/medications/${medicines.first.id}/streak',
        queryParameters:
            elderUserId != null ? {'elderUserId': elderUserId} : null,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final streak = (data['streak'] ?? 0) as int;
        _log('✅ Adherence streak: $streak days');
        return streak;
      }
    } catch (e) {
      _log('⚠️ Warning: Failed to get streak: $e');
    }

    return 0;
  }

  // Test immediate notification (for debugging)
  Future<void> testImmediateNotification(String medicineName) async {
    try {
      _log('🧪 Testing immediate notification for $medicineName');

      // Check if FCM service is initialized
      if (!_fcmService.isInitialized) {
        _log('FCM service not initialized, attempting to initialize...');
        try {
          await _fcmService.initialize();
        } catch (e) {
          _log('Failed to initialize FCM service: $e');
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
      _log('Test notification scheduled for 10 seconds from now');
    } catch (e) {
      _log('Failed to schedule test notification: $e');
      // Don't rethrow to prevent app crashes
    }
  }

  // Schedule medicine reminder notifications
  Future<void> _scheduleMedicineReminders(MedicineModel medicine) async {
    try {
      // Check if FCM service is initialized
      if (!_fcmService.isInitialized) {
        _log('FCM service not initialized, attempting to initialize...');
        try {
          await _fcmService.initialize();
        } catch (e) {
          _log('Failed to initialize FCM service: $e');
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
              _log('Warning: Invalid time format: $timeStr');
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
              _log('Scheduling notification for ${medicine.name} at ${reminderTime.toString()}');
              await _fcmService.scheduleLocalNotification(
                id: '${medicine.id}_${reminderTime.millisecondsSinceEpoch}'.hashCode,
                title: 'Medicine Reminder',
                body: 'Time to take ${medicine.name} ${medicine.dosage}',
                scheduledDate: reminderTime,
                payload: '{"medicineId": "${medicine.id}", "type": "medicine_reminder"}',
                type: NotificationType.medicineReminder,
              );
              _log('Notification scheduled successfully for ${medicine.name}');
            } else {
              _log('Skipping notification for ${medicine.name} - time ${reminderTime.toString()} is in the past');
            }
          } catch (e) {
            _log('Warning: Failed to schedule reminder for time $timeStr: $e');
            // Continue with other times even if one fails
          }
        }
      }
    } catch (e) {
      _log('Error in _scheduleMedicineReminders: $e');
      rethrow;
    }
  }
}
