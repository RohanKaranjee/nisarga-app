import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/models/appointment.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_colors.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in.')));
    }

    final service = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      body: StreamBuilder<List<Appointment>>(
        stream: service.watchAppointmentsForPatient(user.uid),
        builder: (context, snapshot) {
          final appointments = snapshot.data ?? [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load appointments: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (appointments.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No appointments yet. Book a doctor consultation to see it here.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              appointment.doctorName,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Chip(label: Text(appointment.status)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${appointment.day} at ${appointment.time}'),
                      if (appointment.notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(appointment.notes),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              if (appointment.doctorUserId.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Chat is not available for this appointment because the doctor account is not linked.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              context
                                  .push('/doctor/chat/${appointment.doctorId}');
                            },
                            icon: const Icon(Icons.chat),
                            label: const Text('Chat'),
                          ),
                          OutlinedButton(
                            onPressed: () =>
                                context.push('/doctor/${appointment.doctorId}'),
                            child: const Text('View Doctor'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push('/doctors'),
        icon: const Icon(Icons.add),
        label: const Text('Book'),
      ),
    );
  }
}
