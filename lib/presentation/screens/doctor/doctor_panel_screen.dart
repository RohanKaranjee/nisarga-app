import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/appointment.dart';
import '../../../core/models/cycle_data.dart';
import '../../../core/models/daily_log.dart';
import '../../../core/models/doctor.dart';
import '../../../core/models/prescription.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_colors.dart';

class DoctorPanelScreen extends StatelessWidget {
  const DoctorPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in.')));
    }

    if (auth.isProfileLoading || auth.isLoading) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    if (!auth.isDoctor) {
      return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          title: Text('Doctor Panel',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Doctor access is required for this panel.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    if (!auth.isActive) {
      return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          title: Text('Doctor Panel',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Your doctor account is disabled. Please contact admin.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    final service = FirestoreService();
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: Text('Doctor Panel',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<Doctor?>(
          stream: service.watchDoctorForUser(user.uid),
          builder: (context, snapshot) {
            final doctor = snapshot.data;
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _doctorPanelMessage(
                'Unable to load doctor profile: ${snapshot.error}',
              );
            }

            if (doctor == null) {
              return _DoctorProfileForm(userId: user.uid);
            }

            if (doctor.status != 'approved' || !doctor.active) {
              return _DoctorStatusView(doctor: doctor);
            }

            return DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  _DoctorHeader(doctor: doctor),
                  const TabBar(
                    isScrollable: true,
                    labelColor: AppColors.primary,
                    tabs: [
                      Tab(text: 'Overview'),
                      Tab(text: 'Appointments'),
                      Tab(text: 'Patients'),
                      Tab(text: 'Profile'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _OverviewTab(service: service, doctor: doctor),
                        _AppointmentsTab(service: service, doctor: doctor),
                        _PatientsTab(service: service, doctor: doctor),
                        _ProfileTab(doctor: doctor),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget _doctorPanelMessage(String message) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(message, textAlign: TextAlign.center),
    ),
  );
}

Future<void> _runDoctorAction(
  BuildContext context,
  Future<void> Function() action, {
  required String successMessage,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(successMessage)));
  } catch (e) {
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text('Action failed: ${e.toString()}'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

void _showDoctorProfileEditor(BuildContext context, Doctor doctor) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _DoctorProfileForm(existingDoctor: doctor),
  );
}

class _OverviewTab extends StatelessWidget {
  final FirestoreService service;
  final Doctor doctor;

  const _OverviewTab({required this.service, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Appointment>>(
      stream: service.watchAppointmentsForDoctorUser(doctor.userId),
      builder: (context, snapshot) {
        final appointments = snapshot.data ?? const <Appointment>[];
        final requested = appointments
            .where((appointment) => appointment.status == 'requested')
            .length;
        final accepted = appointments
            .where((appointment) => appointment.status == 'accepted')
            .length;
        final completed = appointments
            .where((appointment) => appointment.status == 'completed')
            .length;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (snapshot.hasError)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'Unable to load dashboard: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              )
            else if (snapshot.connectionState == ConnectionState.waiting)
              const LinearProgressIndicator(minHeight: 2),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetricCard(
                  label: 'Requests',
                  value: '$requested',
                  icon: Icons.inbox_outlined,
                ),
                _MetricCard(
                  label: 'Accepted',
                  value: '$accepted',
                  icon: Icons.event_available,
                ),
                _MetricCard(
                  label: 'Completed',
                  value: '$completed',
                  icon: Icons.check_circle_outline,
                ),
                _MetricCard(
                  label: 'Slots',
                  value: '${doctor.availability.length}',
                  icon: Icons.schedule,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today in Doctor Panel',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appointments.isEmpty
                          ? 'No appointment requests yet. When patients book, they appear here in realtime.'
                          : requested > 0
                              ? 'You have $requested new appointment request(s). Open Appointments to accept or reschedule.'
                              : 'No pending requests. Keep your availability updated so patients can book easily.',
                    ),
                    if (doctor.availability.isEmpty) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'No fixed availability is set. Patients can still request a free appointment, but you should add timings or reschedule requests.',
                        style: TextStyle(color: AppColors.warning),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showDoctorProfileEditor(
                            context,
                            doctor,
                          ),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Availability'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              DefaultTabController.of(context).animateTo(1),
                          icon: const Icon(Icons.event_note),
                          label: const Text('Appointments'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 42) / 2,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(label, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _DoctorEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
              child: Icon(icon, color: AppColors.primary, size: 34),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorStatusView extends StatelessWidget {
  final Doctor doctor;

  const _DoctorStatusView({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final title = switch (doctor.status) {
      'pending' => 'Waiting for admin approval',
      'rejected' => 'Doctor profile rejected',
      'disabled' => 'Doctor profile disabled',
      _ => 'Doctor profile not approved',
    };
    final message = switch (doctor.status) {
      'pending' =>
        'Your profile is saved. Admin must approve it before patients, appointments, chat, and prescriptions are available.',
      'rejected' =>
        'Admin rejected this profile. Update your details and contact admin for another review.',
      'disabled' =>
        'This doctor profile is disabled. Contact admin to reactivate it.',
      _ => 'Admin approval is required before using doctor panel features.',
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _DoctorHeader(doctor: doctor),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(message),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showEditor(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile & Availability'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _ProfileTab(doctor: doctor),
      ],
    );
  }

  void _showEditor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _DoctorProfileForm(existingDoctor: doctor),
    );
  }
}

class _DoctorHeader extends StatelessWidget {
  final Doctor doctor;
  const _DoctorHeader({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            doctor.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(doctor.specialization,
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text('Status: ${doctor.status}')),
              Chip(label: Text('${doctor.availability.length} slots')),
            ],
          ),
        ],
      ),
    );
  }
}

class _PatientsTab extends StatelessWidget {
  final FirestoreService service;
  final Doctor doctor;

  const _PatientsTab({required this.service, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Appointment>>(
      stream: service.watchAppointmentsForDoctorUser(doctor.userId),
      builder: (context, appointmentSnapshot) {
        if (appointmentSnapshot.connectionState == ConnectionState.waiting &&
            !appointmentSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (appointmentSnapshot.hasError) {
          return _doctorPanelMessage(
            'Unable to load patients: ${appointmentSnapshot.error}',
          );
        }
        final appointments = appointmentSnapshot.data ?? const <Appointment>[];
        return StreamBuilder<List<String>>(
          stream: service.watchDoctorPatientIds(doctor.userId),
          builder: (context, accessSnapshot) {
            final relationships = _relationships(
              appointments,
              accessSnapshot.data ?? const <String>[],
            );

            if (accessSnapshot.connectionState == ConnectionState.waiting &&
                !accessSnapshot.hasData &&
                relationships.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (relationships.isEmpty) {
              return _DoctorEmptyState(
                icon: Icons.groups_outlined,
                title: 'No patients yet',
                message:
                    'Patients will appear here after they send appointment requests or start consultations.',
                actionLabel: 'Check Appointments',
                onAction: () => DefaultTabController.of(context).animateTo(1),
              );
            }

            final showAccessError = accessSnapshot.hasError;
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: relationships.length + (showAccessError ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (showAccessError && index == 0) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        'Some chat relationships could not load: ${accessSnapshot.error}',
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  );
                }
                final relationship =
                    relationships[index - (showAccessError ? 1 : 0)];
                return _PatientCard(
                  service: service,
                  doctor: doctor,
                  relationship: relationship,
                );
              },
            );
          },
        );
      },
    );
  }

  List<_PatientRelationship> _relationships(
    List<Appointment> appointments,
    List<String> accessPatientIds,
  ) {
    final latestByPatient = <String, Appointment>{};
    for (final appointment in appointments) {
      final existing = latestByPatient[appointment.patientId];
      if (existing == null ||
          appointment.updatedAt.isAfter(existing.updatedAt)) {
        latestByPatient[appointment.patientId] = appointment;
      }
    }

    final patientIds = <String>{
      ...latestByPatient.keys,
      ...accessPatientIds.where((id) => id.trim().isNotEmpty),
    };
    final relationships = patientIds
        .map(
          (patientId) => _PatientRelationship(
            patientId: patientId,
            appointment: latestByPatient[patientId],
          ),
        )
        .toList();
    relationships.sort((a, b) {
      final aDate = a.appointment?.updatedAt;
      final bDate = b.appointment?.updatedAt;
      if (aDate == null && bDate == null) {
        return a.patientId.compareTo(b.patientId);
      }
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
    return relationships;
  }
}

class _PatientRelationship {
  final String patientId;
  final Appointment? appointment;

  const _PatientRelationship({
    required this.patientId,
    required this.appointment,
  });
}

class _PatientCard extends StatelessWidget {
  final FirestoreService service;
  final Doctor doctor;
  final _PatientRelationship relationship;

  const _PatientCard({
    required this.service,
    required this.doctor,
    required this.relationship,
  });

  @override
  Widget build(BuildContext context) {
    final appointment = relationship.appointment;
    return StreamBuilder<AppUser?>(
      stream: service.watchUser(relationship.patientId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text('Unable to load patient: ${snapshot.error}'),
            ),
          );
        }
        final patient = snapshot.data;
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
                        patient?.displayName.isNotEmpty == true
                            ? patient!.displayName
                            : appointment?.patientName ?? 'Patient',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                    Chip(label: Text(appointment?.status ?? 'Chat')),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Age: ${_ageLabel(patient?.dob)}'),
                Text(
                    'Contact: ${patient?.contact.isNotEmpty == true ? patient!.contact : 'Not set'}'),
                Text(
                  appointment == null
                      ? 'Relationship: Chat started'
                      : 'Last contact: ${_dateLabel(appointment.updatedAt)}',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: patient == null
                          ? null
                          : () => _showPatientDetails(
                                context,
                                patient,
                                doctor,
                                appointment,
                                service,
                              ),
                      child: const Text('View'),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.chat),
                      onPressed: () {
                        context.push(
                          '/doctor/chat/${doctor.id}?patientId=${relationship.patientId}',
                        );
                      },
                      label: const Text('Chat'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AppointmentsTab extends StatelessWidget {
  final FirestoreService service;
  final Doctor doctor;

  const _AppointmentsTab({required this.service, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Appointment>>(
      stream: service.watchAppointmentsForDoctorUser(doctor.userId),
      builder: (context, snapshot) {
        final appointments = snapshot.data ?? [];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _doctorPanelMessage(
            'Unable to load appointments: ${snapshot.error}',
          );
        }
        if (appointments.isEmpty) {
          return _DoctorEmptyState(
            icon: Icons.event_note_outlined,
            title: 'No appointments yet',
            message:
                'Free appointment requests from patients will appear here in realtime. Keep your availability updated.',
            actionLabel: 'Edit Availability',
            onAction: () => _showDoctorProfileEditor(context, doctor),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return _AppointmentCard(
              service: service,
              doctor: doctor,
              appointment: appointments[index],
            );
          },
        );
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final FirestoreService service;
  final Doctor doctor;
  final Appointment appointment;

  const _AppointmentCard({
    required this.service,
    required this.doctor,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      appointment.patientName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Chip(label: Text(appointment.status)),
                ],
              ),
              Text('${appointment.day} at ${appointment.time}'),
              if (appointment.notes.isNotEmpty) Text(appointment.notes),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: appointment.status == 'accepted'
                        ? null
                        : () => _updateStatus(context, 'accepted'),
                    child: const Text('Accept'),
                  ),
                  OutlinedButton(
                    onPressed: appointment.status == 'rescheduled'
                        ? null
                        : () => _showRescheduleSheet(context),
                    child: const Text('Reschedule'),
                  ),
                  OutlinedButton(
                    onPressed: appointment.status == 'completed'
                        ? null
                        : () => _updateStatus(context, 'completed'),
                    child: const Text('Complete'),
                  ),
                  TextButton(
                    onPressed: appointment.status == 'cancelled'
                        ? null
                        : () => _updateStatus(context, 'cancelled'),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, String status) {
    return _runDoctorAction(
      context,
      () => service.updateAppointment(appointment.copyWith(status: status)),
      successMessage: 'Appointment marked $status.',
    );
  }

  Future<void> _showRescheduleSheet(BuildContext context) async {
    final updatedAppointment = await showModalBottomSheet<Appointment>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _RescheduleAppointmentSheet(
        doctor: doctor,
        appointment: appointment,
      ),
    );
    if (updatedAppointment == null || !context.mounted) return;
    await _runDoctorAction(
      context,
      () => service.updateAppointment(updatedAppointment),
      successMessage:
          'Appointment rescheduled to ${updatedAppointment.day} at ${updatedAppointment.time}.',
    );
  }
}

class _RescheduleAppointmentSheet extends StatefulWidget {
  final Doctor doctor;
  final Appointment appointment;

  const _RescheduleAppointmentSheet({
    required this.doctor,
    required this.appointment,
  });

  @override
  State<_RescheduleAppointmentSheet> createState() =>
      _RescheduleAppointmentSheetState();
}

class _RescheduleAppointmentSheetState
    extends State<_RescheduleAppointmentSheet> {
  static const _allowedDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Saturday',
  ];

  late String _selectedDay;
  late final TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    final days = _days;
    _selectedDay = days.contains(widget.appointment.day)
        ? widget.appointment.day
        : days.first;
    final currentTime = widget.appointment.time == 'Doctor will confirm'
        ? ''
        : widget.appointment.time;
    _timeController = TextEditingController(text: currentTime);
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _slots {
    return widget.doctor.availability
        .where((slot) =>
            _allowedDays.contains(slot['day']) &&
            (slot['time'] ?? '').trim().isNotEmpty)
        .toList();
  }

  List<String> get _days {
    final days = <String>[];
    for (final slot in _slots) {
      final day = slot['day'] ?? '';
      if (day.isNotEmpty && !days.contains(day)) days.add(day);
    }
    if (days.isEmpty) days.addAll(_allowedDays);
    return days;
  }

  List<String> get _timesForSelectedDay {
    return _slots
        .where((slot) => slot['day'] == _selectedDay)
        .map((slot) => slot['time'] ?? '')
        .where((time) => time.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final times = _timesForSelectedDay;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reschedule Appointment',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text('Patient: ${widget.appointment.patientName}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedDay,
              decoration: const InputDecoration(
                labelText: 'Day',
                border: OutlineInputBorder(),
              ),
              items: _days
                  .map((day) => DropdownMenuItem(
                        value: day,
                        child: Text(day),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedDay = value;
                  final dayTimes = _timesForSelectedDay;
                  if (dayTimes.isNotEmpty) {
                    _timeController.text = dayTimes.first;
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            if (times.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final time in times)
                    ChoiceChip(
                      label: Text(time),
                      selected: _timeController.text == time,
                      onSelected: (_) =>
                          setState(() => _timeController.text = time),
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'Time',
                hintText: 'Example: 10:00 AM',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save New Timing'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final time = _timeController.text.trim();
    if (time.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter appointment time.')),
      );
      return;
    }
    Navigator.pop(
      context,
      widget.appointment.copyWith(
        status: 'rescheduled',
        day: _selectedDay,
        time: time,
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final Doctor doctor;

  const _ProfileTab({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton.icon(
          onPressed: () => _showDoctorProfileEditor(context, doctor),
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profile & Availability'),
        ),
        const SizedBox(height: 16),
        _info('Clinic', doctor.clinic),
        _info('Location', doctor.location),
        _info('About', doctor.about),
        _info('Qualifications', doctor.qualifications.join(', ')),
        _info(
            'Availability',
            doctor.availability
                .map((slot) => '${slot['day']} - ${slot['time']}')
                .join('\n')),
      ],
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(value.trim().isEmpty ? 'Not set' : value),
        ],
      ),
    );
  }
}

class _PatientDetailSheet extends StatelessWidget {
  final AppUser patient;
  final Doctor doctor;
  final Appointment? appointment;
  final FirestoreService service;

  const _PatientDetailSheet({
    required this.patient,
    required this.doctor,
    required this.appointment,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.55,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Patient Details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _section(context, 'Personal Information', [
              _line('Full Name', patient.displayName),
              _line('Age', _ageLabel(patient.dob)),
              _line('Gender',
                  patient.gender.isEmpty ? 'Not set' : patient.gender),
              _line('Contact Number',
                  patient.contact.isEmpty ? 'Not set' : patient.contact),
              _line('Email Address',
                  patient.email.isEmpty ? 'Not set' : patient.email),
            ]),
            StreamBuilder<List<CycleData>>(
              stream: service.watchPatientCycles(patient.id),
              builder: (context, cycleSnapshot) {
                return StreamBuilder<List<DailyLog>>(
                  stream: service.watchPatientDailyLogs(patient.id),
                  builder: (context, logSnapshot) {
                    if (cycleSnapshot.hasError || logSnapshot.hasError) {
                      return _section(context, 'Period Information', [
                        _line('Status', 'Unable to load period details.'),
                      ]);
                    }
                    final cycles = cycleSnapshot.data ?? [];
                    final logs = logSnapshot.data ?? [];
                    final latestCycle = cycles.isEmpty ? null : cycles.first;
                    return _section(context, 'Period Information', [
                      _line(
                        'Last Menstrual Period Date',
                        latestCycle == null
                            ? 'Not recorded'
                            : _dateLabel(latestCycle.startDate),
                      ),
                      _line('Average Cycle Length', _averageCycle(cycles)),
                      _line('Current Cycle Status',
                          _currentCycleStatus(latestCycle)),
                      _line('Symptoms Logged', _symptoms(logs)),
                    ]);
                  },
                );
              },
            ),
            _PrescriptionForm(
              service: service,
              doctor: doctor,
              patient: patient,
              appointment: appointment,
            ),
          ],
        );
      },
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _averageCycle(List<CycleData> cycles) {
    if (cycles.isEmpty) return 'Not recorded';
    final total =
        cycles.fold<int>(0, (sum, cycle) => sum + (cycle.cycleLength ?? 28));
    return '${(total / cycles.length).round()} days';
  }

  String _currentCycleStatus(CycleData? cycle) {
    if (cycle == null) return 'Not recorded';
    final day = DateTime.now().difference(cycle.startDate).inDays + 1;
    return day <= 0 ? 'Not started' : 'Day $day';
  }

  String _symptoms(List<DailyLog> logs) {
    if (logs.isEmpty) return 'No logs recorded';
    final log = logs.first;
    return [
      if (log.flow != 'none') 'Flow: ${log.flow}',
      if (log.cramps != 'none') 'Cramps: ${log.cramps}',
      'Mood: ${log.mood}',
      if (log.notes.trim().isNotEmpty) 'Notes added',
    ].join(', ');
  }
}

class _PrescriptionForm extends StatefulWidget {
  final FirestoreService service;
  final Doctor doctor;
  final AppUser patient;
  final Appointment? appointment;

  const _PrescriptionForm({
    required this.service,
    required this.doctor,
    required this.patient,
    required this.appointment,
  });

  @override
  State<_PrescriptionForm> createState() => _PrescriptionFormState();
}

class _PrescriptionFormState extends State<_PrescriptionForm> {
  final _medicinesController = TextEditingController();
  final _notesController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _medicinesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final medicines = _medicinesController.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter at least one medicine.')),
      );
      return;
    }

    setState(() => _saving = true);
    final now = DateTime.now();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.service.savePrescription(Prescription(
        id: '',
        patientId: widget.patient.id,
        doctorId: widget.doctor.id,
        doctorUserId: widget.doctor.userId,
        doctorName: widget.doctor.name,
        appointmentId: widget.appointment?.id ?? '',
        medicines: medicines,
        notes: _notesController.text.trim(),
        createdAt: now,
        updatedAt: now,
      ));
      if (mounted) {
        _medicinesController.clear();
        _notesController.clear();
        messenger.showSnackBar(
          const SnackBar(content: Text('Prescription saved.')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Prescription save failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Prescription',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              TextField(
                controller: _medicinesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Medicines, one per line',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Additional recommendations',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Saving...' : 'Save Prescription'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorProfileForm extends StatefulWidget {
  final String? userId;
  final Doctor? existingDoctor;

  const _DoctorProfileForm({this.userId, this.existingDoctor});

  @override
  State<_DoctorProfileForm> createState() => _DoctorProfileFormState();
}

class _DoctorProfileFormState extends State<_DoctorProfileForm> {
  static const _allowedDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Saturday',
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _specializationController;
  late final TextEditingController _clinicController;
  late final TextEditingController _locationController;
  late final TextEditingController _qualificationController;
  late final TextEditingController _aboutController;
  late final TextEditingController _timeController;
  late final List<Map<String, String>> _availabilitySlots;
  String _selectedAvailabilityDay = _allowedDays.first;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final doctor = widget.existingDoctor;
    _nameController = TextEditingController(text: doctor?.name ?? '');
    _specializationController =
        TextEditingController(text: doctor?.specialization ?? '');
    _clinicController = TextEditingController(text: doctor?.clinic ?? '');
    _locationController = TextEditingController(text: doctor?.location ?? '');
    _qualificationController =
        TextEditingController(text: doctor?.qualifications.join('\n') ?? '');
    _aboutController = TextEditingController(text: doctor?.about ?? '');
    _timeController = TextEditingController();
    _availabilitySlots =
        (doctor?.availability ?? const <Map<String, String>>[]).where((slot) {
      final day = slot['day'] ?? '';
      final time = slot['time'] ?? '';
      return _allowedDays.contains(day) && time.trim().isNotEmpty;
    }).map((slot) {
      return {
        'day': slot['day'] ?? _allowedDays.first,
        'time': (slot['time'] ?? '').trim(),
      };
    }).toList();
    if (_availabilitySlots.isNotEmpty) {
      _selectedAvailabilityDay =
          _availabilitySlots.first['day'] ?? _allowedDays.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _clinicController.dispose();
    _locationController.dispose();
    _qualificationController.dispose();
    _aboutController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final existing = widget.existingDoctor;
    final userId = existing?.userId ?? widget.userId ?? '';
    final messenger = ScaffoldMessenger.of(context);
    final missing = <String>[
      if (userId.isEmpty) 'User account',
      if (_nameController.text.trim().isEmpty) 'Name',
      if (_specializationController.text.trim().isEmpty) 'Specialization',
      if (_clinicController.text.trim().isEmpty) 'Clinic',
      if (_locationController.text.trim().isEmpty) 'Location',
    ];
    if (missing.isNotEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text('Fill required fields: ${missing.join(', ')}')),
      );
      return;
    }

    final availability = _availabilitySlots
        .map((slot) => {
              'day': slot['day'] ?? _allowedDays.first,
              'time': slot['time'] ?? '',
            })
        .where((slot) => (slot['time'] ?? '').trim().isNotEmpty)
        .toList();
    final qualifications = _qualificationController.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final doctor = Doctor(
      id: existing?.id ?? '',
      userId: userId,
      name: _nameController.text.trim(),
      specialization: _specializationController.text.trim(),
      experience: existing?.experience ?? 0,
      rating: existing?.rating ?? 0,
      reviews: existing?.reviews ?? 0,
      location: _locationController.text.trim(),
      photo: existing?.photo ?? '',
      photoUrl: existing?.photoUrl ?? '',
      about: _aboutController.text.trim(),
      clinic: _clinicController.text.trim(),
      fee: existing?.fee ?? '',
      status: existing?.status ?? 'pending',
      availability: availability,
      qualifications: qualifications,
      articles: existing?.articles ?? const [],
      active: existing?.active ?? true,
    );

    setState(() => _saving = true);
    try {
      await FirestoreService().saveDoctor(doctor);
      if (!mounted) return;
      setState(() => _saving = false);
      if (widget.existingDoctor != null) Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Doctor profile saved.')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Doctor profile save failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted && _saving) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existingDoctor == null
                  ? 'Create Doctor Profile'
                  : 'Edit Doctor Profile',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _field(_nameController, 'Name'),
            _field(_specializationController, 'Specialization'),
            _field(_clinicController, 'Clinic'),
            _field(_locationController, 'Location'),
            _field(_qualificationController, 'Qualifications, one per line',
                maxLines: 3),
            _field(_aboutController, 'About', maxLines: 3),
            _availabilityEditor(context),
            const Text(
              'After adding or removing slots, tap Save Profile & Slots to publish them. If no slots are added, patients can still request timing.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving...' : 'Save Profile & Slots'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _availabilityEditor(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Availability Slots',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Day',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedAvailabilityDay,
                      isExpanded: true,
                      items: _allowedDays
                          .map(
                            (day) => DropdownMenuItem(
                              value: day,
                              child: Text(day),
                            ),
                          )
                          .toList(),
                      onChanged: (day) {
                        if (day == null) return;
                        setState(() => _selectedAvailabilityDay = day);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    hintText: '10:00 AM',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addAvailabilitySlot,
              icon: const Icon(Icons.add),
              label: const Text('Add Slot'),
            ),
          ),
          const SizedBox(height: 8),
          if (_availabilitySlots.isEmpty)
            Text(
              'No fixed slots added.',
              style: TextStyle(color: Colors.grey.shade700),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var index = 0; index < _availabilitySlots.length; index++)
                  InputChip(
                    label: Text(
                      '${_availabilitySlots[index]['day']} - ${_availabilitySlots[index]['time']}',
                    ),
                    onDeleted: () {
                      setState(() => _availabilitySlots.removeAt(index));
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }

  void _addAvailabilitySlot() {
    final time = _timeController.text.trim();
    if (time.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter slot time, example 10:00 AM.')),
      );
      return;
    }
    final duplicate = _availabilitySlots.any((slot) {
      return slot['day'] == _selectedAvailabilityDay &&
          slot['time']?.toLowerCase() == time.toLowerCase();
    });
    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This slot is already added.')),
      );
      return;
    }
    setState(() {
      _availabilitySlots.add({
        'day': _selectedAvailabilityDay,
        'time': time,
      });
      _timeController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Slot added. Tap Save Profile & Slots to publish.'),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

void _showPatientDetails(
  BuildContext context,
  AppUser patient,
  Doctor doctor,
  Appointment? appointment,
  FirestoreService service,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _PatientDetailSheet(
      patient: patient,
      doctor: doctor,
      appointment: appointment,
      service: service,
    ),
  );
}

String _ageLabel(DateTime? dob) {
  if (dob == null) return 'Not set';
  final now = DateTime.now();
  var age = now.year - dob.year;
  if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
    age--;
  }
  return age < 0 ? 'Not set' : '$age';
}

String _dateLabel(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
