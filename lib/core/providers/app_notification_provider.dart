import 'dart:async';

import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../services/firestore_service.dart';

class AppNotificationProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  StreamSubscription<List<AppNotification>>? _subscription;
  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount =>
      _notifications.where((notification) => !notification.read).length;

  Future<void> loadNotifications(String userId) async {
    _isLoading = true;
    notifyListeners();

    await _subscription?.cancel();
    _subscription =
        _firestoreService.watchNotifications(userId).listen((notifications) {
      _notifications = notifications;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> markRead(String userId, String notificationId) async {
    await _firestoreService.markNotificationRead(userId, notificationId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
