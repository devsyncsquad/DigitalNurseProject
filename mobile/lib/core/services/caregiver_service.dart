import '../models/caregiver_model.dart';

class CaregiverService {
  final List<CaregiverModel> _caregivers = [];

  Future<void> _mockDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Get all caregivers for a patient
  Future<List<CaregiverModel>> getCaregivers(String patientId) async {
    await _mockDelay();
    return _caregivers.where((c) => c.linkedPatientId == patientId).toList();
  }

  // Add caregiver and send invitation
  Future<CaregiverModel> addCaregiver({
    required String patientId,
    required String phone,
    String? name,
    String? relationship,
  }) async {
    await _mockDelay();

    final caregiver = CaregiverModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name ?? 'Caregiver',
      phone: phone,
      status: CaregiverStatus.pending,
      relationship: relationship,
      linkedPatientId: patientId,
      invitedAt: DateTime.now(),
    );

    _caregivers.add(caregiver);
    return caregiver;
  }

  // Generate invitation link
  Future<String> generateInvitationLink(String caregiverId) async {
    await _mockDelay();
    return 'https://digitalnurse.app/invite/$caregiverId';
  }

  // Send SMS invitation (mock)
  Future<bool> sendInvitationSMS(String phone, String invitationLink) async {
    await _mockDelay();
    // Mock SMS sending
    print('SMS sent to $phone: Join as caregiver: $invitationLink');
    return true;
  }

  // Accept caregiver invitation
  Future<CaregiverModel> acceptInvitation(String caregiverId) async {
    await _mockDelay();

    final index = _caregivers.indexWhere((c) => c.id == caregiverId);
    if (index == -1) {
      throw Exception('Caregiver not found');
    }

    final updatedCaregiver = _caregivers[index].copyWith(
      status: CaregiverStatus.accepted,
      acceptedAt: DateTime.now(),
    );

    _caregivers[index] = updatedCaregiver;
    return updatedCaregiver;
  }

  // Decline caregiver invitation
  Future<void> declineInvitation(String caregiverId) async {
    await _mockDelay();

    final index = _caregivers.indexWhere((c) => c.id == caregiverId);
    if (index == -1) {
      throw Exception('Caregiver not found');
    }

    final updatedCaregiver = _caregivers[index].copyWith(
      status: CaregiverStatus.declined,
    );

    _caregivers[index] = updatedCaregiver;
  }

  // Remove caregiver
  Future<void> removeCaregiver(String caregiverId) async {
    await _mockDelay();
    _caregivers.removeWhere((c) => c.id == caregiverId);
  }

  // Get caregiver by ID
  Future<CaregiverModel?> getCaregiverById(String caregiverId) async {
    await _mockDelay();
    try {
      return _caregivers.firstWhere((c) => c.id == caregiverId);
    } catch (e) {
      return null;
    }
  }

  // Initialize mock data
  void initializeMockData(String patientId) {
    _caregivers.addAll([
      CaregiverModel(
        id: 'mock-cg-1',
        name: 'Sarah Johnson',
        phone: '+1234567890',
        status: CaregiverStatus.accepted,
        relationship: 'Daughter',
        linkedPatientId: patientId,
        invitedAt: DateTime.now().subtract(const Duration(days: 5)),
        acceptedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      CaregiverModel(
        id: 'mock-cg-2',
        name: 'Mike Wilson',
        phone: '+1987654321',
        status: CaregiverStatus.pending,
        relationship: 'Son',
        linkedPatientId: patientId,
        invitedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);
  }
}
