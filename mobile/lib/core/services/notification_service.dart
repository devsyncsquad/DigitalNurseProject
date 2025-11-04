import '../models/notification_model.dart';
import 'fcm_service.dart';

class NotificationService {
  final List<NotificationModel> _notifications = [];
  final FCMService _fcmService = FCMService();

  Future<void> _mockDelay() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Get all notifications
  Future<List<NotificationModel>> getNotifications() async {
    await _mockDelay();
    return _notifications..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get unread notifications
  Future<List<NotificationModel>> getUnreadNotifications() async {
    await _mockDelay();
    return _notifications.where((n) => !n.isRead).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    await _mockDelay();
    return _notifications.where((n) => !n.isRead).length;
  }

  // Schedule notification (mock)
  Future<NotificationModel> scheduleNotification({
    required String title,
    required String body,
    required NotificationType type,
    DateTime? scheduledTime,
    String? actionData,
  }) async {
    await _mockDelay();

    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      timestamp: scheduledTime ?? DateTime.now(),
      isRead: false,
      actionData: actionData,
    );

    _notifications.add(notification);

    // Schedule local notification if scheduledTime is provided
    if (scheduledTime != null && scheduledTime.isAfter(DateTime.now())) {
      await _fcmService.scheduleLocalNotification(
        id: notification.hashCode,
        title: title,
        body: body,
        scheduledDate: scheduledTime,
        payload: actionData,
        type: type,
      );
    }

    return notification;
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _mockDelay();
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    await _mockDelay();
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _mockDelay();
    _notifications.removeWhere((n) => n.id == notificationId);
  }

  // Clear all notifications
  Future<void> clearAll() async {
    await _mockDelay();
    _notifications.clear();
  }

  // Initialize FCM service
  Future<void> initializeFCM() async {
    await _fcmService.initialize();
  }

  // Get FCM token
  String? getFCMToken() {
    return _fcmService.fcmToken;
  }

  // Subscribe to FCM topic
  Future<void> subscribeToTopic(String topic) async {
    await _fcmService.subscribeToTopic(topic);
  }

  // Unsubscribe from FCM topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcmService.unsubscribeFromTopic(topic);
  }

  // Request exact alarm permission
  Future<bool> requestExactAlarmPermission() async {
    return await _fcmService.requestExactAlarmPermission();
  }

  // Initialize mock notifications
  void initializeMockData() {
    final now = DateTime.now();

    _notifications.addAll([
      NotificationModel(
        id: 'notif-1',
        title: 'Medicine Reminder',
        body: 'Time to take Aspirin 75mg',
        type: NotificationType.medicineReminder,
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: false,
        actionData: '{"medicineId": "mock-med-1"}',
      ),
      NotificationModel(
        id: 'notif-2',
        title: 'Missed Dose Alert',
        body: 'You missed your Metformin dose at 9:00 AM',
        type: NotificationType.missedDose,
        timestamp: now.subtract(const Duration(hours: 5)),
        isRead: true,
        actionData: '{"medicineId": "mock-med-2"}',
      ),
      NotificationModel(
        id: 'notif-3',
        title: 'Health Alert',
        body: 'Your blood pressure reading was higher than normal',
        type: NotificationType.healthAlert,
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: false,
      ),
      NotificationModel(
        id: 'notif-4',
        title: 'Caregiver Invitation',
        body: 'Mike Wilson accepted your caregiver invitation',
        type: NotificationType.caregiverInvitation,
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
        actionData: '{"caregiverId": "mock-cg-2"}',
      ),
      NotificationModel(
        id: 'notif-5',
        title: 'Daily Reminder',
        body: 'Don\'t forget to log your vitals today',
        type: NotificationType.general,
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
    ]);
  }
}
