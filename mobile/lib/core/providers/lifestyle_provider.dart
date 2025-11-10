import 'package:flutter/material.dart';
import '../models/diet_log_model.dart';
import '../models/exercise_log_model.dart';
import '../services/diet_exercise_service.dart';

class LifestyleProvider with ChangeNotifier {
  final DietExerciseService _service = DietExerciseService();
  List<DietLogModel> _dietLogs = [];
  List<ExerciseLogModel> _exerciseLogs = [];
  Map<String, dynamic>? _dailySummary;
  bool _isLoading = false;
  String? _error;

  List<DietLogModel> get dietLogs => _dietLogs;
  List<ExerciseLogModel> get exerciseLogs => _exerciseLogs;
  Map<String, dynamic>? get dailySummary => _dailySummary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load diet logs
  Future<void> loadDietLogs(String userId,
      {DateTime? date, String? elderUserId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _dietLogs = await _service.getDietLogs(
        userId,
        date: date,
        elderUserId: elderUserId,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load exercise logs
  Future<void> loadExerciseLogs(String userId,
      {DateTime? date, String? elderUserId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _exerciseLogs = await _service.getExerciseLogs(
        userId,
        date: date,
        elderUserId: elderUserId,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load both diet and exercise logs
  Future<void> loadAll(String userId,
      {DateTime? date, String? elderUserId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _dietLogs = await _service.getDietLogs(
        userId,
        date: date,
        elderUserId: elderUserId,
      );
      _exerciseLogs = await _service.getExerciseLogs(
        userId,
        date: date,
        elderUserId: elderUserId,
      );
      _dailySummary = await _service.getDailySummary(
        userId,
        date ?? DateTime.now(),
        elderUserId: elderUserId,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add diet log
  Future<bool> addDietLog(DietLogModel dietLog) async {
    try {
      final added = await _service.addDietLog(dietLog);
      _dietLogs.insert(0, added);
      _dailySummary = await _service.getDailySummary(
        dietLog.userId,
        dietLog.timestamp,
        elderUserId: dietLog.userId,
      );
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete diet log
  Future<bool> deleteDietLog(String logId, String userId,
      {String? elderUserId}) async {
    try {
      await _service.deleteDietLog(
        logId,
        elderUserId: elderUserId,
      );
      _dietLogs.removeWhere((d) => d.id == logId);
      _dailySummary = await _service.getDailySummary(
        userId,
        DateTime.now(),
        elderUserId: elderUserId,
      );
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Add exercise log
  Future<bool> addExerciseLog(ExerciseLogModel exerciseLog) async {
    try {
      final added = await _service.addExerciseLog(exerciseLog);
      _exerciseLogs.insert(0, added);
      _dailySummary = await _service.getDailySummary(
        exerciseLog.userId,
        exerciseLog.timestamp,
        elderUserId: exerciseLog.userId,
      );
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete exercise log
  Future<bool> deleteExerciseLog(String logId, String userId,
      {String? elderUserId}) async {
    try {
      await _service.deleteExerciseLog(
        logId,
        elderUserId: elderUserId,
      );
      _exerciseLogs.removeWhere((e) => e.id == logId);
      _dailySummary = await _service.getDailySummary(
        userId,
        DateTime.now(),
        elderUserId: elderUserId,
      );
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get weekly summary
  Future<Map<String, dynamic>> getWeeklySummary(String userId,
      {String? elderUserId}) async {
    return await _service.getWeeklySummary(
      userId,
      elderUserId: elderUserId,
    );
  }

  // Initialize mock data (deprecated - no longer needed with API integration)
  @Deprecated('Mock data initialization no longer supported')
  Future<void> initializeMockData(String userId) async {
    // Mock data initialization removed - data now comes from API
    await loadAll(userId);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
