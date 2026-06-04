import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/appointment.dart';
import '../../../core/models/article.dart';
import '../../../core/models/cloudinary_settings.dart';
import '../../../core/models/doctor.dart';
import '../../../core/models/exercise_content.dart';
import '../../../core/models/feedback_entry.dart';
import '../../../core/models/home_remedy.dart';
import '../../../core/models/medicine.dart';
import '../../../core/models/product.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/firestore_service.dart';

import '../../../core/theme/app_colors.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final service = FirestoreService();

    if (auth.isProfileLoading || auth.isLoading) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          title: Text('Admin Panel',
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
                'Admin access is required for this panel.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          title: Text('Admin Panel',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Dashboard'),
              Tab(text: 'Users'),
              Tab(text: 'Doctors'),
              Tab(text: 'Appointments'),
              Tab(text: 'Content'),
              Tab(text: 'Feedback'),
            ],
          ),
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
          child: TabBarView(
            children: [
              _AdminDashboardTab(service: service),
              _UsersTab(service: service),
              _DoctorsTab(service: service),
              _AppointmentsTab(service: service),
              _ContentTab(service: service),
              _FeedbackTab(service: service),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _adminEmpty(String message) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(message, textAlign: TextAlign.center),
    ),
  );
}

Widget _adminError(String message) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(message, textAlign: TextAlign.center),
    ),
  );
}

Widget _adminInlineMessage(String message, {bool isError = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      message,
      style: TextStyle(color: isError ? AppColors.error : Colors.grey),
    ),
  );
}

