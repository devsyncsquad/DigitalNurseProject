import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/notification_model.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  bool _isInitialized = false;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  /// Initialize Firebase Cloud Messaging
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase if not already done
      await Firebase.initializeApp();

      // Initialize timezone data
      tz.initializeTimeZones();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permission for notifications
      await _requestPermission();

      // Get FCM token
      await _getToken();

      // Setup message handlers
      _setupMessageHandlers();

      _isInitialized = true;
      print('FCM Service initialized successfully');
    } catch (e) {
      print('Error initializing FCM Service: $e');
      // Don't rethrow to prevent app crashes
      // Just mark as not initialized so it can be retried
      _isInitialized = false;
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Setup notification channels for Android
    if (Platform.isAndroid) {
      await _setupNotificationChannels();
    }
  }

  /// Setup Android notification channels
  Future<void> _setupNotificationChannels() async {
    const medicationChannel = AndroidNotificationChannel(
      'medication_reminders',
      'Medication Reminders',
      description: 'Notifications for medication reminders and missed doses',
      importance: Importance.high,
      playSound: true,
    );

    const healthChannel = AndroidNotificationChannel(
      'health_alerts',
      'Health Alerts',
      description: 'Notifications for health monitoring and vitals',
      importance: Importance.high,
      playSound: true,
    );

    const generalChannel = AndroidNotificationChannel(
      'general_notifications',
      'General Notifications',
      description: 'General app notifications and updates',
      importance: Importance.defaultImportance,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(medicationChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(healthChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(generalChannel);
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    if (Platform.isIOS) {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        throw Exception('Notification permission denied');
      }
    } else if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      final granted = await androidPlugin?.requestNotificationsPermission();
      if (granted != true) {
        throw Exception('Notification permission denied');
      }

      // Request exact alarm permission for Android 12+
      try {
        final canScheduleExact = await androidPlugin
            ?.canScheduleExactNotifications();
        if (canScheduleExact == false) {
          print('Requesting exact alarm permission...');
          final exactAlarmGranted = await androidPlugin
              ?.requestExactAlarmsPermission();
          if (exactAlarmGranted == true) {
            print('✅ Exact alarm permission granted!');
          } else {
            print(
              '⚠️ Exact alarm permission denied - using inexact scheduling',
            );
          }
        } else {
          print('✅ Exact alarm permission already granted');
        }
      } catch (e) {
        print('Could not request exact alarm permission: $e');
      }
    }
  }

  /// Get FCM token
  Future<void> _getToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      print('FCM Token: $_fcmToken');

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        print('FCM Token refreshed: $newToken');
        // TODO: Send new token to backend
      });
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle initial message (when app is terminated)
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessageOpenedApp(message);
      }
    });
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.messageId}');

    // Show local notification for foreground messages
    await _showLocalNotification(message);
  }

  /// Handle message opened app (background/terminated)
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.messageId}');

    // TODO: Navigate to specific screen based on message data
    final data = message.data;
    if (data.containsKey('type')) {
      _handleNotificationNavigation(data['type'], data);
    }
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');

    // TODO: Navigate based on payload
    if (response.payload != null) {
      // Parse payload and navigate
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      _getChannelId(message.data),
      _getChannelName(message.data),
      channelDescription: _getChannelDescription(message.data),
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  /// Get channel ID based on message data
  String _getChannelId(Map<String, dynamic> data) {
    final type = data['type'] ?? 'general';
    switch (type) {
      case 'medicine_reminder':
      case 'missed_dose':
        return 'medication_reminders';
      case 'health_alert':
      case 'vitals_reminder':
        return 'health_alerts';
      default:
        return 'general_notifications';
    }
  }

  /// Get channel name based on message data
  String _getChannelName(Map<String, dynamic> data) {
    final type = data['type'] ?? 'general';
    switch (type) {
      case 'medicine_reminder':
      case 'missed_dose':
        return 'Medication Reminders';
      case 'health_alert':
      case 'vitals_reminder':
        return 'Health Alerts';
      default:
        return 'General Notifications';
    }
  }

  /// Get channel description based on message data
  String _getChannelDescription(Map<String, dynamic> data) {
    final type = data['type'] ?? 'general';
    switch (type) {
      case 'medicine_reminder':
      case 'missed_dose':
        return 'Notifications for medication reminders and missed doses';
      case 'health_alert':
      case 'vitals_reminder':
        return 'Notifications for health monitoring and vitals';
      default:
        return 'General app notifications and updates';
    }
  }

  /// Handle notification navigation
  void _handleNotificationNavigation(String type, Map<String, dynamic> data) {
    // TODO: Implement navigation logic based on notification type
    switch (type) {
      case 'medicine_reminder':
        // Navigate to medicine detail screen
        break;
      case 'health_alert':
        // Navigate to health monitoring screen
        break;
      case 'diet_reminder':
        // Navigate to diet/exercise screen
        break;
      default:
        // Navigate to dashboard
        break;
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Schedule local notification
  Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationType type = NotificationType.general,
  }) async {
    try {
      // Check if FCM service is initialized
      if (!_isInitialized) {
        print('FCM service not initialized, attempting to initialize...');
        try {
          await initialize();
        } catch (e) {
          print('Failed to initialize FCM service: $e');
          return; // Exit gracefully instead of crashing
        }
      }

      // Only schedule if the date is in the future
      if (scheduledDate.isBefore(DateTime.now())) {
        print('Skipping notification - scheduled time is in the past');
        return;
      }

      final channelId = _getChannelId({'type': type.toString()});
      final channelName = _getChannelName({'type': type.toString()});
      final channelDescription = _getChannelDescription({
        'type': type.toString(),
      });

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Try exact scheduling first, fallback to inexact if permission denied
      try {
        await _localNotifications.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledDate, tz.local),
          details,
          payload: payload,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        print(
          'Notification scheduled successfully for $title at $scheduledDate',
        );
      } catch (e) {
        if (e.toString().contains('exact_alarms_not_permitted')) {
          print('Exact alarm permission denied, using inexact scheduling');
          // Fallback to inexact scheduling
          await _localNotifications.zonedSchedule(
            id,
            title,
            body,
            tz.TZDateTime.from(scheduledDate, tz.local),
            details,
            payload: payload,
            androidScheduleMode: AndroidScheduleMode.inexact,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          print('Notification scheduled with inexact timing for $title');
        } else {
          print('Error scheduling notification: $e');
          // Don't rethrow to prevent app crashes
        }
      }
    } catch (e) {
      print('Failed to schedule notification: $e');
      // Don't rethrow to prevent breaking medicine saving
    }
  }

  /// Cancel scheduled notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Request exact alarm permission manually
  Future<bool> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      try {
        final androidPlugin = _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

        final canScheduleExact = await androidPlugin
            ?.canScheduleExactNotifications();
        if (canScheduleExact == false) {
          print('Requesting exact alarm permission...');
          final granted = await androidPlugin?.requestExactAlarmsPermission();
          if (granted == true) {
            print('✅ Exact alarm permission granted!');
            return true;
          } else {
            print('⚠️ Exact alarm permission denied');
            return false;
          }
        } else {
          print('✅ Exact alarm permission already granted');
          return true;
        }
      } catch (e) {
        print('Error requesting exact alarm permission: $e');
        return false;
      }
    }
    return true; // iOS doesn't need this permission
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}
