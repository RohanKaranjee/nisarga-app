import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import root application widget
import 'app.dart';

// Import state management providers
import 'core/providers/auth_provider.dart';
import 'core/providers/app_notification_provider.dart';
import 'core/providers/cycle_provider.dart';
import 'core/providers/reminder_provider.dart';
import 'core/providers/theme_provider.dart';

// Import local notifications service
import 'core/services/notification_service.dart';

/// The main entry point for the Nisarga Flutter application.
///
/// This function is responsible for:
/// 1. Initializing the Flutter bindings.
/// 2. Initializing Firebase (for Auth and Firestore).
/// 3. Initializing Local Notifications.
/// 4. Wrapping the entire app with [MultiProvider] to inject state management dependencies.
void main() async {
  // Ensure that widget bindings are initialized before calling async methods
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (Requires flutterfire configure - Phase 5)
  // This is wrapped in a try-catch to prevent crashes if Firebase is not yet configured on the dev machine.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed or not configured yet: $e');
  }

  // Initialize Local Notifications service for smart reminders
  try {
    final notificationService = NotificationService();
    await notificationService.init();
  } catch (e) {
    debugPrint('Notification init failed: $e');
  }

  // Run the app, wrapped in MultiProvider to make providers globally accessible via context.read() or Provider.of()
  runApp(
    MultiProvider(
      providers: [
        // Manages light/dark theme state
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Manages user authentication state
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Manages menstrual cycle data and daily logs
        ChangeNotifierProvider(create: (_) => CycleProvider()),
        // Manages user reminders and notifications
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        // Manages realtime in-app notifications
        ChangeNotifierProvider(create: (_) => AppNotificationProvider()),
      ],
      child: const NisargaApp(),
    ),
  );
}
