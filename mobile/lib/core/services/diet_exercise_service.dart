import '../models/diet_log_model.dart';
import '../models/exercise_log_model.dart';

class DietExerciseService {
  final List<DietLogModel> _dietLogs = [];
  final List<ExerciseLogModel> _exerciseLogs = [];

  Future<void> _mockDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Diet Log Methods
  Future<List<DietLogModel>> getDietLogs(
    String userId, {
    DateTime? date,
  }) async {
    await _mockDelay();
    if (date != null) {
      return _dietLogs
          .where(
            (d) =>
                d.userId == userId &&
                d.timestamp.year == date.year &&
                d.timestamp.month == date.month &&
                d.timestamp.day == date.day,
          )
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    return _dietLogs.where((d) => d.userId == userId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<DietLogModel> addDietLog(DietLogModel dietLog) async {
    await _mockDelay();
    _dietLogs.add(dietLog);
    return dietLog;
  }

  Future<void> deleteDietLog(String logId) async {
    await _mockDelay();
    _dietLogs.removeWhere((d) => d.id == logId);
  }

  // Exercise Log Methods
  Future<List<ExerciseLogModel>> getExerciseLogs(
    String userId, {
    DateTime? date,
  }) async {
    await _mockDelay();
    if (date != null) {
      return _exerciseLogs
          .where(
            (e) =>
                e.userId == userId &&
                e.timestamp.year == date.year &&
                e.timestamp.month == date.month &&
                e.timestamp.day == date.day,
          )
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    return _exerciseLogs.where((e) => e.userId == userId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<ExerciseLogModel> addExerciseLog(ExerciseLogModel exerciseLog) async {
    await _mockDelay();
    _exerciseLogs.add(exerciseLog);
    return exerciseLog;
  }

  Future<void> deleteExerciseLog(String logId) async {
    await _mockDelay();
    _exerciseLogs.removeWhere((e) => e.id == logId);
  }

  // Daily Summary
  Future<Map<String, dynamic>> getDailySummary(
    String userId,
    DateTime date,
  ) async {
    await _mockDelay();

    final dietLogs = await getDietLogs(userId, date: date);
    final exerciseLogs = await getExerciseLogs(userId, date: date);

    final totalCaloriesIn = dietLogs.fold<int>(
      0,
      (sum, log) => sum + log.calories,
    );

    final totalCaloriesOut = exerciseLogs.fold<int>(
      0,
      (sum, log) => sum + log.caloriesBurned,
    );

    final totalExerciseMinutes = exerciseLogs.fold<int>(
      0,
      (sum, log) => sum + log.durationMinutes,
    );

    return {
      'date': date,
      'caloriesIn': totalCaloriesIn,
      'caloriesOut': totalCaloriesOut,
      'netCalories': totalCaloriesIn - totalCaloriesOut,
      'exerciseMinutes': totalExerciseMinutes,
      'mealCount': dietLogs.length,
      'workoutCount': exerciseLogs.length,
    };
  }

  // Weekly Summary
  Future<Map<String, dynamic>> getWeeklySummary(String userId) async {
    await _mockDelay();

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: 7));

    final dietLogs = _dietLogs
        .where((d) => d.userId == userId && d.timestamp.isAfter(weekStart))
        .toList();

    final exerciseLogs = _exerciseLogs
        .where((e) => e.userId == userId && e.timestamp.isAfter(weekStart))
        .toList();

    final totalCaloriesIn = dietLogs.fold<int>(
      0,
      (sum, log) => sum + log.calories,
    );

    final totalCaloriesOut = exerciseLogs.fold<int>(
      0,
      (sum, log) => sum + log.caloriesBurned,
    );

    final totalExerciseMinutes = exerciseLogs.fold<int>(
      0,
      (sum, log) => sum + log.durationMinutes,
    );

    return {
      'weekStart': weekStart,
      'weekEnd': now,
      'totalCaloriesIn': totalCaloriesIn,
      'totalCaloriesOut': totalCaloriesOut,
      'avgCaloriesPerDay': totalCaloriesIn / 7,
      'totalExerciseMinutes': totalExerciseMinutes,
      'avgExercisePerDay': totalExerciseMinutes / 7,
    };
  }

  // Initialize mock data
  void initializeMockData(String userId) {
    final now = DateTime.now();

    // Mock diet logs for today
    _dietLogs.addAll([
      DietLogModel(
        id: 'diet-1',
        mealType: MealType.breakfast,
        description: 'Oatmeal with berries and honey',
        calories: 350,
        timestamp: DateTime(now.year, now.month, now.day, 8, 30),
        userId: userId,
      ),
      DietLogModel(
        id: 'diet-2',
        mealType: MealType.lunch,
        description: 'Grilled chicken salad',
        calories: 450,
        timestamp: DateTime(now.year, now.month, now.day, 12, 30),
        userId: userId,
      ),
      DietLogModel(
        id: 'diet-3',
        mealType: MealType.snack,
        description: 'Apple and almonds',
        calories: 200,
        timestamp: DateTime(now.year, now.month, now.day, 15, 0),
        userId: userId,
      ),
    ]);

    // Mock diet logs for yesterday
    final yesterday = now.subtract(const Duration(days: 1));
    _dietLogs.addAll([
      DietLogModel(
        id: 'diet-4',
        mealType: MealType.breakfast,
        description: 'Scrambled eggs and toast',
        calories: 400,
        timestamp: DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          9,
          0,
        ),
        userId: userId,
      ),
      DietLogModel(
        id: 'diet-5',
        mealType: MealType.dinner,
        description: 'Salmon with vegetables',
        calories: 550,
        timestamp: DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          19,
          0,
        ),
        userId: userId,
      ),
    ]);

    // Mock exercise logs
    _exerciseLogs.addAll([
      ExerciseLogModel(
        id: 'exercise-1',
        activityType: ActivityType.walking,
        description: 'Morning walk in the park',
        durationMinutes: 30,
        caloriesBurned: 150,
        timestamp: DateTime(now.year, now.month, now.day, 7, 0),
        userId: userId,
      ),
      ExerciseLogModel(
        id: 'exercise-2',
        activityType: ActivityType.yoga,
        description: 'Evening yoga session',
        durationMinutes: 45,
        caloriesBurned: 200,
        timestamp: DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          18,
          0,
        ),
        userId: userId,
      ),
    ]);
  }
}
