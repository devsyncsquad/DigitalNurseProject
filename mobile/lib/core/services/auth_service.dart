import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'token_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  void _log(String message) {
    print('🔍 [AUTH] $message');
  }

  // Login with phone and password
  Future<UserModel> login(String phone, String password) async {
    _log('🔐 [AUTH] Attempting login for: $phone');
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {'phone': phone, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _log('✅ [AUTH] Login successful');

        // Save tokens
        await _tokenService.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        _log('💾 [AUTH] Tokens saved');

        // Create user model from response
        final userData = data['user'] ?? data;

        // Convert role string to enum
        UserRole role = UserRole.patient;
        final roleStr = (userData['role'] ?? 'patient')
            .toString()
            .toLowerCase();
        if (roleStr == 'caregiver') {
          role = UserRole.caregiver;
        }

        // Convert subscription tier string to enum
        SubscriptionTier subscriptionTier = SubscriptionTier.free;
        final tierStr = (userData['subscriptionTier'] ?? 'free')
            .toString()
            .toLowerCase();
        if (tierStr == 'premium') {
          subscriptionTier = SubscriptionTier.premium;
        }

        final user = UserModel(
          id:
              userData['id']?.toString() ??
              userData['userId']?.toString() ??
              '',
          email: userData['email']?.toString() ?? '',
          name:
              userData['name']?.toString() ??
              userData['full_name']?.toString() ??
              '',
          role: role,
          subscriptionTier: subscriptionTier,
          age: userData['age']?.toString(),
          medicalConditions: userData['medicalConditions']?.toString(),
          emergencyContact: userData['emergencyContact']?.toString(),
          phone: userData['phone']?.toString() ?? phone,
        );

        // Save user to shared preferences
        await _saveUser(user);
        _log('💾 [AUTH] User saved: ${user.phone ?? user.email} (${user.id})');
        return user;
      } else {
        _log('❌ [AUTH] Login failed: ${response.statusMessage}');
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ [AUTH] Login error: $e');
      throw Exception(e.toString());
    }
  }

  // Register new user
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required UserRole role,
    String? phone,
    String? caregiverInviteCode,
  }) async {
    _log('📝 [AUTH] Attempting registration for: $email');

    // Client-side validation
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _log('❌ [AUTH] Registration validation failed: All fields are required');
      throw Exception('All fields are required');
    }

    if (password != confirmPassword) {
      _log('❌ [AUTH] Registration validation failed: Passwords do not match');
      throw Exception('Passwords do not match');
    }

    if (password.length < 8) {
      _log('❌ [AUTH] Registration validation failed: Password too short');
      throw Exception('Password must be at least 8 characters');
    }

    final trimmedPhone =
        phone != null && phone.trim().isNotEmpty ? phone.trim() : null;
    final payloadRole = role == UserRole.caregiver ? 'caregiver' : 'patient';

    try {
      final requestBody = {
        'email': email.trim(),
        'password': password,
        'name': name.trim(),
        'roleCode': payloadRole,
        if (trimmedPhone != null) 'phone': trimmedPhone,
        if (role == UserRole.caregiver && caregiverInviteCode != null)
          'caregiverInviteCode': caregiverInviteCode.trim(),
      };

      final response = await _apiService.post(
        '/auth/register',
        data: requestBody,
      );

      if (response.statusCode == 201) {
        final data = response.data;
        _log('✅ [AUTH] Registration successful: ${data['userId']}');

        // Registration successful - return a user model with the userId
        // Note: Backend returns { message, userId }, not full user object
        // User will need to verify email before logging in
        final responseRole =
            (data['role'] ?? payloadRole).toString().toLowerCase();
        final userRole =
            responseRole == 'caregiver' ? UserRole.caregiver : UserRole.patient;

        final user = UserModel(
          id: data['userId'].toString(),
          email: email,
          name: name,
          role: userRole,
          subscriptionTier: SubscriptionTier.free,
        );

        // Don't save user as logged in yet - they need to verify email
        // Just return the user for UI purposes
        _log('📝 [AUTH] User created (not logged in): ${user.email}');
        return user;
      } else {
        _log('❌ [AUTH] Registration failed: ${response.statusMessage}');
        throw Exception('Registration failed: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ [AUTH] Registration error: $e');
      throw Exception(e.toString());
    }
  }

  // Verify email with token
  Future<bool> verifyEmail(String token) async {
    _log('✉️ [AUTH] Attempting email verification');
    try {
      final response = await _apiService.post(
        '/auth/verify-email',
        data: {'token': token},
      );

      if (response.statusCode == 200) {
        _log('✅ [AUTH] Email verification successful');
        return true;
      } else {
        _log('❌ [AUTH] Email verification failed: ${response.statusMessage}');
        throw Exception('Email verification failed');
      }
    } catch (e) {
      _log('❌ [AUTH] Email verification error: $e');
      throw Exception(e.toString());
    }
  }

  // Resend verification email (if backend supports it)
  // Note: This might need to be a different endpoint
  Future<bool> resendVerificationEmail(String email) async {
    // Backend might not have this endpoint yet
    // For now, we'll just return true or throw
    throw Exception('Resend verification email not implemented in backend');
  }

  // Refresh access token
  Future<void> refreshToken() async {
    try {
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _apiService.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _tokenService.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
      } else {
        throw Exception('Token refresh failed');
      }
    } catch (e) {
      await _tokenService.clearTokens();
      throw Exception(e.toString());
    }
  }

  // Get user profile from API
  Future<UserModel> getProfile() async {
    _log('👤 [AUTH] Fetching user profile from API');
    try {
      final response = await _apiService.get('/users/profile');

      if (response.statusCode == 200) {
        final userData = response.data;
        _log('✅ [AUTH] Profile fetched successfully');

        // Convert role string to enum
        UserRole role = UserRole.patient;
        final roleStr = (userData['role'] ?? 'patient')
            .toString()
            .toLowerCase();
        if (roleStr == 'caregiver') {
          role = UserRole.caregiver;
        }

        // Convert subscription tier string to enum
        SubscriptionTier subscriptionTier = SubscriptionTier.free;
        final tierStr = (userData['subscriptionTier'] ?? 'free')
            .toString()
            .toLowerCase();
        if (tierStr == 'premium') {
          subscriptionTier = SubscriptionTier.premium;
        }

        final user = UserModel(
          id: userData['id']?.toString() ?? '',
          email: userData['email']?.toString() ?? '',
          name: userData['name']?.toString() ?? '',
          role: role,
          subscriptionTier: subscriptionTier,
          age: userData['age']?.toString(),
          medicalConditions: userData['medicalConditions']?.toString(),
          emergencyContact: userData['emergencyContact']?.toString(),
          phone: userData['phone']?.toString(),
        );

        await _saveUser(user);
        return user;
      } else {
        _log('❌ [AUTH] Profile fetch failed: ${response.statusMessage}');
        throw Exception('Profile fetch failed: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ [AUTH] Profile fetch error: $e');
      throw Exception(e.toString());
    }
  }

  // Update user profile
  Future<UserModel> updateProfile({
    String? name,
    String? age,
    String? phoneNumber,
    String? dateOfBirth,
    String? address,
    String? city,
    String? country,
    String? medicalConditions,
    String? emergencyContact,
  }) async {
    _log('📝 [AUTH] Updating user profile');
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phoneNumber != null) {
        data['phoneNumber'] = phoneNumber;
        data['phone'] = phoneNumber;
      }
      if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth;
      if (address != null) data['address'] = address;
      if (city != null) data['city'] = city;
      if (country != null) data['country'] = country;
      if (medicalConditions != null)
        data['medicalConditions'] = medicalConditions;
      if (emergencyContact != null) data['emergencyContact'] = emergencyContact;
      if (age != null) data['age'] = age;

      final response = await _apiService.patch('/users/profile', data: data);

      if (response.statusCode == 200) {
        _log('✅ [AUTH] Profile updated successfully');
        final userData = response.data;

        // Convert role string to enum
        UserRole role = UserRole.patient;
        final roleStr = (userData['role'] ?? 'patient')
            .toString()
            .toLowerCase();
        if (roleStr == 'caregiver') {
          role = UserRole.caregiver;
        }

        // Convert subscription tier string to enum
        SubscriptionTier subscriptionTier = SubscriptionTier.free;
        final tierStr = (userData['subscriptionTier'] ?? 'free')
            .toString()
            .toLowerCase();
        if (tierStr == 'premium') {
          subscriptionTier = SubscriptionTier.premium;
        }

        final updatedUser = UserModel(
          id: userData['id']?.toString() ?? '',
          email: userData['email']?.toString() ?? '',
          name: userData['name']?.toString() ?? '',
          role: role,
          subscriptionTier: subscriptionTier,
          age: userData['age']?.toString(),
          medicalConditions: userData['medicalConditions']?.toString(),
          emergencyContact: userData['emergencyContact']?.toString(),
          phone: userData['phone']?.toString(),
        );

        await _saveUser(updatedUser);
        return updatedUser;
      } else {
        _log('❌ [AUTH] Profile update failed: ${response.statusMessage}');
        throw Exception('Profile update failed: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ [AUTH] Profile update error: $e');
      throw Exception(e.toString());
    }
  }

  // Update subscription tier
  Future<UserModel> updateSubscription(SubscriptionTier tier) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    // This would typically call a subscription endpoint
    // For now, just update locally
    final updatedUser = currentUser.copyWith(subscriptionTier: tier);
    await _saveUser(updatedUser);
    return updatedUser;
  }

  // Get current logged-in user
  Future<UserModel?> getCurrentUser() async {
    _log('👤 [AUTH] Checking for current user...');
    // Check if we have tokens
    final hasTokens = await _tokenService.hasTokens();
    if (!hasTokens) {
      _log('❌ [AUTH] No tokens found');
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    if (!isLoggedIn) {
      _log('❌ [AUTH] User not logged in');
      return null;
    }

    final userJson = prefs.getString(_userKey);
    if (userJson == null) {
      _log('❌ [AUTH] No user data found');
      return null;
    }

    try {
      final user = UserModel.fromJson(json.decode(userJson));
      _log('✅ [AUTH] Current user found: ${user.email} (${user.id})');
      return user;
    } catch (e) {
      _log('❌ [AUTH] Error parsing user data: $e');
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final hasTokens = await _tokenService.hasTokens();
    if (!hasTokens) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Logout
  Future<void> logout() async {
    _log('🚪 [AUTH] Logging out...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
    await _tokenService.clearTokens();
    _log('✅ [AUTH] Logout complete - tokens and user data cleared');
  }

  // Save user to shared preferences
  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
  }
}
