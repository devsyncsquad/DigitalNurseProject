import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  // Initialize - check if user is already logged in
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUser();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Register returns user but doesn't log them in
      // User needs to verify email first
      await _authService.register(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Verify email
  Future<bool> verifyEmail(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.verifyEmail(token);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? age,
    String? medicalConditions,
    String? emergencyContact,
    String? phone,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.updateProfile(
        phoneNumber: phone,
        medicalConditions: medicalConditions,
        emergencyContact: emergencyContact,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update subscription
  Future<bool> updateSubscription(SubscriptionTier tier) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.updateSubscription(tier);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Extract user-friendly error message
  String _extractErrorMessage(dynamic error) {
    final errorString = error.toString();
    
    // Remove "Exception: " prefix if present
    if (errorString.startsWith('Exception: ')) {
      return errorString.substring(11);
    }
    
    // Handle common error patterns
    if (errorString.contains('Conflict:')) {
      return errorString.split('Conflict:').last.trim();
    }
    if (errorString.contains('Unauthorized:')) {
      return errorString.split('Unauthorized:').last.trim();
    }
    if (errorString.contains('Bad request:')) {
      return errorString.split('Bad request:').last.trim();
    }
    
    return errorString;
  }
}
