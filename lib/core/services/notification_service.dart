import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder.dart';
import 'firestore_service.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> init() async {
    tz_data.initializeTimeZones();

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

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: notification.title ?? 'Nisarga',
        body: notification.body ?? '',
      );
    });
  }

  Future<void> registerDeviceToken(String userId) async {
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _firestoreService.saveFcmToken(userId, token);
    }

    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _firestoreService.saveFcmToken(userId, newToken);
    });
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'nisarga_general',
      'Nisarga Notifications',
      channelDescription: 'Health, appointment, chat, and reminder alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _flutterLocalNotificationsPlugin.show(id, title, body, details);
  }

  Future<void> scheduleReminder(Reminder reminder) async {
    final scheduled = _nextReminderTime(reminder.time);
    const androidDetails = AndroidNotificationDetails(
      'nisarga_reminders',
      'Nisarga Reminders',
      channelDescription: 'Daily health reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.notes.isNotEmpty ? reminder.notes : 'Reminder from Nisarga',
      scheduled,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelReminder(String id) async {
    // Convert string ID to int for notification ID
    final notificationId = id.hashCode;
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  tz.TZDateTime _nextReminderTime(String timeLabel) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*([AP]M)$', caseSensitive: false)
        .firstMatch(timeLabel.trim());
    var hour = 9;
    var minute = 0;

    if (match != null) {
      hour = int.tryParse(match.group(1)!) ?? 9;
      minute = int.tryParse(match.group(2)!) ?? 0;
      final period = match.group(3)!.toUpperCase();
      if (period == 'PM' && hour < 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
    }

    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
