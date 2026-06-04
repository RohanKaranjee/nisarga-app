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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w700)),
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

    final service = FirestoreService();
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: Text('Doctor Panel',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white, fontWeight: FontWeight.w700)),
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

            if (doctor == null) {
              return _DoctorProfileForm(userId: user.uid);
            }

            return DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  _DoctorHeader(doctor: doctor),
                  const TabBar(
                    labelColor: AppColors.primary,
                    tabs: [
                      Tab(text: 'Patients'),
                      Tab(text: 'Appointments'),
                      Tab(text: 'Profile'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _PatientsTab(service: service, doctor: doctor),
                        _AppointmentsTab(service: service, doctor: doctor),
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
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final latestByPatient = <String, Appointment>{};
        for (final appointment in snapshot.data ?? const <Appointment>[]) {
          final existing = latestByPatient[appointment.patientId];
          if (existing == null ||
              appointment.updatedAt.isAfter(existing.updatedAt)) {
            latestByPatient[appointment.patientId] = appointment;
          }
        }
        final patients = latestByPatient.values.toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        if (patients.isEmpty) {
          return const Center(child: Text('No patients yet.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: patients.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return _PatientCard(
              service: service,
              doctor: doctor,
              appointment: patients[index],
            );
          },
        );
      },
    );
  }
}

class _PatientCard extends StatelessWidget {
  final FirestoreService service;
  final Doctor doctor;
  final Appointment appointment;

  const _PatientCard({
    required this.service,
    required this.doctor,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: service.watchUser(appointment.patientId),
      builder: (context, snapshot) {
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
                            : appointment.patientName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Chip(label: Text(appointment.status)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Age: ${_ageLabel(patient?.dob)}'),
                Text(
                    'Contact: ${patient?.contact.isNotEmpty == true ? patient!.contact : 'Not set'}'),
                Text('Last contact: ${_dateLabel(appointment.updatedAt)}'),
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
                          '/doctor/chat/${appointment.doctorId}?patientId=${appointment.patientId}',
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
        if (appointments.isEmpty) {
          return const Center(child: Text('No appointments yet.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return _AppointmentCard(
              service: service,
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
  final Appointment appointment;

  const _AppointmentCard({required this.service, required this.appointment});

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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
                      : () => service.updateAppointment(
                          appointment.copyWith(status: 'accepted')),
                  child: const Text('Accept'),
                ),
                OutlinedButton(
                  onPressed: () => service.updateAppointment(
                      appointment.copyWith(status: 'rescheduled')),
                  child: const Text('Reschedule'),
                ),
                OutlinedButton(
                  onPressed: () => service.updateAppointment(
                      appointment.copyWith(status: 'completed')),
                  child: const Text('Complete'),
                ),
                TextButton(
                  onPressed: () => service.updateAppointment(
                      appointment.copyWith(status: 'cancelled')),
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
          onPressed: () => _showProfileEditor(context, doctor),
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

  void _showProfileEditor(BuildContext context, Doctor doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _DoctorProfileForm(existingDoctor: doctor),
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
  final Appointment appointment;
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
            _section(context,'Personal Information', [
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
                    final cycles = cycleSnapshot.data ?? [];
                    final logs = logSnapshot.data ?? [];
                    final latestCycle = cycles.isEmpty ? null : cycles.first;
                    return _section(context,'Period Information', [
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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
  final Appointment appointment;

  const _PrescriptionForm({
    required this.service,
    required this.doctor,
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
    await widget.service.savePrescription(Prescription(
      id: '',
      patientId: widget.appointment.patientId,
      doctorId: widget.doctor.id,
      doctorUserId: widget.doctor.userId,
      doctorName: widget.doctor.name,
      appointmentId: widget.appointment.id,
      medicines: medicines,
      notes: _notesController.text.trim(),
      createdAt: now,
      updatedAt: now,
    ));
    if (mounted) {
      setState(() => _saving = false);
      _medicinesController.clear();
      _notesController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prescription saved.')),
      );
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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
  late final TextEditingController _availabilityController;

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
    _availabilityController = TextEditingController(
      text: doctor?.availability
              .map((slot) => '${slot['day']}|${slot['time']}')
              .join('\n') ??
          '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _clinicController.dispose();
    _locationController.dispose();
    _qualificationController.dispose();
    _aboutController.dispose();
    _availabilityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final existing = widget.existingDoctor;
    final userId = existing?.userId ?? widget.userId ?? '';
    if (userId.isEmpty || _nameController.text.trim().isEmpty) return;

    final availability = _availabilityController.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.contains('|'))
        .map((line) {
      final parts = line.split('|');
      return {'day': parts.first.trim(), 'time': parts.last.trim()};
    }).where((slot) {
      return _allowedDays.contains(slot['day']) &&
          (slot['time'] ?? '').isNotEmpty;
    }).toList();

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
      fee: '',
      status: existing?.status ?? 'pending',
      availability: availability,
      qualifications: qualifications,
      articles: existing?.articles ?? const [],
    );

    await FirestoreService().saveDoctor(doctor);
    if (mounted) {
      if (widget.existingDoctor != null) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor profile saved.')),
      );
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
            _field(
              _availabilityController,
              'Availability: Monday|10:00 AM',
              maxLines: 5,
            ),
            const Text(
              'Allowed days: Monday, Tuesday, Wednesday, Thursday, Saturday',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save Profile'),
              ),
            ),
          ],
        ),
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
  Appointment appointment,
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



