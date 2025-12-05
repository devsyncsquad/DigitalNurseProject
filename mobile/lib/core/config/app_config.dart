import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String _apiBaseUrlKey = 'api_base_url';
  static const String _geminiApiKeyKey = 'gemini_api_key';
  
  // Default URLs for different environments
  static const String _defaultLocalhost = 'http://100.42.177.77:3000/api';
  static const String _defaultAndroidEmulator = 'http://100.42.177.77:3000/api';
  
  // Default Gemini API key (can be overridden by environment variable or saved preference)
  static const String _defaultGeminiApiKey = 'AIzaSyBB-nGNXzlo399N1viNLq011V4YJJDWzBg';
  
  // Convert localhost URLs to Android emulator URL (10.0.2.2)
  // This is needed because Android emulators can't access host machine's localhost directly
  // Note: Only converts localhost/127.0.0.1 URLs, not IP addresses
  static String _convertToAndroidEmulatorUrl(String url) {
    // Check if URL contains localhost or 127.0.0.1 (not needed for IP addresses)
    if (url.contains('localhost') || url.contains('127.0.0.1')) {
      // Replace localhost/127.0.0.1 with 10.0.2.2 while preserving port and path
      final converted = url
          .replaceAll('localhost', '10.0.2.2')
          .replaceAll('127.0.0.1', '10.0.2.2');
      print('🔄 [CONFIG] Converted localhost URL to Android emulator URL: $url -> $converted');
      return converted;
    }
    // Return as-is for IP addresses (like 100.42.177.77)
    return url;
  }
  
  // Get API base URL with smart defaults
  static Future<String> getBaseUrl() async {
    String finalUrl;
    
    // First, check if user has set a custom URL
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString(_apiBaseUrlKey);
    
    if (savedUrl != null && savedUrl.isNotEmpty) {
      print('🔍 [CONFIG] Using saved API URL: $savedUrl');
      finalUrl = savedUrl;
    } else {
      // Use environment variable if set
      const envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
      if (envUrl.isNotEmpty) {
        print('🔍 [CONFIG] Using environment API URL: $envUrl');
        finalUrl = envUrl;
      } else {
        // Smart defaults based on platform
        if (Platform.isAndroid) {
          // Use deployed API URL for Android
          print('🔍 [CONFIG] Android detected, using API URL: $_defaultAndroidEmulator');
          finalUrl = _defaultAndroidEmulator;
        } else if (Platform.isIOS) {
          // Use deployed API URL for iOS
          print('🔍 [CONFIG] iOS detected, using API URL: $_defaultLocalhost');
          finalUrl = _defaultLocalhost;
        } else {
          // Fallback
          print('🔍 [CONFIG] Using default API URL: $_defaultLocalhost');
          finalUrl = _defaultLocalhost;
        }
      }
    }
    
    // If running on Android and URL contains localhost/127.0.0.1, convert it
    if (Platform.isAndroid) {
      finalUrl = _convertToAndroidEmulatorUrl(finalUrl);
    }
    
    return finalUrl;
  }
  
  // Set custom API base URL (useful for physical devices)
  static Future<void> setApiBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiBaseUrlKey, url);
    print('✅ [CONFIG] API URL saved: $url');
  }
  
  // Clear custom API base URL
  static Future<void> clearApiBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiBaseUrlKey);
    print('🗑️ [CONFIG] API URL cleared, will use defaults');
  }
  
  // Get current API base URL (synchronous for backward compatibility)
  // Note: This will use defaults, not saved URL
  static String get baseUrl {
    if (Platform.isAndroid) {
      return _defaultAndroidEmulator;
    }
    return _defaultLocalhost;
  }

  // Get Gemini API key
  static Future<String?> getGeminiApiKey() async {
    // First check environment variable
    const envKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (envKey.isNotEmpty) {
      print('🔍 [CONFIG] Using Gemini API key from environment variable');
      return envKey;
    }

    // Then check saved preference
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString(_geminiApiKeyKey);
    if (savedKey != null && savedKey.isNotEmpty) {
      print('🔍 [CONFIG] Using saved Gemini API key');
      return savedKey;
    }

    // Use default API key
    if (_defaultGeminiApiKey.isNotEmpty) {
      print('🔍 [CONFIG] Using default Gemini API key');
      return _defaultGeminiApiKey;
    }

    print('⚠️ [CONFIG] Gemini API key not found');
    return null;
  }

  // Set Gemini API key
  static Future<void> setGeminiApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiApiKeyKey, key);
    print('✅ [CONFIG] Gemini API key saved');
  }

  // Clear Gemini API key
  static Future<void> clearGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_geminiApiKeyKey);
    print('🗑️ [CONFIG] Gemini API key cleared');
  }

  // Legacy method for backward compatibility (deprecated)
  @Deprecated('Use getGeminiApiKey() instead')
  static Future<String?> getOpenAIApiKey() async {
    return getGeminiApiKey();
  }

  // Legacy method for backward compatibility (deprecated)
  @Deprecated('Use setGeminiApiKey() instead')
  static Future<void> setOpenAIApiKey(String key) async {
    return setGeminiApiKey(key);
  }

  // Legacy method for backward compatibility (deprecated)
  @Deprecated('Use clearGeminiApiKey() instead')
  static Future<void> clearOpenAIApiKey() async {
    return clearGeminiApiKey();
  }
}

