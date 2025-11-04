import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  // Load notifications
  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _notificationService.getNotifications();
      _unreadCount = await _notificationService.getUnreadCount();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Schedule notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required NotificationType type,
    DateTime? scheduledTime,
    String? actionData,
  }) async {
    final notification = await _notificationService.scheduleNotification(
      title: title,
      body: body,
      type: type,
      scheduledTime: scheduledTime,
      actionData: actionData,
    );

    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
  }

  // Mark as read
  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount--;
      notifyListeners();
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    _unreadCount = 0;
    notifyListeners();
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    final notification = _notifications.firstWhere(
      (n) => n.id == notificationId,
    );
    await _notificationService.deleteNotification(notificationId);
    _notifications.removeWhere((n) => n.id == notificationId);
    if (!notification.isRead) {
      _unreadCount--;
    }
    notifyListeners();
  }

  // Initialize FCM
  Future<void> initializeFCM() async {
    await _notificationService.initializeFCM();
  }

  // Get FCM token
  String? getFCMToken() {
    return _notificationService.getFCMToken();
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _notificationService.subscribeToTopic(topic);
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _notificationService.unsubscribeFromTopic(topic);
  }

  // Initialize mock data
  Future<void> initializeMockData() async {
    _notificationService.initializeMockData();
    await loadNotifications();
  }

  // Request exact alarm permission
  Future<bool> requestExactAlarmPermission() async {
    return await _notificationService.requestExactAlarmPermission();
  }
}
