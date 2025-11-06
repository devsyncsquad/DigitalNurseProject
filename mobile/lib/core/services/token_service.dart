import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  void _log(String message) {
    print('🔍 [TOKEN] $message');
  }

  // Save tokens to SharedPreferences
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _log('💾 Saving tokens (access: ${accessToken.substring(0, 20)}..., refresh: ${refreshToken.substring(0, 20)}...)');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    _log('✅ Tokens saved successfully');
  }

  // Get access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    if (token != null) {
      _log('🔑 Access token found (${token.substring(0, 20)}...)');
    } else {
      _log('❌ No access token found');
    }
    return token;
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_refreshTokenKey);
    if (token != null) {
      _log('🔑 Refresh token found (${token.substring(0, 20)}...)');
    } else {
      _log('❌ No refresh token found');
    }
    return token;
  }

  // Clear all tokens
  Future<void> clearTokens() async {
    _log('🗑️ Clearing all tokens...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    _log('✅ Tokens cleared');
  }

  // Check if tokens exist
  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    final hasTokens = accessToken != null && refreshToken != null;
    _log('🔍 Token check: ${hasTokens ? "Tokens exist" : "No tokens"}');
    return hasTokens;
  }
}

