import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medication_provider.dart';
import '../providers/notification_provider.dart';

/// Simple test widget to test notifications
class NotificationTestWidget extends StatelessWidget {
  const NotificationTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Test Notifications',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final provider = Provider.of<MedicationProvider>(
                  context,
                  listen: false,
                );
                await provider.testImmediateNotification('Test Medicine');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Test notification scheduled for 10 seconds from now!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Test Notification (10 seconds)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final provider = Provider.of<NotificationProvider>(
                  context,
                  listen: false,
                );
                final granted = await provider.requestExactAlarmPermission();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        granted
                            ? '✅ Exact alarm permission granted!'
                            : '⚠️ Exact alarm permission denied',
                      ),
                      backgroundColor: granted ? Colors.green : Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Request Exact Alarm Permission'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Instructions:\n'
              '1. Try "Request Exact Alarm Permission" first\n'
              '2. If that fails, test with "Test Notification"\n'
              '3. Minimize the app (don\'t close)\n'
              '4. Wait 10 seconds\n'
              '5. Check your notification panel\n\n'
              'Note: If exact alarms are disabled, notifications may be delayed by 5-15 minutes.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
