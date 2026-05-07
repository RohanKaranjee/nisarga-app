import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();
  
  List<Reminder> _reminders = [];
  bool _isLoading = false;

  List<Reminder> get reminders => _reminders;
  List<Reminder> get activeReminders => _reminders.where((r) => r.enabled).toList();
  bool get isLoading => _isLoading;

  Future<void> loadReminders(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _reminders = await _firestoreService.getReminders(userId);
    } catch (e) {
      print('Error loading reminders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    try {
      await _firestoreService.saveReminder(reminder);
      _reminders.add(reminder);
      if (reminder.enabled) {
        await _notificationService.scheduleReminder(reminder);
      }
      notifyListeners();
    } catch (e) {
      print('Error adding reminder: $e');
    }
  }

  Future<void> toggleReminder(Reminder reminder, bool enabled) async {
    try {
      final updatedReminder = reminder.copyWith(enabled: enabled);
      await _firestoreService.updateReminder(updatedReminder);
      
      final index = _reminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        _reminders[index] = updatedReminder;
      }

      if (enabled) {
        await _notificationService.scheduleReminder(updatedReminder);
      } else {
        await _notificationService.cancelReminder(updatedReminder.id);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error toggling reminder: $e');
    }
  }

  Future<void> deleteReminder(Reminder reminder) async {
    try {
      await _firestoreService.deleteReminder(reminder.userId, reminder.id);
      await _notificationService.cancelReminder(reminder.id);
      _reminders.removeWhere((r) => r.id == reminder.id);
      notifyListeners();
    } catch (e) {
      print('Error deleting reminder: $e');
    }
  }
}
