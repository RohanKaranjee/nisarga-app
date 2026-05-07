import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/reminder.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }

  Future<void> scheduleReminder(Reminder reminder) async {
    // Parse time string '09:00 AM' to time components
    // Then schedule recurring notification
    // Note: requires timezone initialization in main.dart in Phase 5
    // For now this is a placeholder implementation
    print('Scheduling notification for reminder ${reminder.id} at ${reminder.time}');
  }

  Future<void> cancelReminder(String id) async {
    // Convert string ID to int for notification ID
    final notificationId = id.hashCode;
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
