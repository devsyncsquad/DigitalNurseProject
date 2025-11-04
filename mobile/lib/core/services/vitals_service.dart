import '../models/vital_measurement_model.dart';

class VitalsService {
  final List<VitalMeasurementModel> _vitals = [];

  Future<void> _mockDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Get all vitals for a user
  Future<List<VitalMeasurementModel>> getVitals(String userId) async {
    await _mockDelay();
    return _vitals.where((v) => v.userId == userId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get vitals by type
  Future<List<VitalMeasurementModel>> getVitalsByType(
    String userId,
    VitalType type,
  ) async {
    await _mockDelay();
    return _vitals.where((v) => v.userId == userId && v.type == type).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Add vital measurement
  Future<VitalMeasurementModel> addVital(VitalMeasurementModel vital) async {
    await _mockDelay();
    _vitals.add(vital);
    return vital;
  }

  // Update vital
  Future<VitalMeasurementModel> updateVital(VitalMeasurementModel vital) async {
    await _mockDelay();
    final index = _vitals.indexWhere((v) => v.id == vital.id);
    if (index == -1) {
      throw Exception('Vital not found');
    }
    _vitals[index] = vital;
    return vital;
  }

  // Delete vital
  Future<void> deleteVital(String vitalId) async {
    await _mockDelay();
    _vitals.removeWhere((v) => v.id == vitalId);
  }

  // Get recent vitals (last 7 days)
  Future<List<VitalMeasurementModel>> getRecentVitals(String userId) async {
    await _mockDelay();
    final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
    return _vitals
        .where((v) => v.userId == userId && v.timestamp.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Calculate average for a vital type over a period
  Future<Map<String, dynamic>> calculateTrends(
    String userId,
    VitalType type, {
    int days = 7,
  }) async {
    await _mockDelay();

    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final measurements = _vitals
        .where(
          (v) =>
              v.userId == userId &&
              v.type == type &&
              v.timestamp.isAfter(cutoffDate),
        )
        .toList();

    if (measurements.isEmpty) {
      return {'average': 0.0, 'count': 0, 'hasAbnormal': false};
    }

    double sum = 0;
    int count = measurements.length;
    bool hasAbnormal = false;

    for (var vital in measurements) {
      // Parse value based on type
      if (type == VitalType.bloodPressure) {
        final parts = vital.value.split('/');
        if (parts.length == 2) {
          sum += double.tryParse(parts[0]) ?? 0; // Only systolic for average
        }
      } else {
        sum += double.tryParse(vital.value) ?? 0;
      }

      if (vital.isAbnormal()) {
        hasAbnormal = true;
      }
    }

    return {
      'average': sum / count,
      'count': count,
      'hasAbnormal': hasAbnormal,
      'measurements': measurements,
    };
  }

  // Check for abnormal readings
  Future<List<VitalMeasurementModel>> getAbnormalReadings(String userId) async {
    await _mockDelay();
    return _vitals.where((v) => v.userId == userId && v.isAbnormal()).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Initialize mock data
  void initializeMockData(String userId) {
    final now = DateTime.now();

    // Blood Pressure readings
    for (int i = 0; i < 30; i++) {
      _vitals.add(
        VitalMeasurementModel(
          id: 'bp-$i',
          type: VitalType.bloodPressure,
          value: '${120 + (i % 10)}/${80 + (i % 5)}',
          timestamp: now.subtract(Duration(days: i)),
          userId: userId,
        ),
      );
    }

    // Blood Sugar readings
    for (int i = 0; i < 30; i++) {
      _vitals.add(
        VitalMeasurementModel(
          id: 'bs-$i',
          type: VitalType.bloodSugar,
          value: '${95 + (i % 15)}',
          timestamp: now.subtract(Duration(days: i)),
          notes: i % 7 == 0 ? 'Fasting' : 'Post-meal',
          userId: userId,
        ),
      );
    }

    // Heart Rate readings
    for (int i = 0; i < 15; i++) {
      _vitals.add(
        VitalMeasurementModel(
          id: 'hr-$i',
          type: VitalType.heartRate,
          value: '${70 + (i % 10)}',
          timestamp: now.subtract(Duration(days: i * 2)),
          userId: userId,
        ),
      );
    }

    // Weight readings
    for (int i = 0; i < 10; i++) {
      _vitals.add(
        VitalMeasurementModel(
          id: 'wt-$i',
          type: VitalType.weight,
          value: '${170 - i}',
          timestamp: now.subtract(Duration(days: i * 3)),
          userId: userId,
        ),
      );
    }
  }
}
