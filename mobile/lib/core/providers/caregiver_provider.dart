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

  // Send caregiver invitation
  Future<Map<String, dynamic>?> inviteCaregiver({
    required String patientId,
    required String email,
    String? phone,
    String? name,
    String? relationship,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final invitation = await _caregiverService.sendInvitation(
        email: email,
        phone: phone,
        relationship: relationship,
        name: name,
      );

      // Refresh caregiver assignments to include pending invitations
      await loadCaregivers(patientId);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return invitation;
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
      final patientId = _caregivers.isNotEmpty
          ? _caregivers.first.linkedPatientId
          : '';
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
