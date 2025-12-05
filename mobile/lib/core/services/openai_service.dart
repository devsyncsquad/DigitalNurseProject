import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/app_config.dart';

/// Service for interacting with Google Gemini API to analyze food descriptions
/// and calculate calories, as well as analyze exercise descriptions and
/// calculate calories burned
class OpenAIService {
  static OpenAIService? _instance;
  Dio? _dio;
  String? _apiKey;
  static const String _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  // Try these models in order until one works
  static const List<String> _geminiModels = [
    'gemini-2.0-flash-exp', // Latest experimental model (often referred to as 2.0/2.5 in previews)
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-1.5-pro',
    'gemini-1.5-flash', // Stable fallback
  ];
  static String _geminiModel = _geminiModels[0];

  factory OpenAIService() {
    _instance ??= OpenAIService._internal();
    return _instance!;
  }

  OpenAIService._internal();

  void _log(String message) {
    print('🔍 [GEMINI] $message');
  }

  /// Get Gemini API key from configuration
  Future<String?> _getApiKey() async {
    final apiKey = await AppConfig.getGeminiApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      _log('❌ Gemini API key not configured');
      return null;
    }
    return apiKey;
  }

  /// Initialize Dio client for Gemini API
  Future<void> _ensureInitialized() async {
    if (_dio != null && _apiKey != null) return;

    final apiKey = await _getApiKey();
    if (apiKey == null) {
      throw Exception('Gemini API key not configured. Please set GEMINI_API_KEY environment variable or in app config.');
    }

    _apiKey = apiKey;
    _dio = Dio(
      BaseOptions(
        baseUrl: _geminiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _log('✅ Gemini service initialized');
    _log('📌 Using model: $_geminiModel with API: $_geminiBaseUrl');
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
        throw Exception('Gemini service not initialized');
      }

      _log('🤖 Analyzing food description: ${foodDescription.substring(0, foodDescription.length > 50 ? 50 : foodDescription.length)}...');

      // Create prompt for calorie analysis
      final prompt = _buildCalorieAnalysisPrompt(foodDescription);

      // Try different models until one works
      DioException? lastError;
      for (final model in _geminiModels) {
        try {
          _log('🔄 Trying model: $model');
          final response = await _dio!.post(
            '/models/$model:generateContent',
            queryParameters: {'key': _apiKey},
            data: {
              'contents': [
                {
                  'parts': [
                    {
                      'text': 'You are a nutrition expert. Analyze food descriptions and provide accurate calorie estimates. Always respond with valid JSON only.\n\n$prompt'
                    }
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.3,
                'maxOutputTokens': 200,
                'responseMimeType': 'application/json',
              },
            },
          );

          if (response.statusCode == 200) {
            _geminiModel = model; // Save working model
            _log('✅ Successfully using model: $model');
            final data = response.data;
            final content = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
            
            if (content != null) {
              final result = _parseCalorieResponse(content);
              if (result != null) {
                _log('✅ Calories calculated: $result kcal');
                return result;
              }
            }
          }
        } on DioException catch (e) {
          lastError = e;
          // Handle both Model Not Found (404) and Quota Exceeded (429)
          if (e.response?.statusCode == 404 || e.response?.statusCode == 429) {
            final reason = e.response?.statusCode == 404 ? 'not available' : 'quota exceeded';
            _log('⚠️ Model $model $reason, trying next...');
            continue; // Try next model
          } else {
            rethrow; // Re-throw other errors
          }
        }
      }

      // If we get here, all models failed
      if (lastError != null) {
        throw lastError;
      }

      // This code is now handled in the loop above
      _log('❌ Failed to get valid response from Gemini after trying all models');
      return null;
    } on DioException catch (e) {
      _log('❌ Gemini API error: ${e.message}');
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
      _log('📝 Raw response content: $jsonContent');
      
      // Clean up the response if it contains markdown code blocks
      String cleanContent = jsonContent;
      if (cleanContent.contains('```json')) {
        cleanContent = cleanContent.replaceAll('```json', '').replaceAll('```', '');
      } else if (cleanContent.contains('```')) {
        cleanContent = cleanContent.replaceAll('```', '');
      }
      
      cleanContent = cleanContent.trim();
      
      final json = jsonDecode(cleanContent) as Map<String, dynamic>;
      
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

      _log('❌ Unable to parse calories from response. Content: $cleanContent');
      return null;
    } catch (e) {
      _log('❌ Error parsing Gemini response: $e');
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
        throw Exception('Gemini service not initialized');
      }

      _log('🤖 Analyzing exercise: ${exerciseDescription.substring(0, exerciseDescription.length > 50 ? 50 : exerciseDescription.length)}... for $durationMinutes minutes');

      // Create prompt for exercise calorie analysis
      final prompt = _buildExerciseCalorieAnalysisPrompt(exerciseDescription, durationMinutes);

      // Try different models until one works
      DioException? lastError;
      for (final model in _geminiModels) {
        try {
          _log('🔄 Trying model: $model');
          final response = await _dio!.post(
            '/models/$model:generateContent',
            queryParameters: {'key': _apiKey},
            data: {
              'contents': [
                {
                  'parts': [
                    {
                      'text': 'You are a fitness and exercise expert. Analyze exercise descriptions and calculate accurate calorie burn estimates based on duration. Always respond with valid JSON only.\n\n$prompt'
                    }
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.3,
                'maxOutputTokens': 200,
                'responseMimeType': 'application/json',
              },
            },
          );

          if (response.statusCode == 200) {
            _geminiModel = model; // Save working model
            _log('✅ Successfully using model: $model');
            final data = response.data;
            final content = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
            
            if (content != null) {
              final result = _parseCalorieResponse(content);
              if (result != null) {
                _log('✅ Calories burned calculated: $result kcal');
                return result;
              }
            }
          }
        } on DioException catch (e) {
          lastError = e;
          // Handle both Model Not Found (404) and Quota Exceeded (429)
          if (e.response?.statusCode == 404 || e.response?.statusCode == 429) {
            final reason = e.response?.statusCode == 404 ? 'not available' : 'quota exceeded';
            _log('⚠️ Model $model $reason, trying next...');
            continue; // Try next model
          } else {
            rethrow; // Re-throw other errors
          }
        }
      }

      // If we get here, all models failed
      if (lastError != null) {
        throw lastError;
      }
      
      _log('❌ Failed to get valid response from Gemini after trying all models');
      return null;
    } on DioException catch (e) {
      _log('❌ Gemini API error: ${e.message}');
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

  /// List available Gemini models
  /// This helps identify which models are available for your API key
  Future<List<Map<String, dynamic>>> listAvailableModels() async {
    try {
      await _ensureInitialized();
      if (_dio == null) {
        throw Exception('Gemini service not initialized');
      }

      _log('📋 Fetching available models...');

      // Try v1beta first (more models available)
      try {
        final dioV1Beta = Dio(
          BaseOptions(
            baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );

        final response = await dioV1Beta.get(
          '/models',
          queryParameters: {'key': _apiKey},
        );

        if (response.statusCode == 200) {
          final data = response.data;
          final models = (data['models'] as List<dynamic>?) ?? [];
          _log('✅ Found ${models.length} models in v1beta');
          
          // Log each model
          for (var model in models) {
            final name = model['name'] ?? 'Unknown';
            final displayName = model['displayName'] ?? '';
            final supportedMethods = (model['supportedGenerationMethods'] as List<dynamic>?) ?? [];
            _log('  📌 $name ($displayName) - Methods: ${supportedMethods.join(", ")}');
          }
          
          return models.map((m) => Map<String, dynamic>.from(m)).toList();
        }
      } catch (e) {
        _log('⚠️ v1beta listModels failed: $e');
      }

      // Try v1 as fallback
      final response = await _dio!.get(
        '/models',
        queryParameters: {'key': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final models = (data['models'] as List<dynamic>?) ?? [];
        _log('✅ Found ${models.length} models in v1');
        
        // Log each model
        for (var model in models) {
          final name = model['name'] ?? 'Unknown';
          final displayName = model['displayName'] ?? '';
          final supportedMethods = (model['supportedGenerationMethods'] as List<dynamic>?) ?? [];
          _log('  📌 $name ($displayName) - Methods: ${supportedMethods.join(", ")}');
        }
        
        return models.map((m) => Map<String, dynamic>.from(m)).toList();
      }

      _log('❌ Failed to get models list');
      return [];
    } on DioException catch (e) {
      _log('❌ Error listing models: ${e.message}');
      if (e.response != null) {
        _log('Response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      _log('❌ Error listing models: $e');
      rethrow;
    }
  }
}

