import '../models/caregiver_model.dart';
import '../models/care_recipient_model.dart';
import '../mappers/caregiver_mapper.dart';
import 'api_service.dart';

class CaregiverService {
  final ApiService _apiService = ApiService();

  void _log(String message) {
    print('🔍 [CAREGIVER] $message');
  }

  // Get all caregivers for a patient
  Future<List<CaregiverModel>> getCaregivers(String patientId) async {
    _log('📋 Fetching caregivers for patient: $patientId');
    try {
      final response = await _apiService.get('/caregivers');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        final caregivers = data
            .map(
              (json) => CaregiverMapper.fromApiResponse(
                json is Map<String, dynamic>
                    ? json
                    : Map<String, dynamic>.from(json),
              ),
            )
            .toList();
        _log('✅ Fetched ${caregivers.length} caregivers');
        return caregivers;
      } else {
        _log('❌ Failed to fetch caregivers: ${response.statusMessage}');
        throw Exception(
          'Failed to fetch caregivers: ${response.statusMessage}',
        );
      }
    } catch (e) {
      _log('❌ Error fetching caregivers: $e');
      throw Exception(e.toString());
    }
  }

  // Get all elder assignments for a caregiver
  Future<List<CareRecipientModel>> getCareRecipients() async {
    _log('📋 Fetching caregiver assignments');
    try {
      final response = await _apiService.get('/caregivers/assignments');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        final assignments = data
            .map(
              (json) => CareRecipientModel.fromJson(
                json is Map<String, dynamic>
                    ? json
                    : Map<String, dynamic>.from(json),
              ),
            )
            .where((assignment) => assignment.elderId.isNotEmpty)
            .toList();
        _log('✅ Fetched ${assignments.length} caregiver assignments');
        return assignments;
      } else {
        _log('❌ Failed to fetch caregiver assignments: ${response.statusMessage}');
        throw Exception(
          'Failed to fetch caregiver assignments: ${response.statusMessage}',
        );
      }
    } catch (e) {
      _log('❌ Error fetching caregiver assignments: $e');
      throw Exception(e.toString());
    }
  }

  // Send caregiver invitation
  Future<Map<String, dynamic>> sendInvitation({
    required String email,
    String? phone,
    String? relationship,
    String? name,
  }) async {
    _log('📧 Sending caregiver invitation to: $email');
    try {
      final requestData = CaregiverMapper.invitationToApiRequest(
        email: email,
        phone: phone,
        relationship: relationship,
        name: name,
      );

      final response = await _apiService.post(
        '/caregivers/invitations',
        data: requestData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _log('✅ Invitation sent successfully');
        return response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data);
      } else {
        _log('❌ Failed to send invitation: ${response.statusMessage}');
        throw Exception('Failed to send invitation: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error sending invitation: $e');
      throw Exception(e.toString());
    }
  }

  // Get all pending invitations
  Future<List<CaregiverModel>> getInvitations(String patientId) async {
    _log('📋 Fetching pending invitations for patient: $patientId');
    try {
      final response = await _apiService.get('/caregivers/invitations');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        final invitations = data
            .map(
              (json) => CaregiverMapper.invitationFromApiResponse(
                json is Map<String, dynamic>
                    ? json
                    : Map<String, dynamic>.from(json),
              ),
            )
            .toList();
        _log('✅ Fetched ${invitations.length} pending invitations');
        return invitations;
      } else {
        _log('❌ Failed to fetch invitations: ${response.statusMessage}');
        throw Exception(
          'Failed to fetch invitations: ${response.statusMessage}',
        );
      }
    } catch (e) {
      _log('❌ Error fetching invitations: $e');
      throw Exception(e.toString());
    }
  }

  // Get invitation by code
  Future<Map<String, dynamic>> getInvitationByCode(String code) async {
    _log('🔍 Fetching invitation by code: $code');
    try {
      final response = await _apiService.get('/caregivers/invitations/$code');

      if (response.statusCode == 200) {
        _log('✅ Invitation fetched successfully');
        return response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data);
      } else {
        _log('❌ Failed to fetch invitation: ${response.statusMessage}');
        throw Exception(
          'Failed to fetch invitation: ${response.statusMessage}',
        );
      }
    } catch (e) {
      _log('❌ Error fetching invitation: $e');
      throw Exception(e.toString());
    }
  }

  // Accept caregiver invitation
  Future<Map<String, dynamic>> acceptInvitation(String invitationId) async {
    _log('✅ Accepting invitation: $invitationId');
    try {
      final response = await _apiService.post(
        '/caregivers/invitations/$invitationId/accept',
      );

      if (response.statusCode == 200) {
        _log('✅ Invitation accepted successfully');
        return response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data);
      } else {
        _log('❌ Failed to accept invitation: ${response.statusMessage}');
        throw Exception(
          'Failed to accept invitation: ${response.statusMessage}',
        );
      }
    } catch (e) {
      _log('❌ Error accepting invitation: $e');
      throw Exception(e.toString());
    }
  }

  // Decline caregiver invitation
  Future<void> declineInvitation(String invitationId) async {
    _log('❌ Declining invitation: $invitationId');
    try {
      final response = await _apiService.post(
        '/caregivers/invitations/$invitationId/decline',
      );

      if (response.statusCode == 200) {
        _log('✅ Invitation declined successfully');
      } else {
        _log('❌ Failed to decline invitation: ${response.statusMessage}');
        throw Exception(
          'Failed to decline invitation: ${response.statusMessage}',
        );
      }
    } catch (e) {
      _log('❌ Error declining invitation: $e');
      throw Exception(e.toString());
    }
  }

  // Remove caregiver
  Future<void> removeCaregiver(String caregiverId) async {
    _log('🗑️ Removing caregiver: $caregiverId');
    try {
      final response = await _apiService.delete('/caregivers/$caregiverId');

      if (response.statusCode == 200) {
        _log('✅ Caregiver removed successfully');
      } else {
        _log('❌ Failed to remove caregiver: ${response.statusMessage}');
        throw Exception(
          'Failed to remove caregiver: ${response.statusMessage}',
        );
      }
    } catch (e) {
      _log('❌ Error removing caregiver: $e');
      throw Exception(e.toString());
    }
  }

  // Legacy methods for backward compatibility
  // Add caregiver and send invitation (deprecated - use sendInvitation instead)
  @Deprecated('Use sendInvitation instead')
  Future<CaregiverModel> addCaregiver({
    required String patientId,
    required String phone,
    String? name,
    String? relationship,
  }) async {
    // For backward compatibility, we'll send an invitation
    // Note: The backend requires email, so we'll need to handle this differently
    // This is a legacy method that may not work perfectly with the new API
    _log(
      '⚠️ Using deprecated addCaregiver method - consider using sendInvitation',
    );

    try {
      final result = await sendInvitation(
        email:
            phone, // Using phone as email is not ideal, but for backward compatibility
        phone: phone,
        relationship: relationship,
        name: name,
      );

      // The result may not be a CaregiverModel, so we'll create a placeholder
      return CaregiverModel(
        id: result['id']?.toString() ?? '',
        name: name ?? 'Caregiver',
        phone: phone,
        status: CaregiverStatus.pending,
        relationship: relationship,
        linkedPatientId: patientId,
        invitedAt: DateTime.now(),
      );
    } catch (e) {
      _log('❌ Error in addCaregiver: $e');
      throw Exception(e.toString());
    }
  }

  // Generate invitation link (deprecated - backend handles this)
  @Deprecated('Backend generates invitation links')
  Future<String> generateInvitationLink(String caregiverId) async {
    _log('⚠️ Using deprecated generateInvitationLink method');
    // Backend should provide the invitation link in the response
    return 'https://digitalnurse.app/invite/$caregiverId';
  }

  // Send SMS invitation (deprecated - backend handles this)
  @Deprecated('Backend handles SMS sending')
  Future<bool> sendInvitationSMS(String phone, String invitationLink) async {
    _log('⚠️ Using deprecated sendInvitationSMS method - backend handles SMS');
    return true;
  }

  // Get caregiver by ID (not directly supported by API, filter from list)
  Future<CaregiverModel?> getCaregiverById(String caregiverId) async {
    _log('🔍 Fetching caregiver by ID: $caregiverId');
    try {
      final caregivers = await getCaregivers('');
      try {
        return caregivers.firstWhere((c) => c.id == caregiverId);
      } catch (e) {
        return null;
      }
    } catch (e) {
      _log('❌ Error fetching caregiver by ID: $e');
      return null;
    }
  }

  // Get user details for a patient (including avatarUrl and age)
  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    _log('📋 Fetching user details for: $userId');
    try {
      final response = await _apiService.get('/users/$userId');

      if (response.statusCode == 200) {
        _log('✅ Fetched user details successfully');
        return response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data);
      } else {
        _log('❌ Failed to fetch user details: ${response.statusMessage}');
        throw Exception(
          'Failed to fetch user details: ${response.statusMessage}',
        );
      }
    } catch (e) {
      _log('❌ Error fetching user details: $e');
      throw Exception(e.toString());
    }
  }

  // Get patient status summary (vitals, medications, activity)
  Future<Map<String, dynamic>> getPatientStatusSummary(String elderId) async {
    _log('📋 Fetching patient status summary for: $elderId');
    try {
      final response = await _apiService.get(
        '/caregivers/assignments/$elderId/status',
      );

      if (response.statusCode == 200) {
        _log('✅ Fetched patient status summary successfully');
        return response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data);
      } else {
        _log('❌ Failed to fetch patient status: ${response.statusMessage}');
        // Return empty status if endpoint doesn't exist yet
        return {
          'hasAbnormalVitals': false,
          'hasMissedMedications': false,
          'lastActivityTime': null,
        };
      }
    } catch (e) {
      _log('⚠️ Patient status endpoint may not exist, returning default: $e');
      // Return default status if endpoint doesn't exist
      return {
        'hasAbnormalVitals': false,
        'hasMissedMedications': false,
        'lastActivityTime': null,
      };
    }
  }
}
