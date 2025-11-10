import 'dart:async';
import 'package:digital_nurse/core/models/user_model.dart';
import 'package:flutter/material.dart';
import '../models/care_recipient_model.dart';
import '../services/caregiver_service.dart';
import 'auth_provider.dart';

class CareContextProvider with ChangeNotifier {
  final CaregiverService _caregiverService = CaregiverService();

  List<CareRecipientModel> _careRecipients = [];
  CareRecipientModel? _selectedRecipient;
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;
  UserRole? _currentUserRole;
  bool _hasAttemptedLoad = false;

  List<CareRecipientModel> get careRecipients => _careRecipients;
  CareRecipientModel? get selectedRecipient => _selectedRecipient;
  String? get selectedElderId => _selectedRecipient?.elderId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateAuth(AuthProvider authProvider) {
    final user = authProvider.currentUser;
    final userId = user?.id;
    final userRole = user?.role;

    if (userId == _currentUserId && userRole == _currentUserRole) {
      return;
    }

    _currentUserId = userId;
    _currentUserRole = userRole;
    _hasAttemptedLoad = false;

    if (userRole != UserRole.caregiver) {
      _clearState();
      notifyListeners();
      return;
    }

    if (userId != null) {
      unawaited(loadCareRecipients());
    }
  }

  Future<void> ensureLoaded() async {
    if (_hasAttemptedLoad) {
      return;
    }
    await loadCareRecipients();
  }

  Future<void> loadCareRecipients() async {
    if (_currentUserRole != UserRole.caregiver) {
      return;
    }

    _isLoading = true;
    _error = null;
    _hasAttemptedLoad = true;
    notifyListeners();

    try {
      final assignments = await _caregiverService.getCareRecipients();
      _careRecipients = assignments;
      if (assignments.isEmpty) {
        _selectedRecipient = null;
      } else {
        // Preserve previous selection if still available
        final previousId = _selectedRecipient?.elderId;
        _selectedRecipient = assignments.firstWhere(
          (assignment) => assignment.elderId == previousId,
          orElse: () => assignments.first,
        );
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      _careRecipients = [];
      _selectedRecipient = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectRecipient(String elderId) {
    if (_selectedRecipient?.elderId == elderId) {
      return;
    }
    final recipient = _careRecipients.firstWhere(
      (assignment) => assignment.elderId == elderId,
      orElse: () => _selectedRecipient ?? (_careRecipients.isNotEmpty ? _careRecipients.first : throw StateError('No care recipients available')),
    );
    _selectedRecipient = recipient;
    notifyListeners();
  }

  void _clearState() {
    _careRecipients = [];
    _selectedRecipient = null;
    _error = null;
    _isLoading = false;
  }
}

