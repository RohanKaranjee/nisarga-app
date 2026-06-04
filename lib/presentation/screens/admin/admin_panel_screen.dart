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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w700)),
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
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          title: Text('Admin Panel',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
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
                      service.updateUserRole(user.id, value);
                    } else {
                      service.updateUserStatus(user.id, value);
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
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: doctors.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final doctor = doctors[index];
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
                      children: [
                        ElevatedButton(
                          onPressed: () => service.updateDoctorStatus(
                            doctor.id,
                            'approved',
                            doctorUserId: doctor.userId,
                          ),
                          child: const Text('Approve'),
                        ),
                        OutlinedButton(
                          onPressed: () => service.updateDoctorStatus(
                            doctor.id,
                            'rejected',
                            doctorUserId: doctor.userId,
                          ),
                          child: const Text('Reject'),
                        ),
                        TextButton(
                          onPressed: () => service.updateDoctorStatus(
                            doctor.id,
                            'disabled',
                            doctorUserId: doctor.userId,
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
                  onSelected: (status) => service
                      .updateAppointment(appointment.copyWith(status: status)),
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
        _CloudinarySettingsCard(service: service),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: () => _showArticleForm(context),
              child: const Text('Add Article'),
            ),
            OutlinedButton(
              onPressed: () => _showMedicineForm(context),
              child: const Text('Add Medicine'),
            ),
            OutlinedButton(
              onPressed: () => _showProductForm(context),
              child: const Text('Add Product'),
            ),
            OutlinedButton(
              onPressed: () => _showRemedyForm(context),
              child: const Text('Add Remedy'),
            ),
            OutlinedButton(
              onPressed: () => _showExerciseForm(context),
              child: const Text('Add Exercise'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Content Management'),
        const SizedBox(height: 16),
        _ContentManagerList(service: service),
      ],
    );
  }

  void _showArticleForm(BuildContext context, {Article? article}) {
    _showSimpleForm(
      context,
      article == null ? 'Add Article' : 'Edit Article',
      ['Title', 'Author', 'Read time', 'Category', 'Excerpt', 'Body'],
      (values, imageUrl) {
        final id = article?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
        service.saveArticle(Article(
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
      initialValues: article != null ? [
        article.title, article.author, article.readTime, article.category, article.excerpt, article.content
      ] : null,
      initialImageUrl: article?.imageUrl,
    );
  }

  void _showMedicineForm(BuildContext context, {Medicine? medicine}) {
    _showSimpleForm(
      context,
      medicine == null ? 'Add Medicine' : 'Edit Medicine',
      ['Name', 'Usage', 'Dosage', 'Side Effects', 'Notes'],
      (values, _) {
        final id = medicine?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
        service.saveMedicine(Medicine(
          id: id,
          name: values[0],
          usage: values[1],
          dosage: values[2],
          sideEffects: values[3],
          notes: values[4],
        ));
      },
      initialValues: medicine != null ? [
        medicine.name, medicine.usage, medicine.dosage, medicine.sideEffects, medicine.notes
      ] : null,
    );
  }

  void _showProductForm(BuildContext context, {Product? product}) {
    _showSimpleForm(
      context,
      product == null ? 'Add Product' : 'Edit Product',
      ['Name', 'Category', 'Rating', 'Reviews', 'Price', 'Description', 'Features, comma separated', 'Buy URL (optional)'],
      (values, imageUrl) {
        final id = product?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
        service.saveProduct(Product(
          id: id,
          name: values[0],
          category: values[1],
          rating: double.tryParse(values[2]) ?? 0,
          reviews: int.tryParse(values[3]) ?? 0,
          price: double.tryParse(values[4]) ?? 0,
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
      initialValues: product != null ? [
        product.name, product.category, product.rating.toString(), product.reviews.toString(), product.price.toString(), product.description, product.features.join(', '), product.buyUrl ?? ''
      ] : null,
      initialImageUrl: product?.imageUrl,
    );
  }

  void _showRemedyForm(BuildContext context, {HomeRemedy? remedy}) {
    _showSimpleForm(
      context,
      remedy == null ? 'Add Remedy' : 'Edit Remedy',
      ['Title', 'Category', 'Description', 'Ingredients, comma separated', 'Preparation', 'Benefits', 'Precautions'],
      (values, _) {
        final id = remedy?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
        service.saveHomeRemedy(HomeRemedy(
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
      initialValues: remedy != null ? [
        remedy.title, remedy.category, remedy.description, remedy.ingredients.join(', '), remedy.preparation, remedy.benefits, remedy.precautions
      ] : null,
    );
  }

  void _showExerciseForm(BuildContext context, {ExerciseContent? exercise}) {
    _showSimpleForm(
      context,
      exercise == null ? 'Add Exercise' : 'Edit Exercise',
      ['Condition: pcod or pcos', 'Title', 'Description'],
      (values, imageUrl) {
        final id = exercise?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
        final condition = values[0].trim().toLowerCase();
        service.saveExercise(ExerciseContent(
          id: id,
          condition: condition == 'pcos' ? 'pcos' : 'pcod',
          title: values[1],
          description: values[2],
          imageUrl: imageUrl,
          createdAt: exercise?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      },
      includeImageUpload: true,
      initialValues: exercise != null ? [
        exercise.condition, exercise.title, exercise.description
      ] : null,
      initialImageUrl: exercise?.imageUrl,
    );
  }

  void _showSimpleForm(
    BuildContext context,
    String title,
    List<String> labels,
    void Function(List<String> values, String imageUrl) onSave, {
    bool includeImageUpload = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ContentFormSheet(
        title: title,
        labels: labels,
        includeImageUpload: includeImageUpload,
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                    onPressed: () async {
                      await service.saveCloudinarySettings(
                        CloudinarySettings(
                          cloudName: cloudNameController.text.trim(),
                          uploadPreset: uploadPresetController.text.trim(),
                          folder: folderController.text.trim(),
                        ),
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Save Settings'),
                  ),
                ),
              ],
            ),
          ),
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
  final void Function(List<String> values, String imageUrl) onSave;

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

  @override
  void initState() {
    super.initState();
    _controllers = widget.labels
        .map((label) => TextEditingController())
        .toList(growable: false);
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
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
                onPressed: () {
                  widget.onSave(
                    _controllers.map((c) => c.text.trim()).toList(),
                    _imageUrl,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
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
                          onPressed: () =>
                              service.updateFeedbackStatus(entry.id, 'read'),
                          child: const Text('Mark Read'),
                        ),
                        OutlinedButton(
                          onPressed: () => service.updateFeedbackStatus(
                              entry.id, 'resolved'),
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
  const _ContentManagerList({required this.service});

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
          getTitle: (item) => (item).title,
          getSubtitle: (item) => 'By ${(item).author}',
          onEdit: (item) => showArticleForm(context, service, article: item as Article),
        ),
        _buildContentSection(
          context,
          title: 'Medicines',
          stream: service.watchMedicines(activeOnly: false),
          collection: 'medicines',
          getTitle: (item) => (item as Medicine).name,
          getSubtitle: (item) => 'Usage: ${(item as Medicine).usage}',
          onEdit: (item) => showMedicineForm(context, service, medicine: item as Medicine),
        ),
        _buildContentSection(
          context,
          title: 'Products',
          stream: service.watchProducts(activeOnly: false),
          collection: 'products',
          getTitle: (item) => (item).name,
          getSubtitle: (item) => 'Price: ₹${(item).price}',
          onEdit: (item) => showProductForm(context, service, product: item as Product),
        ),
        _buildContentSection(
          context,
          title: 'Home Remedies',
          stream: service.watchHomeRemedies(activeOnly: false),
          collection: 'home_remedies',
          getTitle: (item) => (item as HomeRemedy).title,
          getSubtitle: (item) => (item as HomeRemedy).category,
          onEdit: (item) => showRemedyForm(context, service, remedy: item as HomeRemedy),
        ),
        _buildContentSection(
          context,
          title: 'Exercises',
          stream: service.watchAllExercises(),
          collection: 'exercises',
          getTitle: (item) => (item).title,
          getSubtitle: (item) => 'Condition: ${(item).condition.toUpperCase()}',
          onEdit: (item) => showExerciseForm(context, service, exercise: item as ExerciseContent),
        ),
      ],
    );
  }

  Widget _buildContentSection<T>(
    BuildContext context, {
    required String title,
    required Stream<List<T>> stream,
    required String collection,
    required String Function(T) getTitle,
    required String Function(T) getSubtitle,
    void Function(T)? onEdit,
  }) {
    return StreamBuilder<List<T>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox();
        }
        final items = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                title,
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
                final dynamic dynamicItem = item; // Access dynamic 'id' safely
                return Card(
                  child: ListTile(
                    title: Text(getTitle(item)),
                    subtitle: Text(getSubtitle(item)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEdit != null)
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => onEdit(item),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(
                              context, collection, dynamicItem.id),
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
            onPressed: () {
              service.deleteGlobalContent(collection, id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
ors.red)),
          ),
        ],
      ),
    );
  }
}
