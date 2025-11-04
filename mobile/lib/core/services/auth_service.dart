import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  // Mock delay to simulate network request
  Future<void> _mockDelay() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  // Login with email and password
  Future<UserModel> login(String email, String password) async {
    await _mockDelay();

    // Mock validation
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }

    // Create mock user
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: email.split('@')[0],
      role: UserRole.patient,
      subscriptionTier: SubscriptionTier.free,
    );

    // Save to shared preferences
    await _saveUser(user);
    return user;
  }

  // Register new user
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    await _mockDelay();

    // Mock validation
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('All fields are required');
    }

    if (password != confirmPassword) {
      throw Exception('Passwords do not match');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Create mock user
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      role: UserRole.patient,
      subscriptionTier: SubscriptionTier.free,
    );

    // Save to shared preferences
    await _saveUser(user);
    return user;
  }

  // Verify email (mock)
  Future<bool> verifyEmail(String email) async {
    await _mockDelay();
    return true; // Always successful in mock
  }

  // Resend verification email (mock)
  Future<bool> resendVerificationEmail(String email) async {
    await _mockDelay();
    return true;
  }

  // Update user profile
  Future<UserModel> updateProfile({
    required String userId,
    String? age,
    String? medicalConditions,
    String? emergencyContact,
    String? phone,
  }) async {
    await _mockDelay();

    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    final updatedUser = currentUser.copyWith(
      age: age,
      medicalConditions: medicalConditions,
      emergencyContact: emergencyContact,
      phone: phone,
    );

    await _saveUser(updatedUser);
    return updatedUser;
  }

  // Update subscription tier
  Future<UserModel> updateSubscription(SubscriptionTier tier) async {
    await _mockDelay();

    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    final updatedUser = currentUser.copyWith(subscriptionTier: tier);
    await _saveUser(updatedUser);
    return updatedUser;
  }

  // Get current logged-in user
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    if (!isLoggedIn) {
      return null;
    }

    final userJson = prefs.getString(_userKey);
    if (userJson == null) {
      return null;
    }

    return UserModel.fromJson(json.decode(userJson));
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Save user to shared preferences
  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
  }
}
