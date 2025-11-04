import 'fcm_service.dart';

/// Helper class for testing FCM functionality
class FCMTestHelper {
  static final FCMService _fcmService = FCMService();

  /// Test FCM initialization
  static Future<void> testInitialization() async {
    print('Testing FCM initialization...');
    try {
      await _fcmService.initialize();
      print('✅ FCM initialized successfully');
      print('FCM Token: ${_fcmService.fcmToken}');
    } catch (e) {
      print('❌ FCM initialization failed: $e');
    }
  }

  /// Test local notification scheduling
  static Future<void> testLocalNotification() async {
    print('Testing local notification...');
    try {
      await _fcmService.scheduleLocalNotification(
        id: 999,
        title: 'Test Notification',
        body: 'This is a test notification from Digital Nurse',
        scheduledDate: DateTime.now().add(const Duration(seconds: 5)),
        payload: '{"type": "test"}',
      );
      print('✅ Local notification scheduled successfully');
    } catch (e) {
      print('❌ Local notification scheduling failed: $e');
    }
  }

  /// Test topic subscription
  static Future<void> testTopicSubscription() async {
    print('Testing topic subscription...');
    try {
      await _fcmService.subscribeToTopic('test_topic');
      print('✅ Subscribed to test_topic');

      await _fcmService.unsubscribeFromTopic('test_topic');
      print('✅ Unsubscribed from test_topic');
    } catch (e) {
      print('❌ Topic subscription failed: $e');
    }
  }

  /// Run all tests
  static Future<void> runAllTests() async {
    print('🧪 Starting FCM Tests...\n');

    await testInitialization();
    print('');

    await testLocalNotification();
    print('');

    await testTopicSubscription();
    print('');

    print('🏁 FCM Tests completed!');
  }
}
