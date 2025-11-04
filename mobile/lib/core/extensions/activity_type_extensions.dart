import '../models/exercise_log_model.dart';

extension ActivityTypeExtensions on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.walking:
        return 'Walking';
      case ActivityType.running:
        return 'Running';
      case ActivityType.cycling:
        return 'Cycling';
      case ActivityType.swimming:
        return 'Swimming';
      case ActivityType.yoga:
        return 'Yoga';
      case ActivityType.gym:
        return 'Gym';
      case ActivityType.sports:
        return 'Sports';
      case ActivityType.other:
        return 'Other';
    }
  }
}
