import 'package:flutter/material.dart';
import '../models/caregiver_model.dart';
import '../services/caregiver_service.dart';

class CaregiverProvider with ChangeNotifier {
  final CaregiverService _caregiverService = CaregiverService();
  List<CaregiverModel> _caregivers = [];
  bool _isLoading = false;
  String? _error;

  List<CaregiverModel> get caregivers => _caregivers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load caregivers
  Future<void> loadCaregivers(String patientId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _caregivers = await _caregiverService.getCaregivers(patientId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add caregiver
  Future<CaregiverModel?> addCaregiver({
    required String patientId,
    required String phone,
    String? name,
    String? relationship,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final caregiver = await _caregiverService.addCaregiver(
        patientId: patientId,
        phone: phone,
        name: name,
        relationship: relationship,
      );

      // Generate and send invitation
      final link = await _caregiverService.generateInvitationLink(caregiver.id);
      await _caregiverService.sendInvitationSMS(phone, link);

      _caregivers.add(caregiver);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return caregiver;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Accept invitation
  Future<bool> acceptInvitation(String invitationId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _caregiverService.acceptInvitation(invitationId);
      
      // Reload caregivers to get updated status
      final patientId = _caregivers.isNotEmpty ? _caregivers.first.linkedPatientId : '';
      if (patientId.isNotEmpty) {
        await loadCaregivers(patientId);
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

  // Remove caregiver
  Future<bool> removeCaregiver(String caregiverId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _caregiverService.removeCaregiver(caregiverId);
      _caregivers.removeWhere((c) => c.id == caregiverId);
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

  // Initialize mock data (deprecated - no longer needed with API integration)
  @Deprecated('Mock data initialization no longer supported')
  Future<void> initializeMockData(String patientId) async {
    // Mock data initialization removed - data now comes from API
    await loadCaregivers(patientId);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
