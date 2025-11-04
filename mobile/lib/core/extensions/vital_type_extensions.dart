import '../models/vital_measurement_model.dart';

extension VitalTypeExtensions on VitalType {
  String get displayName {
    switch (this) {
      case VitalType.bloodPressure:
        return 'Blood Pressure';
      case VitalType.bloodSugar:
        return 'Blood Sugar';
      case VitalType.heartRate:
        return 'Heart Rate';
      case VitalType.temperature:
        return 'Temperature';
      case VitalType.weight:
        return 'Weight';
      case VitalType.oxygenSaturation:
        return 'Oxygen Saturation';
    }
  }

  String get unit {
    switch (this) {
      case VitalType.bloodPressure:
        return 'mmHg';
      case VitalType.bloodSugar:
        return 'mg/dL';
      case VitalType.heartRate:
        return 'bpm';
      case VitalType.temperature:
        return '°F';
      case VitalType.weight:
        return 'lbs';
      case VitalType.oxygenSaturation:
        return '%';
    }
  }
}
