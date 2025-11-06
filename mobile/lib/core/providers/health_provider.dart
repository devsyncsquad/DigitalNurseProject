import 'package:flutter/material.dart';
import '../models/vital_measurement_model.dart';
import '../services/vitals_service.dart';

class HealthProvider with ChangeNotifier {
  final VitalsService _vitalsService = VitalsService();
  List<VitalMeasurementModel> _vitals = [];
  bool _isLoading = false;
  String? _error;

  List<VitalMeasurementModel> get vitals => _vitals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load vitals
  Future<void> loadVitals(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _vitals = await _vitalsService.getVitals(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get vitals by type
  Future<List<VitalMeasurementModel>> getVitalsByType(
    String userId,
    VitalType type,
  ) async {
    return await _vitalsService.getVitalsByType(userId, type);
  }

  // Add vital
  Future<bool> addVital(VitalMeasurementModel vital) async {
    _isLoading = true;
    notifyListeners();

    try {
      final added = await _vitalsService.addVital(vital);
      _vitals.insert(0, added);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update vital
  Future<bool> updateVital(VitalMeasurementModel vital) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _vitalsService.updateVital(vital);
      final index = _vitals.indexWhere((v) => v.id == vital.id);
      if (index != -1) {
        _vitals[index] = updated;
      }
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete vital
  Future<bool> deleteVital(String vitalId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _vitalsService.deleteVital(vitalId);
      _vitals.removeWhere((v) => v.id == vitalId);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get recent vitals
  Future<List<VitalMeasurementModel>> getRecentVitals(String userId) async {
    return await _vitalsService.getRecentVitals(userId);
  }

  // Get vitals for a specific date
  List<VitalMeasurementModel> getVitalsForDate(DateTime date) {
    return _vitals.where((vital) {
      final vitalDate = DateTime(
        vital.timestamp.year,
        vital.timestamp.month,
        vital.timestamp.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return vitalDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  // Calculate trends
  Future<Map<String, dynamic>> calculateTrends(
    String userId,
    VitalType type, {
    int days = 7,
  }) async {
    return await _vitalsService.calculateTrends(userId, type, days: days);
  }

  // Get abnormal readings
  Future<List<VitalMeasurementModel>> getAbnormalReadings(String userId) async {
    return await _vitalsService.getAbnormalReadings(userId);
  }

  // Initialize mock data (deprecated - no longer needed with API integration)
  @Deprecated('Mock data initialization no longer supported')
  Future<void> initializeMockData(String userId) async {
    // Mock data initialization removed - data now comes from API
    await loadVitals(userId);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