Future<void> _runAdminAction(
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

class _AdminDashboardTab extends StatelessWidget {
  final FirestoreService service;
  const _AdminDashboardTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Realtime Dashboard',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Live admin overview for users, doctors, appointments, content, feedback, and uploads.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 920
                ? 4
                : constraints.maxWidth >= 680
                    ? 3
                    : 2;
            final width =
                (constraints.maxWidth - ((columns - 1) * 12)) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: width,
                  child: _DashboardListMetric<AppUser>(
                    title: 'Users',
                    icon: Icons.people_alt_outlined,
                    stream: service.watchUsers(),
                    subtitleBuilder: _userSubtitle,
                    tabIndex: 1,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _DashboardListMetric<Doctor>(
                    title: 'Doctors',
                    icon: Icons.medical_services_outlined,
                    stream: service.watchDoctors(approvedOnly: false),
                    subtitleBuilder: _doctorSubtitle,
                    tabIndex: 2,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _DashboardListMetric<Appointment>(
                    title: 'Appointments',
                    icon: Icons.event_available_outlined,
                    stream: service.watchAllAppointments(),
                    subtitleBuilder: _appointmentSubtitle,
                    tabIndex: 3,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _DashboardListMetric<FeedbackEntry>(
                    title: 'Feedback',
                    icon: Icons.feedback_outlined,
                    stream: service.watchFeedbackEntries(),
                    subtitleBuilder: _feedbackSubtitle,
                    tabIndex: 5,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        _DashboardContentCountsCard(service: service),
        const SizedBox(height: 16),
        _CloudinaryDashboardCard(service: service),
        const SizedBox(height: 16),
        const _AdminQuickActionsCard(),
      ],
    );
  }

  String _userSubtitle(List<AppUser> users) {
    final patients = users.where((user) => user.role == 'patient').length;
    final doctors = users.where((user) => user.role == 'doctor').length;
    final admins = users.where((user) => user.role == 'admin').length;
    return '$patients patients | $doctors doctors | $admins admins';
  }

  String _doctorSubtitle(List<Doctor> doctors) {
    final approved = doctors
        .where((doctor) => doctor.status == 'approved' && doctor.active)
        .length;
    final pending =
        doctors.where((doctor) => doctor.status == 'pending').length;
    final disabled = doctors
        .where((doctor) => doctor.status == 'disabled' || !doctor.active)
        .length;
    return '$approved approved | $pending pending | $disabled disabled';
  }

  String _appointmentSubtitle(List<Appointment> appointments) {
    final requested = appointments
        .where((appointment) => appointment.status == 'requested')
        .length;
    final accepted = appointments
        .where((appointment) => appointment.status == 'accepted')
        .length;
    final completed = appointments
        .where((appointment) => appointment.status == 'completed')
        .length;
    return '$requested requested | $accepted accepted | $completed done';
  }

  String _feedbackSubtitle(List<FeedbackEntry> entries) {
    final newEntries = entries.where((entry) => entry.status == 'new').length;
    final openEntries =
        entries.where((entry) => entry.status != 'resolved').length;
    return '$newEntries new | $openEntries open';
  }
}

class _DashboardListMetric<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final Stream<List<T>> stream;
  final String Function(List<T> items) subtitleBuilder;
  final int tabIndex;

  const _DashboardListMetric({
    required this.title,
    required this.icon,
    required this.stream,
    required this.subtitleBuilder,
    required this.tabIndex,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(
      stream: stream,
      builder: (context, snapshot) {
        final hasData = snapshot.hasData;
        final items = snapshot.data ?? <T>[];
        final hasError = snapshot.hasError;
        return _DashboardMetricCard(
          title: title,
          icon: icon,
          value: hasError
              ? '!'
              : hasData
                  ? items.length.toString()
                  : '--',
          subtitle: hasError
              ? 'Unable to load'
              : hasData
                  ? subtitleBuilder(items)
                  : 'Loading...',
          onTap: () => DefaultTabController.of(context).animateTo(tabIndex),
        );
      },
    );
  }
}

class _DashboardMetricCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String subtitle;
  final VoidCallback? onTap;

  const _DashboardMetricCard({
    required this.title,
    required this.icon,
    required this.value,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.primary),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardContentCountsCard extends StatelessWidget {
  final FirestoreService service;
  const _DashboardContentCountsCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.library_books_outlined,
                    color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Content Library',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      DefaultTabController.of(context).animateTo(4),
                  child: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _DashboardCountRow<Article>(
              label: 'Articles',
              stream: service.watchArticles(activeOnly: false),
              subtitleBuilder: (items) =>
                  '${items.where((item) => item.active).length} active',
            ),
            _DashboardCountRow<Medicine>(
              label: 'Medicines',
              stream: service.watchMedicines(activeOnly: false),
              subtitleBuilder: (items) =>
                  '${items.where((item) => item.active).length} active',
            ),
            _DashboardCountRow<Product>(
              label: 'Products',
              stream: service.watchProducts(activeOnly: false),
              subtitleBuilder: (items) =>
                  '${items.where((item) => item.active).length} active',
            ),
            _DashboardCountRow<HomeRemedy>(
              label: 'Home Remedies',
              stream: service.watchHomeRemedies(activeOnly: false),
              subtitleBuilder: (items) =>
                  '${items.where((item) => item.active).length} active',
            ),
            _DashboardCountRow<ExerciseContent>(
              label: 'Exercises',
              stream: service.watchAllExercises(),
              subtitleBuilder: (items) =>
                  '${items.where((item) => item.active).length} active',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCountRow<T> extends StatelessWidget {
  final String label;
  final Stream<List<T>> stream;
  final String Function(List<T> items) subtitleBuilder;

  const _DashboardCountRow({
    required this.label,
    required this.stream,
    required this.subtitleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(
      stream: stream,
      builder: (context, snapshot) {
        final items = snapshot.data ?? <T>[];
        final value = snapshot.hasError
            ? 'Error'
            : snapshot.hasData
                ? items.length.toString()
                : '--';
        final subtitle = snapshot.hasError
            ? 'Unable to load'
            : snapshot.hasData
                ? subtitleBuilder(items)
                : 'Loading...';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              Expanded(child: Text(label)),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
              const SizedBox(width: 12),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CloudinaryDashboardCard extends StatelessWidget {
  final FirestoreService service;
  const _CloudinaryDashboardCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CloudinarySettings?>(
      stream: service.watchCloudinarySettings(),
      builder: (context, snapshot) {
        final settings = snapshot.data;
        final configured = settings?.isConfigured ?? false;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(
                  configured
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_off_outlined,
                  color: configured ? AppColors.primary : AppColors.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Image Uploads',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        snapshot.hasError
                            ? 'Unable to read Cloudinary settings.'
                            : configured
                                ? 'Cloud ${settings!.cloudName} is ready for content images.'
                                : 'Cloudinary setup is required before article, product, or exercise images can be uploaded.',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      DefaultTabController.of(context).animateTo(4),
                  child: Text(configured ? 'Open' : 'Set Up'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdminQuickActionsCard extends StatelessWidget {
  const _AdminQuickActionsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _quickAction(context, 'Users', Icons.people_alt_outlined, 1),
                _quickAction(
                    context, 'Doctors', Icons.medical_services_outlined, 2),
                _quickAction(
                    context, 'Appointments', Icons.event_available_outlined, 3),
                _quickAction(
                    context, 'Content', Icons.library_books_outlined, 4),
                _quickAction(context, 'Feedback', Icons.feedback_outlined, 5),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(
    BuildContext context,
    String label,
    IconData icon,
    int tabIndex,
  ) {
    return OutlinedButton.icon(
      onPressed: () => DefaultTabController.of(context).animateTo(tabIndex),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _UsersTab extends StatelessWidget {
  final FirestoreService service;
  const _UsersTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppUser>>(
      stream: service.watchUsers(),
      builder: (context, snapshot) {
        final users = snapshot.data ?? [];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _adminError('Unable to load users: ${snapshot.error}');
        }
        if (users.isEmpty) {
          return _adminEmpty('No users found.');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              child: ListTile(
                title: Text(user.displayName),
                subtitle:
                    Text('${user.email}\nRole: ${user.role} | ${user.status}'),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (['patient', 'doctor', 'admin'].contains(value)) {
                      _runAdminAction(
                        context,
                        () => service.updateUserRole(user.id, value),
                        successMessage: 'User role updated.',
                      );
                    } else {
                      _runAdminAction(
                        context,
                        () => service.updateUserStatus(user.id, value),
                        successMessage: 'User status updated.',
                      );
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                        value: 'patient', child: Text('Make patient')),
                    PopupMenuItem(value: 'doctor', child: Text('Make doctor')),
                    PopupMenuItem(value: 'admin', child: Text('Make admin')),
                    PopupMenuDivider(),
                    PopupMenuItem(value: 'active', child: Text('Activate')),
                    PopupMenuItem(value: 'disabled', child: Text('Disable')),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DoctorsTab extends StatelessWidget {
  final FirestoreService service;
  const _DoctorsTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Doctor>>(
      stream: service.watchDoctors(approvedOnly: false),
      builder: (context, snapshot) {
        final doctors = snapshot.data ?? [];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _adminError('Unable to load doctors: ${snapshot.error}');
        }
        if (doctors.isEmpty) {
          return _adminEmpty('No doctors registered yet.');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: doctors.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            final isLinked = doctor.userId.trim().isNotEmpty;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${doctor.specialization} | ${doctor.status}'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          label: Text(isLinked
                              ? 'Doctor login linked'
                              : 'Doctor login missing'),
                        ),
                        if (!isLinked)
                          const Chip(
                            label: Text('Hidden from patients'),
                          ),
                      ],
                    ),
                    if (!isLinked) ...[
                      const SizedBox(height: 6),
                      const Text(
                        'This profile cannot receive bookings or chat until it is linked to a real doctor account.',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed:
                              doctor.status == 'approved' && doctor.active
                                  ? null
                                  : () => _runAdminAction(
                                        context,
                                        () => service.updateDoctorStatus(
                                          doctor.id,
                                          'approved',
                                          doctorUserId: doctor.userId,
                                        ),
                                        successMessage: 'Doctor approved.',
                                      ),
                          child: const Text('Approve'),
                        ),
                        OutlinedButton(
                          onPressed: doctor.status == 'rejected'
                              ? null
                              : () => _runAdminAction(
                                    context,
                                    () => service.updateDoctorStatus(
                                      doctor.id,
                                      'rejected',
                                      doctorUserId: doctor.userId,
                                    ),
                                    successMessage: 'Doctor rejected.',
                                  ),
                          child: const Text('Reject'),
                        ),
                        TextButton(
                          onPressed:
                              doctor.status == 'disabled' || !doctor.active
                                  ? null
                                  : () => _runAdminAction(
                                        context,
                                        () => service.updateDoctorStatus(
                                          doctor.id,
                                          'disabled',
                                          doctorUserId: doctor.userId,
                                        ),
                                        successMessage: 'Doctor disabled.',
                                      ),
                          child: const Text('Disable'),
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
    );
  }
}

class _AppointmentsTab extends StatelessWidget {
  final FirestoreService service;
  const _AppointmentsTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Appointment>>(
      stream: service.watchAllAppointments(),
      builder: (context, snapshot) {
        final appointments = snapshot.data ?? [];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _adminError('Unable to load appointments: ${snapshot.error}');
        }
        if (appointments.isEmpty) {
          return _adminEmpty('No appointments yet.');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return Card(
              child: ListTile(
                title: Text(
                    '${appointment.patientName} -> ${appointment.doctorName}'),
                subtitle: Text(
                    '${appointment.day} ${appointment.time}\nStatus: ${appointment.status}'),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (status) => _runAdminAction(
                    context,
                    () => service.updateAppointment(
                      appointment.copyWith(status: status),
                    ),
                    successMessage: 'Appointment updated.',
                  ),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'accepted', child: Text('Accepted')),
                    PopupMenuItem(
                        value: 'rescheduled', child: Text('Rescheduled')),
                    PopupMenuItem(value: 'completed', child: Text('Completed')),
                    PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ContentTab extends StatelessWidget {
  final FirestoreService service;
  const _ContentTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Content Library',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Create and manage the live articles, medicines, products, remedies, and exercise cards shown in the app.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 16),
        _CloudinarySettingsCard(service: service),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => _showArticleForm(context),
              icon: const Icon(Icons.article_outlined),
              label: const Text('Article'),
            ),
            OutlinedButton.icon(
              onPressed: () => _showMedicineForm(context),
              icon: const Icon(Icons.medication_outlined),
              label: const Text('Medicine'),
            ),
            OutlinedButton.icon(
              onPressed: () => _showProductForm(context),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Product'),
            ),
            OutlinedButton.icon(
              onPressed: () => _showRemedyForm(context),
              icon: const Icon(Icons.spa_outlined),
              label: const Text('Remedy'),
            ),
            OutlinedButton.icon(
              onPressed: () => _showExerciseForm(context),
              icon: const Icon(Icons.fitness_center_outlined),
              label: const Text('Exercise'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _ContentManagerList(
          service: service,
          onEditArticle: (article) =>
              _showArticleForm(context, article: article),
          onEditMedicine: (medicine) =>
              _showMedicineForm(context, medicine: medicine),
          onEditProduct: (product) =>
              _showProductForm(context, product: product),
          onEditRemedy: (remedy) => _showRemedyForm(context, remedy: remedy),
          onEditExercise: (exercise) =>
              _showExerciseForm(context, exercise: exercise),
        ),
      ],
    );
  }

  void _showArticleForm(BuildContext context, {Article? article}) {
    _showSimpleForm(
      context,
      article == null ? 'Add Article' : 'Edit Article',
      ['Title', 'Author', 'Read time', 'Category', 'Excerpt', 'Body'],
      (values, imageUrl) async {
        final id =
            article?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
        await service.saveArticle(Article(
          id: id,
          title: values[0],
          author: values[1],
          readTime: values[2],
          category: values[3],
          excerpt: values[4],
          date: article?.date ?? DateTime.now().toIso8601String(),
          imageUrl: imageUrl,
          content: values[5],
        ));
      },
      includeImageUpload: true,
      initialValues: article != null
          ? [
              article.title,
              article.author,
              article.readTime,
              article.category,
              article.excerpt,
              article.content
            ]
          : null,
      initialImageUrl: article?.imageUrl,
    );
  }

  void _showMedicineForm(BuildContext context, {Medicine? medicine}) {
    _showSimpleForm(
      context,
      medicine == null ? 'Add Medicine' : 'Edit Medicine',
      ['Name', 'Usage', 'Dosage', 'Side Effects', 'Notes'],
      (values, _) async {
        final id =
            medicine?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
        await service.saveMedicine(Medicine(
          id: id,
          name: values[0],
          usage: values[1],
          dosage: values[2],
          sideEffects: values[3],
          notes: values[4],
        ));
      },
      initialValues: medicine != null
          ? [
              medicine.name,
              medicine.usage,
              medicine.dosage,
              medicine.sideEffects,
              medicine.notes
            ]
          : null,
    );
  }

  void _showProductForm(BuildContext context, {Product? product}) {
    _showSimpleForm(
      context,
      product == null ? 'Add Product' : 'Edit Product',
      [
        'Name',
        'Category',
        'Rating',
        'Reviews',
        'Price',
        'Description',
        'Features, comma separated',
        'Buy URL (optional)'
      ],
      (values, imageUrl) async {
        final id =
            product?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
        final rating = double.tryParse(values[2]);
        final reviews = int.tryParse(values[3]);
        final price = double.tryParse(values[4]);
        if (rating == null || rating < 0 || rating > 5) {
          throw Exception('Rating must be a number from 0 to 5.');
        }
        if (reviews == null || reviews < 0) {
          throw Exception('Reviews must be a positive whole number.');
        }
        if (price == null || price < 0) {
          throw Exception('Price must be a positive number.');
        }
        await service.saveProduct(Product(
          id: id,
          name: values[0],
          category: values[1],
          rating: rating,
          reviews: reviews,
          price: price,
          description: values[5],
          features: values[6]
              .split(',')
              .map((feature) => feature.trim())
              .where((feature) => feature.isNotEmpty)
              .toList(),
          buyUrl: values[7],
          imageUrl: imageUrl,
        ));
      },
      includeImageUpload: true,
      initialValues: product != null
          ? [
              product.name,
              product.category,
              product.rating.toString(),
              product.reviews.toString(),
              product.price.toString(),
              product.description,
              product.features.join(', '),
              product.buyUrl
            ]
          : null,
      initialImageUrl: product?.imageUrl,
    );
  }

  void _showRemedyForm(BuildContext context, {HomeRemedy? remedy}) {
    _showSimpleForm(
      context,
      remedy == null ? 'Add Remedy' : 'Edit Remedy',
      [
        'Title',
        'Category',
        'Description',
        'Ingredients, comma separated',
        'Preparation',
        'Benefits',
        'Precautions'
      ],
      (values, _) async {
        final id =
            remedy?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
        await service.saveHomeRemedy(HomeRemedy(
          id: id,
          title: values[0],
          category: values[1],
          description: values[2],
          ingredients: values[3]
              .split(',')
              .map((ingredient) => ingredient.trim())
              .where((ingredient) => ingredient.isNotEmpty)
              .toList(),
          preparation: values[4],
          benefits: values[5],
          precautions: values[6],
        ));
      },
      initialValues: remedy != null
          ? [
              remedy.title,
              remedy.category,
              remedy.description,
              remedy.ingredients.join(', '),
              remedy.preparation,
              remedy.benefits,
              remedy.precautions
            ]
          : null,
    );
  }

  void _showExerciseForm(BuildContext context, {ExerciseContent? exercise}) {
    _showSimpleForm(
      context,
      exercise == null ? 'Add Exercise' : 'Edit Exercise',
      ['Condition: pcod or pcos', 'Title', 'Description'],
      (values, imageUrl) async {
        final id =
            exercise?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
        final condition = values[0].trim().toLowerCase();
        if (condition != 'pcod' && condition != 'pcos') {
          throw Exception('Condition must be pcod or pcos.');
        }
        await service.saveExercise(ExerciseContent(
          id: id,
          condition: condition,
          title: values[1],
          description: values[2],
          imageUrl: imageUrl,
          createdAt: exercise?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      },
      includeImageUpload: true,
      initialValues: exercise != null
          ? [exercise.condition, exercise.title, exercise.description]
          : null,
      initialImageUrl: exercise?.imageUrl,
    );
  }

  void _showSimpleForm(
    BuildContext context,
    String title,
    List<String> labels,
    Future<void> Function(List<String> values, String imageUrl) onSave, {
    bool includeImageUpload = false,
    List<String>? initialValues,
    String? initialImageUrl,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ContentFormSheet(
        title: title,
        labels: labels,
        includeImageUpload: includeImageUpload,
        initialValues: initialValues,
        initialImageUrl: initialImageUrl,
        onSave: onSave,
      ),
    );
  }
}

class _CloudinarySettingsCard extends StatelessWidget {
  final FirestoreService service;
  const _CloudinarySettingsCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CloudinarySettings?>(
      stream: service.watchCloudinarySettings(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child:
                  Text('Unable to load Cloudinary settings: ${snapshot.error}'),
            ),
          );
        }
        final settings = snapshot.data;
        final configured = settings?.isConfigured ?? false;
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
                        'Cloudinary Uploads',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Chip(
                      label: Text(configured ? 'Ready' : 'Setup needed'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  configured
                      ? 'Cloud: ${settings!.cloudName} | Folder: ${settings.folder}'
                      : 'Set cloud name and unsigned upload preset to upload images through Cloudinary.',
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _showCloudinarySettingsForm(
                    context,
                    service,
                    settings,
                  ),
                  icon: const Icon(Icons.settings),
                  label: Text(configured ? 'Edit Settings' : 'Set Up'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCloudinarySettingsForm(
    BuildContext context,
    FirestoreService service,
    CloudinarySettings? current,
  ) {
    final cloudNameController =
        TextEditingController(text: current?.cloudName ?? '');
    final uploadPresetController =
        TextEditingController(text: current?.uploadPreset ?? '');
    final folderController =
        TextEditingController(text: current?.folder ?? 'nisarga');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        var saving = false;
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                    const Text(
                      'Cloudinary Settings',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cloudNameController,
                      decoration: const InputDecoration(
                        labelText: 'Cloud name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: uploadPresetController,
                      decoration: const InputDecoration(
                        labelText: 'Unsigned upload preset',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: folderController,
                      decoration: const InputDecoration(
                        labelText: 'Folder',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: saving
                            ? null
                            : () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final cloudName =
                                    cloudNameController.text.trim();
                                final uploadPreset =
                                    uploadPresetController.text.trim();
                                final folder = folderController.text.trim();
                                if (cloudName.isEmpty ||
                                    uploadPreset.isEmpty ||
                                    folder.isEmpty) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Cloud name, preset, and folder are required.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                setSheetState(() => saving = true);
                                try {
                                  await service.saveCloudinarySettings(
                                    CloudinarySettings(
                                      cloudName: cloudName,
                                      uploadPreset: uploadPreset,
                                      folder: folder,
                                    ),
                                  );
                                  if (!context.mounted) return;
                                  setSheetState(() => saving = false);
                                  Navigator.pop(context);
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Cloudinary settings saved.'),
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Settings save failed: ${e.toString()}'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                } finally {
                                  if (context.mounted && saving) {
                                    setSheetState(() => saving = false);
                                  }
                                }
                              },
                        child: Text(saving ? 'Saving...' : 'Save Settings'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      cloudNameController.dispose();
      uploadPresetController.dispose();
      folderController.dispose();
    });
  }
}

class _ContentFormSheet extends StatefulWidget {
  final String title;
  final List<String> labels;
  final bool includeImageUpload;
  final List<String>? initialValues;
  final String? initialImageUrl;
  final Future<void> Function(List<String> values, String imageUrl) onSave;

  const _ContentFormSheet({
    required this.title,
    required this.labels,
    required this.includeImageUpload,
    this.initialValues,
    this.initialImageUrl,
    required this.onSave,
  });

  @override
  State<_ContentFormSheet> createState() => _ContentFormSheetState();
}

class _ContentFormSheetState extends State<_ContentFormSheet> {
  late final List<TextEditingController> _controllers;
  String _imageUrl = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.labels.length, (index) {
      final initialValue =
          widget.initialValues != null && index < widget.initialValues!.length
              ? widget.initialValues![index]
              : '';
      return TextEditingController(text: initialValue);
    }, growable: false);
    _imageUrl = widget.initialImageUrl ?? '';
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
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
            Text(widget.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            for (var i = 0; i < widget.labels.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: _controllers[i],
                  maxLines: widget.labels[i].contains('Body') ||
                          widget.labels[i].contains('Description') ||
                          widget.labels[i].contains('Preparation')
                      ? 3
                      : 1,
                  decoration: InputDecoration(
                    labelText: widget.labels[i],
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            if (widget.includeImageUpload) ...[
              _CloudinaryImageField(
                imageUrl: _imageUrl,
                onUploaded: (url) => setState(() => _imageUrl = url),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving...' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final values = _controllers.map((c) => c.text.trim()).toList();
    final missing = <String>[];
    for (var i = 0; i < widget.labels.length; i++) {
      final label = widget.labels[i];
      final optional = label.toLowerCase().contains('(optional)');
      if (!optional && values[i].isEmpty) {
        missing.add(label);
      }
    }
    if (missing.isNotEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Fill required fields: ${missing.take(3).join(', ')}'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.onSave(values, _imageUrl.trim());
      if (!mounted) return;
      setState(() => _saving = false);
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(content: Text('${widget.title} saved.')));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Save failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted && _saving) setState(() => _saving = false);
    }
  }
}

class _CloudinaryImageField extends StatefulWidget {
  final String imageUrl;
  final ValueChanged<String> onUploaded;

  const _CloudinaryImageField({
    required this.imageUrl,
    required this.onUploaded,
  });

  @override
  State<_CloudinaryImageField> createState() => _CloudinaryImageFieldState();
}

class _CloudinaryImageFieldState extends State<_CloudinaryImageField> {
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  bool _uploading = false;

  Future<void> _pickAndUpload() async {
    final settings = await FirestoreService().getCloudinarySettings();
    if (settings == null || !settings.isConfigured) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Set Cloudinary settings first.')),
        );
      }
      return;
    }

    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (image == null) return;

    setState(() => _uploading = true);
    try {
      final result = await _cloudinaryService.uploadImage(
        settings: settings,
        file: image,
      );
      widget.onUploaded(result.secureUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: _uploading ? null : _pickAndUpload,
          icon: _uploading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.cloud_upload_outlined),
          label: Text(_uploading ? 'Uploading...' : 'Upload Image'),
        ),
        if (widget.imageUrl.isNotEmpty) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 150,
                width: double.infinity,
                alignment: Alignment.center,
                color: Colors.grey.shade200,
                child: const Text('Image preview unavailable'),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FeedbackTab extends StatelessWidget {
  final FirestoreService service;
  const _FeedbackTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FeedbackEntry>>(
      stream: service.watchFeedbackEntries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _adminError('Unable to load feedback: ${snapshot.error}');
        }
        final entries = snapshot.data ?? [];
        if (entries.isEmpty) {
          return const Center(child: Text('No feedback submitted yet.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final entry = entries[index];
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
                              entry.name.isEmpty ? entry.email : entry.name),
                        ),
                        Chip(label: Text(entry.status)),
                      ],
                    ),
                    if (entry.email.isNotEmpty)
                      Text(entry.email,
                          style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(entry.message),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: entry.status == 'read'
                              ? null
                              : () => _runAdminAction(
                                    context,
                                    () => service.updateFeedbackStatus(
                                        entry.id, 'read'),
                                    successMessage: 'Feedback marked read.',
                                  ),
                          child: const Text('Mark Read'),
                        ),
                        OutlinedButton(
                          onPressed: entry.status == 'resolved'
                              ? null
                              : () => _runAdminAction(
                                    context,
                                    () => service.updateFeedbackStatus(
                                        entry.id, 'resolved'),
                                    successMessage: 'Feedback resolved.',
                                  ),
                          child: const Text('Resolve'),
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
    );
  }
}

class _ContentManagerList extends StatelessWidget {
  final FirestoreService service;
  final ValueChanged<Article> onEditArticle;
  final ValueChanged<Medicine> onEditMedicine;
  final ValueChanged<Product> onEditProduct;
  final ValueChanged<HomeRemedy> onEditRemedy;
  final ValueChanged<ExerciseContent> onEditExercise;

  const _ContentManagerList({
    required this.service,
    required this.onEditArticle,
    required this.onEditMedicine,
    required this.onEditProduct,
    required this.onEditRemedy,
    required this.onEditExercise,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentSection(
          context,
          title: 'Articles',
          stream: service.watchArticles(activeOnly: false),
          collection: 'articles',
          icon: Icons.article_outlined,
          getTitle: (item) => item.title,
          getSubtitle: (item) => 'By ${item.author}',
          getMeta: (item) => '${item.category} | ${item.readTime}',
          getImageUrl: (item) => item.imageUrl,
          isActive: (item) => item.active,
          onEdit: onEditArticle,
        ),
        _buildContentSection(
          context,
          title: 'Medicines',
          stream: service.watchMedicines(activeOnly: false),
          collection: 'medicines',
          icon: Icons.medication_outlined,
          getTitle: (item) => item.name,
          getSubtitle: (item) => 'Usage: ${item.usage}',
          getMeta: (item) => 'Dosage: ${item.dosage}',
          isActive: (item) => item.active,
          onEdit: onEditMedicine,
        ),
        _buildContentSection(
          context,
          title: 'Products',
          stream: service.watchProducts(activeOnly: false),
          collection: 'products',
          icon: Icons.shopping_bag_outlined,
          getTitle: (item) => item.name,
          getSubtitle: (item) =>
              '${item.category} | Rs. ${item.price.toStringAsFixed(2)}',
          getMeta: (item) =>
              'Rating ${item.rating.toStringAsFixed(1)} | ${item.reviews} reviews',
          getImageUrl: (item) => item.imageUrl,
          isActive: (item) => item.active,
          onEdit: onEditProduct,
        ),
        _buildContentSection(
          context,
          title: 'Home Remedies',
          stream: service.watchHomeRemedies(activeOnly: false),
          collection: 'home_remedies',
          icon: Icons.spa_outlined,
          getTitle: (item) => item.title,
          getSubtitle: (item) => item.category,
          getMeta: (item) => '${item.ingredients.length} ingredients',
          isActive: (item) => item.active,
          onEdit: onEditRemedy,
        ),
        _buildContentSection(
          context,
          title: 'Exercises',
          stream: service.watchAllExercises(),
          collection: 'exercises',
          icon: Icons.fitness_center_outlined,
          getTitle: (item) => item.title,
          getSubtitle: (item) => 'Condition: ${item.condition.toUpperCase()}',
          getMeta: (item) => item.description,
          getImageUrl: (item) => item.imageUrl,
          isActive: (item) => item.active,
          onEdit: onEditExercise,
        ),
      ],
    );
  }

  Widget _buildContentSection<T>(
    BuildContext context, {
    required String title,
    required Stream<List<T>> stream,
    required String collection,
    required IconData icon,
    required String Function(T) getTitle,
    required String Function(T) getSubtitle,
    String Function(T)? getMeta,
    String Function(T)? getImageUrl,
    bool Function(T)? isActive,
    void Function(T)? onEdit,
  }) {
    return StreamBuilder<List<T>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(minHeight: 2),
          );
        }
        if (snapshot.hasError) {
          return _adminInlineMessage(
            'Unable to load $title: ${snapshot.error}',
            isError: true,
          );
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return _adminInlineMessage('No $title added yet.');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '$title (${items.length})',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final dynamic dynamicItem = item;
                final imageUrl = getImageUrl?.call(item) ?? '';
                final meta = getMeta?.call(item) ?? '';
                final active = isActive?.call(item);
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ContentPreviewImage(
                          imageUrl: imageUrl,
                          fallbackIcon: icon,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getTitle(item),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                getSubtitle(item),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              if (meta.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  meta,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              if (active != null) ...[
                                const SizedBox(height: 8),
                                _ContentStatusPill(active: active),
                              ],
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'Options',
                          onSelected: (value) {
                            if (value == 'edit' && onEdit != null) {
                              onEdit(item);
                            }
                            if (value == 'delete') {
                              _confirmDelete(
                                  context, collection, dynamicItem.id);
                            }
                          },
                          itemBuilder: (_) => [
                            if (onEdit != null)
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 18),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline,
                                      size: 18, color: AppColors.error),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String collection, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this content?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _runAdminAction(
                context,
                () => service.deleteGlobalContent(collection, id),
                successMessage: 'Content deleted.',
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ContentPreviewImage extends StatelessWidget {
  final String imageUrl;
  final IconData fallbackIcon;

  const _ContentPreviewImage({
    required this.imageUrl,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 76,
        height: 76,
        child: imageUrl.trim().isEmpty
            ? _fallback()
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(),
              ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(fallbackIcon, color: Colors.grey.shade600),
    );
  }
}

class _ContentStatusPill extends StatelessWidget {
  final bool active;

  const _ContentStatusPill({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? Colors.green.shade50 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? Colors.green.shade200 : Colors.grey.shade400,
        ),
      ),
      child: Text(
        active ? 'Active' : 'Hidden',
        style: TextStyle(
          color: active ? Colors.green.shade800 : Colors.grey.shade700,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
