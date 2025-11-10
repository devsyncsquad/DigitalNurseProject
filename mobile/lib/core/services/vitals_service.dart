import '../models/vital_measurement_model.dart';
import '../mappers/vital_mapper.dart';
import 'api_service.dart';

class VitalsService {
  final ApiService _apiService = ApiService();

  void _log(String message) {
    print('🔍 [VITALS] $message');
  }

  // Get all vitals for a user
  Future<List<VitalMeasurementModel>> getVitals(
    String userId, {
    String? elderUserId,
  }) async {
    _log('📋 Fetching vitals for user: $userId');
    try {
      final response = await _apiService.get(
        '/vitals',
        queryParameters:
            elderUserId != null ? {'elderUserId': elderUserId} : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        final vitals = data
            .map((json) => VitalMapper.fromApiResponse(
                json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json)))
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _log('✅ Fetched ${vitals.length} vital measurements');
        return vitals;
      } else {
        _log('❌ Failed to fetch vitals: ${response.statusMessage}');
        throw Exception('Failed to fetch vitals: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error fetching vitals: $e');
      throw Exception(e.toString());
    }
  }

  // Get vitals by type
Future<List<VitalMeasurementModel>> getVitalsByType(
  String userId,
  VitalType type, {
  String? elderUserId,
}) async {
    _log('📋 Fetching vitals by type: $type for user: $userId');
    try {
      // Convert type enum to string for API
      String typeStr;
      switch (type) {
        case VitalType.bloodPressure:
          typeStr = 'bloodPressure';
          break;
        case VitalType.bloodSugar:
          typeStr = 'bloodSugar';
          break;
        case VitalType.heartRate:
          typeStr = 'heartRate';
          break;
        case VitalType.temperature:
          typeStr = 'temperature';
          break;
        case VitalType.oxygenSaturation:
          typeStr = 'oxygenSaturation';
          break;
        case VitalType.weight:
          typeStr = 'weight';
          break;
      }

      final queryParameters = {'type': typeStr};
      if (elderUserId != null) {
        queryParameters['elderUserId'] = elderUserId;
      }

      final response = await _apiService.get(
        '/vitals',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        final vitals = data
            .map((json) => VitalMapper.fromApiResponse(
                json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json)))
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _log('✅ Fetched ${vitals.length} vital measurements of type $type');
        return vitals;
      } else {
        _log('❌ Failed to fetch vitals by type: ${response.statusMessage}');
        throw Exception('Failed to fetch vitals by type: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error fetching vitals by type: $e');
      throw Exception(e.toString());
    }
  }

