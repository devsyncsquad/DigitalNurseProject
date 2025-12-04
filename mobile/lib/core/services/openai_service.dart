import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/app_config.dart';

/// Service for interacting with OpenAI API to analyze food descriptions
/// and calculate calories, as well as analyze exercise descriptions and
/// calculate calories burned
class OpenAIService {
  static OpenAIService? _instance;
  Dio? _dio;
  static const String _openAIBaseUrl = 'https://api.openai.com/v1';

  factory OpenAIService() {
    _instance ??= OpenAIService._internal();
    return _instance!;
  }

  OpenAIService._internal();

  void _log(String message) {
    print('🔍 [OPENAI] $message');
  }

  /// Get OpenAI API key from configuration
  Future<String?> _getApiKey() async {
    final apiKey = await AppConfig.getOpenAIApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      _log('❌ OpenAI API key not configured');
      return null;
    }
    return apiKey;
  }

  /// Initialize Dio client for OpenAI API
  Future<void> _ensureInitialized() async {
    if (_dio != null) return;

    final apiKey = await _getApiKey();
    if (apiKey == null) {
      throw Exception('OpenAI API key not configured. Please set OPENAI_API_KEY environment variable or in app config.');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: _openAIBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      ),
    );

    _log('✅ OpenAI service initialized');
  }

  /// Analyze food description and calculate total calories
  /// Returns the estimated calorie count, or null if unable to calculate
  Future<int?> analyzeFoodCalories(String foodDescription) async {
    if (foodDescription.trim().isEmpty) {
      _log('❌ Empty food description provided');
      return null;
    }

    try {
      await _ensureInitialized();
      if (_dio == null) {
        throw Exception('OpenAI service not initialized');
      }

      _log('🤖 Analyzing food description: ${foodDescription.substring(0, foodDescription.length > 50 ? 50 : foodDescription.length)}...');

      // Create prompt for calorie analysis
      final prompt = _buildCalorieAnalysisPrompt(foodDescription);

      // Call OpenAI Chat Completions API
      final response = await _dio!.post(
        '/chat/completions',
        data: {
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a nutrition expert. Analyze food descriptions and provide accurate calorie estimates. Always respond with valid JSON only.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.3,
          'max_tokens': 200,
          'response_format': {'type': 'json_object'},
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices']?[0]?['message']?['content'];
        
        if (content != null) {
          final result = _parseCalorieResponse(content);
          if (result != null) {
            _log('✅ Calories calculated: $result kcal');
            return result;
          }
        }
      }

      _log('❌ Failed to get valid response from OpenAI');
      return null;
    } on DioException catch (e) {
      _log('❌ OpenAI API error: ${e.message}');
      if (e.response != null) {
        _log('Response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      _log('❌ Error analyzing food calories: $e');
      rethrow;
    }
  }

  /// Build prompt for calorie analysis
  String _buildCalorieAnalysisPrompt(String foodDescription) {
    return '''Analyze the following food description and calculate the total estimated calories.

Food description: "$foodDescription"

Please provide your response as JSON with the following format:
{
  "calories": <estimated_total_calories>,
  "breakdown": [optional array of individual items if multiple foods mentioned],
  "confidence": "high" | "medium" | "low",
  "notes": "any relevant notes about the estimation"
}

Guidelines:
- If serving size is not mentioned, assume standard serving sizes
- If multiple food items are mentioned, calculate total calories for all items
- Provide your best estimate even if details are limited
- Return only valid JSON, no additional text

JSON response:''';
  }

  /// Parse OpenAI response to extract calorie count
  int? _parseCalorieResponse(String jsonContent) {
    try {
      final json = jsonDecode(jsonContent) as Map<String, dynamic>;
      
      // Try to get calories from the response
      final calories = json['calories'];
      
      if (calories != null) {
        if (calories is int) {
          return calories;
        } else if (calories is double) {
          return calories.round();
        } else if (calories is String) {
          final parsed = int.tryParse(calories);
          if (parsed != null) return parsed;
        }
      }

      _log('❌ Unable to parse calories from response: $jsonContent');
      return null;
    } catch (e) {
      _log('❌ Error parsing OpenAI response: $e');
      return null;
    }
  }

  /// Analyze exercise description and duration to calculate calories burned
  /// Returns the estimated calories burned, or null if unable to calculate
  Future<int?> analyzeExerciseCalories(
    String exerciseDescription,
    int durationMinutes,
  ) async {
    if (exerciseDescription.trim().isEmpty) {
      _log('❌ Empty exercise description provided');
      return null;
    }

    if (durationMinutes <= 0) {
      _log('❌ Invalid duration provided: $durationMinutes');
      return null;
    }

    try {
      await _ensureInitialized();
      if (_dio == null) {
        throw Exception('OpenAI service not initialized');
      }

      _log('🤖 Analyzing exercise: ${exerciseDescription.substring(0, exerciseDescription.length > 50 ? 50 : exerciseDescription.length)}... for $durationMinutes minutes');

      // Create prompt for exercise calorie analysis
      final prompt = _buildExerciseCalorieAnalysisPrompt(exerciseDescription, durationMinutes);

      // Call OpenAI Chat Completions API
      final response = await _dio!.post(
        '/chat/completions',
        data: {
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a fitness and exercise expert. Analyze exercise descriptions and calculate accurate calorie burn estimates based on duration. Always respond with valid JSON only.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.3,
          'max_tokens': 200,
          'response_format': {'type': 'json_object'},
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices']?[0]?['message']?['content'];
        
        if (content != null) {
          final result = _parseCalorieResponse(content);
          if (result != null) {
            _log('✅ Calories burned calculated: $result kcal');
            return result;
          }
        }
      }

      _log('❌ Failed to get valid response from OpenAI');
      return null;
    } on DioException catch (e) {
      _log('❌ OpenAI API error: ${e.message}');
      if (e.response != null) {
        _log('Response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      _log('❌ Error analyzing exercise calories: $e');
      rethrow;
    }
  }

  /// Build prompt for exercise calorie analysis
  String _buildExerciseCalorieAnalysisPrompt(String exerciseDescription, int durationMinutes) {
    return '''Analyze the following exercise description and calculate the total estimated calories burned.

Exercise description: "$exerciseDescription"
Duration: $durationMinutes minutes

Please provide your response as JSON with the following format:
{
  "calories": <estimated_total_calories_burned>,
  "intensity": "low" | "moderate" | "high",
  "confidence": "high" | "medium" | "low",
  "notes": "any relevant notes about the estimation"
}

Guidelines:
- Calculate calories burned based on the exercise type and duration
- Consider the intensity level mentioned or implied in the description
- Use standard calorie burn rates for common exercises
- For average body weight (assume 70kg/154lbs if not specified)
- Provide your best estimate even if details are limited
- Return only valid JSON, no additional text

JSON response:''';
  }
}

