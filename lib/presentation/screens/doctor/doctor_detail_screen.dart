import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/models/app_notification.dart';
import '../../../core/models/appointment.dart';
import '../../../core/models/doctor.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_colors.dart';

class DoctorDetailScreen extends StatefulWidget {
  final String doctorId;
  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  static const _allowedDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Saturday',
  ];

  final FirestoreService _service = FirestoreService();
  String? _selectedDay;
  String? _selectedTime;
  final TextEditingController _notesController = TextEditingController();
  bool _isBooking = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Doctor?>(
      stream: _service.watchDoctor(widget.doctorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final doctor = snapshot.data;
        if (doctor == null || doctor.status != 'approved' || !doctor.active) {
          return Scaffold(
            appBar: AppBar(title: const Text('Doctor')),
            body: const Center(child: Text('Doctor not available.')),
          );
        }

        _ensureSelection(doctor);
        return _buildDetail(context, doctor);
      },
    );
  }

  void _ensureSelection(Doctor doctor) {
    final slots = _availableSlots(doctor);
    if (slots.isEmpty) return;
    final selectedStillExists = slots.any(
        (slot) => slot['day'] == _selectedDay && slot['time'] == _selectedTime);
    if (selectedStillExists) return;
    _selectedDay = slots.first['day'];
    _selectedTime = slots.first['time'];
  }

  Widget _buildDetail(BuildContext context, Doctor doctor) {
    final imageProvider = doctor.photoUrl.isNotEmpty
        ? NetworkImage(doctor.photoUrl)
        : doctor.photo.isNotEmpty
            ? AssetImage(doctor.photo) as ImageProvider
            : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.primaryGradient),
                child: Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white24,
                    backgroundImage: imageProvider,
                    child: imageProvider == null
                        ? const Icon(Icons.person,
                            size: 80, color: Colors.white)
                        : null,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doctor.name,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(doctor.specialization,
                                style: const TextStyle(
                                    color: AppColors.primary, fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat(
                          'Experience', '${doctor.experience} yrs', Icons.work),
                      _buildStat('Rating', doctor.rating.toStringAsFixed(1),
                          Icons.star),
                      _buildStat(
                          'Reviews', '${doctor.reviews}', Icons.rate_review),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.chat_bubble_rounded,
                        label: 'Chat',
                        color: Colors.green,
                        onTap: () => context.push('/doctor/chat/${doctor.id}'),
                      ),
                      _buildActionButton(
                        icon: Icons.phone,
                        label: 'Call',
                        color: AppColors.primary,
                        onTap: () => _sendDoctorRequest(
                          doctor,
                          title: 'Voice call request',
                          bodyAction: 'requested a voice call',
                          type: 'call_request',
                        ),
                      ),
                      _buildActionButton(
                        icon: Icons.videocam,
                        label: 'Video',
                        color: Colors.deepPurple,
                        onTap: () => _sendDoctorRequest(
                          doctor,
                          title: 'Video call request',
                          bodyAction: 'requested a video call',
                          type: 'video_request',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('About Doctor',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    doctor.about.isEmpty
                        ? 'No profile details added yet.'
                        : doctor.about,
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  if (doctor.clinic.isNotEmpty) ...[
                    const Text('Clinic',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(doctor.clinic),
                    const SizedBox(height: 20),
                  ],
                  const Text('Availability',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_availableSlots(doctor).isEmpty)
                    const Text('No slots available right now.')
                  else ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _days(doctor)
                          .map((day) => _buildDateButton(day))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableSlots(doctor)
                          .where((slot) => slot['day'] == _selectedDay)
                          .map((slot) => _buildTimeButton(slot['time'] ?? ''))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Symptoms or notes for doctor',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed:
                _availableSlots(doctor).isEmpty ? null : () => _book(doctor),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Book Appointment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  List<String> _days(Doctor doctor) {
    final days = <String>[];
    for (final slot in _availableSlots(doctor)) {
      final day = slot['day'] ?? '';
      if (day.isNotEmpty && !days.contains(day)) days.add(day);
    }
    return days;
  }

  List<Map<String, String>> _availableSlots(Doctor doctor) {
    return doctor.availability
        .where((slot) => _allowedDays.contains(slot['day']))
        .toList();
  }

  Widget _buildDateButton(String day) {
    final selected = _selectedDay == day;
    final theme = Theme.of(context);
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _selectedDay = day;
          _selectedTime = null;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppColors.primary : theme.colorScheme.surface,
        foregroundColor: selected ? Colors.white : theme.textTheme.bodyMedium?.color,
      ),
      child: Text(day),
    );
  }

  Widget _buildTimeButton(String time) {
    final selected = _selectedTime == time;
    return OutlinedButton(
      onPressed: () => setState(() => _selectedTime = time),
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppColors.primary : AppColors.surface,
        foregroundColor: selected ? Colors.white : Colors.black,
      ),
      child: Text(time),
    );
  }

  Future<void> _book(Doctor doctor) async {
    if (_isBooking) return;
    
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;

    final selectedDay = _selectedDay;
    var selectedTime = _selectedTime;
    if (selectedDay == null) return;
    selectedTime ??= _availableSlots(doctor)
        .where((slot) => slot['day'] == selectedDay)
        .map((slot) => slot['time'] ?? '')
        .firstWhere((time) => time.isNotEmpty, orElse: () => '');
    if (selectedTime.isEmpty) return;

    setState(() => _isBooking = true);

    try {
      final profile = auth.userProfile ?? {};
      final patientName =
          '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}'.trim();
      final now = DateTime.now();
      final appointment = Appointment(
        id: '',
        patientId: user.uid,
        patientName:
            patientName.isEmpty ? (user.email ?? 'Patient') : patientName,
        doctorId: doctor.id,
        doctorUserId: doctor.userId,
        doctorName: doctor.name,
        day: selectedDay,
        time: selectedTime,
        status: 'requested',
        notes: _notesController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await _service.createAppointment(appointment);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment request sent.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book appointment: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  Future<void> _sendDoctorRequest(
    Doctor doctor, {
    required String title,
    required String bodyAction,
    required String type,
  }) async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null || doctor.userId.isEmpty) return;

    final profile = auth.userProfile ?? {};
    final patientName =
        '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}'.trim();
    final displayName =
        patientName.isEmpty ? (user.email ?? 'Patient') : patientName;
    await _service.createNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: doctor.userId,
      title: title,
      body: '$displayName $bodyAction.',
      type: type,
      route: '/doctor/chat/${doctor.id}?patientId=${user.uid}',
      createdAt: DateTime.now(),
    ));

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$title sent.')));
    }
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
