import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Multi-user support: keys are now per-user
  static String _phoneKey(String userId) => 'biometric_phone_$userId';
  static String _passwordKey(String userId) => 'biometric_password_$userId';
  static String _biometricEnabledKey(String userId) => 'biometric_enabled_$userId';
  static const String _usersListKey = 'biometric_users_list';

  void _log(String message) {
    print('🔍 [SECURE_STORAGE] $message');
  }

  /// Save credentials for biometric login for a specific user
  Future<void> saveCredentials({
    required String userId,
    required String phone,
    required String password,
  }) async {
    try {
      _log('💾 Saving credentials securely for user: $userId');
      
      // Store credentials separately for security, keyed by userId
      await _storage.write(key: _phoneKey(userId), value: phone);
      await _storage.write(key: _passwordKey(userId), value: password);
      await _storage.write(key: _biometricEnabledKey(userId), value: 'true');
      
      // Add userId to the list of users with biometric enabled
      await _addUserToBiometricList(userId);
      
      _log('✅ Credentials saved successfully for user: $userId');
    } catch (e) {
      _log('❌ Error saving credentials for user $userId: $e');
      rethrow;
    }
  }

  /// Get saved phone number for biometric login for a specific user
  Future<String?> getSavedPhone(String userId) async {
    try {
      final phone = await _storage.read(key: _phoneKey(userId));
      if (phone != null) {
        _log('✅ Saved phone retrieved for user: $userId');
      } else {
        _log('⚠️ No saved phone found for user: $userId');
      }
      return phone;
    } catch (e) {
      _log('❌ Error retrieving phone for user $userId: $e');
      return null;
    }
  }

  /// Get saved password for biometric login for a specific user
  Future<String?> getSavedPassword(String userId) async {
    try {
      final password = await _storage.read(key: _passwordKey(userId));
      if (password != null) {
        _log('✅ Saved password retrieved for user: $userId');
      } else {
        _log('⚠️ No saved password found for user: $userId');
      }
      return password;
    } catch (e) {
      _log('❌ Error retrieving password for user $userId: $e');
      return null;
    }
  }

  /// Check if biometric login is enabled for a specific user
  Future<bool> isBiometricEnabled(String userId) async {
    try {
      final enabled = await _storage.read(key: _biometricEnabledKey(userId));
      final isEnabled = enabled == 'true';
      _log('🔍 Biometric enabled status for user $userId: $isEnabled');
      return isEnabled;
    } catch (e) {
      _log('❌ Error checking biometric enabled status for user $userId: $e');
      return false;
    }
  }

  /// Check if credentials are saved for a specific user
  Future<bool> hasSavedCredentials(String userId) async {
    try {
      final phone = await getSavedPhone(userId);
      final password = await getSavedPassword(userId);
      final hasCredentials = phone != null && password != null && phone.isNotEmpty && password.isNotEmpty;
      _log('🔍 Has saved credentials for user $userId: $hasCredentials');
      return hasCredentials;
    } catch (e) {
      _log('❌ Error checking saved credentials for user $userId: $e');
      return false;
    }
  }

  /// Clear all saved credentials for a specific user
  Future<void> clearCredentials(String userId) async {
    try {
      _log('🗑️ Clearing saved credentials for user: $userId');
      await _storage.delete(key: _phoneKey(userId));
      await _storage.delete(key: _passwordKey(userId));
      await _storage.delete(key: _biometricEnabledKey(userId));
      
      // Remove userId from the list
      await _removeUserFromBiometricList(userId);
      
      _log('✅ Credentials cleared for user: $userId');
    } catch (e) {
      _log('❌ Error clearing credentials for user $userId: $e');
      rethrow;
    }
  }

  /// Disable biometric login for a specific user (keep credentials but mark as disabled)
  Future<void> disableBiometric(String userId) async {
    try {
      _log('🔒 Disabling biometric login for user: $userId');
      await _storage.write(key: _biometricEnabledKey(userId), value: 'false');
      
      // Remove userId from the list
      await _removeUserFromBiometricList(userId);
      
      _log('✅ Biometric login disabled for user: $userId');
    } catch (e) {
      _log('❌ Error disabling biometric for user $userId: $e');
      rethrow;
    }
  }

  /// Enable biometric login for a specific user
  Future<void> enableBiometric(String userId) async {
    try {
      _log('🔓 Enabling biometric login for user: $userId');
      await _storage.write(key: _biometricEnabledKey(userId), value: 'true');
      
      // Add userId to the list
      await _addUserToBiometricList(userId);
      
      _log('✅ Biometric login enabled for user: $userId');
    } catch (e) {
      _log('❌ Error enabling biometric for user $userId: $e');
      rethrow;
    }
  }

  /// Get list of user IDs who have biometric login enabled
  Future<List<String>> getUsersWithBiometricEnabled() async {
    try {
      final usersListJson = await _storage.read(key: _usersListKey);
      if (usersListJson == null || usersListJson.isEmpty) {
        _log('🔍 No users with biometric enabled');
        return [];
      }

      final List<dynamic> usersList = json.decode(usersListJson);
      final List<String> userIds = usersList.map((e) => e.toString()).toList();
      
      // Filter to only include users who actually have biometric enabled
      final List<String> validUserIds = [];
      for (final userId in userIds) {
        if (await isBiometricEnabled(userId) && await hasSavedCredentials(userId)) {
          validUserIds.add(userId);
        }
      }
      
      _log('🔍 Found ${validUserIds.length} users with biometric enabled: $validUserIds');
      return validUserIds;
    } catch (e) {
      _log('❌ Error getting users with biometric enabled: $e');
      return [];
    }
  }

  /// Add a user ID to the biometric users list
  Future<void> _addUserToBiometricList(String userId) async {
    try {
      final usersListJson = await _storage.read(key: _usersListKey);
      List<String> currentUsers = [];
      
      if (usersListJson != null && usersListJson.isNotEmpty) {
        try {
          final List<dynamic> usersList = json.decode(usersListJson);
          currentUsers = usersList.map((e) => e.toString()).toList();
        } catch (e) {
          _log('⚠️ Error parsing users list, starting fresh: $e');
        }
      }
      
      if (!currentUsers.contains(userId)) {
        currentUsers.add(userId);
        await _storage.write(key: _usersListKey, value: json.encode(currentUsers));
        _log('✅ Added user $userId to biometric users list');
      }
    } catch (e) {
      _log('❌ Error adding user to biometric list: $e');
    }
  }

  /// Remove a user ID from the biometric users list
  Future<void> _removeUserFromBiometricList(String userId) async {
    try {
      final usersListJson = await _storage.read(key: _usersListKey);
      if (usersListJson == null || usersListJson.isEmpty) {
        return;
      }
      
      List<String> currentUsers = [];
      try {
        final List<dynamic> usersList = json.decode(usersListJson);
        currentUsers = usersList.map((e) => e.toString()).toList();
      } catch (e) {
        _log('⚠️ Error parsing users list: $e');
        return;
      }
      
      if (currentUsers.contains(userId)) {
        currentUsers.remove(userId);
        await _storage.write(key: _usersListKey, value: json.encode(currentUsers));
        _log('✅ Removed user $userId from biometric users list');
      }
    } catch (e) {
      _log('❌ Error removing user from biometric list: $e');
    }
  }
}

