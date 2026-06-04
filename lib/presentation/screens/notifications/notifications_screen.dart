import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_notification_provider.dart';
import '../../../core/providers/auth_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final provider = context.watch<AppNotificationProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: user == null
          ? const Center(child: Text('Please log in.'))
          : provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Unable to load notifications: ${provider.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : provider.notifications.isEmpty
                      ? const Center(child: Text('No notifications yet.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.notifications.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final notification = provider.notifications[index];
                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  notification.read
                                      ? Icons.notifications_none
                                      : Icons.notifications_active,
                                  color: notification.read
                                      ? Colors.grey
                                      : Colors.pink,
                                ),
                                title: Text(notification.title),
                                subtitle: Text(notification.body),
                                onTap: () async {
                                  try {
                                    await provider.markRead(
                                        user.uid, notification.id);
                                    if (context.mounted &&
                                        notification.route.isNotEmpty) {
                                      context.push(notification.route);
                                    }
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Notification update failed: ${e.toString()}'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
    );
  }
}