  // Add vital measurement
  Future<VitalMeasurementModel> addVital(VitalMeasurementModel vital) async {
    _log('➕ Adding vital measurement: ${vital.type}');
    try {
      final requestData = VitalMapper.toApiRequest(
        vital,
        elderUserId: vital.userId,
      );
      final response = await _apiService.post(
        '/vitals',
        data: requestData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final addedVital = VitalMapper.fromApiResponse(response.data);
        _log('✅ Vital measurement added successfully');
        return addedVital;
      } else {
        _log('❌ Failed to add vital: ${response.statusMessage}');
        throw Exception('Failed to add vital: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error adding vital: $e');
      throw Exception(e.toString());
    }
  }

  // Update vital
  Future<VitalMeasurementModel> updateVital(VitalMeasurementModel vital) async {
    _log('✏️ Updating vital measurement: ${vital.id}');
    try {
      final requestData = VitalMapper.toApiRequest(
        vital,
        elderUserId: vital.userId,
      );
      final response = await _apiService.patch(
        '/vitals/${vital.id}',
        data: requestData,
        queryParameters:
            vital.userId.isNotEmpty ? {'elderUserId': vital.userId} : null,
      );

      if (response.statusCode == 200) {
        final updatedVital = VitalMapper.fromApiResponse(response.data);
        _log('✅ Vital measurement updated successfully');
        return updatedVital;
      } else {
        _log('❌ Failed to update vital: ${response.statusMessage}');
        throw Exception('Failed to update vital: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error updating vital: $e');
      throw Exception(e.toString());
    }
  }

  // Delete vital
  Future<void> deleteVital(String vitalId, {String? elderUserId}) async {
    _log('🗑️ Deleting vital measurement: $vitalId');
    try {
      final response = await _apiService.delete(
        '/vitals/$vitalId',
        queryParameters:
            elderUserId != null ? {'elderUserId': elderUserId} : null,
      );

      if (response.statusCode == 200) {
        _log('✅ Vital measurement deleted successfully');
      } else {
        _log('❌ Failed to delete vital: ${response.statusMessage}');
        throw Exception('Failed to delete vital: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error deleting vital: $e');
      throw Exception(e.toString());
    }
  }

  // Get recent vitals (last 7 days)
  Future<List<VitalMeasurementModel>> getRecentVitals(
    String userId, {
    String? elderUserId,
  }) async {
    _log('📋 Fetching recent vitals (last 7 days) for user: $userId');
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
      final response = await _apiService.get(
        '/vitals',
        queryParameters: {
          'startDate': cutoffDate.toIso8601String(),
          if (elderUserId != null) 'elderUserId': elderUserId,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        final vitals = data
            .map((json) => VitalMapper.fromApiResponse(
                json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json)))
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _log('✅ Fetched ${vitals.length} recent vital measurements');
        return vitals;
      } else {
        _log('❌ Failed to fetch recent vitals: ${response.statusMessage}');
        throw Exception('Failed to fetch recent vitals: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error fetching recent vitals: $e');
      throw Exception(e.toString());
    }
  }

  // Calculate average for a vital type over a period
  Future<Map<String, dynamic>> calculateTrends(
    String userId,
    VitalType type, {
    int days = 7,
    String? elderUserId,
  }) async {
    _log('📊 Calculating trends for ${type.toString()} (last $days days)');
    try {
      String typeStr;
      switch (type) {
        case VitalType.bloodPressure:
          typeStr = 'bloodPressure';
          break;
        case VitalType.bloodSugar:
          typeStr = 'bloodSugar';
          break;
        case VitalType.heartRate:
          typeStr = 'heartRate';
          break;
        case VitalType.temperature:
          typeStr = 'temperature';
          break;
        case VitalType.oxygenSaturation:
          typeStr = 'oxygenSaturation';
          break;
        case VitalType.weight:
          typeStr = 'weight';
          break;
      }

      final queryParameters = {'kindCode': typeStr};
      if (elderUserId != null) {
        queryParameters['elderUserId'] = elderUserId;
      }

      final response = await _apiService.get(
        '/vitals/trends',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _log('✅ Trends calculated successfully');
        return {
          'average': (data['average'] ?? 0.0).toDouble(),
          'count': (data['count'] ?? 0) as int,
          'hasAbnormal': (data['hasAbnormal'] ?? false) as bool,
          'measurements': (data['measurements'] ?? [])
              .map((json) => VitalMapper.fromApiResponse(
                    json is Map<String, dynamic>
                        ? json
                        : Map<String, dynamic>.from(json),
                  ))
              .toList(),
        };
      } else {
        _log('❌ Failed to calculate trends: ${response.statusMessage}');
        throw Exception(
            'Failed to calculate trends: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error calculating trends: $e');
      throw Exception(e.toString());
    }
  }

  // Check for abnormal readings
  Future<List<VitalMeasurementModel>> getAbnormalReadings(
    String userId, {
    String? elderUserId,
  }) async {
    _log('⚠️ Fetching abnormal readings for user: $userId');
    try {
      final response = await _apiService.get(
        '/vitals/abnormal',
        queryParameters:
            elderUserId != null ? {'elderUserId': elderUserId} : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        final vitals = data
            .map((json) => VitalMapper.fromApiResponse(
                json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json)))
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _log('✅ Fetched ${vitals.length} abnormal readings');
        return vitals;
      } else {
        _log('❌ Failed to fetch abnormal readings: ${response.statusMessage}');
        throw Exception('Failed to fetch abnormal readings: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error fetching abnormal readings: $e');
      throw Exception(e.toString());
    }
  }

  // Get latest vitals per kind
  Future<Map<String, VitalMeasurementModel>> getLatestVitals(
    String userId, {
    String? elderUserId,
  }) async {
    _log('📋 Fetching latest vitals per kind for user: $userId');
    try {
      final response = await _apiService.get(
        '/vitals/latest',
        queryParameters:
            elderUserId != null ? {'elderUserId': elderUserId} : null,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final latestVitals = <String, VitalMeasurementModel>{};
        
        if (data is Map) {
          data.forEach((key, value) {
            if (value != null) {
              latestVitals[key] = VitalMapper.fromApiResponse(
                  value is Map<String, dynamic> ? value : Map<String, dynamic>.from(value));
            }
          });
        }
        
        _log('✅ Fetched latest vitals for ${latestVitals.length} types');
        return latestVitals;
      } else {
        _log('❌ Failed to fetch latest vitals: ${response.statusMessage}');
        throw Exception('Failed to fetch latest vitals: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error fetching latest vitals: $e');
      throw Exception(e.toString());
    }
  }
}
